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

function Invoke-Bash 
{
  <#
      .SYNOPSIS
      Runs a bash command

      .DESCRIPTION
      Invoke Bash attempts to run the provided $command string as a command through the WSL subsystem

      .PARAMETER Command
      (Mandatory) A string containing the command to run.

      .EXAMPLE
      Invoke-Bash "sudo apt update"
      This would update the WSL by running sudo apt update via bash
    #>
    Param
    (
      [Parameter(
        Mandatory = $true,
        Position = 0
      )]
      [string]
      $Command
    )
    bash -c "$Command"
}

function ssh {
    <#
      .SYNOPSIS
      Opens a remote shell connection to $RemoteMachine

      .DESCRIPTION
      The ssh function opens a remote shell connection using either bash -c "ssh $RemoteMachine"
      to open an ssh tunnel to a UNIX remote machine, or using Enter-PSSession for a Windows remote
      machine whose hostname is provided by the $RemoteMachine parameter.

      .PARAMETER RemoteMachine
      (Mandatory) A single remote machine hostname. Must include full FQDN.

      .PARAMETER UNIX
      (Optional, Default) Flags the ssh function to use BASH to ssh into the remote UNIX-based computer.

      .PARAMETER Windows
      (Optional) Allows user to remote into a Windows powershell session instead using Enter-PSSession

      .PARAMETER Credential
      (Mandatory with Windows parameter) Accepts either a username or a PSCredential object for authentication in PSSession

      .EXAMPLE
      Remote into a UNIX machine
      ssh -RemoteMachine ubuntu22.ant.amazon.com

      .EXAMPLE
      Remote into a Windows machine
      ssh -Windows -Credential username -RemoteMachine SEA-1800010000.ant.amazon.com
    #>

    [CmdletBinding(DefaultParameterSetName = 'UNIX')]
    Param(
        [Parameter(Mandatory=$true,ParameterSetName = 'UNIX')]
        [Parameter(Mandatory=$true,ParameterSetName = 'Windows',Position=0)]
        [Alias("RemoteComputer","ComputerName")]
        [string]$RemoteMachine,
        
        [Parameter(ParameterSetName = 'UNIX')]
        [Alias("Linux","Mac")]
        [switch]$UNIX,

        [Parameter(ParameterSetName = 'UNIX')]
        [Parameter(ParameterSetName = 'WithKey')]
        [Alias("i")]
        [string]$Key = $null,
        
        [Parameter(ParameterSetName = 'UNIX')]
        [Parameter(ParameterSetName = 'WithKey', Mandatory = $true)]
        [string]$User,
        
        [Parameter(ParameterSetName = 'Windows')]
        [switch]$Windows,
        
        [Parameter(Mandatory=$true,ParameterSetName = 'Windows')]
        [System.Management.Automation.CredentialAttribute()]
        $Credential
    )

    Process { 
      if (Test-Connection -ComputerName $RemoteMachine -Count 1 -ErrorAction SilentlyContinue) {    #Test if $RemoteMachine can be pinged.
          if ($Windows) { #Check for Windows flag
              Enter-PSSession -ComputerName $RemoteMachine -Credential $Credential
          } Else { #UNIX style
              if ($Key) {
                  bash -c "ssh -i $Key $User@$RemoteMachine"
              } Else {
                  bash -c "ssh $RemoteMachine"
              }
          }
      } Else {
          Write-Error "$RemoteMachine appears to be offline. Verify you are using the FQDN and that the hostname was entered correctly before retrying."
      }
    }
}

function Update-Bash {
    <#
      .SYNOPSIS
      Updates packages for the WSL

      .DESCRIPTION
      This function will update the package cache (apt update) and then upgrade and packages that need it (apt upgrade)

      .EXAMPLE
      Update packages
      Update-BASH
    #>
    & bash -c 'sudo apt update && sudo apt upgrade -y'
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
