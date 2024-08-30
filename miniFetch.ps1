# Function to get system information
function Get-SystemInfo {
    $os = Get-WmiObject -Class Win32_OperatingSystem
    $kernel = $os.Version
    $shell = if ($env:SHELL) { $env:SHELL -replace ".*\\(.*)", '$1' } else { "PowerShell" }
    
    # Convert LastBootUpTime to DateTime and calculate uptime
    try {
        $lastBootUpTime = [System.Management.ManagementDateTimeConverter]::ToDateTime($os.LastBootUpTime)
    } catch {
        $lastBootUpTime = Get-Date
    }
    
    $uptime = New-TimeSpan -Start $lastBootUpTime
    $memory = Get-WmiObject -Class Win32_OperatingSystem | 
              Select-Object @{Name="UsedMemoryMB";Expression={[math]::Round(($_.TotalVisibleMemorySize - $_.FreePhysicalMemory)/1024, 0)}},
                            @{Name="TotalMemoryMB";Expression={[math]::Round($_.TotalVisibleMemorySize/1024, 0)}}

    @{
        "os" = $os.Caption
        "kernel" = $kernel
        "shell" = $shell
        "uptime" = "{0}d {1}h {2:D2}m" -f $uptime.Days, $uptime.Hours, $uptime.Minutes
        "memory" = "{0}MB / {1}MB" -f $memory.UsedMemoryMB, $memory.TotalMemoryMB
    }
}

# Function to display styled system information
function Show-StyledSystemInfo {
    $info = Get-SystemInfo
    $username = $env:USERNAME
    $hostname = $env:COMPUTERNAME

    # Color settings
    $colors = @{
        Header = "White"
        Label = "Red"
        Value = "Blue"
        Divider = "DarkGray"
    }

    # Header
    Write-Host
    Write-Host " $username@$hostname " -ForegroundColor $colors.Header
    Write-Host ("-" * ($username.Length + $hostname.Length + 3)) -ForegroundColor $colors.Divider

    # System Info
    foreach ($item in $info.GetEnumerator()) {
        Write-Host (" $($item.Key.PadRight(8)) : ") -ForegroundColor $colors.Label -NoNewline
        Write-Host $item.Value -ForegroundColor $colors.Value
    }
    Write-Host
}

# Clear the console and display the styled system information
Clear-Host
Show-StyledSystemInfo