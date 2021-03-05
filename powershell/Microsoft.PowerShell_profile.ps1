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
$workAliasScript = "$env:USERPROFILE/work/PowerShell/aliases.ps1"
if (Test-Path $workAliasScript) {
    . $workAliasScript
}

# Commands
function touch($Filename) {
    echo $null >> $Filename
}

# Modules
Import-Module oh-my-posh -Scope Local

# Set theme
Set-Theme Honukai
Set-PSReadLineOption -Colors @{ Parameter = "DarkGreen" }
Set-PSReadLineOption -Colors @{ Operator = "White" }

# Functions
function Show-Notification {
    [cmdletbinding()]
    Param (
        [string]
        $ToastTitle,
        [string]
        [parameter(ValueFromPipeline)]
        $ToastText
    )

    if (-not $IsWindows) {
        Write-Error "Only supports Windows"
    }

    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
    $template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)

    $rawXml = [xml] $template.GetXml()
    ($rawXml.toast.visual.binding.text|where {$_.id -eq "1"}).AppendChild($rawXml.CreateTextNode($ToastTitle)) > $null
    ($rawXml.toast.visual.binding.text|where {$_.id -eq "2"}).AppendChild($rawXml.CreateTextNode($ToastText)) > $null

    $serializedXml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $serializedXml.LoadXml($rawXml.OuterXml)

    $toast = [Windows.UI.Notifications.ToastNotification]::new($serializedXml)
    $toast.Tag = "PowerShell"
    $toast.Group = "PowerShell"
    $toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(1)

    $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("PowerShell")
    $notifier.Show($toast);
}
