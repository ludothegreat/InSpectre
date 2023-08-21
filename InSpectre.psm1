function Get-CpuUsage {
    [CmdletBinding()]
    param()
    
    <#
    .SYNOPSIS
    Retrieves the current CPU usage percentage.

    .DESCRIPTION
    This cmdlet retrieves the current CPU usage as a percentage of total capacity using the Get-Counter cmdlet.

    .EXAMPLE
    Get-CpuUsage -Verbose

    .OUTPUTS
    [float] CPU usage percentage.
    #>

    Write-Verbose "Retrieving CPU utilization using Get-Counter..."
    
    $cpuUtilization = Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples 1 |
    Select-Object -ExpandProperty CounterSamples |
    Select-Object -ExpandProperty CookedValue |
    ForEach-Object { [math]::Round($_, 2) }

    Write-Debug "CPU utilization retrieved: $cpuUtilization%"

    [PSCustomObject]@{
        ProcessorName = "Core i7-12700F"
        Utilization   = $cpuUtilization
    }
}

function Get-CpuTemperature {
    [CmdletBinding()]
    param()
    
    <#
    .SYNOPSIS
    Retrieves the current CPU temperature.

    .DESCRIPTION
    This cmdlet attempts to retrieve the current CPU temperature using the MSAcpi_ThermalZoneTemperature WMI class.

    .EXAMPLE
    Get-CpuTemperature -Verbose

    .OUTPUTS
    [float] CPU temperature in degrees Celsius.
    #>

    Write-Verbose "Querying WMI for CPU temperature..."
    
    $temperature = Get-WmiObject -Query "SELECT * FROM MSAcpi_ThermalZoneTemperature" -Namespace "root/wmi"

    if ($null -ne $temperature) {
        $celsius = [math]::Round(($temperature.CurrentTemperature - 2732) / 10, 2)
        Write-Debug "CPU temperature retrieved: $celsius°C"

        [PSCustomObject]@{
            ProcessorName    = "Core i7-12700F"
            'Temperature °C' = $celsius
        }
    }
    else {
        Write-Warning "Unable to retrieve CPU temperature. This feature may not be supported on your system."
        $null
    }
}

function Get-MotherboardTemperature {
    [CmdletBinding()]
    param()
    
    <#
    .SYNOPSIS
    Retrieves the current motherboard temperature.

    .DESCRIPTION
    This cmdlet is a placeholder for retrieving the motherboard temperature. Actual implementation may require
    third-party tools, drivers, or specific hardware APIs.

    .EXAMPLE
    Get-MotherboardTemperature -Verbose

    .OUTPUTS
    [float] Motherboard temperature in degrees Celsius.
    #>

    Write-Verbose "Querying motherboard temperature..."

    # Placeholder logic to retrieve the motherboard temperature
    # You may need to call into a third-party tool or specific hardware API

    Write-Warning "Motherboard temperature retrieval is not implemented. You may need specific tools or APIs for your hardware."

    $null
}

function Get-MemoryUsage {
    [CmdletBinding()]
    param()
    
    <#
    .SYNOPSIS
    Retrieves the current memory usage.

    .DESCRIPTION
    This cmdlet retrieves the total and free physical memory, as well as the percentage of memory used.

    .EXAMPLE
    Get-MemoryUsage -Verbose

    .OUTPUTS
    [PSCustomObject] An object containing total memory, free memory, and memory usage percentage.
    #>

    Write-Verbose "Querying total and free physical memory..."

    $os = Get-CimInstance -ClassName CIM_OperatingSystem
    $totalMemoryGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeMemoryGB = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $usedMemoryPercentage = [math]::Round((($totalMemoryGB - $freeMemoryGB) / $totalMemoryGB) * 100, 2)

    Write-Debug "Total Memory: $totalMemoryGB GB, Free Memory: $freeMemoryGB GB, Used Memory: $usedMemoryPercentage%"

    [PSCustomObject]@{
        TotalMemoryGB        = $totalMemoryGB
        FreeMemoryGB         = $freeMemoryGB
        UsedMemoryPercentage = $usedMemoryPercentage
    }
}

function Get-DiskSpace {
    [CmdletBinding()]
    param()
    
    <#
    .SYNOPSIS
    Retrieves the disk space information for each drive.

    .DESCRIPTION
    This cmdlet retrieves the free space, total space, and disk usage percentage for each drive.

    .EXAMPLE
    Get-DiskSpace -Verbose

    .OUTPUTS
    [PSCustomObject[]] An array of objects containing drive name, free space, total space, and disk usage percentage.
    #>

    Write-Verbose "Querying disk space for all drives..."

    $diskSpaceInfo = Get-PSDrive -PSProvider 'FileSystem' | ForEach-Object {
        $freeSpaceGB = [math]::Round($_.Free / 1GB, 2)
        $totalSpaceGB = [math]::Round(($_.Used + $_.Free) / 1GB, 2)
        $usedSpacePercentage = [math]::Round(($_.Used / ($_.Used + $_.Free)) * 100, 2)

        Write-Debug "Drive: $($_.Name), Free Space: $freeSpaceGB GB, Total Space: $totalSpaceGB GB, Used Space: $usedSpacePercentage%"

        [PSCustomObject]@{
            DriveName           = $_.Name
            FreeSpaceGB         = $freeSpaceGB
            TotalSpaceGB        = $totalSpaceGB
            UsedSpacePercentage = $usedSpacePercentage
        }
    }

    $diskSpaceInfo
}

function Get-DiskTemperature {
    [CmdletBinding()]
    param()
    
    <#
    .SYNOPSIS
    Retrieves the temperature of each disk drive.

    .DESCRIPTION
    This cmdlet is a placeholder for retrieving the temperature of each disk drive. Actual implementation may require
    third-party tools, drivers, or specific hardware APIs.

    .EXAMPLE
    Get-DiskTemperature -Verbose

    .OUTPUTS
    [PSCustomObject[]] An array of objects containing drive name and temperature.
    #>

    Write-Verbose "Querying disk temperature for all drives..."

    # Placeholder logic to retrieve disk temperature
    # You may need to call into a third-party tool or specific hardware API

    Write-Warning "Disk temperature retrieval is not implemented. You may need specific tools or APIs for your hardware."

    $null
}

function Get-DiskActivity {
    [CmdletBinding()]
    param()
    
    <#
    .SYNOPSIS
    Retrieves the disk read and write activity for total logical disks.

    .DESCRIPTION
    This cmdlet retrieves the read and write megabytes per second for total logical disks.

    .EXAMPLE
    Get-DiskActivity -Verbose

    .OUTPUTS
    [PSCustomObject] An object containing logical disk name (_Total), read MB/s, and write MB/s.
    #>

    Write-Verbose "Querying disk read and write activity for total logical disks..."

    $diskActivityInfo = Get-Counter -Counter '\LogicalDisk(_Total)\Disk Read Bytes/sec', '\LogicalDisk(_Total)\Disk Write Bytes/sec' -SampleInterval 1 -MaxSamples 1 | ForEach-Object {
        $readMBPerSec = [math]::Round($_.CounterSamples[0].CookedValue / 1MB, 2)
        $writeMBPerSec = [math]::Round($_.CounterSamples[1].CookedValue / 1MB, 2)

        Write-Debug "Logical Disk: _Total, Read MB/s: $readMBPerSec, Write MB/s: $writeMBPerSec"

        [PSCustomObject]@{
            LogicalDisk      = "C:"
            ReadMBPerSecond  = $readMBPerSec
            WriteMBPerSecond = $writeMBPerSec
        }
    }

    $diskActivityInfo
}

function Get-NetworkActivity {
    [CmdletBinding()]
    param()
    
    <#
    .SYNOPSIS
    Retrieves the network send and receive activity.

    .DESCRIPTION
    This cmdlet retrieves the network send and receive megabits per second for all network interfaces.

    .EXAMPLE
    Get-NetworkActivity -Verbose

    .OUTPUTS
    [PSCustomObject] An object containing total network send Mbps and receive Mbps.
    #>

    Write-Verbose "Querying network send and receive activity for all network interfaces..."

    $networkAdapters = Get-NetAdapterStatistics
    $sendBytesPerSec = 0
    $receiveBytesPerSec = 0

    foreach ($adapter in $networkAdapters) {
        $sendBytesPerSec += $adapter.SentBytes
        $receiveBytesPerSec += $adapter.ReceivedBytes
    }

    # We'll calculate the difference between two consecutive queries to get the rate
    Start-Sleep -Seconds 1
    $networkAdapters = Get-NetAdapterStatistics
    $sendBytesPerSecNew = 0
    $receiveBytesPerSecNew = 0

    foreach ($adapter in $networkAdapters) {
        $sendBytesPerSecNew += $adapter.SentBytes
        $receiveBytesPerSecNew += $adapter.ReceivedBytes
    }

    $sendMbps = [math]::Round(($sendBytesPerSecNew - $sendBytesPerSec) * 8 / 1MB, 2)
    $receiveMbps = [math]::Round(($receiveBytesPerSecNew - $receiveBytesPerSec) * 8 / 1MB, 2)

    Write-Debug "Total Network Send Mbps: $sendMbps, Receive Mbps: $receiveMbps"

    [PSCustomObject]@{
        NetworkInterface = "_Total"
        SendMbps         = $sendMbps
        ReceiveMbps      = $receiveMbps
    }
}

function Get-GpuUsage {
    [CmdletBinding()]
    param()

    <#
    .SYNOPSIS
    Retrieves the GPU utilization percentage and temperature.

    .DESCRIPTION
    This cmdlet retrieves the GPU name, utilization percentage, and temperature for NVIDIA GPUs.

    .EXAMPLE
    Get-GpuUsage

    .OUTPUTS
    [PSCustomObject] An object containing GPU name, utilization percentage, and temperature.
    #>

    Write-Verbose "Retrieving GPU utilization and temperature..."
    $gpuUtilization = & 'nvidia-smi' --query-gpu=utilization.gpu --format=csv,noheader,nounits
    $gpuTemperature = & 'nvidia-smi' --query-gpu=temperature.gpu --format=csv,noheader,nounits
    Write-Debug "GPU Utilization: $gpuUtilization%, Temperature: $gpuTemperature°C"
    [PSCustomObject]@{
        GpuName      = "NVIDIA GeForce RTX 3070"
        Utilization  = [int]$gpuUtilization
        Temperature  = [int]$gpuTemperature
    }
}

function Get-GpuUtilization {
    [CmdletBinding()]
    param()

    <#
    .SYNOPSIS
    Retrieves the GPU utilization percentage.

    .DESCRIPTION
    This cmdlet retrieves the GPU name and utilization percentage for NVIDIA GPUs.

    .EXAMPLE
    Get-GpuUtilization

    .OUTPUTS
    [PSCustomObject] An object containing GPU name and utilization percentage.
    #>

    Write-Verbose "Retrieving GPU utilization percentage..."

    $gpuUtilization = & 'nvidia-smi' --query-gpu=utilization.gpu --format=csv,noheader,nounits
    Write-Debug "GPU Utilization: $gpuUtilization%"
    [PSCustomObject]@{
        GpuName      = "NVIDIA GeForce RTX 3070"
        Utilization  = [int]$gpuUtilization
    }
}

function Get-GpuTemperature {
    [CmdletBinding()]
    param()
    
    <#
    .SYNOPSIS
    Retrieves the GPU temperature in Celsius for NVIDIA GPUs.

    .EXAMPLE
    Get-GpuTemperature

    .OUTPUTS
    [PSCustomObject] An object containing GPU ID and temperature in Celsius.
    #>

    Write-Verbose "Retrieving GPU temperature in Celsius..."

    $gpuTemperature = & 'nvidia-smi' --query-gpu=temperature.gpu --format=csv,noheader,nounits
    Write-Debug "GPU Temperature: $gpuTemperature°C"
    [PSCustomObject]@{
        GpuName      = "NVIDIA GeForce RTX 3070"
        Temperature  = [int]$gpuTemperature
    }
}

function Get-RunningProcesses {
    [CmdletBinding()]
    param(
        [string]$Name,
        [int]$MinCpuUsage,
        [int]$MinMemoryUsage
    )

    <#
    .SYNOPSIS
    Retrieves a list of running processes.

    .DESCRIPTION
    This cmdlet retrieves a list of running processes, with optional filtering by name, minimum CPU usage, or minimum memory usage.

    .PARAMETER Name
    Specifies the process name to filter on.

    .PARAMETER MinCpuUsage
    Specifies the minimum CPU usage percentage to filter on.

    .PARAMETER MinMemoryUsage
    Specifies the minimum memory usage (in MB) to filter on.

    .EXAMPLE
    Get-RunningProcesses -MinCpuUsage 10

    .OUTPUTS
    [System.Diagnostics.Process] A list of running processes.
    #>

    Write-Verbose "Querying running processes with Name: '$Name', MinCpuUsage: $MinCpuUsage, MinMemoryUsage: $MinMemoryUsage..."

    $processes = Get-Process | Where-Object {
        ($_ -match $Name -or [string]::IsNullOrEmpty($Name)) -and
        ($_.CPU -ge $MinCpuUsage -or [string]::IsNullOrEmpty($MinCpuUsage)) -and
        (($_.WorkingSet64 / 1MB) -ge $MinMemoryUsage -or [string]::IsNullOrEmpty($MinMemoryUsage))
    }

    Write-Debug "Found $($processes.Count) matching processes."

    $processes | Select-Object -Property Name, CPU, @{Name = "Memory(MB)"; Expression = { [math]::Round($_.WorkingSet64 / 1MB, 2) } }
}

function Get-RunningServices {
    [CmdletBinding()]
    param(
        [string]$Status,
        [string]$Name
    )

    <#
    .SYNOPSIS
    Retrieves a list of running services.

    .DESCRIPTION
    This cmdlet retrieves a list of running services, with optional filtering by service status or service name.

    .PARAMETER Status
    Specifies the service status to filter on (e.g., 'Running', 'Stopped').

    .PARAMETER Name
    Specifies the service name to filter on.

    .EXAMPLE
    Get-RunningServices -Status 'Running'

    .EXAMPLE
    Get-RunningServices -Name 'wuauserv'

    .OUTPUTS
    [System.ServiceProcess.ServiceController] A list of running services.
    #>

    Write-Verbose "Querying running services..."

    $services = Get-Service -ErrorAction SilentlyContinue | Where-Object {
        ($_ -match $Name -or [string]::IsNullOrEmpty($Name)) -and
        ($_.Status -eq $Status -or [string]::IsNullOrEmpty($Status))
    }

    Write-Debug "Found $($services.Count) services with status '$Status' and name '$Name'."

    $services | ForEach-Object {
        try {
            $_ | Select-Object -Property DisplayName, Status, ServiceName
        }
        catch {
            Write-Debug "Failed to query service '$($_.Name)': $_"
        }
    }
}

function Get-InSpectreSummary {
    [CmdletBinding()]
    param()

    <#
    .SYNOPSIS
    Retrieves and displays a summary of system information.

    .DESCRIPTION
    This cmdlet retrieves and presents a summary of various system information including CPU, GPU, memory, disk, network, processes, and services.

    .EXAMPLE
    Get-SystemSummary
    #>

    Write-Host "`nCPU Information:"
    Get-CpuUsage | Format-Table -AutoSize

    Write-Host "`nCPU Temperature:"
    Get-CpuTemperature | Format-Table -AutoSize

    Write-Host "`nGPU Information:"
    Get-GpuUsage | Format-Table -AutoSize

    Write-Host "`nMemory Usage:"
    Get-MemoryUsage | Format-Table -AutoSize

    Write-Host "`nDisk Space Information:"
    Get-DiskSpace | Format-Table -AutoSize

    Write-Host "`nDisk Activity:"
    Get-DiskActivity | Format-Table -AutoSize

    Write-Host "`nNetwork Activity:"
    Get-NetworkActivity | Format-Table -AutoSize

    Write-Host "`nRunning Processes (Top 5 by CPU):"
    Get-RunningProcesses | Sort-Object CPU -Descending | Select-Object -First 5 | Format-Table -AutoSize

    Write-Host "`nRunning Services (Top 5):"
    Get-RunningServices -Status 'Running' | Select-Object -First 5 | Format-Table -AutoSize

    Write-Host "`nMotherboard Temperature:"
    Get-MotherboardTemperature | Format-Table -AutoSize

    Write-Host "`nDisk Temperature Information:"
    Get-DiskTemperature | Format-Table -AutoSize

    Write-Host "`nSystem Summary Completed.`n"
}
