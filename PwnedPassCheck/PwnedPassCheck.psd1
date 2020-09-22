@{

RootModule = 'PwnedPassCheck.psm1'
ModuleVersion = '1.1.0'
GUID = 'f33d7d9c-2dc0-4bd4-a80a-557bc46bfe8c'
Author = 'Ryan Bolger'
Copyright = '(c) 2019 Ryan Bolger. All rights reserved.'
Description = 'Check passwords and hashes against the haveibeenpwned.com Pwned Passwords API. Also supports third party equivalent APIs.'
PowerShellVersion = '3.0'

FunctionsToExport = @(
    'Get-NTLMHash'
    'Get-SHA1Hash'
    'Test-PwnedHash'
    'Test-PwnedHashBytes'
    'Test-PwnedPassword'
)

CmdletsToExport = @()
VariablesToExport = @()
AliasesToExport = @()

PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'Security','HIBP','HaveIBeenPwned','InfoSec','PSEdition_Desktop','PSEdition_Core','Linux','Mac'

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/rmbolger/PwnedPassCheck/blob/main/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/rmbolger/PwnedPassCheck'

        # ReleaseNotes of this module
        ReleaseNotes = @'
## 1.1.0 (2019-08-13)

* Added Test-PwnedHashBytes which takes a byte array instead of a hex string hash.
* Added -Label parameter to Test-PwnedHash and Test-PwnedHashBytes which will show as an additional output column to help distinguish the hashes in the result.
* The -ApiRoot param in all Test-* functions will now accept filesystem or UNC paths in addition to web URLs.
* The -ApiRoot param now validates against null/empty values
* Added -AsBytes switch to Get-SHA1Hash and Get-NTLMHash to return the hash as a byte array.
'@

    } # End of PSData hashtable

} # End of PrivateData hashtable

}
