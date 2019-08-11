function Test-ValidPassObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)]
        [object]$PassObject,
        [switch]$ThrowOnFail
    )

    # This is basically a workaround for PowerShell 5+'s inability to properly do parameter
    # binding when both a SecureString and PSCredential object are in different parameter
    # sets and the same position or passed via pipeline.

    if ($PassObject -isnot [string] -and
        $PassObject -isnot [securestring] -and
        $PassObject -isnot [pscredential])
    {
        if ($ThrowOnFail) {
            throw "Specified password object must be String, SecureString, or PSCredential."
        } else {
            return $false
        }
    }

    return $true
}
