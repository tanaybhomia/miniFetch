# Function to get system information
function Get-SystemInfo {
    $os = Get-WmiObject -Class Win32_OperatingSystem
    $kernel = $os.Version
    $shell = $env:SHELL -replace ".*\\(.*)", '$1'  # Extract just the shell name
    if (-not $shell) { $shell = "PowerShell" }  # Default to PowerShell if $env:SHELL is not set

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

    return @{
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
    $headerColor = "White"
    $labelColor = "Red"
    $valueColor = "Blue"
    $dividerColor = "DarkGray"

    # Header
    Write-Host
    Write-Host " $username@$hostname " -ForegroundColor $headerColor
    Write-Host ("-" * ($username.Length + $hostname.Length + 1 + 2)) -ForegroundColor $dividerColor

    # System Info
    Write-Host " OS      : " -ForegroundColor $labelColor -NoNewline
    Write-Host $info.os -ForegroundColor $valueColor
    Write-Host " Kernel  : " -ForegroundColor $labelColor -NoNewline
    Write-Host $info.kernel -ForegroundColor $valueColor
    Write-Host " Shell   : " -ForegroundColor $labelColor -NoNewline
    Write-Host $info.shell -ForegroundColor $valueColor
    Write-Host " Uptime  : " -ForegroundColor $labelColor -NoNewline
    Write-Host $info.uptime -ForegroundColor $valueColor
    Write-Host " Memory  : " -ForegroundColor $labelColor -NoNewline
    Write-Host $info.memory -ForegroundColor $valueColor
    Write-Host
}

# Clear the console and display the styled system information
Clear-Host
Show-StyledSystemInfo
