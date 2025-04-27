function Import-XlockGroups
{
  <#
    .SYNOPSIS
    Short Description
    .DESCRIPTION
    Detailed Description
    .EXAMPLE
    Import-XlockGroups
  #>
  
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$false, Position=0)]
    [System.Object]
    $userdata = '???',
    [Parameter(Mandatory=$false, Position=0)]
    [System.Object]
    $xlockgroups = '???'
  )
  
  $distinctgroups = (New-Object -TypeName System.Collections.ArrayList)

  ForEach ( $user in $userdata ) {
    If ($($user.Groups).Length -gt 0) {
      If ($($user.Groups).Contains(";")) {
        $distinctgroupstemp = $($user.Groups) -split ";"
        ForEach ( $newgrouptemp in $distinctgroupstemp ) {
          If ( $distinctgroups.count -eq 0 -or -not $distinctgroups.name.contains($newgrouptemp) ) {
            $newgroup = New-Object -TypeName PSCustomObject
            $newgroup | Add-Member NoteProperty name $newgrouptemp
            $void = $distinctgroups.add($newgroup)
          }
        }
      } Else {
        If ( $distinctgroups.count -eq 0 -or -not $distinctgroups.name.contains($user.Groups) ) {
          $newgroup = New-Object -TypeName PSCustomObject
          $newgroup | Add-Member NoteProperty name $($user.Groups)
          $void = $distinctgroups.add($newgroup)
        }
      }
    }
  }
  
  Write-InfoLog "There were $($distinctgroups.Count) groups in the import file."
  
  # All groups that are not existis in xlock will be added
  
  $groupsadded = 0
  ForEach ( $newgroup in $distinctgroups ) {
    
    If ( $xlockgroups.name.Contains($newgroup.name) ) {
      Write-DebugLog "Group $($newgroup.name) exists in xlock.app"        
    } Else {
      Write-DebugLog "Group $($newgroup.name) does not exist in xlock.app"        
      $response = Add-XlockGroup -Server $Global:Server -apikey $Global:apikey -GroupName $($newgroup.name)
      If ( $response.StatusCode -eq "200" ) {
        $groupsadded += 1
        Write-InfoLog "The group $($newgroup.name) has been successfully added."
      } Else {
        Write-ErrorLog "The group $($newgroup.name) could not be created."
        Write-InfoLog "$response"
      }
    }
  }
  
  # All groups in xlock that are not needed anymore will be listed, except the 000_DisabledLocks
  
  $groupstodelete = 0
  ForEach ( $group in $xlockgroups ) {
    If ( $distinctgroups.name.Contains($group.name) ) {
      # Gruppe existiert in beiden Listen
    } Else {
      If ( -not $($group.name).Contains("000_DisabledLocks") ) {
        $groupstodelete += 1
        Write-WarningLog "The group $($group.name) in xlock.app is not found in import file, can be deleted?"
      } Else {
        Write-InfoLog "The group $($group.name) exists only in xlock.app, this is normal."
      }
    }
  }
  
  Write-InfoLog "Statistic of groups:"
  Write-InfoLog " - groups in Import file .......: $($distinctgroups.Count)"
  Write-InfoLog " - groups in xlock.app .........: $($xlockgroups.Count)"
  Write-InfoLog " - groups in xlock.app created..: $groupsadded"
  Write-InfoLog " - groups in xlock.app only.....: $groupstodelete"
  
}

