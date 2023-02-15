function Test-PwnedHashBytes {
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('NTHash')]
        [byte[]]$HashBytes,
        [ValidateNotNullOrEmpty()]
        [string]$ApiRoot = "https://api.pwnedpasswords.com/range/",
        [switch]$RequestPadding
    )

    Begin {
        $padding = @{}
        if ($RequestPadding) { $padding.RequestPadding = $true }
    }

    Process
    {
        trap { $PSCmdlet.ThrowTerminatingError($PSItem) }

        # validate the length of the byte array here since we can't do it in ValidateScript
        # due to this oddity:
        # https://github.com/PowerShell/PowerShell/issues/6185
        if ($HashBytes.Length -ne 16 -and $HashBytes.Length -ne 20) {
            throw "HashBytes has an invalid length for SHA1 and NTLM."
        }

        # convert it to a hex string for submission
        $PasswordHash = [BitConverter]::ToString($HashBytes).Replace('-','')
        Write-Verbose "Converted hash bytes to $PasswordHash"

        # Check the hash
        $result = Get-PwnedHash $PasswordHash -ApiRoot $ApiRoot @padding

        if ($result.SeenCount -gt 0) {
            return $true
        } else {
            return $false
        }
    }

    <#
    .SYNOPSIS
        Checks a SHA1 or NTLM hash byte array against a haveibeenpwned.com compatible Pwned Passwords API endpoint and returns True if the seen count is greater than zero.

    .DESCRIPTION
        The Pwned Passwords API is a way to check a password hash against a list of more than half a billion passwords which have been previously exposed in data breaches. The API implements a k-Anonymity model that allows a password to be searched for by partial hash. This means your full password hash never leaves your machine and ensures your privacy.

        This function will check the specified hash against the API and return True if it has been seen in at least one data breach.

        TO BE CLEAR, only the first 5 characters of the password hash are submitted to the API. See https://haveibeenpwned.com/API/v3#PwnedPasswords for more detail.

    .PARAMETER HashBytes
        A byte array hash value. An error will be thrown if the byte array has a length other than 16 (NTLM) or 20 (SHA1).

    .PARAMETER ApiRoot
        If specified, overrides the default pwnedpasswords.com API URL. URLs or filesystem paths can both be used as an alternative. The URL\Path should include everything preceding the 5 character hash prefix (e.g. 'https://example.com/range/' or 'C:\temp\').

    .PARAMETER RequestPadding
        If specified, HTTP based queries will add the 'Add-Padding: true' header to the request which signals to the server to return a randomly padded response. See https://www.troyhunt.com/enhancing-pwned-passwords-privacy-with-padding for details.

    .EXAMPLE
        $hashBytes = Get-SHA1Hash 'password' -AsBytes
        PS C:\>Test-PwnedHashBytes $hashBytes

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
