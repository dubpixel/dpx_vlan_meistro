# Changelog

## v1.94

### Added or Changed
- Added DHCP vs Static IP configuration choice at the beginning of IP assignment section
- Users can now choose between DHCP (automatic IP assignment) or Static IP (manual octet entry)
- DHCP option skips octet collection and validation, enabling DHCP on all virtual adapters
- Static IP option continues with existing subnet-aware validation and IP assignment logic
- Updated configuration summary to display IP method and handle DHCP configurations appropriately
- Updated version to 1.94 and ASCII art title accordingly

## v1.93

### Added or Changed
- Reorganized README.md with collapsible sections using HTML details/summary tags
- Made Configuration, Usage Examples, and Troubleshooting sections collapsible for better user experience
- Removed duplicate Quick Start and Script Workflow sections to eliminate redundancy
- Added prominent BAT file instructions at the top of the Usage section
- Improved overall documentation organization and accessibility
- Updated version to 1.93 and ASCII art title accordingly

## v1.87

### Added or Changed
- Fixed IP prompt default values not displaying by changing `$ipDefaults[$promptName]` to `$ipDefaults.$promptName` to properly access PSCustomObject properties from JSON data
- Updated version to 1.87 and ASCII art title accordingly

## v1.86

### Added or Changed
- Implemented comprehensive subnet-aware IP validation that checks complete IP addresses against subnet constraints instead of dumb 0-255 octet validation
- Added configuration summary at script end showing selected NIC, subnet, and all VLAN IPs with broadcast addresses
- Updated IP input prompts to display subnet information for better user guidance
- Added Test-IPAgainstSubnet function for proper IP/subnet validation with network/broadcast calculation
- Updated version to 1.86 and ASCII art title accordingly

## v1.85

## v1.83

### Added or Changed
- Refactored hardcoded VLAN configurations to be defined as variables ($hardcoded4Wall, $hardcodedAeonPoint, $hardcodedDesert) at the top of the script for better maintainability
- Simplified the else block in VLAN set building to assign these pre-defined variables instead of inline definitions
- Updated version to 1.83 and ASCII art title accordingly

## v0.0.0

### Added or Changed
- 

### Removed

- S