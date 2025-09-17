# Stop on errors
$ErrorActionPreference = "Stop"

# Bash-like completion
Set-PSReadlineKeyHandler -Key Tab -Function Complete

# No beeping
Set-PSReadlineOption -BellStyle None

# Aliases
Set-Alias -Name g -Value git
Set-Alias -Name unzip -Value Expand-Archive
Set-Alias -Name touch -Value New-Item
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

# Functions
function Test-ModuleInstallation() {
    $modules = @(
        [PSCustomObject]@{
            Name = "BurntToast";
            Installed = $false;
            Version = [Version]0.0.0.0;
        }
    )

    foreach ($module in $modules) {
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
}

function Build-Sln($sln) {
    $pattern = if ($sln) { $sln } else { "*.sln" }
    $slns = @(Get-ChildItem $pattern)
    $failingSlns = @()

    foreach ($sln in $slns) {
        dotnet build $sln.Name

        if ($LASTEXITCODE -ne 0) {
            $failingSlns += $sln.Name
        }
    }

    if ($failingSlns) {
        $errorMessage = "`nERROR: These slns failed to build`n`n" + (($failingSlns | ForEach-Object { "• $_" }) -join "`n")
        Write-Host $errorMessage -ForegroundColor Red
    }
}

function Clean-Sln($sln) {
    $pattern = if ($sln) { $sln } else { "*.sln" }
    Get-ChildItem $pattern | ForEach-Object { dotnet clean $_.Name }
}

function Start-DotnetProject($ProjectDirectory, [switch]$Watch) {
    if (-not $ProjectDirectory) {
        $ProjectDirectory = (Get-Location).Path
    }

    Start-Process dotnet -ArgumentList "run", "--project", "`"$projectDirectory`""
}

function Start-DotNetProject($ProjectDirectory, $WindowTitle, [switch]$SkipWatch) {
  $setTitleCmd = if ($WindowTitle) {
      "-NoProfile -Command `$host.ui.RawUI.WindowTitle = '$WindowTitle';"
    }
    else {
        ""
    }

  $dotnetRunCmd = if (-not $DotNetWatch -or $SkipWatch) {
      "dotnet run --project '$ProjectDirectory'"
    }
    else {
      "dotnet watch --project '$projectDirectory' run"
    }

  Start-Process pwsh -ArgumentList ($setTitleCmd + $dotnetRunCmd)
}

function Stop-AllDotNetProcesses {
    $processes = @(Get-Process | Where-Object { $_.ProcessName -eq "dotnet" })
    Write-Output "Stopping $($processes.Count) .NET processes..."
    $processes | ForEach-Object { Stop-Process $_ }
}

function Get-ObjectFromJsonFile($jsonFile) {
    return Get-Content $jsonFile | ConvertFrom-Json
}

function Sum {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline=$true)]
        $numbers
    )

    begin {
        $sum = [decimal]0
    }

    process {
        foreach ($number in $numbers) {
            $sum += $number
        }
    }

    end {
        return $sum
    }
}

