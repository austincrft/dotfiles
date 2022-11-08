# Stop on errors
$ErrorActionPreference = "Stop"

# Bash-like completion
Set-PSReadlineKeyHandler -Key Tab -Function Complete

# No beeping
Set-PSReadlineOption -BellStyle None

# Aliases
Set-Alias -Name g -Value git
Set-Alias -Name unzip -Value Expand-Archive
Set-Alias -Name ss -Value Select-String
Set-Alias -Name grep -Value Select-String

# Import Work-Specific Commands/Aliases
$workAliasScript = "$env:USERPROFILE/work/PowerShell/profile.ps1"
if (Test-Path $workAliasScript) {
    . $workAliasScript
}

# Console customization
oh-my-posh init pwsh --config "C:\src\dotfiles\powershell\mytheme.omp.json" | Invoke-Expression