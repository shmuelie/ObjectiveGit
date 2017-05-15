function Export-SvnRepository
{
	<#
		.Synopsis
		Commit each diff from the current branch directly to the SVN repository, and then rebase or reset.

		.Description
		This will create a revision in SVN for each commit in Git.

		.Parameter Repository
		Path to the git repository. Can be relative or absolute. If not specified defaults to the current directory

		.Link
		https://git-scm.com/docs/git-svn#git-svn-emdcommitem
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$False,Position=1,ValueFromPipeline=$True)]
		[string]$Repository = ".\"
	)
	process
	{
		$Repository = Resolve-Path -Path $Repository
		Write-Verbose -Message "Committing SVN $Repository"
		$ErrorCount = $Error.Count
		$Output = (Invoke-Expression -Command "git -C $Repository svn dcommit") 2>&1
		if ($Error.Count -gt $ErrorCount)
		{
			$Error | select -Skip $ErrorCount | ForEach-Object { Write-Error -ErrorRecord $_ }
			return
		}
		$Output = [string[]]$Output;
		if ($Output.Count -eq 1)
		{
			Write-Verbose -Message "Nothing to commit to SVN"
			return
		}
		$Files = New-Object System.Collections.ArrayList
		for($i = 1; $i -lt $Output.Length; $i++)
		{
			$Line = $Output[$i]
			if ($Line -cmatch '\s+([\.MADRCU\?\!][\.MDUA]?)\s+(\S+)')
			{
				$Files.Add([PSCustomObject]@{
					Status = $Matches[1]
					Path = $Matches[2]
				}) | Out-Null
			}
			elseif ($Line -cmatch 'Committed r\d+')
			{
				$i += $Files.Count
			}
			elseif ($Line -cmatch '(r\d+)\s=\s([0-9a-f]{40}).*')
			{
				Write-Output ([PSCustomObject]@{
					Files = $Files
					SvnCommit = $Matches[1]
					GitCommit = $Matches[2]
				})
				$Files = New-Object System.Collections.ArrayList
			}
		}
	}
}