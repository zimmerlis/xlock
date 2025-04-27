function Remove-XlockNFCard
{
  <#
    .SYNOPSIS
    Short Description
    .DESCRIPTION
    Detailed Description
    .EXAMPLE
    Remove-XlockNFCard
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$false, Position=0)]
    [string]
    $name = "???",
    
    [Parameter(Mandatory=$false, Position=1)]
    [string]
    $LockId = '???',
    
    [Parameter(Mandatory=$false, Position=2)]
    [long]
    $cardNumber = '???'
  )
  
  $Headers = @{"Authorization" = "$Global:apikey"}
  $BaseUrl = "https://$Global:Server"
  $Method = "POST"
  $Request = "v1-gatewayManageCard"
  $Uri = "$BaseUrl/$Request"
  
  $response = ""
  $RequestUri = [System.Web.HttpUtility]::UrlPathEncode($Uri + "?lockId=$LockId&operation=1&cardNumber=$cardNumber")
  $response = Invoke-WebRequest -Headers $Headers -Method $Method -Uri $RequestUri -ContentType "application/json"
  
  If ( $response.StatusCode -eq "200" ) {
    $response
  } Else {
    Write-Output "The card $cardNumber of user $name could not be removed from lock $LockId."
  }
}

