[CmdletBinding()]
param(
    [string]$SourceMusicDir = "",
    [string]$SourceJinglesDir = "",
    [string]$SourceInsertsDir = "",
    [string]$OutputRoot = "./.local/test-media",
    [ValidateRange(10, 15)]
    [int]$SnippetSeconds = 15,
    [ValidateRange(1, 10)]
    [int]$SnippetsPerSource = 3,
    [ValidateRange(1, 1000)]
    [int]$MaxMusicFiles = 200,
    [ValidateRange(1, 1000)]
    [int]$MaxJingleFiles = 200,
    [ValidateRange(1, 1000)]
    [int]$MaxInsertFiles = 200,
    [string[]]$SourceComposeFiles = @("docker-compose.yml", "docker-compose.local.yml")
)

$ErrorActionPreference = 'Stop'

function Import-DotEnvFile {
    param([string]$Path)

    if (-not (Test-Path -Path $Path)) {
        return
    }

    foreach ($line in Get-Content -Path $Path) {
        $trimmed = $line.Trim()
        if ([string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith('#')) {
            continue
        }

        $split = $trimmed.Split('=', 2)
        if ($split.Count -ne 2) {
            continue
        }

        $key = $split[0].Trim()
        $value = $split[1].Trim()

        if ([string]::IsNullOrWhiteSpace($key)) {
            continue
        }

        if ([string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($key))) {
            [Environment]::SetEnvironmentVariable($key, $value)
        }
    }
}

Import-DotEnvFile -Path (Join-Path -Path (Get-Location).Path -ChildPath '.env')

function Resolve-SourceDir {
    param(
        [string]$Provided,
        [string]$EnvValue,
        [string]$Fallback
    )

    if (-not [string]::IsNullOrWhiteSpace($Provided)) {
        return (Resolve-Path -Path $Provided).Path
    }

    if (-not [string]::IsNullOrWhiteSpace($EnvValue)) {
        return (Resolve-Path -Path $EnvValue).Path
    }

    return (Resolve-Path -Path $Fallback).Path
}

function Get-AudioFiles {
    param([string]$Path)

    $extensions = @('*.mp3', '*.wav', '*.flac', '*.m4a', '*.ogg', '*.aac')
    Get-ChildItem -Path $Path -File -Recurse -Include $extensions
}

function Select-RandomFiles {
    param(
        [System.IO.FileInfo[]]$Files,
        [int]$MaxCount
    )

    if (-not $Files -or $Files.Count -eq 0) {
        return @()
    }

    $count = [Math]::Min($MaxCount, $Files.Count)
    if ($count -le 0) {
        return @()
    }

    if ($count -eq $Files.Count) {
        return $Files
    }

    return @($Files | Get-Random -Count $count)
}

function Select-RandomPaths {
    param(
        [string[]]$Paths,
        [int]$MaxCount
    )

    if (-not $Paths -or $Paths.Count -eq 0) {
        return @()
    }

    $count = [Math]::Min($MaxCount, $Paths.Count)
    if ($count -le 0) {
        return @()
    }

    if ($count -eq $Paths.Count) {
        return $Paths
    }

    return @($Paths | Get-Random -Count $count)
}

function Ensure-EmptyDir {
    param([string]$Path)

    if (-not (Test-Path -Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }

    Get-ChildItem -Path $Path -File -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
}

function New-OutputName {
    param(
        [string]$SourceName,
        [int]$GlobalIndex,
        [int]$SnippetIndex
    )

    $safeBaseName = ($SourceName -replace '[^a-zA-Z0-9._-]', '_')
    return "{0:D4}-{1}-s{2:D2}.mp3" -f $GlobalIndex, $safeBaseName, $SnippetIndex
}

function Get-RangedStartSecond {
    param(
        [double]$DurationSeconds,
        [int]$SnippetLengthSeconds,
        [int]$SnippetIndex,
        [int]$TotalSnippets
    )

    $maxStart = [Math]::Max(0.0, $DurationSeconds - $SnippetLengthSeconds - 0.25)
    if ($maxStart -le 0.0) {
        return 0.0
    }

    $bins = [Math]::Max(1, $TotalSnippets)
    $binSize = $maxStart / $bins
    $binStart = [Math]::Min($maxStart, ($SnippetIndex - 1) * $binSize)
    $binEnd = if ($SnippetIndex -ge $bins) { $maxStart } else { [Math]::Min($maxStart, $SnippetIndex * $binSize) }

    if ($binEnd -le $binStart) {
        return [Math]::Round($binStart, 3)
    }

    $randomFraction = Get-Random -Minimum 0.0 -Maximum 1.0
    $start = $binStart + (($binEnd - $binStart) * $randomFraction)
    return [Math]::Round($start, 3)
}

function Get-LocalMediaDurationSeconds {
    param([string]$InputPath)

    $duration = & ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 $InputPath
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($duration)) {
        return 0.0
    }

    return [double]::Parse($duration.Trim(), [System.Globalization.CultureInfo]::InvariantCulture)
}

function Get-ContainerMediaDurationSeconds {
    param(
        [string]$ContainerId,
        [string]$InputPath
    )

    $duration = docker run --rm --entrypoint ffprobe --volumes-from $ContainerId jrottenberg/ffmpeg:6.1-alpine -v error -show_entries format=duration -of default=nw=1:nk=1 "$InputPath"
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($duration)) {
        return 0.0
    }

    return [double]::Parse($duration.Trim(), [System.Globalization.CultureInfo]::InvariantCulture)
}

function Convert-ToSnippet {
    param(
        [System.IO.FileInfo]$InputFile,
        [string]$OutputDir,
        [int]$Seconds,
        [double]$StartSecond,
        [string]$OutputName
    )

    $outputPath = Join-Path -Path $OutputDir -ChildPath $outputName

    & ffmpeg -y -hide_banner -loglevel error -ss $StartSecond -t $Seconds -i $InputFile.FullName -vn -ac 2 -ar 44100 -acodec libmp3lame -b:a 128k $outputPath
    if ($LASTEXITCODE -ne 0) {
        throw "ffmpeg failed for '$($InputFile.FullName)'"
    }
}

function Get-ComposeServiceContainerId {
    param(
        [string]$ServiceName,
        [string[]]$ComposeArgs
    )

    & docker compose @ComposeArgs up -d $ServiceName | Out-Null

    $id = (& docker compose @ComposeArgs ps -q $ServiceName).Trim()
    if ([string]::IsNullOrWhiteSpace($id)) {
        throw "Could not find running compose service '$ServiceName'. Start the stack first."
    }

    return $id
}

function Get-ComposeArgsFromFiles {
    param([string[]]$Files)

    $args = @()
    foreach ($file in $Files) {
        if ([string]::IsNullOrWhiteSpace($file)) {
            continue
        }

        if (Test-Path -Path $file) {
            $args += @('-f', $file)
        }
    }

    if ($args.Count -eq 0) {
        throw 'No compose files found for Docker fallback source media resolution.'
    }

    return $args
}

function Get-ContainerAudioFiles {
    param(
        [string]$ContainerId,
        [string]$ContainerPath
    )

    $findCommand = "find $ContainerPath -type f \( -iname '*.mp3' -o -iname '*.wav' -o -iname '*.flac' -o -iname '*.m4a' -o -iname '*.ogg' -o -iname '*.aac' \)"
    $raw = docker run --rm --volumes-from $ContainerId alpine:3.20 sh -lc $findCommand
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to list media files from container path '$ContainerPath'"
    }

    if ([string]::IsNullOrWhiteSpace($raw)) {
        return @()
    }

    return @($raw -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Convert-ContainerSnippet {
    param(
        [string]$ContainerId,
        [string]$InputPath,
        [string]$OutputDir,
        [int]$Seconds,
        [double]$StartSecond,
        [string]$OutputName
    )

    docker run --rm --entrypoint ffmpeg --volumes-from $ContainerId -v "${OutputDir}:/out" jrottenberg/ffmpeg:6.1-alpine -y -hide_banner -loglevel error -ss $StartSecond -t $Seconds -i "$InputPath" -vn -ac 2 -ar 44100 -acodec libmp3lame -b:a 128k "/out/$OutputName" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "docker ffmpeg failed for '$InputPath'"
    }
}

$outputRootPath = Join-Path -Path (Get-Location).Path -ChildPath $OutputRoot
$outputMusicDir = Join-Path -Path $outputRootPath -ChildPath 'music'
$outputJinglesDir = Join-Path -Path $outputRootPath -ChildPath 'jingles'
$outputInsertsDir = Join-Path -Path $outputRootPath -ChildPath 'inserts'

$useDockerFfmpeg = $false
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        throw 'Neither ffmpeg nor docker is available. Install ffmpeg or run with Docker installed.'
    }
    $useDockerFfmpeg = $true
}

$musicCount = 0
$jingleCount = 0
$insertCount = 0

if ($useDockerFfmpeg) {
    $composeArgs = Get-ComposeArgsFromFiles -Files $SourceComposeFiles
    $containerId = Get-ComposeServiceContainerId -ServiceName 'liquidsoap' -ComposeArgs $composeArgs

    $allMusicPaths = @(Get-ContainerAudioFiles -ContainerId $containerId -ContainerPath '/media/music')
    $allJinglePaths = @(Get-ContainerAudioFiles -ContainerId $containerId -ContainerPath '/media/jingles')
    $allInsertPaths = @(Get-ContainerAudioFiles -ContainerId $containerId -ContainerPath '/media/inserts')

    $musicPaths = @(Select-RandomPaths -Paths $allMusicPaths -MaxCount $MaxMusicFiles)
    $jinglePaths = @(Select-RandomPaths -Paths $allJinglePaths -MaxCount $MaxJingleFiles)
    $insertPaths = @(Select-RandomPaths -Paths $allInsertPaths -MaxCount $MaxInsertFiles)

    if ($musicPaths.Count -eq 0) { throw 'No source files found in container music dir: /media/music' }
    if ($jinglePaths.Count -eq 0) { Write-Warning 'No source files found in container jingles dir: /media/jingles' }
    if ($insertPaths.Count -eq 0) { Write-Warning 'No source files found in container inserts dir: /media/inserts' }

    Ensure-EmptyDir -Path $outputMusicDir
    Ensure-EmptyDir -Path $outputJinglesDir
    Ensure-EmptyDir -Path $outputInsertsDir

    $musicGlobalIndex = 1
    foreach ($path in $musicPaths) {
        $sourceName = [System.IO.Path]::GetFileNameWithoutExtension($path)
        $duration = Get-ContainerMediaDurationSeconds -ContainerId $containerId -InputPath $path

        for ($snippetIndex = 1; $snippetIndex -le $SnippetsPerSource; $snippetIndex++) {
            $startSecond = Get-RangedStartSecond -DurationSeconds $duration -SnippetLengthSeconds $SnippetSeconds -SnippetIndex $snippetIndex -TotalSnippets $SnippetsPerSource
            $outputName = New-OutputName -SourceName $sourceName -GlobalIndex $musicGlobalIndex -SnippetIndex $snippetIndex
            Convert-ContainerSnippet -ContainerId $containerId -InputPath $path -OutputDir $outputMusicDir -Seconds $SnippetSeconds -StartSecond $startSecond -OutputName $outputName
            $musicGlobalIndex++
        }
    }

    $jingleGlobalIndex = 1
    foreach ($path in $jinglePaths) {
        $sourceName = [System.IO.Path]::GetFileNameWithoutExtension($path)
        $duration = Get-ContainerMediaDurationSeconds -ContainerId $containerId -InputPath $path

        for ($snippetIndex = 1; $snippetIndex -le $SnippetsPerSource; $snippetIndex++) {
            $startSecond = Get-RangedStartSecond -DurationSeconds $duration -SnippetLengthSeconds $SnippetSeconds -SnippetIndex $snippetIndex -TotalSnippets $SnippetsPerSource
            $outputName = New-OutputName -SourceName $sourceName -GlobalIndex $jingleGlobalIndex -SnippetIndex $snippetIndex
            Convert-ContainerSnippet -ContainerId $containerId -InputPath $path -OutputDir $outputJinglesDir -Seconds $SnippetSeconds -StartSecond $startSecond -OutputName $outputName
            $jingleGlobalIndex++
        }
    }

    $insertGlobalIndex = 1
    foreach ($path in $insertPaths) {
        $sourceName = [System.IO.Path]::GetFileNameWithoutExtension($path)
        $duration = Get-ContainerMediaDurationSeconds -ContainerId $containerId -InputPath $path

        for ($snippetIndex = 1; $snippetIndex -le $SnippetsPerSource; $snippetIndex++) {
            $startSecond = Get-RangedStartSecond -DurationSeconds $duration -SnippetLengthSeconds $SnippetSeconds -SnippetIndex $snippetIndex -TotalSnippets $SnippetsPerSource
            $outputName = New-OutputName -SourceName $sourceName -GlobalIndex $insertGlobalIndex -SnippetIndex $snippetIndex
            Convert-ContainerSnippet -ContainerId $containerId -InputPath $path -OutputDir $outputInsertsDir -Seconds $SnippetSeconds -StartSecond $startSecond -OutputName $outputName
            $insertGlobalIndex++
        }
    }

    $musicCount = [Math]::Max(0, $musicGlobalIndex - 1)
    $jingleCount = [Math]::Max(0, $jingleGlobalIndex - 1)
    $insertCount = [Math]::Max(0, $insertGlobalIndex - 1)
} else {
    $musicDir = Resolve-SourceDir -Provided $SourceMusicDir -EnvValue $env:HOST_MUSIC_DIR -Fallback './media/music'
    $jinglesDir = Resolve-SourceDir -Provided $SourceJinglesDir -EnvValue $env:HOST_JINGLES_DIR -Fallback './media/jingles'
    $insertsDir = Resolve-SourceDir -Provided $SourceInsertsDir -EnvValue $env:HOST_INSERTS_DIR -Fallback './media/inserts'

    $allMusicFiles = @(Get-AudioFiles -Path $musicDir)
    $allJingleFiles = @(Get-AudioFiles -Path $jinglesDir)
    $allInsertFiles = @(Get-AudioFiles -Path $insertsDir)

    $musicFiles = @(Select-RandomFiles -Files $allMusicFiles -MaxCount $MaxMusicFiles)
    $jingleFiles = @(Select-RandomFiles -Files $allJingleFiles -MaxCount $MaxJingleFiles)
    $insertFiles = @(Select-RandomFiles -Files $allInsertFiles -MaxCount $MaxInsertFiles)

    if ($musicFiles.Count -eq 0) { throw "No source files found in music dir: $musicDir" }
    if ($jingleFiles.Count -eq 0) { Write-Warning "No source files found in jingles dir: $jinglesDir" }
    if ($insertFiles.Count -eq 0) { Write-Warning "No source files found in inserts dir: $insertsDir" }

    Ensure-EmptyDir -Path $outputMusicDir
    Ensure-EmptyDir -Path $outputJinglesDir
    Ensure-EmptyDir -Path $outputInsertsDir

    $musicGlobalIndex = 1
    foreach ($file in $musicFiles) {
        $sourceName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        $duration = Get-LocalMediaDurationSeconds -InputPath $file.FullName

        for ($snippetIndex = 1; $snippetIndex -le $SnippetsPerSource; $snippetIndex++) {
            $startSecond = Get-RangedStartSecond -DurationSeconds $duration -SnippetLengthSeconds $SnippetSeconds -SnippetIndex $snippetIndex -TotalSnippets $SnippetsPerSource
            $outputName = New-OutputName -SourceName $sourceName -GlobalIndex $musicGlobalIndex -SnippetIndex $snippetIndex
            Convert-ToSnippet -InputFile $file -OutputDir $outputMusicDir -Seconds $SnippetSeconds -StartSecond $startSecond -OutputName $outputName
            $musicGlobalIndex++
        }
    }

    $jingleGlobalIndex = 1
    foreach ($file in $jingleFiles) {
        $sourceName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        $duration = Get-LocalMediaDurationSeconds -InputPath $file.FullName

        for ($snippetIndex = 1; $snippetIndex -le $SnippetsPerSource; $snippetIndex++) {
            $startSecond = Get-RangedStartSecond -DurationSeconds $duration -SnippetLengthSeconds $SnippetSeconds -SnippetIndex $snippetIndex -TotalSnippets $SnippetsPerSource
            $outputName = New-OutputName -SourceName $sourceName -GlobalIndex $jingleGlobalIndex -SnippetIndex $snippetIndex
            Convert-ToSnippet -InputFile $file -OutputDir $outputJinglesDir -Seconds $SnippetSeconds -StartSecond $startSecond -OutputName $outputName
            $jingleGlobalIndex++
        }
    }

    $insertGlobalIndex = 1
    foreach ($file in $insertFiles) {
        $sourceName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        $duration = Get-LocalMediaDurationSeconds -InputPath $file.FullName

        for ($snippetIndex = 1; $snippetIndex -le $SnippetsPerSource; $snippetIndex++) {
            $startSecond = Get-RangedStartSecond -DurationSeconds $duration -SnippetLengthSeconds $SnippetSeconds -SnippetIndex $snippetIndex -TotalSnippets $SnippetsPerSource
            $outputName = New-OutputName -SourceName $sourceName -GlobalIndex $insertGlobalIndex -SnippetIndex $snippetIndex
            Convert-ToSnippet -InputFile $file -OutputDir $outputInsertsDir -Seconds $SnippetSeconds -StartSecond $startSecond -OutputName $outputName
            $insertGlobalIndex++
        }
    }

    $musicCount = [Math]::Max(0, $musicGlobalIndex - 1)
    $jingleCount = [Math]::Max(0, $jingleGlobalIndex - 1)
    $insertCount = [Math]::Max(0, $insertGlobalIndex - 1)
}

Write-Host "Generated test media in: $outputRootPath"
Write-Host "  music:   $musicCount file(s)"
Write-Host "  jingles: $jingleCount file(s)"
Write-Host "  inserts: $insertCount file(s)"
Write-Host "Use with: docker compose -f docker-compose.test-media.yml up -d"
