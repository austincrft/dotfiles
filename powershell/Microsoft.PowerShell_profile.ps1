# Stop on errors
$ErrorActionPreference = "Stop"

# Bash-like completion
Set-PSReadlineKeyHandler -Key Tab -Function Complete

# No beeping
Set-PSReadlineOption -BellStyle None

# Aliases
Set-Alias -Name g -Value git
Set-Alias -Name unzip -Value Expand-Archive

# Import Work-Specific Commands/Aliases
$workAliasScript = "$env:USERPROFILE/work/PowerShell/profile.ps1"
if (Test-Path $workAliasScript) {
    . $workAliasScript
}

# Console customization
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\mytheme.omp.json" | Invoke-Expression