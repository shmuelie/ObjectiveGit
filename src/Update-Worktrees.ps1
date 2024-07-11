function Update-Worktrees {
    [CmdletBinding()]
    param(
        [switch]$ShowFastForwarded
    )
    process {
        # Get latest state
        Write-Progress -Activity 'Updating Worktrees' -Status 'Fetching' -PercentComplete 0 -Id 0
        git fetch --all --recurse-submodules --quiet 2>&1 | Out-Null
        Write-Progress -Activity 'Updating Worktrees' -Status 'Getting Worktrees' -PercentComplete 0 -Id 0
        $worktrees = Get-Worktrees
        $percent = 0
        foreach ($worktree in $worktrees) {
            Write-Progress -Activity 'Updating Worktrees' -Status ($worktree.Path) -PercentComplete $percent -CurrentOperation 'Changing location' -Id 0
            # Change to worktre
            Push-Location -Path ($worktree.Path)
            Write-Progress -Activity 'Updating Worktrees' -Status ($worktree.Path) -PercentComplete $percent -CurrentOperation 'Getting GIT status' -Id 0
            $status = Get-GitStatus
            # If behind and nothing local
            if (($status.BehindBy -gt 0) -and ($status.AheadBy -eq 0)) {
                $stashed = $false;
                # Stash any local changes
                if ($status.HasWorking) {
                    Write-Progress -Activity 'Updating Worktrees' -Status ($worktree.Path) -PercentComplete $percent -CurrentOperation 'Stashing changes' -Id 0
                    $stashed = $true
                    git stash push --include-untracked --quiet 2>&1 | Out-Null
                }
                # Fast forward
                Write-Progress -Activity 'Updating Worktrees' -Status ($worktree.Path) -PercentComplete $percent -CurrentOperation 'Fast forwarding' -Id 0
                git merge --ff-only `@`{upstream`} --quiet 2>&1 | Out-Null
                # Pop any stashed changes
                if ($stashed) {
                    Write-Progress -Activity 'Updating Worktrees' -Status ($worktree.Path) -PercentComplete $percent -CurrentOperation 'Restoring changes' -Id 0
                    git stash pop --quiet 2>&1 | Out-Null
                }
                if ($ShowFastForwarded) {
                    Write-Host -ForegroundColor Green "Updated $($status.Branch)"
                }
            }
            # Revert location
            Write-Progress -Activity 'Updating Worktrees' -Status ($worktree.Path) -PercentComplete $percent -CurrentOperation 'Reverting location' -Id 0
            Pop-Location
            $percent += 100 / ($worktrees.Length)
        }
    }
}
