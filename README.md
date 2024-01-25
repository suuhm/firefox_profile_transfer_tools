# firefox_profile_transfer_tools
Automatic transferring your important data from old profile to a new profile for windows, linux and mac

If you're updating or just transfer some data between your Firefox Profiles, this script can help you to transfer the important data between on a smart way.

## You can use for Windows the powershell/batch script:

Just run `run_ff_dt.bat`

### or directly in powershell

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass
.\ff_data_transfer.ps1
```

![grafik](https://github.com/suuhm/firefox_profile_transfer_tools/assets/11504990/b3da4332-2da5-41d0-9e86-abdd709dc119)

 
## on linux, Mac and other UNIX os the `ff_data_transfer.sh` like: 

```bash
chmod +x ff_data_transfer.sh && ./ff_data_transfer.sh
```

or alternatively by some issues with bash you can try pwsh on linux
see more here for install: https://gist.github.com/suuhm/d7621d92b1ff3c06a20d9fea5f831e71

```bash
#!/bin/bash

# Bash script to execute the PowerShell script

# Setup path tp ps1 file
powershell_script_path="./ff_data_transfer.ps1"

# check fpr pwsh
if command -v pwsh &> /dev/null; then
    pwsh -ExecutionPolicy Bypass -File "$powershell_script_path"
else
    echo "PowerShell (pwsh) not installed, exit."
    exit 1
fi
```

### For any questions simply write an issue!
