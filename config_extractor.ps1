# Save this script as config_extractor.ps1
$output_file = "configsave.txt"

function Log-Date {
    Add-Content -Path $output_file -Value "============================================================"
    Add-Content -Path $output_file -Value "==== Date and Time ===="
    Get-Date | Out-String | Add-Content -Path $output_file
    Add-Content -Path $output_file -Value ""
}

function Log-SystemInfo {
    Add-Content -Path $output_file -Value "============================================================"
    Add-Content -Path $output_file -Value "==== System Information ===="
    Get-ComputerInfo | Out-String | Add-Content -Path $output_file
    Add-Content -Path $output_file -Value ""
}

function Log-FileContents {
    param (
        [string]$file_path
    )
    Add-Content -Path $output_file -Value "============================================================"
    Add-Content -Path $output_file -Value "==== Contents of $file_path ===="
    Get-Content -Path $file_path | Out-String | Add-Content -Path $output_file
    Add-Content -Path $output_file -Value ""
}

function Log-FirewallStatus {
    Add-Content -Path $output_file -Value "============================================================"
    Add-Content -Path $output_file -Value "==== Status of Windows Firewall ===="
    Get-NetFirewallProfile | Out-String | Add-Content -Path $output_file
    Add-Content -Path $output_file -Value ""
}

function Extract-DllFiles {
    param (
        [string[]]$file_content
    )
    $dll_files = @()
    
    foreach ($line in $file_content) {
        if ($line -match '\.dll') {
            $dll_files += ($line -replace '.*\s', '').Trim()
        }
    }
    
    return $dll_files
}

function Process-AndLog-DllFiles {
    param (
        [string[]]$dll_files
    )

    foreach ($dll_file in $dll_files) {
        $found_files = Get-ChildItem -Path C:\ -Filter $dll_file -Recurse -ErrorAction SilentlyContinue
        foreach ($found_file in $found_files) {
            Add-Content -Path $output_file -Value "#*#* $found_file"
            & "dumpbin" /ALL $found_file.FullName | Out-String | Add-Content -Path $output_file
            Add-Content -Path $output_file -Value ""
        }
    }
}

Log-Date
Log-SystemInfo

$config_files = @(
    "C:\Windows\System32\drivers\etc\hosts",
    "C:\Windows\System32\GroupPolicy\Machine\Registry.pol",
    "C:\Windows\System32\GroupPolicy\User\Registry.pol",
    "C:\Windows\System32\sysprep\sysprep.xml",
    "C:\Windows\System32\wbem\Repository\FS\INDEX.BTR",
    "C:\Windows\System32\wbem\Repository\FS\OBJECTS.DATA"
)

$collected_dll_files = @()

foreach ($config_file in $config_files) {
    if (Test-Path -Path $config_file) {
        Log-FileContents -file_path $config_file
        $file_content = Get-Content -Path $config_file
        $dll_files = Extract-DllFiles -file_content $file_content
        $collected_dll_files += $dll_files
    } else {
        Add-Content -Path $output_file -Value "============================================================"
        Add-Content -Path $output_file -Value "File $config_file does not exist."
    }
}

Log-FirewallStatus

Process-AndLog-DllFiles -dll_files $collected_dll_files

Write-Output "Configuration extraction completed. Output saved to $output_file."
