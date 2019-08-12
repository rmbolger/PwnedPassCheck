function Convert-HexToByteArray {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$HexString
    )

    $Bytes = New-Object byte[] ($HexString.Length / 2)

    For($i=0; $i -lt $HexString.Length; $i+=2){
        $Bytes[$i/2] = [Convert]::ToByte($HexString.Substring($i, 2), 16)
    }

    $Bytes
}
