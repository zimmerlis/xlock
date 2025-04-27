function Get-XlockLocks
{
  <#
      .SYNOPSIS
      Short Description
      .DESCRIPTION
      Detailed Description
      .EXAMPLE
      Get-XlockLocks
  #>
  
  $Headers = @{"Authorization" = "$Global:apikey"}
  $BaseUrl = "https://$Global:Server"
  $Method = "GET"
  $Request = "v1-getLockList"
  $Uri = "$BaseUrl/$Request"
  
  $response = Invoke-WebRequest -Headers $Headers -Method $Method -Uri $Uri -ContentType "application/json"
  
  If ( $response.StatusCode -eq "200" ) {
    
    $jsonContent = $response.Content
    $data = $jsonContent | ConvertFrom-Json
    $locks = [System.Collections.Generic.List[PSCustomObject]]::new()
    $data.data | ForEach-Object {
      $_.PSObject.Properties | ForEach-Object {
        $lockId = $_.Name
        $lock = $_.Value
        $locks.Add([PSCustomObject]@{
            lockId = $lockId
            lockAlias = $lock.lockAlias
            electricQuantity = $lock.electricQuantity
            lockAdmin = $lock.lockAdmin
            lockSettings = $lock.lockSettings
            lastOnlineCheck = $lock.lastOnlineCheck
            gatewayRSSI = $lock.gatewayRSSI
            admin = $lock.admin
            lockMAC = $lock.lockMAC
            bookingConfig = $lock.bookingConfig
        })
      }
    }
    
    # Ausgabe der Schlösser
    
    Write-Debug "There was $($data.data.Count) locks in xlock.app found."
    Write-Debug "$locks" | Out-String      
    
  } Else {
    Write-Output "Error on Request $Uri : $response"
  }

  Return $locks

}

