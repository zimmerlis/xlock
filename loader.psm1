<#
.SYNOPSIS
    PowerShell module to support xlock.app for registering individuals with cards based on their groups.

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

.FUNCTIONS
    - Convert-XlockMifareToken
    - ConvertFrom-FromArray
    - Export-XlockCsvFile
    - Get-XlockCredential
    - Get-XlockGroups
    - Add-XlockGroup
    - Import-XlockGroups
    - Get-XlockLocks
    - Get-XlockGroupsWithLocks
    - Get-XlocksLocksWithUsers
    - Add-XlockNFCard
    - Remove-XlockNFCard

.EXAMPLE
    # Initialisierung des Moduls
    . $PSScriptRoot\init.ps1

    # Laden aller Funktionsdefinitionen
    . $PSScriptRoot\Convert-XlockMifareToken.ps1
    . $PSScriptRoot\ConvertFrom-FromArray.ps1
    . $PSScriptRoot\Export-XlockCsvFile.ps1
    . $PSScriptRoot\Get-XlockCredential.ps1
    . $PSScriptRoot\Get-XlockGroups.ps1
    . $PSScriptRoot\Add-XlockGroup.ps1
    . $PSScriptRoot\Import-XlockGroups.ps1
    . $PSScriptRoot\Get-XlockLocks.ps1
    . $PSScriptRoot\Get-XlockGroupsWithLocks.ps1
    . $PSScriptRoot\Get-XlocksLocksWithUsers.ps1
    . $PSScriptRoot\Add-XlockNFCard.ps1
    . $PSScriptRoot\Remove-XlockNFCard.ps1
#>


# WHEN NEW CONTENT IS PUBLISHED TO THIS MODULE:
. $PSScriptRoot\init.ps1


# LOADING ALL FUNCTION DEFINITIONS:

# Object and Filehandling

. $PSScriptRoot\Convert-XlockMifareToken.ps1
. $PSScriptRoot\ConvertFrom-FromArray.ps1
. $PSScriptRoot\Export-XlockCsvFile.ps1

# Credetial Handling

. $PSScriptRoot\Get-XlockCredential.ps1

# Groups 

. $PSScriptRoot\Get-XlockGroups.ps1
. $PSScriptRoot\Add-XlockGroup.ps1
. $PSScriptRoot\Import-XlockGroups.ps1

# Locks

. $PSScriptRoot\Get-XlockLocks.ps1
. $PSScriptRoot\Get-XlockGroupsWithLocks.ps1
. $PSScriptRoot\Get-XlocksLocksWithUsers.ps1

# Users and Keys

. $PSScriptRoot\Add-XlockNFCard.ps1
. $PSScriptRoot\Remove-XlockNFCard.ps1

