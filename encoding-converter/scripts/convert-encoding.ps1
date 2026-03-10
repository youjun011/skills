<#
.SYNOPSIS
    Convert file encodings in batch
.DESCRIPTION
    Convert files from one encoding to another, supporting GBK, UTF-8, UTF-8 BOM, etc.
.PARAMETER Path
    Directory path to process
.PARAMETER FromEncoding
    Source encoding: GBK, UTF8, UTF8BOM, UTF16, ASCII (default: GBK)
.PARAMETER ToEncoding
    Target encoding: UTF8, UTF8BOM, GBK, UTF16 (default: UTF8)
.PARAMETER Extensions
    File extensions to process, comma-separated (default: cpp,h)
.PARAMETER Recurse
    Process subdirectories recursively
.EXAMPLE
    .\convert-encoding.ps1 -Path "plugin" -FromEncoding GBK -ToEncoding UTF8
.EXAMPLE
    .\convert-encoding.ps1 -Path "src" -Extensions "cpp,h,hpp,c" -Recurse
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Path,
    
    [ValidateSet("GBK", "UTF8", "UTF8BOM", "UTF16", "ASCII")]
    [string]$FromEncoding = "GBK",
    
    [ValidateSet("UTF8", "UTF8BOM", "GBK", "UTF16")]
    [string]$ToEncoding = "UTF8",
    
    [string]$Extensions = "cpp,h",
    
    [switch]$Recurse
)

# Map encoding names to PowerShell encoding objects
function Get-Encoding($name) {
    switch ($name) {
        "GBK"      { return [System.Text.Encoding]::GetEncoding("GBK") }
        "UTF8"     { return New-Object System.Text.UTF8Encoding $False }
        "UTF8BOM"  { return New-Object System.Text.UTF8Encoding $True }
        "UTF16"    { return [System.Text.Encoding]::Unicode }
        "ASCII"    { return [System.Text.Encoding]::ASCII }
        default    { return [System.Text.Encoding]::GetEncoding($name) }
    }
}

# Get PowerShell -Encoding parameter value for reading
function Get-ReadEncoding($name) {
    switch ($name) {
        "GBK"      { return "Default" }
        "UTF8"     { return "UTF8" }
        "UTF8BOM"  { return "UTF8" }
        "UTF16"    { return "Unicode" }
        "ASCII"    { return "ASCII" }
        default    { return "Default" }
    }
}

# Build extension filter
$extArray = $Extensions -split "," | ForEach-Object { "*.$($_.Trim())" }

# Get files
if ($Recurse) {
    $files = Get-ChildItem -Path $Path -Include $extArray -Recurse
} else {
    $files = Get-ChildItem -Path $Path -Include $extArray -File
}

if ($files.Count -eq 0) {
    Write-Host "No files found matching extensions: $Extensions" -ForegroundColor Yellow
    exit 0
}

# Get encodings
$readEncoding = Get-ReadEncoding $FromEncoding
$writeEncoding = Get-Encoding $ToEncoding

Write-Host "Converting $($files.Count) files from $FromEncoding to $ToEncoding..." -ForegroundColor Cyan
Write-Host ""

$successCount = 0
$errorCount = 0

foreach ($file in $files) {
    try {
        $content = Get-Content -Path $file.FullName -Encoding $readEncoding -Raw
        [System.IO.File]::WriteAllText($file.FullName, $content, $writeEncoding)
        Write-Host "  [OK] $($file.Name)" -ForegroundColor Green
        $successCount++
    }
    catch {
        Write-Host "  [ERROR] $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
        $errorCount++
    }
}

Write-Host ""
Write-Host "Conversion complete: $successCount succeeded, $errorCount failed" -ForegroundColor Cyan
