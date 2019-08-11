@{

RootModule = 'PwnedPassCheck.psm1'
ModuleVersion = '1.0.0'
GUID = 'f33d7d9c-2dc0-4bd4-a80a-557bc46bfe8c'
Author = 'Ryan Bolger'
Copyright = '(c) 2019 Ryan Bolger. All rights reserved.'
Description = 'Check passwords and hashes against the haveibeenpwned.com Pwned Passwords API. Also supports third party equivalent APIs.'
PowerShellVersion = '3.0'

FunctionsToExport = @(
    'Get-NTLMHash'
    'Get-SHA1Hash'
    'Test-PwnedHash'
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
        LicenseUri = 'https://github.com/rmbolger/PwnedPassCheck/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/rmbolger/PwnedPassCheck'

        # ReleaseNotes of this module
        ReleaseNotes = @'
## 1.0.0 (2019-08-11)

* Initial Release
* Added functions
  * Test-PwnedPassword
  * Test-PwnedHash
  * Get-SHA1Hash
  * Get-NTLMHash
'@

    } # End of PSData hashtable

} # End of PrivateData hashtable

}
