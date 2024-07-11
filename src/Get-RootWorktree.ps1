function Get-RootWorktree() {
    $worktreePath = $null
    $isRoot = (Get-ChildItem .\ -Filter .git -Hidden | Select-Object -ExpandProperty PSIsContainer)
    if ($isRoot) {
        $worktreePath = Get-Location
    } else {
        $worktreePath = ((Get-Content .\.git).Substring(8) -split '/.git/')[0] -replace '/','\\'
    }
    Get-Worktrees | Where-Object {
        $pathComparison = Compare-Object -ReferenceObject ($_.Path -split '\\') -DifferenceObject ($worktreePath -split '\\')
        ($pathComparison.Length -eq 0) -or ($pathComparison.Length -eq ($pathComparison | Where-Object SideIndicator -eq '=>').Length)
    }
}
