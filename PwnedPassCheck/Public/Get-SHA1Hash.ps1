function Get-SHA1Hash {
    [CmdletBinding()]
    [OutputType([string],[byte[]])]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [ValidateScript({Test-ValidPassObject $_ -ThrowOnFail})]
        [object]$InputObject,
        [switch]$AsBytes
    )

    Begin {
        $sha1 = New-Object Security.Cryptography.SHA1CryptoServiceProvider
    }

    Process {

        if ($InputObject -is [string]) {
            $BytesToHash = [Text.Encoding]::UTF8.GetBytes($InputObject)
        }
        elseif ($InputObject -is [securestring]) {
            # TODO: Investigate if there are more secure ways to go directly from a SecureString to byte array
            $secPlain = (New-Object PSCredential "user",$InputObject).GetNetworkCredential().Password
            $BytesToHash = [Text.Encoding]::UTF8.GetBytes($secPlain)
        }
        elseif ($InputObject -is [pscredential]) {
            $secPlain = $InputObject.GetNetworkCredential().Password
            $BytesToHash = [Text.Encoding]::UTF8.GetBytes($secPlain)
        }

        # hash it
        $hash = $sha1.ComputeHash($BytesToHash)

        if ($AsBytes) {
            return $hash
        } else {
            # stringify the hash and return it
            [BitConverter]::ToString($hash).Replace('-','')
        }

    }

    End {
        if ($null -ne $sha1) {
            $sha1.Dispose()
        }
    }

    <#
    .SYNOPSIS
        Returns a SHA1 hash for the specified String, SecureString, or PSCredential password.

    .DESCRIPTION
        This function is just a light wrapper around the Security.Cryptography.SHA1CryptoServiceProvider class. String inputs are encoded as UTF8 and then hashed.

    .PARAMETER InputObject
        A String, SecureString, or PSCredential object to hash. The username on a PSCredential object is ignored.

    .PARAMETER AsBytes
        If specified, the hash will be returned as a byte array instead of a string.

    .EXAMPLE
        Get-SHA1Hash 'password'

        Get the SHA1 hash for 'password'.

    .EXAMPLE
        $secString = Read-Host -Prompt 'Secret' -AsSecureSTring
        PS C:\>Get-SHA1Hash $secString

        Get the SHA1 hash for the specified SecureString.

    .EXAMPLE
        $cred = Get-Credential
        PS C:\>Get-SHA1Hash $cred

        Get the SHA1 hash for the specified credential.

    .EXAMPLE
        $hashBytes = Get-SHA1Hash 'password' -AsBytes

        Get the SHA1 hash as a byte array for 'password'.

    .LINK
        Get-NTLMHash

    #>
}
