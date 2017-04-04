$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
. (Resolve-Path "$moduleRoot\Get-RepositoryStatus.ps1")
. (Resolve-Path "$moduleRoot\Rebase-SvnRepository.ps1")
. (Resolve-Path "$moduleRoot\Pull-SvnRepository.ps1")
. (Resolve-Path "$moduleRoot\Stash-Changes.ps1")
. (Resolve-Path "$moduleRoot\Restore-Changes.ps1")
. (Resolve-Path "$moduleRoot\Checkout-Branch.ps1")
. (Resolve-Path "$moduleRoot\Restore-Items.ps1")

Export-ModuleMember -Function Get-Git-Status
Export-ModuleMember -Function Rebase-SvnRepository
Export-ModuleMember -Function Pull-SvnRepository
Export-ModuleMember -Function Stash-Changes
Export-ModuleMember -Function Restore-Changes
Export-ModuleMember -Function Checkout-Branch
Export-ModuleMember -Function Restore-Items