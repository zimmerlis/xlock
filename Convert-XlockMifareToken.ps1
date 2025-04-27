function Convert-XlockMifareToken
{
  <#
      .SYNOPSIS
      Convert a normal Hexadecimal Mifare Token to Xlock 
      .DESCRIPTION
      For Xlock API it is needed to have the "Decimal Reverse Number"
      .EXAMPLE
      Convert-XlockMifareToken -cardKeyHex "12AE34BC25FE2122"
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$false, Position=0)]
    [System.Object]
    $Hex = '???'
  )
  
  $reversedHex = $Hex # Die Glutz bzw. Mifare Numer sit beretis reversed
  $DezimalUmgedreht = [System.Convert]::ToInt64($reversedHex, 16)
  Return $DezimalUmgedreht
}

