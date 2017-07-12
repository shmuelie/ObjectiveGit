$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
. (Resolve-Path "$moduleRoot\Get-RepositoryStatus.ps1")
. (Resolve-Path "$moduleRoot\Import-SvnRepository.ps1")
. (Resolve-Path "$moduleRoot\Update-SvnRepository.ps1")
. (Resolve-Path "$moduleRoot\Backup-Changes.ps1")
. (Resolve-Path "$moduleRoot\Restore-Changes.ps1")
. (Resolve-Path "$moduleRoot\Set-Branch.ps1")
. (Resolve-Path "$moduleRoot\Restore-Items.ps1")
. (Resolve-Path "$moduleRoot\Get-Branch.ps1")
. (Resolve-Path "$moduleRoot\Export-SvnRepository.ps1")
. (Resolve-Path "$moduleRoot\Remove-Branch.ps1")
. (Resolve-Path "$moduleRoot\Set-Config.ps1")

Export-ModuleMember -Function Get-RepositoryStatus
Export-ModuleMember -Function Import-SvnRepository
Export-ModuleMember -Function Update-SvnRepository
Export-ModuleMember -Function Backup-Changes
Export-ModuleMember -Function Restore-Changes
Export-ModuleMember -Function Set-Branch
Export-ModuleMember -Function Restore-Items
Export-ModuleMember -Function Get-Branch
Export-ModuleMember -Function Export-SvnRepository
Export-ModuleMember -Function Remove-Branch
Export-ModuleMember -Function Set-Config