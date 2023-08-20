# System Monitoring PowerShell Module

A collection of PowerShell functions to monitor various aspects of your system`s hardware.

## Get-CpuUsage

Retrieves the current CPU usage percentage.

```powershell
Get-CpuUsage -Verbose
```

## Get-CpuTemperature

Retrieves the current CPU temperature.

```powershell
Get-CpuTemperature -Verbose
```

## Get-MotherboardTemperature

Retrieves the current motherboard temperature (not yet implemented).

```powershell
Get-MotherboardTemperature -Verbose
```

## Get-MemoryUsage

Retrieves the current memory usage.

```powershell
Get-MemoryUsage -Verbose
```

## Get-DiskSpace

Retrieves the disk space information for each drive.

```powershell
Get-DiskSpace -Verbose
```

## Get-DiskTemperature

Retrieves the temperature of each disk drive (not yet implemented).

```powershell
Get-DiskTemperature -Verbose
```

## Get-DiskActivity

Retrieves the disk read and write activity for total logical disks.

```powershell
Get-DiskActivity -Verbose
```

## Get-NetworkActivity

Retrieves the network send and receive activity.

```powershell
Get-NetworkActivity -Verbose
```

## Get-GpuUsage

Retrieves the GPU utilization and temperature for NVIDIA GPUs.

```powershell
Get-GpuUsage -Verbose
```

## Get-GpuUtilization

Retrieves the GPU utilization percentage for NVIDIA GPUs.

```powershell
Get-GpuUtilization
```

## Get-GpuTemperature

Retrieves the GPU temperature in Celsius for NVIDIA GPUs.

```powershell
Get-GpuTemperature
```

Please note that some features are not yet implemented and may require third-party tools or specific hardware APIs. Feel free to contribute and enhance the module!
