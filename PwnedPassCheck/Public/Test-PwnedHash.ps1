function Test-PwnedHash {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword','')]
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [ValidateScript({Test-ValidHash $_ -ThrowOnFail})]
        [string]$PasswordHash,
        [string]$ApiRoot = "https://api.pwnedpasswords.com/range/"
    )

    Process
    {
        $hashPrefix = $PasswordHash.Substring(0,5)
        $hashSuffix = $PasswordHash.Substring(5)

        # query the API
        $results = Invoke-RestMethod "$($apiRoot)$($hashPrefix)" -UserAgent $script:USER_AGENT @script:UseBasic

        # check for the suffix in the results
        $SeenCount = 0
        if ($results -match "(?m:^$($hashSuffix):(?<SeenCount>\d+))") {
            $SeenCount = [int]$matches.SeenCount
        }

        # return the hash and found count
        [pscustomobject]@{
            Hash = $PasswordHash
            SeenCount = $SeenCount
        }
    }

    <#
    .SYNOPSIS
        Checks a password hash against a haveibeenpwned.com compatible Pwned Passwords API endpoint.

    .DESCRIPTION
        The Pwned Passwords API is a way to check a password hash against a list of more than half a billion passwords which have been previously exposed in data breaches. The API implements a k-Anonymity model that allows a password to be searched for by partial hash. This means your full password hash never leaves your machine and ensures your privacy.

        This function will check the specified hash against the API and return a number that indicates the amount of times that password was found in known data breaches. A high count indicates that password has been heavily used and should not be considered safe.

        TO BE CLEAR, only the first 5 characters of the password hash are submitted to the API. See https://haveibeenpwned.com/API/v3#PwnedPasswords for more detail.

    .PARAMETER PasswordHash
        The hash to check. UTF8 encoded SHA1 hashes are expected with the official (default) pwnedpasswords.com API. Some third parties host NTLM (UTF16-LE encoded) versions of the API as well.

    .PARAMETER ApiRoot
        If specified, overrides the default pwnedpasswords.com API endpoint. Alternative URLs should include everything preceding the 5 character hash prefix (e.g. 'https://example.com/range/').

    .EXAMPLE
        $hash = '5BAA61E4C9B93F3F0682250B6CF8331B7EE68FD8' # UTF8 SHA1 hash of 'password'
        PS C:\>Test-PwnedHash $hash

        Test a password hash against the official pwnedpasswords.com API

    .EXAMPLE
        $hash = '8846F7EAEE8FB117AD06BDD830B7586C'  # NTLM hash of 'password'
        PS C:\>$hash | Test-PwnedHash -ApiRoot 'http://internal.example.com/range/'

        Test a password hash against an internal NTLM Pwned Passwords API endpoint.

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
