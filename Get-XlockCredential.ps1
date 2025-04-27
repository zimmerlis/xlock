function Get-XlockCredential 
{
  <#
      .SYNOPSIS
      Short Description
      .DESCRIPTION
      Detailed Description
      .EXAMPLE
      Get-XlockCredential
  #>
    param (
        [string]$UserName,
        [string]$Server
    )
    If ( Get-StoredCredential -Target "$UserName@$Server" ) {
        $StoredCredential = Get-StoredCredential -Target "$UserName@$Server"
        If ( $UserName -eq $StoredCredential.UserName ) {
            $apikey = [System.Net.NetworkCredential]::new("", $StoredCredential.Password).Password
        } Else {
            throw "Credential wrong!"
        }
    } Else {
        $enterapikey = $host.ui.PromptForCredential("API Key ist mandatory", "Please enter the key once it will be stored in Windows Credential Manager. ", $UserName,"")
        $UserName = $enterapikey.UserName
        $apikey = [System.Net.NetworkCredential]::new("", $enterapikey.Password).Password
        New-StoredCredential -Target "$UserName@$Server" -Type Generic -UserName $UserName -Password "$apikey" -Persist LocalMachine
    }
    Return $apikey
}