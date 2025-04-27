function Export-XlockCsvFile
{
  <#
      .SYNOPSIS
      Short Description
      .DESCRIPTION
      Detailed Description
      .EXAMPLE
      Export-XlockCsvFile
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$false, Position=0)]
    [System.Object]
    $data = '???',
    [Parameter(Mandatory=$false, Position=0)]
    [System.String]
    $fileFullNamePath = '???'
  )
  
  if (Test-Path $fileFullNamePath) {
    Remove-Item -Path $fileFullNamePath -Force | Out-Null
  }

  $data | Export-Csv -Path $fileFullNamePath -Delimiter ";" -Encoding UTF8 -NoTypeInformation -NoClobber -Force

}

