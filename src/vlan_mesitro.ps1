###############################################################################
# ================================================================================
# POWERSHELL - VLAN MESITRO OPERATING DIRECTIVES
# ================================================================================
#
# This project includes AI-generated code assistance provided by GitHub Copilot.
#
# GitHub Copilot is an AI programming assistant that helps developers write code
# more efficiently by providing suggestions and completing code patterns.
#
# Ground Rules for AI Assistance:
# - No modifications to working code without explicit request
# - Comprehensive commenting of all code and preservation of existing comments
# - Small, incremental changes to maintain code stability
# - Verification before implementation of any suggestions
# - Stay focused on the current task - do not jump ahead or suggest next steps
# - Answer only what is asked - do not anticipate or propose additional work
# - ALL user prompts and AI solutions must be documented verbatim in the change log
#   Format: User prompt as single line, followed by itemized solution with → bullet
# - INCREMENT VERSION by 0.01 for ANY code changes (e.g., 1.8 → 1.81)
#
# File Header Standard and CHANGE LOG (below):
# - Use consistent separator lines (80 characters of =)
# - Include AI assistance rules in every file header
# - Maintain change log with verbatim user prompt and solution
#
# ================================================================================
# PROJECT: DPX_VLAN_MEISTRO
# VERSION: 1.83
# ================================================================================
#
# [File-specific information]
# File: vlan_mesitro.powershell
# Purpose: Interactive script to create a virtual switch and VLAN network adapters
#          on Windows Hyper-V host, with cleanup of existing configurations and
#          robust IP assignment with delays for proper execution.
# Dependencies: Windows PowerShell Hyper-V module, administrative privileges.
#
# TODO LIST:
# 1. Test "nuke all" feature thoroughly on Hyper-V host with real network adapters
# 2. Test actual network connectivity and VLAN functionality with physical network
# 3. Add input validation for IP octets and VLAN selections
# 4. Consider making delay timing configurable via command line parameter
# 5. Add progress indicators for long-running operations
# 6. Add logging capabilities for troubleshooting and audit trails
# 7. Consider adding more facility VLAN configurations to JSON
# 8. Add dry-run mode for testing without making actual changes
# 9. Add backup/restore functionality for existing network configurations
# 10. Consider adding GUI interface using Windows Forms or WPF - i was thining python OG
#

#
# ================================================================================
################################################################################
# Original commented commands for reference:
#--------------------------------------------------------------------------------
# Create a bew virtual switch named vLanSwitch bound to the physical NIC
# Replace [PHYSICALNICNAME] with the name of the physical NIC you want to bind
# New-VMSwitch -name vLanSwitch -NetAdapterName [PHYSICALNICNAME] -AllowManagementOs $true

# Add virtual network adapters to the management OS and assign them to VLANs
# These are a set of common vlans used in the 4Wall NY facility
# Add-VMNetworkAdapter -ManagementOS -Name 196_Engineering -SwitchName vLanSwitch
# Set-VMNetworkAdapterVlan -VMNetworkAdapterName 196_Engineering -VlanId 196 -Access -ManagementOS
# Add-VMNetworkAdapter -ManagementOS -Name 200_d3Net -SwitchName vLanSwitch
# Set-VMNetworkAdapterVlan -VMNetworkAdapterName 200_d3Net -VlanId 200 -Access -ManagementOS
# Add-VMNetworkAdapter -ManagementOS -Name 210_sACN -SwitchName vLanSwitch
# Set-VMNetworkAdapterVlan -VMNetworkAdapterName 210_sACN -VlanId 210 -Access -ManagementOS
# Add-VMNetworkAdapter -ManagementOS -Name 214_10gMedia -SwitchName vLanSwitch
# Set-VMNetworkAdapterVlan -VMNetworkAdapterName 214_10gMedia -VlanId 214 -Access -ManagementOS
# Add-VMNetworkAdapter -ManagementOS -Name 216_10gMedia2 -SwitchName vLanSwitch
# Set-VMNetworkAdapterVlan -VMNetworkAdapterName 216_10gMedia2 -VlanId 216 -Access -ManagementOS
# Add-VMNetworkAdapter -ManagementOS -Name 206_LED -SwitchName vLanSwitch
# Set-VMNetworkAdapterVlan -VMNetworkAdapterName 206_LED -VlanId 206 -Access -ManagementOS
################################################################################
# Interactive PowerShell script to create virtual switch and VLAN adapters

# ASCII Art Title
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                           ██████╗ ██████╗ ██╗  ██╗                           ║" -ForegroundColor Cyan
Write-Host "║                           ██╔══██╗██╔══██╗╚██╗██╔╝                           ║" -ForegroundColor Cyan
Write-Host "║                           ██║  ██║██████╔╝ ╚███╔╝                            ║" -ForegroundColor Cyan
Write-Host "║                           ██║  ██║██╔═══╝  ██╔██╗                            ║" -ForegroundColor Cyan
Write-Host "║                           ██████╔╝██║     ██╔╝ ██╗                           ║" -ForegroundColor Cyan
Write-Host "║                           ╚═════╝ ╚═╝     ╚═╝  ╚═╝                           ║" -ForegroundColor Cyan
Write-Host "║                                                                              ║" -ForegroundColor Cyan
Write-Host "║                             VLAN MEISTRO v1.83                               ║" -ForegroundColor Yellow
Write-Host "║                      Hyper-V Network Configuration Tool                      ║" -ForegroundColor Yellow
Write-Host "╚══════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Warning Message
Write-Host "╔══════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
Write-Host "║                              ⚠️  WARNING ⚠️                                 ║" -ForegroundColor Red
Write-Host "║                                                                              ║" -ForegroundColor Red
Write-Host "║  This tool will MODIFY your network configuration!                           ║" -ForegroundColor Yellow
Write-Host "║                                                                              ║" -ForegroundColor Red
Write-Host "║  • Selected network interfaces will have their virtual switches REMOVED      ║" -ForegroundColor White
Write-Host "║  • All VLAN adapters on those interfaces will be DELETED                     ║" -ForegroundColor White
Write-Host "║  • New virtual switches and VLAN configurations will be CREATED              ║" -ForegroundColor White
Write-Host "║  • IP addresses will be reassigned (static, not DHCP)                        ║" -ForegroundColor White
Write-Host "║                                                                              ║" -ForegroundColor Red
Write-Host "║  This may DISCONNECT network services temporarily!                           ║" -ForegroundColor Yellow
Write-Host "║  Ensure you have console/physical access before proceeding.                  ║" -ForegroundColor Yellow
Write-Host "║                                                                              ║" -ForegroundColor Red
Write-Host "║  Press Ctrl+C at any time to cancel.                                         ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
Write-Host ""

# Check for administrative privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: This script must be run as Administrator to modify Hyper-V network settings."
    Write-Host "Please restart PowerShell as Administrator (right-click PowerShell, 'Run as administrator') and try again."
    exit
}

$delay =  10 # Delay in seconds between commands

# Function to show countdown during delays
function Start-Countdown {
    param([int]$seconds)
    for ($i = 1; $i -le $seconds; $i++) {
        Write-Host -NoNewline "."
        Start-Sleep -Seconds 1
    }
    Write-Host ""
}

# Function to convert CIDR notation to subnet mask
function Convert-CidrToSubnetMask {
    param([int]$cidr)
    $mask = [uint32]::MaxValue -shl (32 - $cidr)
    $bytes = [BitConverter]::GetBytes([IPAddress]::NetworkToHostOrder($mask))
    return "{0}.{1}.{2}.{3}" -f $bytes[0], $bytes[1], $bytes[2], $bytes[3]
}

# Define hardcoded VLAN configurations (used as fallbacks)
$hardcoded4Wall = @{
    vlans = @(
        @{Name="196_Engineering"; VlanId=196},
        @{Name="200_d3Net"; VlanId=200},
        @{Name="210_sACN"; VlanId=210},
        @{Name="214_10gMedia"; VlanId=214},
        @{Name="216_10gMedia2"; VlanId=216},
        @{Name="206_LED"; VlanId=206}
    )
    ipBase = "10.{vlan}.{third}.{fourth}"
    ipPrompts = @("third", "fourth")
    ipDefaults = @{third=13}
    subnet = "255.254.0.0"
}
$hardcodedAeonPoint = @{
    vlans = @(
        @{Name="10_Server_A"; VlanId=10},
        @{Name="20_Server_B"; VlanId=20},
        @{Name="30_Server_C"; VlanId=30},
        @{Name="40_Server_D"; VlanId=40},
        @{Name="50_System"; VlanId=50},
        @{Name="60_Dante_Primary"; VlanId=60},
        @{Name="65_Dante_Secondary"; VlanId=65},
        @{Name="70_KVM"; VlanId=70},
        @{Name="80_NDI"; VlanId=80},
        @{Name="90_Internet"; VlanId=90}
    )
    ipBase = "10.{vlan}.{third}.{fourth}"
    ipPrompts = @("third", "fourth")
    ipDefaults = @{third=13}
    subnet = "255.255.254.0"
}
$hardcodedDesert = @{
    vlans = @(
        @{Name="101_Server_A"; VlanId=101},
        @{Name="102_Server_B"; VlanId=102},
        @{Name="103_Server_C"; VlanId=103},
        @{Name="104_Server_D"; VlanId=104},
        @{Name="105_System"; VlanId=105},
        @{Name="106_Dante_Primary"; VlanId=106},
        @{Name="116_Dante_Secondary"; VlanId=116},
        @{Name="107_KVM"; VlanId=107},
        @{Name="108_NDI"; VlanId=108},
        @{Name="109_Internet"; VlanId=109},
        @{Name="110_Omneo"; VlanId=110},
        @{Name="111_LED"; VlanId=111},
        @{Name="112_MERGE"; VlanId=112}
    )
    ipBase = "192.168.{vlan}.{fourth}"
    ipPrompts = @("fourth")
    ipDefaults = @{}
    subnet = "255.255.255.0"
}

# Load VLAN sets from external JSON file
$vlanConfigPath = Join-Path $PSScriptRoot "vlan_sets.json"
if (Test-Path $vlanConfigPath) {
    try {
        $vlanConfig = Get-Content $vlanConfigPath -Raw | ConvertFrom-Json
        $vlans4Wall = $vlanConfig.vlanSets."4Wall"
        $vlansAeonPoint = $vlanConfig.vlanSets.AeonPoint
        $vlansDesert = $vlanConfig.vlanSets.Desert
        Write-Host "Loaded VLAN configurations from $vlanConfigPath"
    }
    catch {
        Write-Host "Error loading VLAN configuration file: $($_.Exception.Message)"
        Write-Host "Falling back to built-in configurations..."
    }
} else {
    Write-Host "Warning: VLAN configuration file not found at $vlanConfigPath"
    Write-Host "Using built-in configurations..."
}

# Build dynamic VLAN set selection
$vlanSets = @{}
$vlanSetNames = @()

# Add loaded sets to the dynamic collection
if ($vlanConfig -and $vlanConfig.vlanSets) {
    foreach ($setName in $vlanConfig.vlanSets.PSObject.Properties.Name) {
        $setData = $vlanConfig.vlanSets.$setName
        $vlanSets[$setName] = @{
            vlans = $setData.vlans
            ipBase = $setData.ipBase
            ipPrompts = $setData.ipPrompts
            ipDefaults = $setData.ipDefaults
            subnet = $setData.subnet
        }
        $vlanSetNames += $setName
    }
} else {
    # Fallback to hardcoded sets
    $vlanSets["4Wall"] = $hardcoded4Wall
    $vlanSets["AeonPoint"] = $hardcodedAeonPoint
    $vlanSets["Desert"] = $hardcodedDesert
    $vlanSetNames = @("4Wall", "AeonPoint", "Desert")
}

# Prompt for VLAN set dynamically
Write-Host "Available VLAN sets:"
for ($i = 0; $i -lt $vlanSetNames.Count; $i++) {
    $setName = $vlanSetNames[$i]
    $vlanCount = $vlanSets[$setName].vlans.Count
    Write-Host ('{0}. {1} ({2} VLANs)' -f ($i+1), $setName, $vlanCount)
}

$vlanChoice = Read-Host "Enter choice (1-$($vlanSetNames.Count)):"
$choiceIndex = [int]$vlanChoice - 1

if ($choiceIndex -ge 0 -and $choiceIndex -lt $vlanSetNames.Count) {
    $selectedVlanSet = $vlanSetNames[$choiceIndex]
    $selectedSetData = $vlanSets[$selectedVlanSet]
    $vlans = $selectedSetData.vlans
    $ipBase = $selectedSetData.ipBase
    $ipPrompts = $selectedSetData.ipPrompts
    $ipDefaults = $selectedSetData.ipDefaults
    $subnetMask = $selectedSetData.subnet

    # Convert CIDR to subnet mask if needed
    if ($subnetMask.StartsWith('/')) {
        $cidr = [int]$subnetMask.Substring(1)
        $subnetMask = Convert-CidrToSubnetMask -cidr $cidr
    }
    Write-Host ('Using {0} VLAN set ({1} VLANs).' -f $selectedVlanSet, $vlans.Count)
} else {
    Write-Host "Invalid choice, defaulting to $($vlanSetNames[0])."
    $selectedVlanSet = $vlanSetNames[0]
    $selectedSetData = $vlanSets[$selectedVlanSet]
    $vlans = $selectedSetData.vlans
    $ipBase = $selectedSetData.ipBase
    $ipPrompts = $selectedSetData.ipPrompts
    $ipDefaults = $selectedSetData.ipDefaults
    $subnetMask = $selectedSetData.subnet

    # Convert CIDR to subnet mask if needed
    if ($subnetMask.StartsWith('/')) {
        $cidr = [int]$subnetMask.Substring(1)
        $subnetMask = Convert-CidrToSubnetMask -cidr $cidr
    }
}

# No longer need special case logic - using dynamic IP configuration from JSON

# Prompt for mode
Write-Host "Select mode:"
Write-Host "1. Normal (create switch and adapters, then IP)"
Write-Host "2. IP only (skip creation, only assign IPs)"
Write-Host "3. Nuke all (remove all virtual switches except default)**CURRENTLY IN TESTING**"
$modeChoice = Read-Host 'Enter choice (1, 2, or 3, press Enter for Normal)'
if ($modeChoice -eq "2") {
    $ipOnly = $true
    $nukeAll = $false
} elseif ($modeChoice -eq "3") {
    $ipOnly = $false
    $nukeAll = $true
} else {
    $ipOnly = $false
    $nukeAll = $false
}

# Handle nuke all mode
if ($nukeAll) {
    Write-Host "NUKE ALL MODE: Removing all virtual switches except default switches..."
    Write-Host "WARNING: This will remove ALL user-created virtual switches and their VLAN adapters!"

    $confirm = Read-Host "Are you sure you want to continue? Type 'YES' to confirm"
    if ($confirm -ne "YES") {
        Write-Host "Operation cancelled."
        exit
    }

    # Get all virtual switches
    $allSwitches = Get-VMSwitch
    foreach ($switch in $allSwitches) {
        # Skip default/built-in switches (typically named things like "Default Switch" or starting with certain patterns)
        if ($switch.Name -notlike "*Default*" -and $switch.Name -notlike "vEthernet*" -and $switch.SwitchType -ne "Internal") {
            Write-Host "Removing switch '$($switch.Name)' and all its adapters..."

            # Remove all VLAN adapters associated with this switch
            Write-Host "Removing all adapters bound to switch '$($switch.Name)'..."
            Get-VMNetworkAdapter -ManagementOS | Where-Object { $_.SwitchName -eq $switch.Name } | Remove-VMNetworkAdapter
            Start-Countdown -seconds $delay

            # Remove the switch
            Write-Host "Removing switch '$($switch.Name)'..."
            Remove-VMSwitch -Name $switch.Name -Force
            Start-Countdown -seconds $delay
        } else {
            Write-Host "Skipping default/built-in switch '$($switch.Name)'"
        }
    }

    Write-Host "Nuke all operation completed."
    exit
}

if (!$ipOnly) {
    # List current NICs
    Write-Host "Listing available network adapters:"
    $adapters = Get-NetAdapter | Where-Object { $_.Name -notlike "vEthernet*" -and $_.InterfaceDescription -notlike "*Hyper-V*" } | Sort-Object Name
    for ($i = 0; $i -lt $adapters.Count; $i++) {
        $status = if ($adapters[$i].Status -eq "Up") { "Up" } else { "Down" }
        Write-Host "$($i+1). $($adapters[$i].Name) - $($adapters[$i].InterfaceDescription) [Status: $status]"
    }

    # Prompt for selection
    $choice = Read-Host "Select the NIC by number (1-$($adapters.Count))"
    $selectedNic = $adapters[$choice-1].Name
    Write-Host "Selected NIC: $selectedNic"

    # Prompt for virtual switch name
    $switchName = Read-Host "Enter virtual switch name (press Enter for default: vLanSwitch)"
    if ([string]::IsNullOrWhiteSpace($switchName)) { $switchName = "vLanSwitch" }
    Write-Host "Using switch name: $switchName"

    # Deep cleanup: Remove ALL virtual switches bound to the selected physical NIC
    Write-Host "Checking for existing virtual switches bound to '$selectedNic'..."
    $selectedAdapter = Get-NetAdapter -Name $selectedNic
    $switchesOnNic = Get-VMSwitch | Where-Object { $_.NetAdapterInterfaceDescription -eq $selectedAdapter.InterfaceDescription }
    Write-Host "Found $($switchesOnNic.Count) switches bound to '$selectedNic'."
    foreach ($switch in $switchesOnNic) {
        Write-Host "Found existing switch '$($switch.Name)' bound to '$selectedNic'. Cleaning up..."

        # Remove all VLAN adapters associated with this switch
        Write-Host "Removing all adapters bound to switch '$($switch.Name)'..."
        Get-VMNetworkAdapter -ManagementOS | Where-Object { $_.SwitchName -eq $switch.Name } | Remove-VMNetworkAdapter
        Start-Countdown -seconds $delay

        # Remove the switch itself
        Write-Host "Removing virtual switch '$($switch.Name)'..."
        Remove-VMSwitch -Name $switch.Name -Force
        Start-Countdown -seconds $delay
    }

    # Create virtual switch
    Write-Host "Creating virtual switch '$switchName'..."
    # Reset adapter bindings by disabling and re-enabling the adapter
    Write-Host "Disabling and re-enabling adapter '$selectedNic' to reset bindings..."
    Disable-NetAdapter -Name $selectedNic -Confirm:$false
    Start-Sleep -Seconds 2
    Enable-NetAdapter -Name $selectedNic
    Start-Countdown -seconds $delay
    New-VMSwitch -Name $switchName -NetAdapterName $selectedNic -AllowManagementOS $true
    Start-Countdown -seconds $delay

    # Add virtual network adapters with delays
    foreach ($vlan in $vlans) {
        Write-Host "Adding virtual adapter '$($vlan.Name)'..."
        Add-VMNetworkAdapter -ManagementOS -Name $vlan.Name -SwitchName $switchName
        Start-Countdown -seconds $delay
        Write-Host "Setting VLAN ID $($vlan.VlanId) for '$($vlan.Name)'..."
        Set-VMNetworkAdapterVlan -VMNetworkAdapterName $vlan.Name -VlanId $vlan.VlanId -Access -ManagementOS
        Start-Countdown -seconds $delay
    }
}

# Prompt for IP octets dynamically based on VLAN set configuration
$ipOctets = @{}
foreach ($promptName in $ipPrompts) {
    $defaultValue = $ipDefaults[$promptName]
    if ($defaultValue) {
        $promptText = "Enter the $promptName octet for IP addresses (press Enter for default: $defaultValue)"
        $userInput = Read-Host $promptText
        if ([string]::IsNullOrWhiteSpace($userInput)) {
            $ipOctets[$promptName] = $defaultValue
        } else {
            $ipOctets[$promptName] = $userInput
        }
    } else {
        $promptText = "Enter the $promptName octet for IP addresses"
        $ipOctets[$promptName] = Read-Host $promptText
    }
}

if (!$ipOnly) {
    # Wait 10 seconds after last adapter creation
    Start-Countdown -seconds 10
}

# Assign IP addresses to virtual adapters using template from JSON
foreach ($vlan in $vlans) {
    # Build IP address from template
    $ip = $ipBase
    $ip = $ip -replace '\{vlan\}', $vlan.VlanId
    foreach ($octetName in $ipOctets.Keys) {
        $ip = $ip -replace "`{$octetName`}", $ipOctets[$octetName]
    }
    
    Write-Host "Setting IP $ip for '$($vlan.Name)'..."

    # Wait for adapter to be available and get fresh adapter info
    $maxRetries = 10
    $retryCount = 0
    $adapter = $null

    while ($retryCount -lt $maxRetries -and $adapter -eq $null) {
        $adapter = Get-NetAdapter | Where-Object { $_.Name -eq "vEthernet ($($vlan.Name))" }
        if ($adapter -eq $null) {
            Write-Host "Waiting for adapter 'vEthernet ($($vlan.Name))' to be available... ($($retryCount + 1)/$maxRetries)"
            Start-Sleep -Seconds 3
            $retryCount++
        }
    }

    if ($adapter) {
        try {
            # Use netsh for IP configuration instead of PowerShell cmdlets
            Write-Host "Configuring IP $ip for '$($vlan.Name)' using netsh..."
            
            # Get adapter name for netsh
            $adapterName = $adapter.Name
            
            # Use netsh to set static IP (this automatically handles DHCP disable)
            $netshCommand = "netsh interface ip set address ""$adapterName"" static $ip $subnetMask"
            Write-Host "Running: $netshCommand"
            $result = cmd /c $netshCommand 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✓ Successfully set IP $ip for '$($vlan.Name)'"
            } else {
                Write-Host "✗ Netsh failed: $result"
                throw "Netsh IP configuration failed"
            }

            # Verify the IP was set correctly
            $verifyIP = Get-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex | Where-Object { $_.IPAddress -eq $ip }
            if ($verifyIP) {
                Write-Host "✓ Successfully set IP $ip for '$($vlan.Name)'"
            } else {
                Write-Host "⚠ Warning: IP $ip may not have been set correctly for '$($vlan.Name)'"
            }
        }
        catch {
            Write-Host "✗ Error setting IP for '$($vlan.Name)': $($_.Exception.Message)"
        }
    } else {
        Write-Host "✗ Error: Adapter '$($vlan.Name)' not found after $maxRetries attempts"
    }
}

Write-Host "Script completed."

