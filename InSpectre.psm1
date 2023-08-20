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

    $cpuUtilization
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
        $celsius = ($temperature.CurrentTemperature - 2732) / 10
        Write-Debug "CPU temperature retrieved: $celsius°C"
        $celsius
    } else {
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
            LogicalDisk       = "C:"
            ReadMBPerSecond   = $readMBPerSec
            WriteMBPerSecond  = $writeMBPerSec
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
    Retrieves the GPU utilization and temperature for NVIDIA GPUs.

    .DESCRIPTION
    This cmdlet retrieves the GPU utilization percentage and temperature in Celsius for NVIDIA GPUs.

    .EXAMPLE
    Get-GpuUsage -Verbose

    .OUTPUTS
    [PSCustomObject] An object containing GPU ID, utilization percentage, and temperature in Celsius.
    #>

    Write-Verbose "Querying GPU utilization and temperature for NVIDIA GPUs..."

    $nvidiaSmiPath = "C:\WINDOWS\system32\nvidia-smi.exe"
    
    if (Test-Path $nvidiaSmiPath) {
        $gpuInfo = & $nvidiaSmiPath --query-gpu=index,utilization.gpu,temperature.gpu --format=csv,noheader,nounits
        
        $gpuData = $gpuInfo | ForEach-Object {
            $data = $_.Split(',')
            [PSCustomObject]@{
                GpuId         = $data[0].Trim()
                Utilization   = [int]$data[1].Trim()
                Temperature   = [int]$data[2].Trim()
            }
        }

        Write-Debug "GPU information retrieved: $($gpuData | Out-String)"

        $gpuData
    } else {
        Write-Warning "NVIDIA System Management Interface (nvidia-smi) not found at path $nvidiaSmiPath. Please ensure it is installed and the path is correct."
        return $null
    }
}

function Get-GpuUtilization {
    [CmdletBinding()]
    param()
    
    <#
    .SYNOPSIS
    Retrieves the GPU utilization percentage for NVIDIA GPUs.

    .EXAMPLE
    Get-GpuUtilization

    .OUTPUTS
    [PSCustomObject] An object containing GPU ID and utilization percentage.
    #>

    $nvidiaSmiPath = "C:\WINDOWS\system32\nvidia-smi.exe"
    $gpuInfo = & $nvidiaSmiPath --query-gpu=index,utilization.gpu --format=csv,noheader,nounits
    
    $gpuData = $gpuInfo | ForEach-Object {
        $data = $_.Split(',')
        [PSCustomObject]@{
            GpuId       = $data[0].Trim()
            Utilization = [int]$data[1].Trim()
        }
    }

    $gpuData
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

    $nvidiaSmiPath = "C:\WINDOWS\system32\nvidia-smi.exe"
    $gpuInfo = & $nvidiaSmiPath --query-gpu=name,temperature.gpu --format=csv,noheader,nounits
    
    $gpuData = $gpuInfo | ForEach-Object {
        $lastCommaIndex = $_.LastIndexOf(',')
        $gpuName = $_.Substring(0, $lastCommaIndex)
        $temperature = $_.Substring($lastCommaIndex + 1).Trim()

        [PSCustomObject]@{
            GpuName     = $gpuName
            Temperature = [int]$temperature
        }
    }

    $gpuData
}
