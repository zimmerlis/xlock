function Get-XlockGroupsWithLocks
{
  <#
      .SYNOPSIS
      Short Description
      .DESCRIPTION
      Detailed Description
      .EXAMPLE
      Get-XlockGroupsWithLocks
  #>
  
  param
  (
    [Parameter(Mandatory,Position=0)]$groups='???'
  )  

  $GroupLocks = [System.Collections.Generic.List[PSCustomObject]]::new()
  
  ForEach ( $group in $groups ) {
    $groupName = $group.name
    $groupId = $group.uid
    Write-Debug "$groupName ($groupId)"
    
    $Headers = @{"Authorization" = "$Global:apikey"}
    $BaseUrl = "https://$Global:Server"
    $Method = "GET"
    $Request = "v1-getGroupLocks"
    $Uri = "$BaseUrl/$Request"
    $RequestUri = [System.Web.HttpUtility]::UrlPathEncode($Uri + "?groupId=$groupId")
    
    $response = Invoke-WebRequest -Headers $Headers -Method $Method -Uri $RequestUri -ContentType "application/json"
    
    If ( $response.StatusCode -eq "200" ) {
      $jsonContent = $response.Content
      $data = $jsonContent | ConvertFrom-Json
      $Locks = [System.Collections.Generic.List[PSCustomObject]]::new()
      $data.data | ForEach-Object {
        $_.PSObject.Properties | ForEach-Object {
          $grouplockId = $_.Name
          $grouplock = $_.Value
          $Locks.Add([PSCustomObject]@{
              groupName = $groupName
              groupId = $groupId
              lockId = $grouplockId
              lockAlias = $grouplock.lockAlias
              lockMAC = $grouplock.lockMAC  
          })
        }
      }
	  
      If ( $($data.data.Count) -eq "0" ) {
        Write-Debug "  -"
        Write-Debug ""
      } Else {
        Write-Debug "  $($data.data.Count) Lock(s) in Group $groupName found."
        Write-Debug ""
      }
      
      $GroupLocks += $Locks
      
    } Else {
      Write-Output "Error on Request $Uri : $response"
    }
    
  }
  
  Return $GroupLocks
}

