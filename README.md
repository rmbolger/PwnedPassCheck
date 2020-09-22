# PwnedPassCheck

Check passwords and hashes against the [haveibeenpwned.com](https://haveibeenpwned.com) [Pwned Passwords API](https://haveibeenpwned.com/API/v3#PwnedPasswords) using PowerShell. Also supports third party equivalent APIs.

# Background

The Pwned Passwords portion of Troy Hunt's [Have I Been Pwned](https://haveibeenpwned.com) site is a collection of over half a billion passwords compiled from various data breaches over the years. It's both downloadable and searchable via a free API. This module makes it easy to check existing passwords or hashes against the API to see whether they've been compromised and how many times they've been seen in breaches.

The beauty of the API design is that it implements a [k-Anonymity](https://new.blog.cloudflare.com/validating-leaked-passwords-with-k-anonymity/) model which ensures that neither your password or full hash is ever sent to the API server. Only the first 5 characters of the hash are sent and the server returns a list of compromised hashes starting with that prefix. The client then compares the returned list against the full hash locally to see if it was compromised.

**TO REITERATE:** All passwords are hashed locally and only the first 5 characters of a hash are sent to the API which makes it impossible for API server owners to know, log, or crack your password hashes.

# Install

## Release

The [latest release version](https://www.powershellgallery.com/packages/PwnedPassCheck) can found in the PowerShell Gallery or the [GitHub releases page](https://github.com/rmbolger/PwnedPassCheck/releases). Installing from the gallery is easiest using `Install-Module` from the PowerShellGet module. See [Installing PowerShellGet](https://docs.microsoft.com/en-us/powershell/gallery/installing-psget) if you don't already have it installed.

```powershell
# install for all users (requires elevated privs)
Install-Module -Name PwnedPassCheck

# install for current user
Install-Module -Name PwnedPassCheck -Scope CurrentUser
```

## Development

To install the latest *development* version from the git main branch, use the following command.

```powershell
# (optional) set less restrictive execution policy
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# install latest dev version
iex (irm https://raw.githubusercontent.com/rmbolger/PwnedPassCheck/main/instdev.ps1)
```


# Quick Start

The easiest function to start with is `Test-PwnedPassword`. You can supply a plaintext password to it as either a String, SecureString, or PSCredential object.

```powershell
# Using a regular string like this is super easy, but not recommended for
# real passwords because it can be saved in your command history
Test-PwnedPassword 'password'

# Instead, use Read-Host to interactively collect the password as a SecureString
$secPass = Read-Host -AsSecureString -Prompt 'Enter Password'
Test-PwnedPassword $secPass

# You can do the same thing with a PSCredential (Username is ignored)
$credential = Get-Credential
Test-PwnedPassword $credential
```

If you want to bulk test passwords, just pass them all in via the pipeline like this.

```powershell
'password',$secPass,$credential | Test-PwnedPassword
```

If you have existing hashes to check, you can use `Test-PwnedHash`. However, the official API only supports SHA1 hashes.

```powershell
$hash = '70CCD9007338D6D81DD3B6271621B9CF9A97EA00' # SHA1 hash of "Password1"
Test-PwnedHash $hash
```

Because the Pwned Password data is freely downloadable, it's possible to setup your own local copy of the API or use one hosted by a third party. Use the `ApiRoot` parameter to override the default API URL you test against.

```powershell
Test-PwnedPassword 'password' -ApiRoot 'https://pwnpass.example.com/range/'
```

In addition to the SHA1 hashed copy of the data, an NTLM hashed copy is available. This can be incredibly useful for auditing passwords in an Active Directory environment. If you are testing against an NTLM version of the API, use the `HashType` parameter to make sure the function calculates the correct hash value.

```powershell
Test-PwnedPassword 'password' -HashType 'NTLM' -ApiRoot 'https://pwnntlm.example.com/range/'
```


# Requirements and Platform Support

* Supports Windows PowerShell 3.0 or later (a.k.a. Desktop edition).
* Supports [Powershell Core](https://github.com/PowerShell/PowerShell) 6.0 or later (a.k.a. Core edition) on all supported OS platforms.

# Changelog

See [CHANGELOG.md](/CHANGELOG.md)
