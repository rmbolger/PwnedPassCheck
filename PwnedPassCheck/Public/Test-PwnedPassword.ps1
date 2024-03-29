function Test-PwnedPassword {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [ValidateScript({Test-ValidPassObject $_ -ThrowOnFail})]
        [object]$InputObject,
        [ValidateNotNullOrEmpty()]
        [string]$ApiRoot = "https://api.pwnedpasswords.com/range/",
        [ValidateSet('SHA1','NTLM')]
        [string]$HashType = 'SHA1',
        [switch]$RequestPadding,
        [switch]$NoModeQueryString
    )

    Begin
    {
        $HashCmd = "Get-$($HashType)Hash"

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
        # Generate the appropriate hash
        $PasswordHash = &$HashCmd $InputObject

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
        Checks a password against a haveibeenpwned.com compatible Pwned Passwords API endpoint and returns True if the seen count is greater than zero.

    .DESCRIPTION
        The Pwned Passwords API is a way to check a password hash against a list of more than half a billion passwords which have been previously exposed in data breaches. The API implements a k-Anonymity model that allows a password to be searched for by partial hash. This means your full password hash never leaves your machine and ensures your privacy.

        This function will locally hash the specified password, check it against the API, and return True if it has been seen in at least one data breach.

        TO BE CLEAR, your password is never sent to a remote machine and only the first 5 characters of its *hash* are submitted to the API. See https://haveibeenpwned.com/API/v3#PwnedPasswords for more detail.

    .PARAMETER InputObject
        A String, SecureString, or PSCredential object to check. The username on a PSCredential object is ignored.

    .PARAMETER ApiRoot
        If specified, overrides the default pwnedpasswords.com API URL. URLs or filesystem paths can both be used as an alternative. The URL\Path should include everything preceding the 5 character hash prefix (e.g. 'https://example.com/range/' or 'C:\temp\').

    .PARAMETER HashType
        SHA1 or NTLM. The default is SHA1 and is used by the official pwnedpasswords.com API endpoint.

    .PARAMETER RequestPadding
        If specified, HTTP based queries will add the 'Add-Padding: true' header to the request which signals to the server to return a randomly padded response. See https://www.troyhunt.com/enhancing-pwned-passwords-privacy-with-padding for details.

    .PARAMETER NoModeQueryString
        If specified, HTTP based queries will not automatically add the mode=ntlm querystring parameter when NTLM hashes are checked.

    .EXAMPLE
        $secPass = Read-Host -Prompt 'Password' -AsSecureString
        PS C:\>Test-PwnedPassword $secPass

        Test a SecureString password against the official pwnedpasswords.com API.

    .EXAMPLE
        'pass1','pass2','pass3' | Test-PwnedPassword

        Test a set of passwords against the official pwnedpasswords.com API.

    .EXAMPLE
        $cred = Get-Credential
        PS C:\>Test-PwnedPassword $cred -ApiRoot 'http://internal.example.com/range/' -HashType 'NTLM'

        Test a PSCredential's password against an internal NTLM Pwned Passwords API endpoint.

    .LINK
        Test-PwnedHash

    .LINK
        https://haveibeenpwned.com/API/v3#PwnedPasswords

    .LINK
        https://new.blog.cloudflare.com/validating-leaked-passwords-with-k-anonymity/

    #>
}
