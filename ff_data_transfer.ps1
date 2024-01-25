#
# Firefox Import Data transfer Helper v0.1
# (C) 2024 by suuhm
#
# Based on: Transferring data to a new profile - Firefox
# URL/Link: https://kb.mozillazine.org/Transferring_data_to_a_new_profile_-_Firefox
#
#

Write-Host @"
************************************************************
*                 Firefox Import Data Transfer             *
*                      Version: 0.1                        *
*               Copyright 2024 - suuhm                     *
************************************************************

"@

# Get a list of available Firefox profiles
$firefoxProfiles = Get-ChildItem "$env:APPDATA\Mozilla\Firefox\Profiles" -Directory

# Display available profiles
Write-Host "Available Firefox Profiles:`n--------------------------`n"
$profileNumber = 1
foreach ($profile in $firefoxProfiles) {
    Write-Host "$profileNumber. $($profile.Name)"
    $profileNumber++
}

# Prompt user to select old profile
#Write-Host("")
$oldProfileIndex = Read-Host "`nEnter the number of the old profile to transfer data from"
$oldProfile = $firefoxProfiles[$oldProfileIndex - 1].FullName

# Prompt user to select or create a new profile
$newProfileChoice = Read-Host "`nDo you want to (E)nter the number of an existing profile or (C)reate a new profile? (E/C)"
if ($newProfileChoice -eq "E") {
    # Prompt user to select existing new profile
    $newProfileIndex = Read-Host "Enter the number of the existing new profile to transfer data to"
    $newProfile = $firefoxProfiles[$newProfileIndex - 1].FullName
} elseif ($newProfileChoice -eq "C") {
    # Prompt user to enter the name for the new profile
    $newProfileName = Read-Host "Enter the name for the new profile"
    $newProfile = "$env:APPDATA\Mozilla\Firefox\Profiles\$newProfileName"
    
    # Create the new profile directory
    New-Item -ItemType Directory -Force -Path $newProfile | Out-Null
    
    # Create a placeholder file for the new profile to make it visible in the profile manager
    $placeholderFilePath = Join-Path $newProfile "user.js"
    New-Item -ItemType File -Force -Path $placeholderFilePath | Out-Null
    
    # Create profiles.ini for the new profile
    $profilesIniPath = Join-Path "$env:APPDATA\Mozilla\Firefox" "profiles.ini"
    $newProfileID = [System.Guid]::NewGuid().ToString("B")
    $profileIniContent = @"

[Profile$($profileNumber-1)]
Name=$newProfileName
IsRelative=1
Path=Profiles/$newProfileName
Default=1

"@
    Add-Content -Path $profilesIniPath -Value $profileIniContent
    
    # Increment the profile number for verbosity
    $profileNumber++
} else {
    Write-Host "Invalid choice. Exiting."
    Exit
}

# Function to copy files if they exist
function Copy-FileIfExists {
    param(
        [string]$source,
        [string]$destination
    )

    if (Test-Path $source) {
        Write-Host "Copying $($source) to $($destination)"
        Copy-Item $source -Destination $destination -Force
    }
}

# Copy bookmarks, downloads, and history
Copy-FileIfExists "$oldProfile\places.sqlite" "$newProfile\places.sqlite"
Copy-FileIfExists "$oldProfile\favicons.sqlite" "$newProfile\favicons.sqlite"
Copy-FileIfExists "$oldProfile\logins.json" "$newProfile\logins.json"

# Copy site-specific settings
Copy-FileIfExists "$oldProfile\permissions.sqlite" "$newProfile\permissions.sqlite"

# Copy search engines
Copy-FileIfExists "$oldProfile\search.json.mozlz4" "$newProfile\search.json.mozlz4"

# Copy personal dictionary
Copy-FileIfExists "$oldProfile\persdict.dat" "$newProfile\persdict.dat"

# Copy search and form data
Copy-FileIfExists "$oldProfile\formhistory.sqlite" "$newProfile\formhistory.sqlite"

# Copy cookies
Copy-FileIfExists "$oldProfile\cookies.sqlite" "$newProfile\cookies.sqlite"

# Copy security certificate settings
Copy-FileIfExists "$oldProfile\cert9.db" "$newProfile\cert9.db"

# Copy file formats and download actions
Copy-FileIfExists "$oldProfile\handlers.json" "$newProfile\handlers.json"

Write-Host "`nDone, bye"
