#!/usr/bin/env pwsh
using namespace System.Net

#region    Classes

# Main class
class MvsepClient {
  [string]$ApiKey
  [int]$Retries
  [int]$RetryInterval
  [string]$BaseUrl
  [Logger]$Logger

  MvsepClient([string]$apiKey, [int]$retries = 30, [int]$retryInterval = 20, [Logger]$logger = $null) {
    $this.ApiKey = $apiKey
    $this.Retries = $retries
    $this.RetryInterval = $retryInterval
    $this.BaseUrl = "https://mvsep.com/api"
    if ($null -eq $logger) {
      $this.Logger = New-Logger -Level 1
    } else {
      $this.Logger = $logger
    }
  }

  static [MvsepClient] New([string]$apiKey, [int]$retries = 30, [int]$retryInterval = 20) {
    return [MvsepClient]::new($apiKey, $retries, $retryInterval, $null)
  }

  static [MvsepClient] NewWithLogger([string]$apiKey, [Logger]$logger, [int]$retries = 30, [int]$retryInterval = 20) {
    return [MvsepClient]::new($apiKey, $retries, $retryInterval, $logger)
  }

  static [PSCustomObject] GetAlgorithmsStatic([string]$baseUrl = "https://mvsep.com/api") {
    $url = "$baseUrl/app/algorithms"
    try {
      return Invoke-RestMethod -Uri $url -Method Get
    } catch {
      throw "Failed to fetch algorithms: $($_.Exception.Message)"
    }
  }

  static [PSCustomObject] GetQueueInfoStatic([string]$baseUrl = "https://mvsep.com/api") {
    return Invoke-RestMethod -Uri "$baseUrl/app/queue" -Method Get
  }

  static [PSCustomObject] GetNewsStatic([string]$lang = "en", [int]$start = 0, [int]$limit = 10, [string]$baseUrl = "https://mvsep.com/api") {
    $params = @{ lang = $lang; start = $start; limit = $limit }
    return Invoke-RestMethod -Uri "$baseUrl/app/news" -Method Get -Body $params
  }

  [PSCustomObject] GetAlgorithms() {
    $this.Logger.LogInfoLine("Fetching algorithm list")
    $url = "$($this.BaseUrl)/app/algorithms"
    try {
      $response = Invoke-RestMethod -Uri $url -Method Get
      return $response
    } catch {
      $this.Logger.LogErrorLine("Failed to fetch algorithms: $($_.Exception.Message)")
      throw $_
    }
  }

  [PSCustomObject] CreateSeparation([Hashtable]$params) {
    $url = "$($this.BaseUrl)/separation/create"
    $form = @{
      api_token = $this.ApiKey
    }
    foreach ($key in $params.Keys) {
      $form[$key] = $params[$key]
    }

    $this.Logger.LogInfoLine("Creating separation task...")
    try {
      # If audiofile is a path, we need to handle it as a file upload
      if ($form.ContainsKey("audiofile") -and (Test-Path $form["audiofile"])) {
        $filePath = $form["audiofile"]
        $form["audiofile"] = Get-Item $filePath
      }

      $response = Invoke-RestMethod -Uri $url -Method Post -Form $form
      return $response
    } catch {
      $this.Logger.LogErrorLine("Failed to create separation: $($_.Exception.Message)")
      throw $_
    }
  }

  [PSCustomObject] GetSeparationStatus([string]$hash, [int]$mirror = 0) {
    $url = "$($this.BaseUrl)/separation/get"
    $params = @{
      hash   = $hash
      mirror = $mirror
    }
    if ($mirror -eq 1) {
      $params["api_token"] = $this.ApiKey
    }

    try {
        $response = Invoke-RestMethod -Uri $url -Method Get -Body $params
        return $response
    }
    catch {
        $errMsg = $_.Exception.Message
        $msg = "Failed to get status for hash ${hash}: ${errMsg}"
        $this.Logger.LogErrorLine($msg)
        throw $_
    }
  }

  [void] DownloadTrack([string]$url, [string]$outputPath) {
    $this.Logger.LogInfoLine("Downloading track to $outputPath")
    $dir = [IO.Path]::GetDirectoryName($outputPath)
    if (-not (Test-Path $dir)) {
      New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    try {
      Invoke-WebRequest -Uri $url -OutFile $outputPath
    } catch {
      $this.Logger.LogErrorLine("Failed to download track: $($_.Exception.Message)")
      throw $_
    }
  }

  [void] ProcessDirectory([string]$inputDir, [string]$outputDir, [Hashtable]$options) {
    $this.Logger.LogInfoLine("Processing directory: $inputDir -> $outputDir")
    $extensions = @(".mp3", ".wav", ".flac")
    $files = Get-ChildItem -Path $inputDir | Where-Object { $_.Extension -in $extensions }

    foreach ($file in $files) {
      $this.Logger.LogInfoLine("Processing $($file.Name)")
      $params = $options.Clone()
      $params["audiofile"] = $file.FullName

      try {
        $createResp = $this.CreateSeparation($params)
        if (-not $createResp.success) {
          $this.Logger.LogWarnLine("Creation failed for $($file.Name): $($createResp | ConvertTo-Json)")
          continue
        }

        $hash = $createResp.data.hash
        $this.Logger.LogInfoLine("Created task: $hash")

        $status = ""
        $statusResp = $null
        for ($i = 0; $i -le $this.Retries; $i++) {
          $statusResp = $this.GetSeparationStatus($hash)
          $status = $statusResp.status
          $this.Logger.LogInfoLine("Status: $status")

          if ($status -eq "done") { break }
          if ($status -in @("failed", "error")) { break }

          Start-Sleep -Seconds $this.RetryInterval
        }

        if ($status -eq "done") {
          foreach ($fileInfo in $statusResp.data.files) {
            $downloadUrl = $fileInfo.url.Replace('\/', '/')
            $fileName = $fileInfo.download
            $outputPath = [IO.Path]::Combine($outputDir, $fileName)
            $this.DownloadTrack($downloadUrl, $outputPath)
          }
        } else {
          $this.Logger.LogErrorLine("Task $hash failed or timed out with status: $status")
        }
      } catch {
        $this.Logger.LogErrorLine("Error processing $($file.Name): $($_.Exception.Message)")
      }
    }
  }

  [PSCustomObject] GetQueueInfo() {
    return Invoke-RestMethod -Uri "$($this.BaseUrl)/app/queue" -Method Get
  }

  [PSCustomObject] GetNews([string]$lang = "en", [int]$start = 0, [int]$limit = 10) {
    $params = @{ lang = $lang; start = $start; limit = $limit }
    return Invoke-RestMethod -Uri "$($this.BaseUrl)/app/news" -Method Get -Body $params
  }

  [PSCustomObject] GetHistory([int]$start = 0, [int]$limit = 10) {
    $params = @{ api_token = $this.ApiKey; start = $start; limit = $limit }
    return Invoke-RestMethod -Uri "$($this.BaseUrl)/app/separation_history" -Method Get -Body $params
  }

  [PSCustomObject] EnablePremium() {
    $body = @{ api_token = $this.ApiKey }
    return Invoke-RestMethod -Uri "$($this.BaseUrl)/app/enable_premium" -Method Post -Body $body
  }

  [PSCustomObject] DisablePremium() {
    $body = @{ api_token = $this.ApiKey }
    return Invoke-RestMethod -Uri "$($this.BaseUrl)/app/disable_premium" -Method Post -Body $body
  }

  [PSCustomObject] EnableLongFilenames() {
    $body = @{ api_token = $this.ApiKey }
    return Invoke-RestMethod -Uri "$($this.BaseUrl)/app/enable_long_filenames" -Method Post -Body $body
  }

  [PSCustomObject] DisableLongFilenames() {
    $body = @{ api_token = $this.ApiKey }
    return Invoke-RestMethod -Uri "$($this.BaseUrl)/app/disable_long_filenames" -Method Post -Body $body
  }

  [PSCustomObject] CreateQualityEntry([string]$zipPath, [string]$algoName, [string]$mainText, [int]$datasetType = 0, [int]$ensemble = 0, [string]$password = "") {
    $url = "$($this.BaseUrl)/quality_checker/add"
    $form = @{
      api_token = $this.ApiKey
      algo_name = $algoName
      main_text = $mainText
      dataset_type = $datasetType
      ensemble = $ensemble
      password = $password
    }

    if (Test-Path $zipPath) {
      $form["zipfile"] = Get-Item $zipPath
    } else {
      throw "Zip file not found: $zipPath"
    }

    try {
      $response = Invoke-RestMethod -Uri $url -Method Post -Form $form
      return $response
    } catch {
      $this.Logger.LogErrorLine("Failed to create quality entry: $($_.Exception.Message)")
      throw $_
    }
  }
}
#endregion Classes

# Types that will be available to users when they import the module.
$typestoExport = @(
  [MvsepClient]
)
$TypeAcceleratorsClass = [PsObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
foreach ($Type in $typestoExport) {
  if ($Type.FullName -in $TypeAcceleratorsClass::Get.Keys) {
    $Message = @(
      "Unable to register type accelerator '$($Type.FullName)'"
      'Accelerator already exists.'
    ) -join ' - '
    "TypeAcceleratorAlreadyExists $Message" | Write-Debug
  }
}
# Add type accelerators for every exportable type.
foreach ($Type in $typestoExport) {
  $TypeAcceleratorsClass::Add($Type.FullName, $Type)
}
# Remove type accelerators when the module is removed.
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
  foreach ($Type in $typestoExport) {
    $TypeAcceleratorsClass::Remove($Type.FullName)
  }
}.GetNewClosure();

$scripts = @();
$Public = Get-ChildItem "$PSScriptRoot/Public" -Filter "*.ps1" -Recurse -ErrorAction SilentlyContinue
$scripts += Get-ChildItem "$PSScriptRoot/Private" -Filter "*.ps1" -Recurse -ErrorAction SilentlyContinue
$scripts += $Public

foreach ($file in $scripts) {
  try {
    if ([string]::IsNullOrWhiteSpace($file.fullname)) { continue }
    . "$($file.fullname)"
  } catch {
    Write-Warning "Failed to import function $($file.BaseName): $_"
    $host.UI.WriteErrorLine($_)
  }
}

$Param = @{
  Function = $Public.BaseName
  Cmdlet   = '*'
  Alias    = '*'
  Verbose  = $false
}
Export-ModuleMember @Param
