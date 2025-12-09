#!/bin/bash

# Select a source directory or
# Use Zenity to select a source directory

SOURCE_DIR=$(zenity --file-selection --directory --title="Select the folder you want to back up.")

#check for canceled dialog

if [ -z "$SOURCE_DIR" ]; then
    zenity --error --text="No source folder selected. Stopping."
    exit 1
fi

# Select the destination folder
# Use Zenity to select the destination folder

DEST_DIR=$(zenity --file-selection --directory --title="Select where to save the backup.")

# If using Zeinty check if the user canceled the dialog

if [ $? -ne 0 ] || [ -z "$DEST_DIR" ]; then
    zenity --error --text="No destination folder selected. Stopping."
    exit 1
fi

# Create a tarball of the source folder and backup

tar -czf "$DEST_DIR/backup.tar.gz" "$SOURCE_DIR"
TAR_STATUS=$?

# If using Zenity display the success or failure of the backup

if [ $TAR_STATUS -eq 0 ]; then
    zenity --info --text="Backup done.\nFile: $DEST_DIR/backup.tar.gz"
else
    zenity --error --text="Something went wrong while creating the backup."
fi