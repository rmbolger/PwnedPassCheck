#Requires -Version 3.0

# Get public and private function definition files.
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

# Dot source the files
foreach ($import in @($Public + $Private))
{
    try { . $import.fullname }
    catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

$script:USER_AGENT = "PwnedPassCheck/1.0.0 PowerShell/$($PSVersionTable.PSVersion)"

# Invoke-WebRequest and Invoke-RestMethod on PowerShell 5.1 both use
# IE's DOM parser by default which gives you some nice things that we
# don't use like html/form parsing. The problem is that it can generate
# errors if IE is not installed or hasn't gone through the first-run
# sequence in a new profile. Fortunately, there's a -UseBasicParsing switch
# on both functions that uses a PowerShell native parser instead and avoids
# those problems. In PowerShell Core 6, the parameter has been deprecated
# because there is no IE DOM parser to use and all requests use the native
# parser by default. In order to future proof ourselves for the switch's
# eventual removal, we'll set it only if it actually exists in this
# environment.
$script:UseBasic = @{}
if ('UseBasicParsing' -in (Get-Command Invoke-WebRequest).Parameters.Keys) {
    $script:UseBasic.UseBasicParsing = $true
}

if ('SslProtocol' -notin (Get-Command Invoke-RestMethod).Parameters.Keys) {
    # make sure we have recent TLS versions enabled for Desktop edition
    $currentMaxTls = [Math]::Max([Net.ServicePointManager]::SecurityProtocol.value__,[Net.SecurityProtocolType]::Tls.value__)
    $newTlsTypes = [enum]::GetValues('Net.SecurityProtocolType') | Where-Object { $_ -gt $currentMaxTls }
    $newTlsTypes | ForEach-Object {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor $_
    }
}
