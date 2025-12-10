#!/bin/bash

# Select date using Zenity calender picker and store into a variable
# check to make sure date was selected
selected_date=$(zenity --calendar --title="Select Date for Cron Job" --date-format="%Y-%m-%d")

if [ -z "$selected_date" ]; then
    zenity --error --text="No date selected. Exiting."
    exit 1
fi


# Select time (12-hour format) with zenity using --entry with HH:MM format and store into a variable
# check to make sure a valid format was entered
time_input=$(zenity --entry --title="Select Time" --text="Enter time in HH:MM format (12-hour):" --entry-text="09:00")

if [ -z "$time_input" ]; then
    zenity --error --text="No time entered. Exiting."
    exit 1
fi

# Validate time format
if ! [[ "$time_input" =~ ^[0-1]?[0-9]:[0-5][0-9]$ ]]; then
    zenity --error --text="Invalid time format. Please use HH:MM format."
    exit 1
fi




# Select AM or PM with zenity --list and check to make sure it was selected
am_pm=$(zenity --list --title="Select AM or PM" --column="Period" "AM" "PM")

if [ -z "$am_pm" ]; then
    zenity --error --text="No AM/PM selected. Exiting."
    exit 1
fi



# Convert 12-hour time to 24-hour time
# store the hour in a variable for hour
# store the minutes in a variable for minutes
hour=$(echo "$time_input" | cut -d':' -f1)
minute=$(echo "$time_input" | cut -d':' -f2)

# Convert to 24-hour format
if [ "$am_pm" == "PM" ] && [ "$hour" -ne 12 ]; then
    hour=$((hour + 12))
elif [ "$am_pm" == "AM" ] && [ "$hour" -eq 12 ]; then
    hour=0
fi





# Select script file using zenity and store it in a variable
# check to make sure it was selected 
# Get the directory where this script is located
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
script_file=$(zenity --file-selection --title="Select Script to Schedule" --filename="$script_dir/" --file-filter="*.sh")

if [ -z "$script_file" ]; then
    zenity --error --text="No script selected. Exiting."
    exit 1
fi



# Ask if the scheduled script needs DISPLAY and XAUTHORITY variables
# if you choose to use zenity to choose your files on the create_backup.sh you
# will need to use the display. Since the cronjob will run in the background
# you can use the DISPLAY and the XAURHORITY to display your gui
# use display="DISPLAY=:0" and xauthority="XAUTHORITY=/home/$USER/.Xauthority"
# to use your display
# Automatically detect if the script uses zenity by checking its contents
if grep -q "zenity" "$script_file"; then
    needs_display="yes"
else
    needs_display="no"
fi

display_vars=""
if [ "$needs_display" == "yes" ]; then
    display_vars="DISPLAY=:0 XAUTHORITY=/home/$USER/.Xauthority "
fi

# Select repetition schedule using Zenity --list and --column will be 
# Once a day, Once a week, Once a month, Once a year
repetition=$(zenity --list --title="Select Repetition Schedule" --column="Frequency" "Once a day" "Once a week" "Once a month" "Once a year")

if [ -z "$repetition" ]; then
    zenity --error --text="No repetition schedule selected. Exiting."
    exit 1
fi




# Calculate day and month for the initial run and store
# in a variable into day and variable for month
day=$(date -d "$selected_date" +%d)
month=$(date -d "$selected_date" +%m)
weekday=$(date -d "$selected_date" +%u)




# Use a case to define cron job schedule based on user's selection
# of the repetition selected from your Zenity list
# each selection would store in a variable the syntax for
# Every day at the selected time "$minute $hour * * *"
# Every week on the selected day of the week "$minute $hour * * $weekday"
# Every month on the selected day"$minute $hour $day * *"
# Every year on the selected date "$minute $hour $day $month *"
case "$repetition" in
    "Once a day")
        cron_schedule="$minute $hour * * *"
        ;;
    "Once a week")
        cron_schedule="$minute $hour * * $weekday"
        ;;
    "Once a month")
        cron_schedule="$minute $hour $day * *"
        ;;
    "Once a year")
        cron_schedule="$minute $hour $day $month *"
        ;;
    *)
        zenity --error --text="Invalid repetition schedule. Exiting."
        exit 1
        ;;
esac





# Add the cron job using the variable that was created in the case and the display as well as the script
cron_job="$cron_schedule $display_vars$script_file"

# Add to crontab
(crontab -l 2>/dev/null; echo "$cron_job") | crontab -


# Show confirmation
zenity --info --title="Cron Job Added" --text="Cron job successfully scheduled!\n\nScript: $script_file\nSchedule: $repetition\nTime: $time_input $am_pm\nDate: $selected_date\n\nCron syntax: $cron_job"


