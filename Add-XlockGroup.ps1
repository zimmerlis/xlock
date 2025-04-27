function Add-XlockGroup
{
  <#
      .SYNOPSIS
      Short Description
      .DESCRIPTION
      Detailed Description
      .EXAMPLE
      Add-XlockGroup
  #>
  param
  (
    [Parameter(Mandatory,Position=0)]$apikey,
    [Parameter(Mandatory,Position=1)]$Server,
    [Parameter(Mandatory,Position=1)]$GroupName
  )
  
  # https://docs.xlockgroup.com/requests/editgroup

  $Headers = @{"Authorization" = "$apikey"}
  $BaseUrl = "https://$Server"
  $Method = "POST"
  $Request = "v1-editGroup"
  $Uri = "$BaseUrl/$Request"
  
  $response = ""
  $RequestUri = [System.Web.HttpUtility]::UrlPathEncode($Uri + "?operation=0&groupName=$($GroupName)")
  $response = Invoke-WebRequest -Headers $Headers -Method $Method -Uri $RequestUri -ContentType "application/json"

  If ( $response.StatusCode -eq "200" ) {
      $response
  } Else {
      Write-Output "Error: The group $($newgroup.name) could not be added."
  }

}