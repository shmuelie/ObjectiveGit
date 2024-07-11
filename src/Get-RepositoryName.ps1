function Get-RepositoryName() {
    git remote get-url origin | ForEach-Object { 
        $_.SubString($_.LastIndexOf('/') + 1) -replace '\.git$',''
    }
}
