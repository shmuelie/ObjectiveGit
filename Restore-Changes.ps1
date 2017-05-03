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
		[string]$Repository = ".\"
	)
	process
	{
		$Repository = Resolve-Path -Path $Repository
		Write-Verbose "Restoring changes in $Repository"
		$ErrorCount = $Error.Count
		$Output = (Invoke-Expression -Command "git -C $Repository stash pop") 2>&1
		if ($Error.Count -gt $ErrorCount)
		{
			$Error | select -Skip $ErrorCount | ForEach-Object { Write-Error -ErrorRecord $_ }
			return
		}
	}
}