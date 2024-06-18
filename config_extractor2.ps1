# config_extractor.ps1
# PowerShell Script to extract system configurations on Windows Server

# Define output file
$outputFile = "configsave.txt"

# Get current date and time
$currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $outputFile -Value ("="*80)
Add-Content -Path $outputFile -Value "Date and Time: $currentDateTime"

# Get system information
$systemInfo = Get-ComputerInfo
Add-Content -Path $outputFile -Value ("="*80)
Add-Content -Path $outputFile -Value "System Information:"
Add-Content -Path $outputFile -Value ($systemInfo | Out-String)

# Define the list of config files to extract
$configFiles = @(
    "C:\Windows\System32\drivers\etc\hosts",
    "C:\Windows\System32\GroupPolicy\Machine\Registry.pol",
    "C:\Windows\System32\GroupPolicy\User\Registry.pol",
    "C:\Windows\System32\sysprep\sysprep.xml",
    "C:\Windows\System32\wbem\Repository\INDEX.BTR",
    "C:\Windows\System32\wbem\Repository\OBJECTS.DATA"
)

# Remove duplicate entries from the list
$configFiles = $configFiles | Sort-Object -Unique

# Function to convert binary file to human-readable format
function ConvertTo-HumanReadable {
    param (
        [string]$filePath
    )

    try {
        $output = & certutil -dump $filePath
        return $output
    } catch {
        Write-Error "Failed to convert $filePath to human-readable format."
        return $null
    }
}

# Loop through each config file and save its contents
foreach ($file in $configFiles) {
    if (Test-Path $file) {
        Add-Content -Path $outputFile -Value ("="*80)
        Add-Content -Path $outputFile -Value "Contents of $file:"
        Add-Content -Path $outputFile -Value ("="*80)
        
        # Check if the file is binary and convert if necessary
        if ($file -match "INDEX.BTR|OBJECTS.DATA") {
            $humanReadableContent = ConvertTo-HumanReadable -filePath $file
            Add-Content -Path $outputFile -Value ($humanReadableContent | Out-String)
        } else {
            Get-Content -Path $file | Add-Content -Path $outputFile
        }
    } else {
        Add-Content -Path $outputFile -Value ("="*80)
        Add-Content -Path $outputFile -Value "File $file does not exist."
    }
}

# Get Windows Firewall status
$firewallStatus = Get-NetFirewallProfile | Select-Object -Property Name, Enabled
Add-Content -Path $outputFile -Value ("="*80)
Add-Content -Path $outputFile -Value "Windows Firewall Status:"
Add-Content -Path $outputFile -Value ("="*80)
Add-Content -Path $outputFile -Value ($firewallStatus | Out-String)

# Define the list of .dll files (example, since Windows doesn't use .so files)
$dllFiles = @(
    "C:\Windows\System32\example1.dll",
    "C:\Windows\System32\example2.dll"
)

# Loop through each .dll file and save its contents using objdump
foreach ($dllFile in $dllFiles) {
    if (Test-Path $dllFile) {
        $objdumpOutput = & "C:\Path\To\objdump.exe" -D $dllFile
        Add-Content -Path $outputFile -Value ("#*#* Contents of $dllFile:")
        Add-Content -Path $outputFile -Value ($objdumpOutput | Out-String)
    } else {
        Add-Content -Path $outputFile -Value ("#*#* File $dllFile does not exist.")
    }
}
