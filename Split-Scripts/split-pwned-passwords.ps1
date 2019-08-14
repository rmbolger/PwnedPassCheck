[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$FilePath,
    [string]$OutputFolder = '.\range'
)

# expand relative paths
$FilePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($FilePath)
$OutputFolder = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputFolder)

# validate the input file
if (-not (Test-Path $FilePath -PathType Leaf)) {
    throw "File not found: $FilePath"
}

# create the output folder if it doesn't exist
New-Item -ItemType Directory -Force -Path $OutputFolder | Out-Null

$lastPrefix = [String]::Empty
$curContents = [String]::Empty

# loop through the file
foreach ($line in [IO.File]::ReadLines($FilePath, [Text.Encoding]::ASCII)) {

    # skip malformed lines
    if ($line.Length -lt 33) { continue; }

    $prefix = $line.Substring(0,5)
    $suffix = $line.Substring(5)

    # check for new prefix
    if ($prefix -ne $lastPrefix) {

        # write out previous file
        if ($curContents -ne [String]::Empty) {
            $curContents | Out-File (Join-Path $OutputFolder $lastPrefix) -Encoding ASCII -Force
        }

        # start buffering next file
        Write-Host $prefix
        $curContents = $suffix
    }
    else {
        # add to next file buffer
        $curContents += [Environment]::NewLine + $suffix
    }

    # update last prefix
    $lastPrefix = $prefix
}

# write out last file
$curContents | Out-File (Join-Path $OutputFolder $prefix) -Encoding ASCII -Force
Write-Host $prefix
