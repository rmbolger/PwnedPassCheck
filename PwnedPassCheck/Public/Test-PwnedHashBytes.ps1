function Test-PwnedHashBytes {
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('NTHash')]
        [byte[]]$HashBytes,
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('SamAccountName')]
        [string]$Label,
        [string]$ApiRoot = "https://api.pwnedpasswords.com/range/"
    )

    Process
    {
        # validate the length of the byte array here since we can't do it in ValidateScript
        # due to this oddity:
        # https://github.com/PowerShell/PowerShell/issues/6185
        if ($HashBytes.Length -ne 16 -and $HashBytes.Length -ne 20) {
            throw "HashBytes has an invalid length for SHA1 and NTLM."
        }

        # convert it to a hex string for submission
        $PasswordHash = [BitConverter]::ToString($HashBytes).Replace('-','')
        Write-Verbose "Converted hash bytes to $PasswordHash"

        Test-PwnedHash $PasswordHash -ApiRoot $ApiRoot -Label $Label
    }

    <#
    .SYNOPSIS
        Checks a SHA1 or NTLM hash's byte array against a haveibeenpwned.com compatible Pwned Passwords API endpoint.

    .DESCRIPTION
        The Pwned Passwords API is a way to check a password hash against a list of more than half a billion passwords which have been previously exposed in data breaches. The API implements a k-Anonymity model that allows a password to be searched for by partial hash. This means your full password hash never leaves your machine and ensures your privacy.

        This function will check the specified hash against the API and return a number that indicates the amount of times that password was found in known data breaches. A high count indicates that password has been heavily used and should not be considered safe.

        TO BE CLEAR, only the first 5 characters of the password hash are submitted to the API. See https://haveibeenpwned.com/API/v3#PwnedPasswords for more detail.

    .PARAMETER HashBytes
        A byte array hash value. An error will be thrown if the byte array has a length other than 16 (NTLM) or 20 (SHA1).

    .PARAMETER Label
        This adds an optional Label field to the output to more easily identifiy this hash.

    .PARAMETER ApiRoot
        If specified, overrides the default pwnedpasswords.com API endpoint. Alternative URLs should include everything preceding the 5 character hash prefix (e.g. 'https://example.com/range/').

    .EXAMPLE
        $hashBytes = Get-SHA1Hash 'password' -AsBytes
        PS C:\>Test-PwnedHashBytes $hashBytes -Label 'myuser'

        Test a byte array hash against the official pwnedpasswords.com API

    .LINK
        Get-SHA1Hash

    .LINK
        Get-NTLMHash

    .LINK
        https://haveibeenpwned.com/API/v3#PwnedPasswords

    .LINK
        https://new.blog.cloudflare.com/validating-leaked-passwords-with-k-anonymity/

    #>
}
