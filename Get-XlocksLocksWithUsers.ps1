function Get-XlocksLocksWithUsers
{
  <#
      .SYNOPSIS
      Short Description
      .DESCRIPTION
      Detailed Description
      .EXAMPLE
      Get-XlocksLocksWithUsers
  #>
  
  $Headers = @{ 
    "Accept" = "application/json"
    "Accept-Charset" = "UTF-8"
    "Content-Type" = "application/json"
    "Authorization" = "$Global:apikey"
  }
  $BaseUrl = "https://$Global:Server"
  $Method = "GET"
  $Request = "v1-getLockList"
  $Request2 = "v1-gatewayManageCard"
  $Uri = "$BaseUrl/$Request"
  $Uri2 = "$BaseUrl/$Request2"
  
  $response = Invoke-WebRequest -Headers $Headers -Method $Method -Uri $Uri -ContentType "application/json"
  
  If ( $response.StatusCode -eq "200" ) {
    
    $jsonContent = $response.Content
    $data = $jsonContent | ConvertFrom-Json
    $locks = [System.Collections.Generic.List[PSCustomObject]]::new()
    $locksusers = [System.Collections.Generic.List[PSCustomObject]]::new()
    $data.data | ForEach-Object {
      $_.PSObject.Properties | ForEach-Object {
        $lockId = $_.Name
        $lock = $_.Value
        $RequestUri2 = [System.Web.HttpUtility]::UrlPathEncode($Uri2 + "?lockId=$lockId" + "&operation=2" + "&resultsLimit=999")
        $response2 = Invoke-WebRequest -Headers $Headers -Method $Method -Uri $RequestUri2 -ContentType "application/json"

        $content2 = $response2.Content # Wenn der Inhalt nicht automatisch als UTF-8 dekodiert wird, dekodieren wir ihn manuell 
        $utf8Content = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Default.GetBytes($content2))
        
          If ( $response2.StatusCode -eq "200" ) {
    
             Write-Debug "Request erfolgreich mit ReturnCode: $($response2.StatusCode) "
             Write-Debug ""
             $jsonContent2 = $utf8Content
             $data2 = $jsonContent2 | ConvertFrom-Json
             $data2.data | ForEach-Object {
                $_.PSObject.Properties | ForEach-Object {

                    $cardId = $_.Name
                    $card = $_.Value
                    $cardName = $card.CardName

                    $Global:cardName = $card.CardName

                    $rawBytes = [System.Text.Encoding]::UTF8.GetBytes($cardName) # In Byte-Array konvertieren 
                    $cardName = [System.Text.Encoding]::UTF8.GetString($rawBytes) # In String mit Standardkodierung konvertieren

                    $Global:cardName2 = $cardName

                    $locksusers.Add([PSCustomObject]@{
                        lockId = $lockId
                        lockAlias = $lock.lockAlias
                        cardId = $cardId
                        cardName = $cardName
                    })

                }
             }
          }
        }
      }
    
  } Else {
    Write-Output "Error on Request $Uri : $response"
  }

  Return $locksusers

}

