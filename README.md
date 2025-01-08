# Script-library

This repository is used to store scripts written by me.

## Script Guide
### SetFolderIcons
Batch change Windows folder icons.
#### SetFolderIcons.ps1
```powershell
param(
    [string]$icoDir,
    [string]$rootDir = (Get-Location).Path,
    [int]$depth = 0
)
```

Place the icons you want to replace in the icoDir folder, and run the script in administrator mode.

#### RemoveFolderIcons.ps1
```powershell
param(
    [string]$rootDir = (Get-Location).Path,
    [int]$depth = 0
)
```

