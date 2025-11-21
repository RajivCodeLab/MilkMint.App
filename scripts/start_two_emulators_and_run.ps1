<#
Start two Android emulators and run the Flutter app on each in separate PowerShell windows.

Usage examples:
  # Default: uses built-in example AVD names
  .\start_two_emulators_and_run.ps1 -avd1 "Pixel_9_Pro_XL" -avd2 "pixel_7_-_api_35" -projectPath "D:\Startup\Milk\milk_manager_app"

Parameters:
  -avd1, -avd2 : AVD names as reported by `emulator -list-avds` (required)
  -projectPath : Path to the Flutter project (defaults to current directory)
  -bootTimeout  : Seconds to wait for emulators to appear (default 180)
#>

param(
    [Parameter(Mandatory=$true)] [string]$avd1,
    [Parameter(Mandatory=$true)] [string]$avd2,
    [string]$projectPath = (Get-Location).Path,
    [int]$bootTimeout = 180
)

function Get-EmulatorExe {
    if ($env:ANDROID_SDK_ROOT) {
        $path = Join-Path $env:ANDROID_SDK_ROOT 'emulator\emulator.exe'
        if (Test-Path $path) { return $path }
    }
    if ($env:ANDROID_HOME) {
        $path = Join-Path $env:ANDROID_HOME 'emulator\emulator.exe'
        if (Test-Path $path) { return $path }
    }
    Write-Error "Could not find emulator executable. Ensure ANDROID_SDK_ROOT or ANDROID_HOME is set.";
    exit 1
}

$emulatorExe = Get-EmulatorExe
Write-Host "Using emulator: $emulatorExe"

Write-Host "Starting emulator: $avd1"
Start-Process -FilePath $emulatorExe -ArgumentList "-avd $avd1" -WindowStyle Minimized
Start-Sleep -Seconds 2
Write-Host "Starting emulator: $avd2"
Start-Process -FilePath $emulatorExe -ArgumentList "-avd $avd2" -WindowStyle Minimized

# Wait for flutter devices to list both AVDs
$found = @{}
$elapsed = 0
$interval = 3
Write-Host "Waiting for emulators to boot (timeout: ${bootTimeout}s)..."
while ($elapsed -lt $bootTimeout -and $found.Count -lt 2) {
    Start-Sleep -Seconds $interval
    $elapsed += $interval

    $devicesOutput = & flutter devices 2>&1
    foreach ($line in $devicesOutput) {
        # Example line: emulator-5554 • Pixel_7_-_api_35 • android • Android 13 (API 33)
        if ($line -match '^([^\s]+)\s+•\s+([^•]+)\s+•') {
            $deviceId = $matches[1]
            $deviceName = $matches[2].Trim()
            if ($deviceName -like "*${avd1}*") { $found[$avd1] = $deviceId }
            if ($deviceName -like "*${avd2}*") { $found[$avd2] = $deviceId }
        }
    }
    Write-Host "Elapsed: ${elapsed}s - Found: $($found.Keys -join ', ')"
}

if ($found.Count -lt 2) {
    Write-Warning "Could not detect both emulators within timeout. Detected: $($found.Keys -join ', '); continuing with detected devices."
}

# Launch flutter run in separate PowerShell windows for each detected device
foreach ($avd in $found.Keys) {
    $deviceId = $found[$avd]
    $cmd = "cd '$projectPath'; flutter run -d $deviceId"
    Write-Host "Launching Flutter on $avd -> $deviceId"
    Start-Process powershell -ArgumentList '-NoExit', '-Command', $cmd
}

Write-Host "Done. If any emulator/device is missing, start it from AVD Manager or increase -bootTimeout and re-run the script."