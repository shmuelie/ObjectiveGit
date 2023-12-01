$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$moduleInfo = (Get-Content -Path "$moduleRoot\ObjectiveGit.psd1" -Raw | Invoke-Expression)

$moduleInfo.FileList | ForEach-Object -Process {
    . (Resolve-Path "$moduleRoot\$_")
}

Export-ModuleMember -Function ($moduleInfo.FunctionsToExport) -Cmdlet ($moduleInfo.CmdletsToExport) -Variable ($moduleInfo.VariablesToExport) -Alias ($moduleInfo.AliasesToExport)