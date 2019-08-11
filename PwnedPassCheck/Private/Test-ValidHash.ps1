function Test-ValidHash {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)]
        [string]$HashString,
        [switch]$ThrowOnFail
    )

    if ($HashString -notmatch '(?i:[0-9a-f]{32}|[0-9a-f]{40})') {
        if ($ThrowOnFail) {
            throw "Specified hash is not a valid SHA1 or NTLM hash"
        } else {
            return $false
        }
    }

    return $true
}
