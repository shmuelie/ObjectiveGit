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
		$Output = (Invoke-Expression -Command "git -C $Repository svn dcommit") 2>&1
		if (($LASTEXITCODE -eq 128) -or($LASTEXITCODE -eq -1))
		{
			Write-Error -Message $Output -Category FromStdErr
			return
		}
		if ($LASTEXITCODE -eq 129)
		{
			Write-Error -Message "Bug with ObjectiveGit. Please file a bug at https://github.com/SamuelEnglard/ObjectiveGit." -Category SyntaxError
			return
		}
		$ErrorsInOutput = $Output | Where-Object -FilterScript { $_ -is [System.Management.Automation.ErrorRecord] }
		if (($ErrorsInOutput | Measure-Object | Select-Object -ExpandProperty Count) -gt 0)
		{
			$ErrorsInOutput | ForEach-Object -Process { Write-Error -ErrorRecord $_ }
			return;
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