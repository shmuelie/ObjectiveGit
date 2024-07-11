function Get-Worktrees() {
    ((git worktree list --porcelain) -join ',') -split ',,' | ConvertFrom-Csv -Header 'Path','Commit','Branch' | ForEach-Object {
        $_.Path = (Resolve-Path $_.Path.SubString(9))
        $_.Commit = $_.Commit.SubString(5)
        if ($_.Branch.Length -gt 18) {
            $_.Branch = $_.Branch.SubString(18)
        }
        $_
    }
}
