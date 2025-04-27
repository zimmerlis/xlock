function ConvertFrom-FromArray
{
  <#
    .SYNOPSIS
    Short Description
    .DESCRIPTION
    Detailed Description
    .EXAMPLE
    ConvertFrom-FromArray
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true, Position=0, HelpMessage='Please add a help message here')]
    [System.Object[]]
    $data
  )
  
  $data | ForEach-Object {
    If ( $($_.lockAlias).length -gt 0 ) {
      $object = $_
      $psCustomObject = New-Object PSObject
      $properties = $object | Get-Member -MemberType Properties
      Foreach ($property in $properties) {
        $propName = $property.Name
        $propValue = $object.$propName
        $psCustomObject | Add-Member -NotePropertyName $propName -NotePropertyValue $propValue
      }
      $psCustomObject
    }
  }
}

