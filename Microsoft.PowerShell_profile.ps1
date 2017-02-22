#Module imports
Import-Module bash-cmdlets

#Alias shortcuts
# Alias Git
New-Alias -Name git -Value "$Env:ProgramFiles\Git\bin\git.exe"
New-Alias -name "chrome" -value "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
New-Alias -Name 'nppp' -Value 'C:\Program Files (x86)\Notepad++\notepad++.exe'

#Shortcuts to common folders
New-PSDrive -Name Downloads -PSProvider FileSystem -Root C:\Users\worge\Downloads
New-PSDrive -Name Documents -PSProvider FileSystem -Root C:\Users\worge\Documents
New-PSDrive -Name Scripts -PSProvider FileSystem -Root C:\Users\worge\Documents\Scripts
New-PSDrive -Name CompSci -PSProvider FileSystem -Root C:\Users\worge\Documents\CompSci

#Get rid of backspace beep
Set-PSReadlineOption -BellStyle None

#Set useful variables
$WinHome = '/mnt/c/Users/worge'
$BashHome = "C:\Users\worge\AppData\Local\lxss\home\Awakun"

#Prompt customization
function prompt {
  $global:CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
  $h, $User = $global:CurrentUser.Name -split '\\'
  $principal = New-Object System.Security.Principal.WindowsPrincipal($global:CurrentUser)
  
  if ($principal.IsInRole("Administrator")) { 
    $host.ui.rawui.WindowTitle = $CurrentUser.Name + ".Administrator Line: " + $host.UI.RawUI.CursorPosition.Y
  }
  else { 
    $host.ui.rawui.WindowTitle = $CurrentUser.Name + " Line: " + $host.UI.RawUI.CursorPosition.Y
  }
  
  $promptstring = "PS $User@" + $(Get-Item -Path .\).Name + ">"
  Write-Host $promptstring -NoNewline -ForegroundColor Cyan
  return " "
}

# Start a transcript
#
if (!(Test-Path "$Env:USERPROFILE\Documents\WindowsPowerShell\Transcripts"))
{
    if (!(Test-Path "$Env:USERPROFILE\Documents\WindowsPowerShell"))
    {
        $rc = New-Item -Path "$Env:USERPROFILE\Documents\WindowsPowerShell" -ItemType directory
    }
    $rc = New-Item -Path "$Env:USERPROFILE\Documents\WindowsPowerShell\Transcripts" -ItemType directory
}
$curdate = $(get-date -Format "yyyyMMddhhmmss")
Start-Transcript -Path "$Env:USERPROFILE\Documents\WindowsPowerShell\Transcripts\PowerShell_transcript.$curdate.txt"
