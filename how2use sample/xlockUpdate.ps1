<#
.SYNOPSIS
    Sample Script that uses PowerShell module to support xlock.app for registering individuals with cards based on their groups.

.DESCRIPTION
    This module provides functions for managing users, groups, and cards via the xlock.app API.
    It enables the conversion of Mifare tokens,
    exporting CSV files,
    retrieving and adding groups,
    managing locks, and registering NFC cards.

    Management UI: https://xlock.app/home
    API Documentation: https://docs.xlockgroup.com/basics

.AUTHOR
    René Zimmerli
#>

Add-Type -AssemblyName System.Web

# Create new logger

if ((Get-Module PoshLog -ListAvailable).Count -eq 0) {
  Install-Module PoshLog -Scope AllUsers -Force -MinimumVersion 2.1.0
}
Import-Module PoShLog

$ScriptPath = "$env:HOMEDRIVE\Utilities\xlock"
$LogLevelSwitch = New-LevelSwitch -MinimumLevel Info
$LogLevelDebugSwitch = New-LevelSwitch -MinimumLevel Debug
$ConsoleLevelSwitch = New-LevelSwitch -MinimumLevel Info #Warning
$OutputTemplate = '{Timestamp:yyyy-MM-dd HH:mm:ss.fff zzz} [{Level:u4}] {Message:lj}{NewLine}{Exception}'
If ( Test-Path -Path "$ScriptPath\log\xlockRun.log" ) {
    Remove-Item "$ScriptPath\log\xlockRun.log" -Force
}
New-Logger |
    Set-MinimumLevel -ControlledBy $LogLevelSwitch | # You can change this value later to filter log messages
    # Here you can add as many sinks as you want - see https://github.com/PoShLog/PoShLog/wiki/Sinks for all available sinks
    Add-SinkConsole -LevelSwitch $ConsoleLevelSwitch -OutputTemplate $OutputTemplate |   # Tell logger to write log messages to console
    Add-SinkFile -LevelSwitch $LogLevelDebugSwitch -Path "$ScriptPath\log\xlockRunDebug_.log" -RollingInterval Month -OutputTemplate $OutputTemplate | # Tell logger to write log messages into file
    Add-SinkFile -LevelSwitch $ConsoleLevelSwitch -Path "$ScriptPath\log\xlockRunInfo_.log" -RollingInterval Month -OutputTemplate $OutputTemplate | # Tell logger to write log messages into file
    Add-SinkFile -LevelSwitch $LogLevelSwitch -Path "$ScriptPath\log\xlockRun.log" -OutputTemplate $OutputTemplate | # Tell logger to write log messages into file
    Start-Logger

# Set Environment Variables

$UserName = "infrastruktur@pfimi-sg.ch"
$Server = "api.xlock.app"
$Debug = $false
$env:Debug = [bool]$Debug

# Definition of the import file with columns for PersonName, KeyUid, and Groups

$InputFileName = "GlutzExportFull.csv"
$InputColPersonName = "Media.description" #"label"
$InputColKeyUid = "Media.uid"
$InputColGroups = "group"
$InputFileInternal = "$ScriptPath\csv\xlockImport-Users.csv"
$userkeysFilePath = "$ScriptPath\userkeys.txt"

# Load Modules

If ( (Get-Module -Name xlock).count -gt 0 ) {
  Remove-Module -Name xlock
}

Import-Module CredentialManager

Write-InfoLog ""
Write-InfoLog "Xlock update process has started..."
Write-InfoLog ""

If ( $Debug ) {
  Import-Module -Name xlock -Verbose
} Else {
  Import-Module -Name xlock
}

<# 
    
    Retrieving or storing the API key under Windows Credentials
    Example for an API key: This must be entered for the first time by each Windows user and will then be stored in Windows Credentials.
    Credential Manager in Windows is located here: Control Panel\All Control Panel Items\Credential Manager\Edit Generic Credentials
    An entry with the following attributes must be present:
    Internet or network address: user@domain.com@api.xlock.app
    User Name: user@domain.com

    The Password contains the API Authorization key that has the format: [UID]_[API-Key] (without brackets)
    
    Password Sample:
    <---------- UID ----------->_<------------------------------------ API KEY ---------------------------------------->
    Jk8n3t7XjUDgYBssboo8HhgEMBo4_9hcNoJ5n2kS7BrMbKJub_vfgwc5M342I3Lb78_J8DZV8ZhW-Or71czxvj0XBEzhqPdjHnwuXZnJkg0sIsRrIR==

#>

$storedapikey = Get-XlockCredential -UserName $UserName -Server $Server
$apikey = "x-api-key:$storedapikey"

# Make some Variables Global

$Global:apikey = $apikey
$Global:Server = $Server

# Load the hashmap of tokens (service as a cache for tokens stored with a hash value)

$userkeys = @{}
Get-Content $userkeysFilePath | ForEach-Object {
    $parts = $_ -split "="
    $userkeys[$parts[0]] = $parts[1]
}

# Convert the input file with users and groups to a standardized format for this tool


if (Test-Path $InputFileInternal) {
  Remove-Item -Path $InputFileInternal -Force | Out-Null
}

$csv = Import-Csv -Path "$ScriptPath\$InputFileName" -Delimiter ';' -Encoding Default
$importusers = $csv | Select-Object @{Name='PersonName'; Expression={$_.$InputColPersonName}}, 
@{Name='MediaKeyUid'; Expression={$_.$InputColKeyUid}}, 
@{Name='Groups'; Expression={$_.$InputColGroups}}
# Gruppen für jede Person sammeln
$groupDict = @{}
foreach ($entry in $importusers) {
    if ($entry.Groups -ne "") {
        $groupDict[$entry.PersonName] = $entry.Groups
    }
}
# Set groups for all MediaKeyUid of the person (because Glutz export only has values in the first record)

foreach ($entry in $importusers) {
    if ($entry.Groups -eq "") {
        $entry.Groups = $groupDict[$entry.PersonName]
    }
}
$importusers | Export-Csv -Path $InputFileInternal -Delimiter ',' -NoTypeInformation -Encoding UTF8

###############################
### BEGINN DER VERARBEITUNG ###
###############################

# Reading the import file with the names of the persons, the key, and the assigned team groups

$userdata = Import-Csv $InputFileInternal -Delimiter "," -Encoding UTF8
$userdata | Out-Null

### GET XLOCK GROUPS ###
########################

Write-InfoLog "Get-XlockGroups..."
$groups = Get-XlockGroups
Export-XlockCsvFile -data $groups -fileFullNamePath "$ScriptPath\csv\xlockExport-Groups.csv"

### EXTRACT ALL LOCKS ###
#########################

Write-InfoLog "Get-XlockLocks..."
$locks = Get-XlockLocks
$data = ConvertFrom-FromArray -data $locks
Export-XlockCsvFile -data $data -fileFullNamePath "$ScriptPath\csv\xlockExport-Locks.csv"

### EXTRACT LOCKS WITH CARDS ###
################################

Write-InfoLog "Get-XlocksLocksWithUsers..."
$LocksUsers = Get-XlocksLocksWithUsers
$data = ConvertFrom-FromArray -data $LocksUsers
Export-XlockCsvFile -data $data -fileFullNamePath "$ScriptPath\csv\xlockExport-LocksUsers.csv"

### EXTRACT GROUPS WITH LOCKS ###
#################################

Write-InfoLog "Get-XlockGroupsWithLocks..."
$GroupLocks = Get-XlockGroupsWithLocks -groups $groups
$data = ConvertFrom-FromArray -data $GroupLocks
Export-XlockCsvFile -data $data -fileFullNamePath "$ScriptPath\csv\xlockExport-GroupLocks.csv"

### IMPORT MISSING GROUPS  ###
##############################

# Read existing groups and check if they are available in the XLOCK system
# All missing groups will be created in XLOCK
# A warning will be issued for all surplus groups
Write-InfoLog "Import-XlockGroups..."
Import-XlockGroups -userdata $userdata -xlockgroups $groups

Write-InfoLog ""
Write-InfoLog "Xlock update process add users to locks ..."
Write-InfoLog ""

### IMPORT MISSING USERS TO LOCKS  ###
######################################

# All users are checked for their memberships (groups) to see if the person's key is programmed
# into all locks in the relevant groups. 
# Access will be removed from all other locks in groups where the person is not a member

ForEach ( $person in $userdata ) {
  # For each person
  Write-DebugLog "Processing $($person.PersonName) ($($person.MediaKeyUid)) ..."
  ForEach ( $group in ( $($person.Groups).Split(";") ) ) {
    # For each group the person is in (or should be according to the import file)
    Write-DebugLog "   $group ..."
    ForEach ( $lock in $GroupLocks ) {
      # For all locks
      if ($lock.groupName -eq $group) {
        # For each lock that is in this group in XLOCK
        Write-DebugLog "       The lock $($lock.lockAlias) is verified, because it is in the list of authorized groups ..."
        $userFound = $false
        ForEach ( $LocksUser in $LocksUsers ) {
          If ( $LocksUser.lockId -eq $lock.lockId -and ($person.PersonName.Contains($LocksUser.cardName)) ) {
            $userFound = $true
            Write-DebugLog "          The lock $($lock.lockAlias) has $($person.PersonName) ($($person.MediaKeyUid)) already authorized."
            if (-not $userkeys.ContainsKey($person.MediaKeyUid)) { $userkeys[$person.MediaKeyUid] = $LocksUser.cardId }
          }
        }
        If ( $userFound -eq $false ) {
          $xlockDecimalReversed = Convert-XlockMifareToken -hex "$($person.MediaKeyUid)"
          Write-DebugLog "          The lock $($lock.lockAlias) has $($person.PersonName) - $($person.MediaKeyUid) not authorized now."
          Try {
            $result = Add-XlockNFCard -name $($person.PersonName) -LockId $($lock.lockId) -cardNumber $xlockDecimalReversed
            $jsonObject = $result | ConvertFrom-Json
            $hash = $jsonObject.data[0].PSObject.Properties.Name
            if (-not $userkeys.ContainsKey($person.MediaKeyUid)) { $userkeys[$person.MediaKeyUid] = $hash }
            Write-InfoLog "The person $($person.PersonName) ($($person.MediaKeyUid)) [$($xlockDecimalReversed)] in group $($group), has been added successfully to the lock $($lock.lockAlias) [$($lock.lockId)]."
          } Catch {
            Write-ErrorLog "          The person $($person.PersonName) ($($person.MediaKeyUid)) [$($xlockDecimalReversed)] could not be added to the lock $($lock.lockAlias) ($($lock.lockId))."
            PAUSE
          }
        }
      } 
    }
  }
}

# Finally, the hashmap will store the Glutz key and the hash values converted for XLOCK
$userkeys.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" } > $userkeysFilePath

Write-InfoLog ""
Write-InfoLog "Xlock update process remove users from locks ..."
Write-InfoLog ""

### REMOVE USERS FROM UNAUTHORIZED LOCKS  ###
#############################################

# All users are checked for their memberships (groups) to see if the person's key is programmed 
# into locks of groups for which they do not have membership. 
# In such cases, access will be removed.

ForEach ( $person in $userdata ) {
  # For each person
  Write-DebugLog "Processing $($person.PersonName) ($($person.MediaKeyUid)) ..."
  ForEach ( $group in $groups.name ) {
    # For each group the person is not in (according to the import file
    If ( -Not $person.Groups.Contains($group) ) {
      Write-DebugLog "   $group ..."
      ForEach ( $lock in $GroupLocks ) {
        # For all locks
        if ($lock.groupName -eq $group) {
          # For each lock that is in this group in XLOCK
          Write-DebugLog "       The lock $($lock.lockAlias) should not be authorized for person $($person.PersonName) ..."
          $userFound = $false
          $cardID2Remove = ""
          ForEach ( $LocksUser in $LocksUsers ) {
            If ( $LocksUser.lockId -eq $lock.lockId -and ($person.PersonName.Contains($LocksUser.cardName)) ) {
              $userFound = $true
              $cardID2Remove = $LocksUser.cardId
              Write-DebugLog "          The lock $($lock.lockAlias) [$($lock.lockId)] has $($person.PersonName) ($($person.MediaKeyUid)) [$($LocksUser.cardId)] authortized."
            }
          }
          If ( $userFound -eq $true ) {
            Try {
              $result = ""
              $result = Remove-XlockNFCard -name $($person.PersonName) -LockId $($lock.lockId) -cardNumber $cardID2Remove
              $jsonObject = $result | ConvertFrom-Json
              $hash = $jsonObject.data[0].PSObject.Properties.Name
              Write-InfoLog "The person $($person.PersonName) ($($person.MediaKeyUid)) [$($cardID2Remove)] is not a member of group $group and has been removed from lock $($lock.lockAlias) [$($lock.lockId)]."
            } Catch {
              Write-ErrorLog "          The person $($person.PersonName) ($($person.MediaKeyUid)) [$($cardID2Remove)] clould not be removed from lock $($lock.lockAlias) [$($lock.lockId)]. $result"
            }
          }
        } 
      }
    }
  }
}

Write-InfoLog ""
Write-InfoLog "End of Processing $($userdata.count) users"
Write-InfoLog ""

Close-Logger