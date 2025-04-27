function Add-XlockNFCard
{
  <#
    .SYNOPSIS
    Short Description
    .DESCRIPTION
    Detailed Description
    .EXAMPLE
    Add-XlockNFCard
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
  $RequestUri = [System.Web.HttpUtility]::UrlPathEncode($Uri + "?lockId=$LockId&operation=0&cardNumber=$cardNumber&name=$name")
  $response = Invoke-WebRequest -Headers $Headers -Method $Method -Uri $RequestUri -ContentType "application/json"
  
  If ( $response.StatusCode -eq "200" ) {
    $response
  } Else {
    Write-Output "Error: The card $cardNumber of user $name could not be added to lock $LockId ."
  }
}

