function Invoke-MvSepClient {
  [Alias("MvSepClient")]
  [CmdletBinding()]
  param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Arguments
  )

  begin {
    Import-Module argparser -ErrorAction Stop

    $schema = @{
      token          = [string], ''
      output         = [string], './'
      sep_type       = [int], 48
      add_opt1       = [string], ''
      add_opt2       = [string], ''
      add_opt3       = [string], ''
      output_format  = [int], 1
      wait           = [string], ''
      retries        = [int], 30
      retry_interval = [int], 20
      hash           = [string], ''
      lang           = [string], 'en'
      start          = [int], 0
      limit          = [int], 10
      debug          = [string], ''
    }

    if ($Arguments.Count -eq 0) {
      Write-Host "MvSepClient - MVSep API CLI"
      Write-Host ""
      Write-Host "Usage: MvSepClient <command> [options]"
      Write-Host ""
      Write-Host "Commands:"
      Write-Host "  get-types           Get available separation types"
      Write-Host "  algorithms          Get available algorithms (same as get-types)"
      Write-Host "  separate            Create separation task"
      Write-Host "  get-result          Download result by hash"
      Write-Host "  queue               Get queue information"
      Write-Host "  news                Get news"
      Write-Host "  history             Get separation history"
      Write-Host "  premium-enable      Enable premium"
      Write-Host "  premium-disable    Disable premium"
      Write-Host "  long-filenames-enable   Enable long filenames"
      Write-Host "  long-filenames-disable  Disable long filenames"
      Write-Host ""
      Write-Host "Examples:"
      Write-Host "  MvSepClient get-types --token YOUR_API_KEY"
      Write-Host "  MvSepClient separate --input song.mp3 --output ./output --token YOUR_API_KEY --sep_type 48"
      Write-Host "  MvSepClient separate --input ./audio --output ./output --token YOUR_API_KEY --wait"
      Write-Host "  MvSepClient get-result --hash YOUR_HASH --output ./output --token YOUR_API_KEY"
      return
    }

    $command = $Arguments[0]
    $remainingArgs = $Arguments[1..($Arguments.Count - 1)]

    if ($remainingArgs.Count -gt 0) {
      $params = ConvertTo-Params $remainingArgs -schema $schema
    } else {
      $params = @{}
    }

    $token = ''
    if ($params.ContainsKey('token')) {
      $token = $params['token'].Value
    }

    if ([string]::IsNullOrEmpty($token)) {
      Write-Error "API token is required. Use --token YOUR_API_KEY"
      return
    }

    $logger = New-Logger -Level 2
    $client = New-Object MvsepClient($token, 30, 20, $logger)
  }

  process {
    switch ($command) {
      { $_ -in @('get-types', 'algorithms') } {
        $algos = $client.GetAlgorithms()
        foreach ($algo in $algos) {
          Write-Host $algos[$algo]
        }
      }

      'separate' {
        $inputPath = ''
        $outputPath = './'

        if ($params.ContainsKey('input')) {
          $inputPath = $params['input'].Value
        }
        if ($params.ContainsKey('output')) {
          $outputPath = $params['output'].Value
        }

        if ([string]::IsNullOrEmpty($inputPath)) {
          Write-Error "Input file or folder is required. Use --input <path>"
          return
        }

        $sepType = 48
        $addOpt1 = ''
        $addOpt2 = ''
        $addOpt3 = ''
        $outputFormat = 1

        if ($params.ContainsKey('sep_type')) { $sepType = $params['sep_type'].Value }
        if ($params.ContainsKey('add_opt1')) { $addOpt1 = $params['add_opt1'].Value }
        if ($params.ContainsKey('add_opt2')) { $addOpt2 = $params['add_opt2'].Value }
        if ($params.ContainsKey('add_opt3')) { $addOpt3 = $params['add_opt3'].Value }
        if ($params.ContainsKey('output_format')) { $outputFormat = $params['output_format'].Value }

        $options = @{
          sep_type     = $sepType
          add_opt1     = $addOpt1
          add_opt2     = $addOpt2
          add_opt3     = $addOpt3
          output_format = $outputFormat
        }

        if (Test-Path $inputPath -PathType Container) {
          Write-Host "Processing directory: $inputPath -> $outputPath"
          $client.ProcessDirectory($inputPath, $outputPath, $options)
        }
        elseif (Test-Path $inputPath -PathType Leaf) {
          Write-Host "Processing file: $inputPath"
          $options['audiofile'] = $inputPath

          $createResp = $client.CreateSeparation($options)
          if (-not $createResp.success) {
            Write-Error "Failed to create separation: $($createResp | ConvertTo-Json)"
            return
          }

          $hash = $createResp.data.hash
          Write-Host "Created task: $hash"

          $isWait = $false
          if ($params.ContainsKey('wait')) {
            $isWait = -not $params['wait'].HasDefaultValue
          }

          if ($isWait) {
            Write-Host "Waiting for separation to complete..."

            $retries = 30
            $retryInterval = 20
            if ($params.ContainsKey('retries')) { $retries = $params['retries'].Value }
            if ($params.ContainsKey('retry_interval')) { $retryInterval = $params['retry_interval'].Value }

            $status = ""
            for ($i = 0; $i -le $retries; $i++) {
              $statusResp = $client.GetSeparationStatus($hash)
              $status = $statusResp.status
              Write-Host "Status: $status"

              if ($status -eq "done") { break }
              if ($status -in @("failed", "error")) { break }

              Start-Sleep -Seconds $retryInterval
            }

            if ($status -eq "done") {
              Write-Host "Downloading files to $outputPath"
              foreach ($fileInfo in $statusResp.data.files) {
                $downloadUrl = $fileInfo.url.Replace('\/', '/')
                $fileName = $fileInfo.download
                $fileOutputPath = Join-Path $outputPath $fileName
                $client.DownloadTrack($downloadUrl, $fileOutputPath)
                Write-Host "Downloaded: $fileName"
              }
            }
            else {
              Write-Error "Task failed or timed out with status: $status"
            }
          }
        }
        else {
          Write-Error "Input path not found: $inputPath"
        }
      }

      'get-result' {
        $hash = ''
        $outputPath = './'

        if ($params.ContainsKey('hash')) { $hash = $params['hash'].Value }
        if ($params.ContainsKey('output')) { $outputPath = $params['output'].Value }

        if ([string]::IsNullOrEmpty($hash)) {
          Write-Error "Hash is required. Use --hash <hash>"
          return
        }

        Write-Host "Getting result for hash: $hash"
        $statusResp = $client.GetSeparationStatus($hash)

        if ($statusResp.status -eq "done") {
          Write-Host "Downloading files to $outputPath"
          foreach ($fileInfo in $statusResp.data.files) {
            $downloadUrl = $fileInfo.url.Replace('\/', '/')
            $fileName = $fileInfo.download
            $fileOutputPath = Join-Path $outputPath $fileName
            $client.DownloadTrack($downloadUrl, $fileOutputPath)
            Write-Host "Downloaded: $fileName"
          }
        }
        else {
          Write-Host "Status: $($statusResp.status)"
          if ($statusResp.status -in @("waiting", "processing", "distributing", "merging")) {
            Write-Host "Use --wait flag or poll again later"
          }
        }
      }

      'queue' {
        $queue = $client.GetQueueInfo()
        $queue | ConvertTo-Json -Depth 3
      }

      'news' {
        $lang = 'en'
        $start = 0
        $limit = 10

        if ($params.ContainsKey('lang')) { $lang = $params['lang'].Value }
        if ($params.ContainsKey('start')) { $start = $params['start'].Value }
        if ($params.ContainsKey('limit')) { $limit = $params['limit'].Value }

        $news = $client.GetNews($lang, $start, $limit)
        $news | ConvertTo-Json -Depth 3
      }

      'history' {
        $start = 0
        $limit = 10

        if ($params.ContainsKey('start')) { $start = $params['start'].Value }
        if ($params.ContainsKey('limit')) { $limit = $params['limit'].Value }

        $history = $client.GetHistory($start, $limit)
        $history | ConvertTo-Json -Depth 3
      }

      'premium-enable' {
        $result = $client.EnablePremium()
        $result | ConvertTo-Json -Depth 3
      }

      'premium-disable' {
        $result = $client.DisablePremium()
        $result | ConvertTo-Json -Depth 3
      }

      'long-filenames-enable' {
        $result = $client.EnableLongFilenames()
        $result | ConvertTo-Json -Depth 3
      }

      'long-filenames-disable' {
        $result = $client.DisableLongFilenames()
        $result | ConvertTo-Json -Depth 3
      }

      default {
        Write-Error "Unknown command: $command"
        Write-Host "Run MvSepClient without arguments to see available commands"
      }
    }
  }

  end {
  }
}