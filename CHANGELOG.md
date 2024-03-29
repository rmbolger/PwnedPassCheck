## 3.0.0 (2023-02-14)

* Slightly better error handling.

### Breaking Changes

* Added support for the `mode=ntlm` querystring parameter which is automatically added to HTTP based queries that are using an NTLM hash. It you need to disable this functionality, use the `-NoModeQueryString` switch.

## 2.0.0 (2020-02-17)

### Breaking Changes

* To better adhere to PowerShell naming standards, `Test-PwnedPassword`, `Test-PwnedHash`, and `Test-PwnedHashBytes` have been renamed to `Get-PwnedPassword`, `Get-PwnedHash`, and `Get-PwnedHashBytes` respectively.
* New versions of `Test-PwnedPassword`, `Test-PwnedHash`, and `Test-PwnedHashBytes` have been added that return a simple boolean value to indicate whether the password/hash was seen in a breach or not.
* The Label property is no longer added to results unless it is requested.

## 1.2.0 (2020-11-01)

* Added `-RequestPadding` switch to all of the primary functions which adds an HTTP header to web based queries that signals the web server to randomly pad responses for additional anonymity. See https://www.troyhunt.com/enhancing-pwned-passwords-privacy-with-padding for details.

## 1.1.0 (2019-08-13)

* Added Test-PwnedHashBytes which takes a byte array instead of a hex string hash.
* Added -Label parameter to Test-PwnedHash and Test-PwnedHashBytes which will show as an additional output column to help distinguish the hashes in the result.
* The -ApiRoot param in all Test-* functions will now accept filesystem or UNC paths in addition to web URLs.
* The -ApiRoot param now validates against null/empty values
* Added -AsBytes switch to Get-SHA1Hash and Get-NTLMHash to return the hash as a byte array.

## 1.0.0 (2019-08-11)

* Initial Release
* Added functions
  * Test-PwnedPassword
  * Test-PwnedHash
  * Get-SHA1Hash
  * Get-NTLMHash
