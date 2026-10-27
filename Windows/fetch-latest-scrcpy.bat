@echo off
setlocal

echo Fetching latest scrcpy Windows x64 release URL...

powershell -NoProfile -Command "^
    $ErrorActionPreference = 'Stop'; \
    try { \
        $release = Invoke-RestMethod -Uri 'https://api.github.com/repos/genymobile/scrcpy/releases/latest'; \
        $asset = $release.assets | Where-Object { $_.name -like '*win64*.zip' } | Select-Object -First 1; \
        if (-not $asset) { Write-Error 'Could not find win64 download URL.'; exit 1; } \
        \
        $url = $asset.browser_download_url; \
        $fileName = $asset.name; \
        $tempDir = Join-Path $env:TEMP ([Guid]::NewGuid().ToString()); \
        New-Item -ItemType Directory -Path $tempDir | Out-Null; \
        $destPath = Join-Path $tempDir $fileName; \
        \
        Write-Host ('Downloading ' + $fileName + '...'); \
        Invoke-WebRequest -Uri $url -OutFile $destPath; \
        \
        Write-Host 'Extracting...'; \
        $extractPath = '.\scrcpy-latest'; \
        if (Test-Path $extractPath) { Remove-Item -Recurse -Force $extractPath }; \
        Expand-Archive -Path $destPath -DestinationPath $extractPath; \
        Remove-Item -Recurse -Force $tempDir; \
        \
        Write-Host 'Successfully extracted to .\scrcpy-latest'; \
    } catch { \
        Write-Error $_.Exception.Message; \
        exit 1; \
    } \
"

endlocal
pause
