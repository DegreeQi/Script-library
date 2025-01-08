param(
    [string]$rootDir = (Get-Location).Path,
    [int]$depth = 0
)

function Remove-FolderIcons {
    param(
        [string]$currentDir,
        [int]$currentDepth,
        [int]$maxDepth
    )

    $folders = Get-ChildItem -Path $currentDir -Directory

    foreach ($folder in $folders) {
        $folderPath = $folder.FullName
        $desktopIniPath = Join-Path -Path $folderPath -ChildPath "Desktop.ini"

        if (Test-Path -LiteralPath $desktopIniPath -PathType Leaf) {
            $desktopIniContent = Get-Content -Path $desktopIniPath -ErrorAction SilentlyContinue
            $filteredContent = $desktopIniContent | Where-Object { -not $_.StartsWith('IconResource=') } | Out-String -NoNewline
            Remove-Item -Path $desktopIniPath -Force

            if ($filteredContent -eq '[.ShellClassInfo]') {
                $folder.Attributes = $folder.Attributes -band -not [System.IO.FileAttributes]::System
                Write-Host "$desktopIniPath has been removed."
            }
            else {
                $filteredContent | Out-File -FilePath $desktopIniPath -Encoding UTF8 -Force -NoNewline
                (Get-Item $desktopIniPath).Attributes = [System.IO.FileAttributes]::Hidden -bor [System.IO.FileAttributes]::System
                Write-Host "$desktopIniPath has been updated for icon removing."
            }
        }
    }

    if ($currentDepth -lt $maxDepth) {
        foreach ($subFolder in $folders) {
            Remove-FolderIcons -currentDir $subFolder.FullName -currentDepth ($currentDepth + 1) -maxDepth $maxDepth
        }
    }
}

Remove-FolderIcons -currentDir $rootDir -currentDepth 0 -maxDepth $depth

Write-Host "Done."