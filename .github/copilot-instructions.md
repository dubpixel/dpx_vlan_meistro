# dubpixel Template GitHub Copilot Instructions

**Version:** 1.1
**Last Revised:** October 13, 2025

## Ground Rules for AI Assistance

This project includes AI-generated code assistance provided by GitHub Copilot. Please follow these directives to ensure code quality, maintainability, and collaborative development practices.

### Core Principles

- **No modifications to working code without explicit request**
- **Comprehensive commenting of all code and preservation of existing comments** (remove comments that become false/obsolete)
- **Small, incremental changes to maintain code stability**
- **Verification before implementation of any suggestions**
- **Stay focused on the current task** - do not jump ahead or suggest next steps
- **Answer only what is asked** - do not anticipate or propose additional work
- **ALL user prompts and AI solutions must be documented verbatim in the change log comments**
  - Format: User prompt as single line, followed by itemized solution with → bullet
- **Maintain CHANGELOG.md with version updates and change summaries** for all code modifications

## Project Architecture & Context

### DPX_VLAN_MEISTRO Overview
This is a PowerShell automation script for Windows Hyper-V network management. It creates virtual switches and VLAN-tagged network adapters for different facility configurations (4Wall, Aeon Point, Desert). The script supports two modes: Normal (full creation + IP assignment) and IP-only (IP assignment to existing adapters).

**Key Components:**
- Interactive VLAN set selection (dynamically loaded from `vlan_sets.json`)
- Network adapter enumeration and selection
- Virtual switch creation with physical NIC binding
- VLAN adapter creation with 10-second delays between operations
- IP address assignment (10.x.x.x format or 192.168.x.x for Desert)
- **Nuke all mode:** Removes all virtual switches except default/built-in ones
- **External VLAN configuration:** Reads VLAN sets from `vlan_sets.json` file

**Critical Files:**
- `src/vlan_mesitro.ps1` - Main interactive PowerShell script
- `src/vlan_sets.json` - External VLAN configuration file
- `README.md` - Comprehensive usage documentation with Jekyll/GitHub Pages hosting

### Development Environment Setup
- **OS:** Windows 10/11 with Hyper-V enabled
- **Prerequisites:** PowerShell 5.1+, Administrative privileges, Hyper-V PowerShell module
- **Execution:** Run as Administrator: `.\vlan_mesitro.ps1`
- **Testing:** Manual execution on Hyper-V host with physical network adapter

### Project-Specific Patterns

#### File Header Standards
All code files must include comprehensive headers following this exact format:

```
# ================================================================================
# [FILE TYPE] - [FILE PURPOSE]
# ================================================================================
#
# This project includes AI-generated code assistance provided by GitHub Copilot.
#
# [Include the core principles above]
#
# ================================================================================
# PROJECT: dpx_replace_projectName
# VERSION: [semantic version]
# ================================================================================
#
# [File-specific information: name, author, purpose, dependencies, etc.]
#
# CHANGE LOG:
# [Document all changes using the established format]
#
# ================================================================================
```

- Use consistent 80-character separator lines with `=`
- Include AI assistance rules in every file header
- Maintain verbatim change log with user prompts and solutions
- Use project name placeholder for template reuse

#### PowerShell Script Patterns
- **Delay Management:** Use `$delay = 10` variable for command spacing (critical for Hyper-V operations)
- **Interactive Prompts:** Use `Read-Host` for user input with sensible defaults
- **Error Handling:** Check adapter existence before IP assignment
- **Deep Cleanup Pattern:** Remove ALL virtual switches bound to selected physical NIC before creating new switch
- **External Configuration:** Load VLAN sets from `vlan_sets.json` with fallback to built-in configs
- **Dynamic VLAN Selection:** Automatically detect and present all available VLAN sets from JSON
- **Nuke All Mode:** Remove all user-created virtual switches while preserving default/built-in switches
- **User Warnings:** Display ASCII art title and comprehensive warning about network disruption
- **IP Schemes:** Desert uses `192.168.<vlan>.<4th_octet>`, others use `10.<vlan>.<3rd>.<4th>`
- **Adapter Enumeration:** Filter `Get-NetAdapter` by `Status -eq "Up"`
- **Robust IP Assignment:** Remove existing IPs first, disable DHCP, verify assignment success

#### Documentation Patterns
- **README Structure:** Follow established template with Jekyll hosting
- **Usage Examples:** Include complete command sequences and expected outputs
- **Version Tracking:** Update VERSION in file headers and CHANGELOG.md
- **Release Notes:** Use `dpx_release_note_template.md` format

### Integration Points & Dependencies

#### Hyper-V PowerShell Cmdlets
```powershell
# Deep cleanup - remove all switches bound to selected physical NIC
$switchesOnNic = Get-VMSwitch | Where-Object { $_.NetAdapterName -eq $selectedNic }
foreach ($switch in $switchesOnNic) {
    $adaptersOnSwitch = Get-VMNetworkAdapter -ManagementOS | Where-Object { $_.SwitchName -eq $switch.Name }
    Remove-VMNetworkAdapter -VMNetworkAdapter $adaptersOnSwitch -ManagementOS
    Remove-VMSwitch -Name $switch.Name -Force
}

# Nuke all - remove all user-created switches except defaults
$allSwitches = Get-VMSwitch
foreach ($switch in $allSwitches) {
    if ($switch.Name -notlike "*Default*" -and $switch.Name -notlike "vEthernet*") {
        # Remove adapters and switch
    }
}

# Virtual switch creation
New-VMSwitch -Name $switchName -NetAdapterName $selectedNic -AllowManagementOS $true

# VLAN adapter management
Add-VMNetworkAdapter -ManagementOS -Name $vlan.Name -SwitchName $switchName
Set-VMNetworkAdapterVlan -VMNetworkAdapterName $vlan.Name -VlanId $vlan.VlanId -Access -ManagementOS

# IP configuration with cleanup
Remove-NetIPAddress -IPAddress $existingIP.IPAddress -Confirm:$false
Set-NetIPInterface -InterfaceIndex $adapter.InterfaceIndex -Dhcp Disabled
New-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex -IPAddress $ip -PrefixLength 24
```

#### Jekyll Documentation Hosting
- **Theme:** jekyll-theme-minimal with remote theme support
- **Build:** Automatic via GitHub Pages
- **Configuration:** `_config.yml` with kramdown markdown parser
- **Dependencies:** `Gemfile` with github-pages and jekyll-commonmark-ghpages

### File Header Comment Standards

All code files should include a comprehensive header comment section with the following format:

```
# ================================================================================
# [FILE TYPE] - [FILE PURPOSE]
# ================================================================================
#
# This project includes AI-generated code assistance provided by GitHub Copilot.
#
# GitHub Copilot is an AI programming assistant that helps developers write code
# more efficiently by providing suggestions and completing code patterns.
#
# Ground Rules for AI Assistance:
# [Include the core principles above]
#
# The AI assistant will follow these directives to ensure code quality,
# maintainability, and collaborative development practices.
#
# ================================================================================
# PROJECT: dpx_replace_projectName
# ================================================================================
#
# [File-specific information: name, author, purpose, dependencies, etc.]
#
# CHANGE LOG:
#
# [Document all changes using the established format]
#
# ================================================================================
```

- Use consistent separator lines (80 characters of =)
- Include AI assistance rules in every file
- Maintain change log with verbatim user prompts and solutions
- Use project name placeholder for template replacement

### Documentation Standards

- Maintain comprehensive inline documentation
- Update comments when code changes
- Document all function parameters and return values
- Include usage examples where appropriate
- Keep README files current and accurate, but confirm all changes to the readme file with the user.

### Code Quality Guidelines

- Write clear, readable code with meaningful variable names
- Follow established coding patterns within the project
- Implement proper error handling
- Write testable code with clear interfaces
- Maintain consistent formatting and style

### Change Management

- Make one logical change per modification
- Test changes before suggesting implementation
- Preserve existing functionality unless explicitly asked to change it
- Explain the reasoning behind suggested changes
- Provide rollback information when making significant changes

### Collaboration Standards

- Respect existing architectural decisions
- Ask for clarification when requirements are ambiguous
- Suggest alternatives when appropriate, but don't insist
- Consider the impact of changes on the broader codebase
- Maintain backwards compatibility unless breaking changes are explicitly requested

---

*These instructions help ensure consistent, high-quality AI assistance throughout the development process.*