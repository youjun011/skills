---
name: encoding-converter
description: Convert file encodings between GBK, UTF-8, UTF-8 BOM, and other encodings. Use when dealing with file encoding issues, garbled characters, or when the user mentions encoding conversion, GBK to UTF-8, or needs to fix encoding problems in source files.
---

# File Encoding Converter

Convert file encodings to resolve compilation issues caused by mixed encodings in a project.

## Supported Encodings

| Encoding | PowerShell Name | Description |
|----------|-----------------|-------------|
| UTF-8 (no BOM) | `utf8` | Recommended for cross-platform projects |
| UTF-8 with BOM | `utf8BOM` | Windows default, may cause issues |
| GBK/GB2312 | `Default` | Chinese Windows legacy encoding |
| UTF-16 LE | `unicode` | Windows Unicode |

## Quick Start

### Convert Single File

```powershell
# GBK to UTF-8 (no BOM)
$content = Get-Content -Path "file.cpp" -Encoding Default -Raw
$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("file.cpp", $content, $utf8NoBom)
```

### Batch Convert Directory

```powershell
$files = Get-ChildItem -Path "path/to/dir" -Include *.cpp,*.h -Recurse
foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Encoding Default -Raw
    $utf8NoBom = New-Object System.Text.UTF8Encoding $False
    [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
    Write-Host "Converted: $($file.Name)"
}
```

## Encoding Parameters Reference

When using `Get-Content`, use these `-Encoding` values:

| From Encoding | Parameter Value |
|---------------|-----------------|
| GBK/GB2312 (Chinese) | `Default` |
| UTF-8 | `UTF8` |
| UTF-8 BOM | `UTF8` |
| UTF-16 LE | `Unicode` |
| UTF-16 BE | `BigEndianUnicode` |
| ASCII | `ASCII` |

When writing files with specific encodings:

| To Encoding | Method |
|-------------|--------|
| UTF-8 no BOM | `New-Object System.Text.UTF8Encoding $False` |
| UTF-8 with BOM | `New-Object System.Text.UTF8Encoding $True` |
| GBK | `[System.Text.Encoding]::GetEncoding("GBK")` |

## Common Workflows

### Scenario 1: Fix Mixed Encoding in Qt/C++ Project

Plugin files are GBK, main project is UTF-8, causing compilation errors:

```powershell
$files = Get-ChildItem -Path "plugin" -Include *.cpp,*.h -Recurse
foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Encoding Default -Raw
    $utf8NoBom = New-Object System.Text.UTF8Encoding $False
    [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
    Write-Host "Converted: $($file.Name)"
}
```

### Scenario 2: Add BOM to UTF-8 Files

Some editors require BOM:

```powershell
$files = Get-ChildItem -Path "src" -Include *.cpp,*.h -Recurse
foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Encoding UTF8 -Raw
    $utf8Bom = New-Object System.Text.UTF8Encoding $True
    [System.IO.File]::WriteAllText($file.FullName, $content, $utf8Bom)
    Write-Host "Added BOM: $($file.Name)"
}
```

### Scenario 3: Convert UTF-8 to GBK

For legacy systems requiring GBK:

```powershell
$files = Get-ChildItem -Path "legacy" -Include *.cpp,*.h -Recurse
$gbk = [System.Text.Encoding]::GetEncoding("GBK")
foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Encoding UTF8 -Raw
    [System.IO.File]::WriteAllText($file.FullName, $content, $gbk)
    Write-Host "Converted to GBK: $($file.Name)"
}
```

## Utility Script

For convenience, use the provided script:

```powershell
# Convert all .cpp and .h files in a directory
& "$env:USERPROFILE\.qoder\skills\encoding-converter\scripts\convert-encoding.ps1" -Path "plugin" -FromEncoding "GBK" -ToEncoding "UTF8"
```

## Important Notes

1. **Backup before conversion**: Encoding conversion is irreversible
2. **UTF-8 no BOM recommended**: Best for cross-platform compatibility
3. **MSVC compiler**: Use `/utf-8` flag if source files are UTF-8
4. **Git**: After conversion, entire file may show as changed (normal behavior)

## MSVC Configuration

After converting to UTF-8, add to `.pro` file:

```qmake
QMAKE_CXXFLAGS += /utf-8
```

Or in Visual Studio: Project Properties → C/C++ → Command Line → Add `/utf-8`
