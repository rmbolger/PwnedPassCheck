function Test-PwnedHash {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword','')]
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateScript({Test-ValidHash $_ -ThrowOnFail})]
        [string]$PasswordHash,
        [ValidateNotNullOrEmpty()]
        [string]$ApiRoot = "https://api.pwnedpasswords.com/range/",
        [switch]$RequestPadding,
        [switch]$NoModeQueryString
    )

    Begin {
        $checkParams = @{
            ApiRoot = $ApiRoot
        }
        if ($RequestPadding) {
            $checkParams.RequestPadding = $true
        }
        if ($NoModeQueryString) {
            $checkParams.NoModeQueryString = $true
        }
    }

    Process
    {
        # Check the hash
        $result = Get-PwnedHash $PasswordHash @checkParams

        if ($result.SeenCount -gt 0) {
            return $true
        } else {
            return $false
        }
    }

    <#
    .SYNOPSIS
        Checks a SHA1 or NTLM hash string against a haveibeenpwned.com compatible Pwned Passwords API endpoint and returns True if the seen count is greater than zero.

    .DESCRIPTION
        The Pwned Passwords API is a way to check a password hash against a list of more than half a billion passwords which have been previously exposed in data breaches. The API implements a k-Anonymity model that allows a password to be searched for by partial hash. This means your full password hash never leaves your machine and ensures your privacy.

        This function will check the specified hash against the API and return True if it has been seen in at least one data breach.

        TO BE CLEAR, only the first 5 characters of the password hash are submitted to the API. See https://haveibeenpwned.com/API/v3#PwnedPasswords for more detail.

    .PARAMETER PasswordHash
        The hash to check. UTF8 encoded SHA1 hashes are expected with the official (default) pwnedpasswords.com API. Some third parties host NTLM (UTF16-LE encoded) versions of the API as well.

    .PARAMETER ApiRoot
        If specified, overrides the default pwnedpasswords.com API URL. URLs or filesystem paths can both be used as an alternative. The URL\Path should include everything preceding the 5 character hash prefix (e.g. 'https://example.com/range/' or 'C:\temp\').

    .PARAMETER RequestPadding
        If specified, HTTP based queries will add the 'Add-Padding: true' header to the request which signals to the server to return a randomly padded response. See https://www.troyhunt.com/enhancing-pwned-passwords-privacy-with-padding for details.

    .PARAMETER NoModeQueryString
        If specified, HTTP based queries will not automatically add the mode=ntlm querystring parameter when NTLM hashes are checked.

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
