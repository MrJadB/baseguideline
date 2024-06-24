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

# Function to read binary file and convert to human-readable format
function Read-BinaryFile {
    param (
        [string]$filePath
    )
    try {
        $stream = New-Object System.IO.FileStream($filePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
        $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::ASCII)
        $content = $reader.ReadToEnd()
        $reader.Close()
        $stream.Close()
        return $content
    } catch {
        Write-Host "Error reading file: $_"
        return ""
    }
}

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
            $output = Read-BinaryFile $file
            Add-Content -Path $outputFile -Value $output
        } else {
            Get-Content -Path $file | Out-File -Append -FilePath $outputFile
        }
    } else {
        Add-Content -Path $outputFile -Value "File $file not found."
    }
}

# Check the status of the firewall service
Write-SectionHeader "Firewall Service Status"
netsh advfirewall show allprofiles | Out-File -Append -FilePath $outputFile

# Array to collect .dll files found in the config files
$dllFiles = @()

# Find .dll files mentioned in config files
foreach ($file in $configFiles) {
    if (Test-Path -Path $file) {
        if ($file -notmatch "INDEX.BTR|OBJECTS.DATA") {
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
}

# Process each .dll file at the end
Write-SectionHeader "DLL Files Contents"
foreach ($dllFile in $dllFiles) {
    if (Test-Path -Path $dllFile) {
        Write-SectionHeader "Strings from $dllFile"
        $output = Read-BinaryFile $dllFile
        Add-Content -Path $outputFile -Value $output
    } else {
        Add-Content -Path $outputFile -Value "DLL file $dllFile not found."
    }
}
