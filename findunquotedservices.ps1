# Get ALL services on the system, regardless of whether they are running or stopped
$services = Get-CimInstance -ClassName Win32_Service | 
    Where-Object { $_.PathName -notlike "*C:\Windows\*" }

foreach ($service in $services) {
    # Ensure we have a valid path string to work with
    $path = $service.PathName
    if ([string]::IsNullOrEmpty($path)) { continue }
    $path = $path.Trim()
    
    # Skip if the path is already properly enclosed in quotes
    if ($path.StartsWith('"')) { continue }
    
    # Isolate the executable path from any trailing arguments or flags
    # This splits at .exe (case-insensitive) and takes the first part
    $exePath = $path -split "\.exe" | Select-Object -First 1
    
    # If the executable path contains a space, it's vulnerable
    if ($exePath -like "* *") {
        [PSCustomObject]@{
            ServiceName = $service.Name
            DisplayName = $service.DisplayName
            PathName    = $service.PathName
            StartMode   = $service.StartMode
            CurrentState= $service.State
        }
    }
}