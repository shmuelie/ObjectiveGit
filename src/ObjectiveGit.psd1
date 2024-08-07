@{

# Script module or binary module file associated with this manifest.
RootModule = 'ObjectiveGit.psm1'

# Version number of this module.
ModuleVersion = '1.7'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = '1c3fc402-0a4b-47ef-93d4-31cb220816ef'

# Author of this module
Author = 'Shmueli Engard'

# Company or vendor of this module
CompanyName = 'Shmuelie'

# Copyright statement for this module
Copyright = '© 2024 Shmueli Englard'

# Description of the functionality provided by this module
Description = 'Powershell Git'

# Minimum version of the Windows PowerShell engine required by this module
# PowerShellVersion = ''

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @(
    'Get-RepositoryStatus',
    'Import-SvnRepository', 
    'Update-SvnRepository', 
    'Backup-Changes', 
    'Restore-Changes', 
    'Set-Branch', 
    'Restore-Items', 
    'Get-Branch', 
    'Export-SvnRepository', 
    'Remove-Branch', 
    'Set-Config',
    'Get-CurrentWorktree',
    'Get-RepositoryName',
    'Get-RootWorktree',
    'Get-Worktrees',
    'Update-Worktrees'
)

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @(
    'Get-RepositoryStatus',
    'Import-SvnRepository', 
    'Update-SvnRepository', 
    'Backup-Changes', 
    'Restore-Changes', 
    'Set-Branch', 
    'Restore-Items', 
    'Get-Branch', 
    'Export-SvnRepository', 
    'Remove-Branch', 
    'Set-Config',
    'Get-CurrentWorktree',
    'Get-RepositoryName',
    'Get-RootWorktree',
    'Get-Worktrees',
    'Update-Worktrees'
)

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = '*'

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
FileList = @(
    'Export-SvnRepository.ps1', 
    'Get-Branch.ps1', 
    'Remove-Branch.ps1', 
    'Set-Branch.ps1', 
    'Restore-Changes.ps1', 
    'Restore-Items.ps1', 
    'Backup-Changes.ps1', 
    'Get-RepositoryStatus.ps1', 
    'Set-Config.ps1', 
    'Update-SvnRepository.ps1', 
    'Import-SvnRepository.ps1',
    'Get-CurrentWorktree.ps1',
    'Get-RepositoryName.ps1',
    'Get-RootWorktree.ps1',
    'Get-Worktrees.ps1',
    'Update-Worktrees.ps1'
)

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('Git', 'Svn')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/SamuelEnglard/ObjectiveGit/blob/main/LICENSE.txt'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/SamuelEnglard/ObjectiveGit'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = 'Added Get-Branch, Export-SvnRepository. Lots of bug fixes'

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

