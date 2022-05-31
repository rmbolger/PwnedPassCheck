function Get-NTLMHash {
    [CmdletBinding()]
    [OutputType([string],[byte[]])]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [ValidateScript({Test-ValidPassObject $_ -ThrowOnFail})]
        [object]$InputObject,
        [switch]$AsBytes
    )

    # Adapted From:
    #   https://github.com/LarrysGIT/MD4-powershell
    #   https://tools.ietf.org/html/rfc1320
    #
    # "NT Hash" is basically an MD4 hash of the UTF16-LE encoded password bytes
    # System.Text.Encoding.Unicode = UTF16-LE
    #
    # Example:
    #   Get-NTLMHash 'hello'           # 066DDFD4EF0E9CD7C256FE77191EF43C
    #   'password' | Get-NTLMHash      # 8846F7EAEE8FB117AD06BDD830B7586C

    Begin {

        # Basic MD4 functions (F, G, H)
        function fF([uint32]$X, [uint32]$Y, [uint32]$Z)
        {
            (($X -band $Y) -bor ((-bnot $X) -band $Z))
        }
        function fG ([uint32]$X, [uint32]$Y, [uint32]$Z)
        {
            (($X -band $Y) -bor ($X -band $Z) -bor ($Y -band $Z))
        }
        function fH ([uint32]$X, [uint32]$Y, [uint32]$Z)
        {
            ($X -bxor $Y -bxor $Z)
        }

        # Rotate Bits Left
        function ROL ([UInt32]$val, [Int32]$bits)
        {
            ($val -shl $bits) -bor ($val -shr (32 - $bits))
        }

        $R2Val = 0x5A827999
        $R3Val = 0x6ED9EBA1

    }

    Process {

        if ($InputObject -is [string]) {
            $BytesToHash = [Text.Encoding]::Unicode.GetBytes($InputObject)
        }
        elseif ($InputObject -is [securestring]) {
            $secPlain = (New-Object PSCredential "user",$InputObject).GetNetworkCredential().Password
            $BytesToHash = [Text.Encoding]::Unicode.GetBytes($secPlain)
        }
        elseif ($InputObject -is [pscredential]) {
            $secPlain = $InputObject.GetNetworkCredential().Password
            $BytesToHash = [Text.Encoding]::Unicode.GetBytes($secPlain)
        }

        # padding 100000*** to length 448, last (64 bits / 8) 8 bytes fill with original length
        # at least one (512 bits / 8) 64 bytes array
        $M = New-Object Byte[] (([math]::Floor($BytesToHash.Count/64) + 1) * 64)
        # copy original byte array, start from index 0
        $BytesToHash.CopyTo($M, 0)
        # padding bits 1000 0000
        $M[$BytesToHash.Count] = 0x80
        # padding bits 0000 0000 to fill length (448 bits /8) 56 bytes
        # Default value is 0 when creating a new byte array, so, no action
        # padding message length to the last 64 bits
        @([BitConverter]::GetBytes($BytesToHash.Count * 8)).CopyTo($M, $M.Count - 8)

        # message digest buffer (A,B,C,D)
        $A = [UInt32]'0x67452301'
        $B = [UInt32]'0xefcdab89'
        $C = [UInt32]'0x98badcfe'
        $D = [UInt32]'0x10325476'

        # processing message in one-word blocks
        for($i = 0; $i -lt $M.Count; $i += 64)
        {
            # Save a copy of A/B/C/D
            $AA = $A
            $BB = $B
            $CC = $C
            $DD = $D

            # Round 1
            $A = (ROL (($A + (fF $B $C $D) + [BitConverter]::ToUInt32($M, ($i + 0))) -band [UInt32]::MaxValue) 3)
            $D = (ROL (($D + (fF $A $B $C) + [BitConverter]::ToUInt32($M, ($i + 4))) -band [UInt32]::MaxValue) 7)
            $C = (ROL (($C + (fF $D $A $B) + [BitConverter]::ToUInt32($M, ($i + 8))) -band [UInt32]::MaxValue) 11)
            $B = (ROL (($B + (fF $C $D $A) + [BitConverter]::ToUInt32($M, ($i + 12))) -band [UInt32]::MaxValue) 19)

            $A = (ROL (($A + (fF $B $C $D) + [BitConverter]::ToUInt32($M, ($i + 16))) -band [UInt32]::MaxValue) 3)
            $D = (ROL (($D + (fF $A $B $C) + [BitConverter]::ToUInt32($M, ($i + 20))) -band [UInt32]::MaxValue) 7)
            $C = (ROL (($C + (fF $D $A $B) + [BitConverter]::ToUInt32($M, ($i + 24))) -band [UInt32]::MaxValue) 11)
            $B = (ROL (($B + (fF $C $D $A) + [BitConverter]::ToUInt32($M, ($i + 28))) -band [UInt32]::MaxValue) 19)

            $A = (ROL (($A + (fF $B $C $D) + [BitConverter]::ToUInt32($M, ($i + 32))) -band [UInt32]::MaxValue) 3)
            $D = (ROL (($D + (fF $A $B $C) + [BitConverter]::ToUInt32($M, ($i + 36))) -band [UInt32]::MaxValue) 7)
            $C = (ROL (($C + (fF $D $A $B) + [BitConverter]::ToUInt32($M, ($i + 40))) -band [UInt32]::MaxValue) 11)
            $B = (ROL (($B + (fF $C $D $A) + [BitConverter]::ToUInt32($M, ($i + 44))) -band [UInt32]::MaxValue) 19)

            $A = (ROL (($A + (fF $B $C $D) + [BitConverter]::ToUInt32($M, ($i + 48))) -band [UInt32]::MaxValue) 3)
            $D = (ROL (($D + (fF $A $B $C) + [BitConverter]::ToUInt32($M, ($i + 52))) -band [UInt32]::MaxValue) 7)
            $C = (ROL (($C + (fF $D $A $B) + [BitConverter]::ToUInt32($M, ($i + 56))) -band [UInt32]::MaxValue) 11)
            $B = (ROL (($B + (fF $C $D $A) + [BitConverter]::ToUInt32($M, ($i + 60))) -band [UInt32]::MaxValue) 19)

            # Round 2
            $A = (ROL (($A + (fG $B $C $D) + [BitConverter]::ToUInt32($M, ($i + 0)) + $R2Val) -band [UInt32]::MaxValue) 3)
            $D = (ROL (($D + (fG $A $B $C) + [BitConverter]::ToUInt32($M, ($i + 16)) + $R2Val) -band [UInt32]::MaxValue) 5)
            $C = (ROL (($C + (fG $D $A $B) + [BitConverter]::ToUInt32($M, ($i + 32)) + $R2Val) -band [UInt32]::MaxValue) 9)
            $B = (ROL (($B + (fG $C $D $A) + [BitConverter]::ToUInt32($M, ($i + 48)) + $R2Val) -band [UInt32]::MaxValue) 13)

            $A = (ROL (($A + (fG $B $C $D) + [BitConverter]::ToUInt32($M, ($i + 4)) + $R2Val) -band [UInt32]::MaxValue) 3)
            $D = (ROL (($D + (fG $A $B $C) + [BitConverter]::ToUInt32($M, ($i + 20)) + $R2Val) -band [UInt32]::MaxValue) 5)
            $C = (ROL (($C + (fG $D $A $B) + [BitConverter]::ToUInt32($M, ($i + 36)) + $R2Val) -band [UInt32]::MaxValue) 9)
            $B = (ROL (($B + (fG $C $D $A) + [BitConverter]::ToUInt32($M, ($i + 52)) + $R2Val) -band [UInt32]::MaxValue) 13)

            $A = (ROL (($A + (fG $B $C $D) + [BitConverter]::ToUInt32($M, ($i + 8)) + $R2Val) -band [UInt32]::MaxValue) 3)
            $D = (ROL (($D + (fG $A $B $C) + [BitConverter]::ToUInt32($M, ($i + 24)) + $R2Val) -band [UInt32]::MaxValue) 5)
            $C = (ROL (($C + (fG $D $A $B) + [BitConverter]::ToUInt32($M, ($i + 40)) + $R2Val) -band [UInt32]::MaxValue) 9)
            $B = (ROL (($B + (fG $C $D $A) + [BitConverter]::ToUInt32($M, ($i + 56)) + $R2Val) -band [UInt32]::MaxValue) 13)

            $A = (ROL (($A + (fG $B $C $D) + [BitConverter]::ToUInt32($M, ($i + 12)) + $R2Val) -band [UInt32]::MaxValue) 3)
            $D = (ROL (($D + (fG $A $B $C) + [BitConverter]::ToUInt32($M, ($i + 28)) + $R2Val) -band [UInt32]::MaxValue) 5)
            $C = (ROL (($C + (fG $D $A $B) + [BitConverter]::ToUInt32($M, ($i + 44)) + $R2Val) -band [UInt32]::MaxValue) 9)
            $B = (ROL (($B + (fG $C $D $A) + [BitConverter]::ToUInt32($M, ($i + 60)) + $R2Val) -band [UInt32]::MaxValue) 13)

            # Round 3
            $A = (ROL (($A + (fH $B $C $D) + [BitConverter]::ToUInt32($M, ($i + 0)) + $R3Val) -band [UInt32]::MaxValue) 3)
            $D = (ROL (($D + (fH $A $B $C) + [BitConverter]::ToUInt32($M, ($i + 32)) + $R3Val) -band [UInt32]::MaxValue) 9)
            $C = (ROL (($C + (fH $D $A $B) + [BitConverter]::ToUInt32($M, ($i + 16)) + $R3Val) -band [UInt32]::MaxValue) 11)
            $B = (ROL (($B + (fH $C $D $A) + [BitConverter]::ToUInt32($M, ($i + 48)) + $R3Val) -band [UInt32]::MaxValue) 15)

            $A = (ROL (($A + (fH $B $C $D) + [BitConverter]::ToUInt32($M, ($i + 8)) + $R3Val) -band [UInt32]::MaxValue) 3)
            $D = (ROL (($D + (fH $A $B $C) + [BitConverter]::ToUInt32($M, ($i + 40)) + $R3Val) -band [UInt32]::MaxValue) 9)
            $C = (ROL (($C + (fH $D $A $B) + [BitConverter]::ToUInt32($M, ($i + 24)) + $R3Val) -band [UInt32]::MaxValue) 11)
            $B = (ROL (($B + (fH $C $D $A) + [BitConverter]::ToUInt32($M, ($i + 56)) + $R3Val) -band [UInt32]::MaxValue) 15)

            $A = (ROL (($A + (fH $B $C $D) + [BitConverter]::ToUInt32($M, ($i + 4)) + $R3Val) -band [UInt32]::MaxValue) 3)
            $D = (ROL (($D + (fH $A $B $C) + [BitConverter]::ToUInt32($M, ($i + 36)) + $R3Val) -band [UInt32]::MaxValue) 9)
            $C = (ROL (($C + (fH $D $A $B) + [BitConverter]::ToUInt32($M, ($i + 20)) + $R3Val) -band [UInt32]::MaxValue) 11)
            $B = (ROL (($B + (fH $C $D $A) + [BitConverter]::ToUInt32($M, ($i + 52)) + $R3Val) -band [UInt32]::MaxValue) 15)

            $A = (ROL (($A + (fH $B $C $D) + [BitConverter]::ToUInt32($M, ($i + 12)) + $R3Val) -band [UInt32]::MaxValue) 3)
            $D = (ROL (($D + (fH $A $B $C) + [BitConverter]::ToUInt32($M, ($i + 44)) + $R3Val) -band [UInt32]::MaxValue) 9)
            $C = (ROL (($C + (fH $D $A $B) + [BitConverter]::ToUInt32($M, ($i + 28)) + $R3Val) -band [UInt32]::MaxValue) 11)
            $B = (ROL (($B + (fH $C $D $A) + [BitConverter]::ToUInt32($M, ($i + 60)) + $R3Val) -band [UInt32]::MaxValue) 15)

            # Increment
            $A = ($A + $AA) -band [UInt32]::MaxValue
            $B = ($B + $BB) -band [UInt32]::MaxValue
            $C = ($C + $CC) -band [UInt32]::MaxValue
            $D = ($D + $DD) -band [UInt32]::MaxValue

        }

        # Output
        $A = ('{0:x8}' -f $A) -ireplace '^(\w{2})(\w{2})(\w{2})(\w{2})$', '$4$3$2$1'
        $B = ('{0:x8}' -f $B) -ireplace '^(\w{2})(\w{2})(\w{2})(\w{2})$', '$4$3$2$1'
        $C = ('{0:x8}' -f $C) -ireplace '^(\w{2})(\w{2})(\w{2})(\w{2})$', '$4$3$2$1'
        $D = ('{0:x8}' -f $D) -ireplace '^(\w{2})(\w{2})(\w{2})(\w{2})$', '$4$3$2$1'

        if ($AsBytes) {
            return (Convert-HexToByteArray "$A$B$C$D")
        } else {
            return "$A$B$C$D".ToUpper()
        }

    }

    <#
    .SYNOPSIS
        Returns an NTLM hash for the specified String, SecureString, or PSCredential password.

    .DESCRIPTION
        NTLM hashes are generally used with Windows and are basically just an MD4 hash of a string encoded as UTF16 Little Endian.

        This function will accept a standard String, SecureString, or PSCredential as input.

    .PARAMETER InputObject
        A String, SecureString, or PSCredential object to hash. The username on a PSCredential object is ignored.

    .PARAMETER AsBytes
        If specified, the hash will be returned as a byte array instead of a string.

    .EXAMPLE
        Get-NTLMHash 'password'

        Get the NTLM hash for 'password'.

    .EXAMPLE
        $secString = Read-Host -Prompt 'Secret' -AsSecureSTring
        PS C:\>Get-NTLMHash $secString

        Get the NTLM hash for the specified SecureString.

    .EXAMPLE
        $cred = Get-Credential
        PS C:\>Get-NTLMHash $cred

        Get the NTLM hash for the specified credential.

    .EXAMPLE
        $hashBytes = Get-NTLMHash 'password' -AsBytes

        Get the NTLM hash as a byte array for 'password'.

    .LINK
        Get-SHA1Hash

    #>
}
