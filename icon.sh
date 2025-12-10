#!/bin/bash

# icon.sh - Creates desktop launcher for selected script

# Use Zenity to prompt user to select the script (.sh file) to run and store in a variable
selected_script=$(zenity --file-selection \
    --title="Select Script File" \
    --filename="$HOME/" \
    --file-filter="*.sh" \
    --file-filter="Script files")

# If no script is selected, exit
if [ -z "$selected_script" ]; then
    zenity --info --text="No script selected. Exiting." --width=250
    exit 0
fi

# Make sure the selected file exists and is executable
if [ ! -f "$selected_script" ]; then
    zenity --error --text="Selected file does not exist!\nPlease select a valid script file." --width=300
    exit 1
fi

# Make script executable
chmod +x "$selected_script"

# Use Zenity to prompt user to select an image to use as the icon and store in a variable
icon_image=$(zenity --file-selection \
    --title="Select Icon Image" \
    --filename="/usr/share/icons/" \
    --file-filter="*.png *.jpg *.jpeg *.svg *.ico" \
    --file-filter="Image files" \
    --file-filter="All files | *")

# If no image is selected, use a default icon
if [ -z "$icon_image" ]; then
    icon_image="utilities-terminal"
    zenity --info --text="No icon selected. Using default terminal icon." --width=300
fi

# Use Zenity to prompt user to enter a name for the desktop entry and store in a variable
desktop_name=$(zenity --entry \
    --title="Desktop Launcher Name" \
    --text="Enter a name for the desktop launcher:" \
    --entry-text="My Script Launcher")

# If no name is entered, use a default name
if [ -z "$desktop_name" ]; then
    desktop_name="Script Launcher"
    zenity --info --text="No name entered. Using default name: Script Launcher" --width=300
fi

# Get script name without extension for filename
script_basename=$(basename "$selected_script" .sh)
desktop_filename="${script_basename}_launcher.desktop"

# Define the path for the .desktop file (in the current directory) and store in a variable
desktop_file="$PWD/$desktop_filename"

# Create the .desktop file using echo commands
# You can echo the content with the variables that you created
# using all the variables that were stored for path
# and zenity. The first line will be redirected >
# the following lines will be added with >>
echo "[Desktop Entry]" > "$desktop_file"
echo "Version=1.0" >> "$desktop_file"
echo "Type=Application" >> "$desktop_file"
echo "Name=$desktop_name" >> "$desktop_file"
echo "Comment=Launcher for $(basename "$selected_script")" >> "$desktop_file"
echo "Exec=\"$selected_script\"" >> "$desktop_file"
echo "Icon=$icon_image" >> "$desktop_file"
echo "Terminal=true" >> "$desktop_file"
echo "Categories=Utility;Application;" >> "$desktop_file"
echo "StartupNotify=true" >> "$desktop_file"

# Copy the .desktop file to the user's desktop
desktop_destination="$HOME/Desktop/$desktop_filename"
cp "$desktop_file" "$desktop_destination"

# Make the .desktop file executable
chmod +x "$desktop_destination"

# Use Zenity to notify user that the .desktop file has been created and moved
zenity --info \
    --title="Desktop Launcher Created" \
    --text="Desktop launcher created successfully!\n\n\
Name: $desktop_name\n\
Script: $(basename "$selected_script")\n\
Icon: $(basename "$icon_image")\n\
Location: ~/Desktop/$desktop_filename\n\n\
Double-click the icon on your desktop to run the script." \
    --width=400
