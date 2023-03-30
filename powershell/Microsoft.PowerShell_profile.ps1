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
Set-Alias -Name fromjson -Value Get-ObjectFromJson
Set-Alias -Name toguid -Value ConvertTo-Guid
Set-Alias -Name csharp -Value csharprepl

# Import the work-specific pwsh profile
$WorkProfile = "$env:USERPROFILE/work/PowerShell/profile.ps1"
if (Test-Path $WorkProfile) {
    . $WorkProfile
}

# Console customization
oh-my-posh init pwsh --config "C:\src\dotfiles\powershell\mytheme.omp.json" | Invoke-Expression

# Modules
$Modules = @(
    [PSCustomObject]@{
        Name = "BurntToast";
        Installed = $false;
        Version = [Version]0.0.0.0;
    }
)

foreach ($module in $Modules) {
    $mod = Get-Module -ListAvailable -Name $module.Name
    if (-not $mod) {
        $module.Installed = $false
        Write-Warning "Module $($module.Name) is not installed"
    }
    else {
        $module.Installed = $true
        $module.Version = $mod.Version
        Import-Module $module.Name

        $latestModule = Find-Module $module.Name -ErrorAction SilentlyContinue
        if (-not $latestModule) {
            Write-Warning "Module $($module.Name): Failed to check latest version"
            continue
        }
        if ($latestModule.Version -gt $module.Version) {
            Write-Warning "Module $($module.Name): Upgrade available. Current=$($module.Version), Available=$($latestModule.Version)"
        }
    }
}
Remove-Variable "module"

# Functions
function Build-Sln($sln) {
    $pattern = if ($sln) { $sln } else { "*.sln" }
    Get-ChildItem $pattern | ForEach-Object { dotnet build $_.Name }
}

function Clean-Sln($sln) {
    $pattern = if ($sln) { $sln } else { "*.sln" }
    Get-ChildItem $pattern | ForEach-Object { dotnet clean $_.Name }
}

function Start-DotNetProject($ProjectDirectory) {
    if (-not $ProjectDirectory) {
        $ProjectDirectory = (Get-Location).Path
    }

    Start-Process dotnet -ArgumentList "watch", "--project", "`"$projectDirectory`"", "run"
}

function Start-FunctionProject($ProjectDirectory) {
    if (-not $ProjectDirectory) {
        $ProjectDirectory = (Get-Location).Path
    }

    Start-Process func -ArgumentList "start" -WorkingDirectory "$ProjectDirectory"
}

function Get-ObjectFromJsonFile($jsonFile) {
    return Get-Content $jsonFile | ConvertFrom-Json
}