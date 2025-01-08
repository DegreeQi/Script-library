param(
    [string]$icoDir,
    [string]$rootDir = (Get-Location).Path,
    [int]$depth = 0
)

function Set-FolderIcons {
    param(
        [string]$currentDir,
        [int]$currentDepth,
        [int]$maxDepth
    )

    $currentDirName = Split-Path -Path $currentDir -Leaf
    $folders = Get-ChildItem -Path $currentDir -Directory

    foreach ($folder in $folders) {
        $folderName = $folder.Name
        $folderPath = $folder.FullName
        $desktopIniPath = Join-Path -Path $folderPath -ChildPath "Desktop.ini"
        $desktopIniContent = Get-Content -Path $desktopIniPath -ErrorAction SilentlyContinue
        $icoPath = Join-Path -Path $icoDir -ChildPath "$folderName.ico"

        $hasIcon = $desktopIniContent | Where-Object { $_.StartsWith('IconResource=') }
        $hasSameName = $folderName -eq $currentDirName

        if ($hasIcon -or $hasSameName) {
            continue
        }

        if (Test-Path -LiteralPath $icoPath -PathType Leaf) {
            $folder.Attributes = $folder.Attributes -bor [System.IO.FileAttributes]::System
            $hasShellClassInfo = $True

            if (Test-Path -LiteralPath $desktopIniPath -PathType Leaf) {
                $desktopIniContent = Get-Content -Path $desktopIniPath
                $shellClassInfoIndex = $desktopIniContent.IndexOf('[.ShellClassInfo]')
                if ($shellClassInfoIndex -ge 0) {
                    $newContent = $desktopIniContent[0..$shellClassInfoIndex] + 
                    @("IconResource=\.icos\$folderName.ico") + 
                    $desktopIniContent[($shellClassInfoIndex + 1)..($desktopIniContent.Count - 1)]
                    $newContent | Out-File -FilePath $desktopIniPath -Encoding UTF8 -Force -NoNewline

                    $hasShellClassInfo = $False
                }
            }
            if ($hasShellClassInfo) {
                $desktopIniContent = @"
[.ShellClassInfo]
IconResource=\.icos\$folderName.ico
"@
                $desktopIniContent | Out-File -FilePath $desktopIniPath -Encoding UTF8 -Append -NoNewline
                (Get-Item $desktopIniPath).Attributes = [System.IO.FileAttributes]::Hidden -bor [System.IO.FileAttributes]::System
            }
        }
    }

    if ($currentDepth -lt $maxDepth) {
        $subFolders = Get-ChildItem -Path $currentDir -Directory
        foreach ($subFolder in $subFolders) {
            Set-FolderIcons -currentDir $subFolder.FullName -currentDepth ($currentDepth + 1) -maxDepth $maxDepth
        }
    }

}

if ([string]::IsNullOrWhiteSpace($icoDir)) {
    Write-Host "Usage: .\SetFolderIcons.ps1 -icoDir 'Path to Icon Directory' -depth <Depth> -rootDir 'Root Directory'"
    exit 1
}

Set-FolderIcons -currentDir $rootDir -currentDepth 0 -maxDepth $depth

Write-Host "Done."