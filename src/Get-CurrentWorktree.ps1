function Get-CurrentWorktree() {
    $currentPath = Get-Location
    Get-Worktrees | Where-Object {
        $pathComparison = Compare-Object -ReferenceObject ($_.Path -split '\\') -DifferenceObject ($currentPath -split '\\')
        ($pathComparison.Length -eq 0) -or ($pathComparison.Length -eq ($pathComparison | Where-Object SideIndicator -eq '=>').Length)
    }
}
