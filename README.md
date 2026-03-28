# [mvsepclient](https://www.powershellgallery.com/packages/mvsepclient)

Blazingly fast [MVSep](https://mvsep.com/en) API client PowerShell module

[![Downloads](https://img.shields.io/powershellgallery/dt/mvsepclient.svg?style=flat&logo=powershell&color=blue)](https://www.powershellgallery.com/packages/mvsepclient)

## Installation

```PowerShell
Install-Module mvsepclient
```

## Requirements

- PowerShell 7.6+
- RequiredModules (installed automatically)
  - [argparser](https://www.powershellgallery.com/packages/argparser)
  - [cliHelper.logger](https://www.powershellgallery.com/packages/cliHelper.logger)

- API key. [Get yours here](https://mvsep.com/user-api)

## Quick Start

```PowerShell
Import-Module mvsepclient

# Get your API token from https://mvsep.com/user-api
$client = [MvsepClient]::new("YOUR_API_KEY")

# Get available algorithms
$algos = $client.GetAlgorithms()
```

## CLI Usage

The module provides a CLI interface via `Invoke-MvSepClient` (alias: `MvSepClient`):

```PowerShell
Import-Module mvsepclient
```

### Get Available Separation Types

```PowerShell
Invoke-MvSepClient get-types --token YOUR_API_KEY

# Or use the alias :)
MvSepClient algorithms --token YOUR_API_KEY
```

### Separate a Single File

```PowerShell
MvSepClient separate --input song.mp3 --output ./output --token YOUR_API_KEY --sep_type 48
```

### Separate a File with Automatic Wait

Wait for processing to complete and download automatically:

```PowerShell
MvSepClient separate --input song.mp3 --output ./output --token YOUR_API_KEY --sep_type 48 --wait
```

### Separate a Directory

```PowerShell
MvSepClient separate --input ./audio --output ./output --token YOUR_API_KEY --sep_type 48
```

### Download Result by Hash

```PowerShell
MvSepClient get-result --hash YOUR_HASH --output ./output --token YOUR_API_KEY
```

### Get Queue Information

```PowerShell
MvSepClient queue --token YOUR_API_KEY
```

### Get News

```PowerShell
MvSepClient news --token YOUR_API_KEY --lang en --limit 10
```

### Get Separation History

```PowerShell
MvSepClient history --token YOUR_API_KEY --start 0 --limit 20
```

### Premium Management

```PowerShell
# Enable premium
MvSepClient premium-enable --token YOUR_API_KEY

# Disable premium
MvSepClient premium-disable --token YOUR_API_KEY
```

### Long Filenames

```PowerShell
# Enable long filenames
MvSepClient long-filenames-enable --token YOUR_API_KEY

# Disable long filenames
MvSepClient long-filenames-disable --token YOUR_API_KEY
```

## Class Usage

### Create Client

```PowerShell
Import-Module mvsepclient

# Basic usage
$client = [MvsepClient]::new("YOUR_API_KEY")

# With custom retries
$client = [MvsepClient]::new("YOUR_API_KEY", 60, 30)

# Or use the static factory method
$client = [MvsepClient]::New("YOUR_API_KEY")
```

### Get Algorithms

```PowerShell
$algos = $client.GetAlgorithms()

# Or use static method (no instance needed)
$algos = [MvsepClient]::GetAlgorithmsStatic()
```

### Create Separation

```PowerShell
# For a local file
$params = @{
    audiofile = "song.mp3"
    sep_type = 48          # MelBand Roformer
    add_opt1 = 1
    output_format = 1     # WAV
}

$result = $client.CreateSeparation($params)

if ($result.success) {
    $hash = $result.data.hash
    Write-Host "Created task: $hash"
}
```

### Wait for Result

```PowerShell
$hash = "YOUR_TASK_HASH"

# Poll for status
for ($i = 0; $i -lt 30; $i++) {
    $status = $client.GetSeparationStatus($hash)

    if ($status.status -eq "done") {
        Write-Host "Processing complete!"
        break
    }

    if ($status.status -in @("failed", "error")) {
        Write-Host "Processing failed"
        break
    }

    Start-Sleep -Seconds 20
}

# Download files
foreach ($file in $status.data.files) {
    $url = $file.url.Replace('\/', '/')
    $client.DownloadTrack($url, "./output/$($file.download)")
}
```

### Process Directory

```PowerShell
$options = @{
    sep_type = 48         # MelBand Roformer
    add_opt1 = 1
    output_format = 1    # WAV
}

$client.ProcessDirectory("./input", "./output", $options)
```

### Get Queue Info

```PowerShell
# Instance method
$queue = $client.GetQueueInfo()

# Static method
$queue = [MvsepClient]::GetQueueInfoStatic()
```

### Get News

```PowerShell
# Instance method
$news = $client.GetNews("en", 0, 10)

# Static method
$news = [MvsepClient]::GetNewsStatic("en", 0, 10)
```

### Get History

```PowerShell
$history = $client.GetHistory(0, 20)
```

### Premium Management

```PowerShell
$client.EnablePremium()
$client.DisablePremium()
```

### Long Filenames

```PowerShell
$client.EnableLongFilenames()
$client.DisableLongFilenames()
```

### Quality Checker

```PowerShell
$result = $client.CreateQualityEntry(
    "path/to/results.zip",
    "MelBand Roformer",
    "Test results",
    0,  # dataset_type
    0,  # ensemble
    ""  # password (optional)
)
```

## Available Separation Types

| ID | Name | Description |
|----|------|-------------|
| 48 | MelBand Roformer | Vocals, instrumental |
| 40 | BS Roformer | Vocals, instrumental |
| 20 | Demucs4 HT | Vocals, drums, bass, other |
| 25 | MDX23C | Vocals, instrumental |
| 46 | SCNet | Vocals, instrumental |
| 9 | Ultimate Vocal Remover VR | Vocals, music |
| 26 | Ensemble | Vocals, instrum |
| 28 | Ensemble All-In | Multiple stems |

For the complete list, run:
```PowerShell
MvSepClient get-types --token YOUR_API_KEY
```

## License

This project is licensed under the [WTFPL License](LICENSE).