# PwnedPassCheck

An easy way to check passwords and password hashes against the haveibeenpwned.com Pwned Passwords API or compatible equivalent.

# Install

The [latest release version](https://www.powershellgallery.com/packages/PwnedPassCheck) can found in the PowerShell Gallery or the [GitHub releases page](https://github.com/rmbolger/PwnedPassCheck/releases). Installing from the gallery is easiest using `Install-Module` from the PowerShellGet module. See [Installing PowerShellGet](https://docs.microsoft.com/en-us/powershell/gallery/installing-psget) if you don't already have it installed.

```powershell
# install for all users (requires elevated privs)
Install-Module -Name PwnedPassCheck

# install for current user
Install-Module -Name PwnedPassCheck -Scope CurrentUser
```

To install the latest *development* version from the git master branch, use the following command. This method assumes a default Windows PowerShell environment that includes the [`PSModulePath`](https://msdn.microsoft.com/en-us/library/dd878326.aspx) environment variable which contains a reference to `$HOME\Documents\WindowsPowerShell\Modules`. You must also make sure `Get-ExecutionPolicy` is not set to `Restricted` or `AllSigned`.

```powershell
# (optional) set less restrictive execution policy
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# install latest dev version
iex (irm https://raw.githubusercontent.com/rmbolger/PwnedPassCheck/master/instdev.ps1)
```


# Quick Start

**TODO**

# Requirements and Platform Support

* Supports Windows PowerShell 3.0 or later (a.k.a. Desktop edition).
* Supports [Powershell Core](https://github.com/PowerShell/PowerShell) 6.0 or later (a.k.a. Core edition) on all supported OS platforms.

# Changelog

See [CHANGELOG.md](/CHANGELOG.md)
