#!/bin/bash

echo "************************************************************"
echo "*                 Firefox Import Data Transfer             *"
echo "*                      Version: 0.1                        *"
echo "*               Copyright 2024 - suuhm                     *"
echo "************************************************************"
echo

# Get a list of available Firefox profiles
firefoxProfiles=("$HOME/.mozilla/firefox/"Profiles"/*/")
profileNumber=1

# Display available profiles
echo "Available Firefox Profiles:"
echo "--------------------------"
for profile in "${firefoxProfiles[@]}"; do
    echo "$profileNumber. $(basename "$profile")"
    ((profileNumber++))
done

# Prompt user to select old profile
read -p $'\nEnter the number of the old profile to transfer data from: ' oldProfileIndex
oldProfile="${firefoxProfiles[$oldProfileIndex - 1]}"

# Prompt user to select or create a new profile
read -p $'\nDo you want to (E)nter the number of an existing profile or (C)reate a new profile? (E/C): ' newProfileChoice
if [ "$newProfileChoice" == "E" ]; then
    # Prompt user to select existing new profile
    read -p "Enter the number of the existing new profile to transfer data to: " newProfileIndex
    newProfile="${firefoxProfiles[$newProfileIndex - 1]}"
elif [ "$newProfileChoice" == "C" ]; then
    # Prompt user to enter the name for the new profile
    read -p "Enter the name for the new profile: " newProfileName
    newProfile="$HOME/.mozilla/firefox/Profiles/$newProfileName"

    # Create the new profile directory
    mkdir -p "$newProfile"

    # Create a placeholder file for the new profile to make it visible in the profile manager
    touch "$newProfile/user.js"

    # Create profiles.ini for the new profile
    profilesIniPath="$HOME/.mozilla/firefox/profiles.ini"
    newProfileID=$(uuidgen)
    profileIniContent="[Profile$(($profileNumber-1))]
Name=$newProfileName
IsRelative=1
Path=Profiles/$newProfileName
Default=1
"
    echo "$profileIniContent" >> "$profilesIniPath"

    # Increment the profile number for verbosity
    ((profileNumber++))
else
    echo "Invalid choice. Exiting."
    exit 1
fi

# Function to copy files if they exist
copyFileIfExists() {
    source="$1"
    destination="$2"
    if [ -e "$source" ]; then
        echo "Copying $source to $destination"
        cp -f "$source" "$destination"
    fi
}

# Copy bookmarks, downloads, and history
copyFileIfExists "$oldProfile/places.sqlite" "$newProfile/places.sqlite"
copyFileIfExists "$oldProfile/favicons.sqlite" "$newProfile/favicons.sqlite"
copyFileIfExists "$oldProfile/logins.json" "$newProfile/logins.json"

# Copy site-specific settings
copyFileIfExists "$oldProfile/permissions.sqlite" "$newProfile/permissions.sqlite"

# Copy search engines
copyFileIfExists "$oldProfile/search.json.mozlz4" "$newProfile/search.json.mozlz4"

# Copy personal dictionary
copyFileIfExists "$oldProfile/persdict.dat" "$newProfile/persdict.dat"

# Copy search and form data
copyFileIfExists "$oldProfile/formhistory.sqlite" "$newProfile/formhistory.sqlite"

# Copy cookies
copyFileIfExists "$oldProfile/cookies.sqlite" "$newProfile/cookies.sqlite"

# Copy security certificate settings
copyFileIfExists "$oldProfile/cert9.db" "$newProfile/cert9.db"

# Copy file formats and download actions
copyFileIfExists "$oldProfile/handlers.json" "$newProfile/handlers.json"

echo -e "\nDone, bye"
