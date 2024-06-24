# Output file
$outputFile = "configsave.txt"

# Function to write section headers
function Write-SectionHeader {
    param (
        [string]$header
    )
    Add-Content -Path $outputFile -Value "================================================="
    Add-Content -Path $outputFile -Value $header
    Add-Content -Path $outputFile -Value "================================================="
}

# Write current date and time
Write-SectionHeader "Current Date and Time"
Get-Date | Out-File -Append -FilePath $outputFile

# Write system information
Write-SectionHeader "System Information"
Get-ComputerInfo | Out-File -Append -FilePath $outputFile

# List of config files to check
$configFiles = @(
    "C:\Windows\System32\drivers\etc\hosts",
    "C:\Windows\System32\drivers\etc\networks",
    "C:\Windows\System32\drivers\etc\protocol",
    "C:\Windows\System32\drivers\etc\services",
    "C:\Windows\System32\drivers\etc\lmhosts.sam",
    "C:\Windows\System32\wbem\Repository\INDEX.BTR",
    "C:\Windows\System32\wbem\Repository\OBJECTS.DATA"
)

# Process each config file
foreach ($file in $configFiles) {
    if (Test-Path -Path $file) {
        Write-SectionHeader "Contents of $file"
        if ($file -match "INDEX.BTR|OBJECTS.DATA") {
            # If PowerShell 7+, you can use Format-Hex
            if ($PSVersionTable.PSVersion.Major -ge 7) {
                Format-Hex -Path $file | Out-File -Append -FilePath $outputFile
            } else {
                Get-Content -Path $file -Encoding Byte | Format-Hex | Out-File -Append -FilePath $outputFile
            }
        } else {
            Get-Content -Path $file | Out-File -Append -FilePath $outputFile
        }
    } else {
        Add-Content -Path $outputFile -Value "File $file not found."
    }
}

# Check the status of firewalld service
Write-SectionHeader "Firewall Service Status"
Get-Service -Name "MpsSvc" | Out-File -Append -FilePath $outputFile

# Array to collect .dll files found in the config files
$dllFiles = @()

# Find .dll files mentioned in config files
foreach ($file in $configFiles) {
    if (Test-Path -Path $file -and $file -notmatch "INDEX.BTR|OBJECTS.DATA") {
        $content = Get-Content -Path $file
        foreach ($line in $content) {
            if ($line -match "\.dll") {
                $dllFile = $line -replace '.*?(\S*\.dll).*','$1'
                if (-not ($dllFiles -contains $dllFile)) {
                    $dllFiles += $dllFile
                }
            }
        }
    }
}

# Process each .dll file at the end
Write-SectionHeader "DLL Files Contents"
foreach ($dllFile in $dllFiles) {
    if (Test-Path -Path $dllFile) {
        Write-SectionHeader "Strings from $dllFile"
        strings "$dllFile" | Out-File -Append -FilePath $outputFile
    } else {
        Add-Content -Path $outputFile -Value "DLL file $dllFile not found."
    }
}
