function Get-XlockGroups
{
  <#
      .SYNOPSIS
      Short Description
      .DESCRIPTION
      Detailed Description
      .EXAMPLE
      Get-XlockGroups
  #>
  
  $Headers = @{"Authorization" = "$Global:apikey"}
  $BaseUrl = "https://$Global:Server"
  $Method = "GET"
  $Request = "v1-getGroupList"
  $Uri = "$BaseUrl/$Request"
  
  $response = Invoke-WebRequest -Headers $Headers -Method $Method -Uri $Uri -ContentType "application/json"
  
  If ( $response.StatusCode -eq "200" ) {
    $groups = [Collections.Generic.List[object]]::new()
    $content = $response.Content | ConvertFrom-Json
    
    $content.data | ForEach-Object {
      If ( $Debug ) {Write-Debug $_ }
      $uid = $_ | Get-Member -MemberType NoteProperty | ForEach-Object {"$($_.Name)"}
      $entry = $_.$uid
      $group = New-Object -TypeName PSCustomObject
      $group | Add-Member NoteProperty uid $uid
      $group | Add-Member NoteProperty admin $entry.admin
      $group | Add-Member NoteProperty role $entry.role
      $test = [Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($entry.name)
      $encodedtext = [Text.Encoding]::UTF8.GetString($test)
      $group | Add-Member NoteProperty name $encodedtext
      
      $groups.add($group)
    }

    $groups
    
  } Else {
    Trow "Fehler beim Request $Uri : $response"
  }
}