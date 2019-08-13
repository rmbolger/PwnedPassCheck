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

# Define common parameters for Invoke-WebRequest
$script:IWR_PARAMS = @{
    UserAgent = "PwnedPassCheck/1.1.0 PowerShell/$($PSVersionTable.PSVersion)"
}

# Invoke-WebRequest in Windows PowerShell uses IE's DOM parser by default which
# can cause errors if IE is not installed or hasn't gone through the first-run
# sequence in a new profile. The -UseBasicParsing switch makes it use a PowerShell
# native parser instead and avoids those problems. In PowerShell Core 6+, the
# parameter has been deprecated because there is no IE DOM parser to use and all
# requests use the native parser by default. In order to future proof ourselves
# for the switch's eventual removal, we'll set it only if it actually exists.
if ('UseBasicParsing' -in (Get-Command Invoke-WebRequest).Parameters.Keys) {
    $script:IWR_PARAMS.UseBasicParsing = $true
}

if ('SslProtocol' -notin (Get-Command Invoke-WebRequest).Parameters.Keys) {
    # make sure we have recent TLS versions enabled for Desktop edition
    $currentMaxTls = [Math]::Max([Net.ServicePointManager]::SecurityProtocol.value__,[Net.SecurityProtocolType]::Tls.value__)
    $newTlsTypes = [enum]::GetValues('Net.SecurityProtocolType') | Where-Object { $_ -gt $currentMaxTls }
    $newTlsTypes | ForEach-Object {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor $_
    }
}
