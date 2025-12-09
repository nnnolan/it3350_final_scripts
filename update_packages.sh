#!/bin/bash

# updates a specific list of predefined packages
# this is meant to be called by cron_jobs.sh


# 1. define the array(list) of packages to update
# since this is a var, this is easy to update later
PACKAGES=("curl" "vim" "git" "wget")

# 2. update the repository lists first
# we do this once before the loop so we don't waste time downloading the package lists multiple times.
echo "Updating package repositories..."
sudo apt-get update -y

# 4. update the target packages via iteration
# parse through the package list and update each one
# the 'install' command updates the package if it is already installed
# the '-y' flag automatically answers "yes" to prompts, which is needed for no intearction
# (i.e. operating in background)
for package in "${PACKAGES[@]}"
do
    echo "--------------------------------------"
    echo "Checking and updating: $package"
    
    # attempt to install/update the current package
    sudo apt-get install -y "$package"
    
    echo "$package processing complete."
done

# 5. log completion
echo "Package update process finished successfully at $(date)."
