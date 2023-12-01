function Restore-Changes
{
	<#
		.Synopsis
		Restore the changes to a working directory.

		.Description
		Remove a single stashed state from the stash list and apply it on top of the current working tree state.

		.Parameter Repository
		Path to the git repository. Can be relative or absolute. If not specified defaults to the current directory

		.Link
		https://git-scm.com/docs/git-stash#git-stash-pop--index-q--quietltstashgt
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$False,Position=1,ValueFromPipeline=$True)]
		[string]$Repository = '.\'
	)
	process
	{
		$Repository = Resolve-Path -Path $Repository
		Write-Verbose "Restoring changes in $Repository"
		$Output = (Invoke-Expression -Command "git -C $Repository stash pop") 2>&1
		if (($LASTEXITCODE -eq 128) -or($LASTEXITCODE -eq -1))
		{
			Write-Error -Message $Output -Category FromStdErr
			return
		}
		if ($LASTEXITCODE -eq 129)
		{
			Write-Error -Message 'Bug with ObjectiveGit. Please file a bug at https://github.com/SamuelEnglard/ObjectiveGit.' -Category SyntaxError
			return
		}
		$ErrorsInOutput = $Output | Where-Object -FilterScript { $_ -is [System.Management.Automation.ErrorRecord] }
		if (($ErrorsInOutput | Measure-Object | Select-Object -ExpandProperty Count) -gt 0)
		{
			$ErrorsInOutput | ForEach-Object -Process { Write-Error -ErrorRecord $_ }
			return;
		}
	}
}