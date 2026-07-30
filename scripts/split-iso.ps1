param(
    [string]$SourceIso = "E:\pragmata\PRAGMATA-voices38\voices38-pragmata.iso",
    [string]$OutputDir = "E:\pragmata\PRAGMATA-voices38\voices38-pragmata-pages\release-parts",
    [int64]$PartSizeBytes = 1992294400
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $SourceIso)) {
    throw "Source ISO not found: $SourceIso"
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$sourceItem = Get-Item -LiteralPath $SourceIso
$baseName = $sourceItem.Name
$partPrefix = Join-Path $OutputDir "$baseName.part"
$bufferSize = 8MB
$buffer = New-Object byte[] $bufferSize
$partIndex = 1
$totalWritten = 0L

Write-Host "Source: $SourceIso"
Write-Host "Size:   $($sourceItem.Length) bytes"
Write-Host "Output: $OutputDir"

$inputStream = [System.IO.File]::OpenRead($SourceIso)
try {
    while ($inputStream.Position -lt $inputStream.Length) {
        $partPath = "{0}{1:D3}" -f $partPrefix, $partIndex
        $remainingInPart = $PartSizeBytes
        $outputStream = [System.IO.File]::Create($partPath)
        try {
            while ($remainingInPart -gt 0 -and $inputStream.Position -lt $inputStream.Length) {
                $readSize = [Math]::Min($buffer.Length, $remainingInPart)
                $bytesRead = $inputStream.Read($buffer, 0, [int]$readSize)
                if ($bytesRead -le 0) {
                    break
                }
                $outputStream.Write($buffer, 0, $bytesRead)
                $remainingInPart -= $bytesRead
                $totalWritten += $bytesRead
            }
        }
        finally {
            $outputStream.Dispose()
        }

        Write-Host ("Created {0} ({1:n0} bytes)" -f $partPath, (Get-Item -LiteralPath $partPath).Length)
        $partIndex++
    }
}
finally {
    $inputStream.Dispose()
}

$manifestPath = Join-Path $OutputDir "SHA256SUMS.txt"
Remove-Item -LiteralPath $manifestPath -ErrorAction SilentlyContinue

Get-ChildItem -LiteralPath $OutputDir -Filter "$baseName.part*" |
    Sort-Object Name |
    ForEach-Object {
        $hash = Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256
        "{0}  {1}" -f $hash.Hash.ToLowerInvariant(), $_.Name
    } |
    Set-Content -LiteralPath $manifestPath -Encoding ascii

$isoHash = Get-FileHash -LiteralPath $SourceIso -Algorithm SHA256
Add-Content -LiteralPath $manifestPath -Encoding ascii -Value ("{0}  {1}" -f $isoHash.Hash.ToLowerInvariant(), $baseName)

Write-Host "Manifest: $manifestPath"
Write-Host ("Done. Wrote {0:n0} bytes in {1} part(s)." -f $totalWritten, ($partIndex - 1))

