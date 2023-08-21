![InSpectre logo](logo.png)
# InSpectre System Information Toolkit

The InSpectre System Information Toolkit is a PowerShell module designed to retrieve comprehensive system information. This includes information related to CPU, GPU, memory, disk, network, processes, and services.

## Features

- **CPU Usage**: Get the current CPU usage percentage.
- **CPU Temperature**: Fetch the current CPU temperature.
- **Motherboard Temperature**: A placeholder for retrieving the motherboard temperature.
- **Memory Usage**: Retrieve the current memory usage details.
- **Disk Space Information**: Get free space, total space, and usage percentage for each drive.
- **Disk Temperature**: A placeholder for retrieving the temperature of each disk drive.
- **Disk Read/Write Activity**: Retrieve disk read and write activity.
- **Network Send/Receive Activity**: Get the network send and receive activity.
- **GPU Utilization and Temperature**: For NVIDIA GPUs, fetch utilization and temperature.
- **Running Processes**: Retrieve a list of running processes with optional filtering.
- **Running Services**: Retrieve a list of running services with optional filtering.
- **System Summary**: Display a summary of various system information.

## Installation

1. Clone the repository or download the module.

    ```bash
    git clone https://github.com/yourusername/InSpectre.git
    ```

2. Navigate to the directory containing the module.

    ```bash
    cd InSpectre
    ```

3. Import the module into your PowerShell session.

    ```powershell
    Import-Module .\InSpectre.psm1
    ```

## Usage

Here are examples of how to use some of the cmdlets:

### Get CPU Usage

```powershell
Get-CpuUsage
```

### Get GPU Utilization and Temperature

```powershell
Get-GpuUsage
```

### Get System Summary

```powershell
Get-InSpectreSummary
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

- Your acknowledgments here.
