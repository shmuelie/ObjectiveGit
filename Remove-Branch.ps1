function Remove-Branch
{
	<#
		.Synopsis
		Delete a branch.

		.Description
		Deletes a local or remote branch.

		.Parameter Branch
		Branch to delete

		.Parameter Repository
		Path to the git repository. Can be relative or absolute. If not specified defaults to the current directory

		.Parameter Force
		Allows deleting the branch even if it is not fully merged in its upstream branch, or in HEAD if no upstream was set.

		.Parameter Remote
		Delete remote branch.

		.Link
		https://git-scm.com/docs/git-branch#git-branch--d
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$True,ValueFromPipeline=$True)]
		[string]$Branch,
		[string]$Repository = ".\",
		[Alias("f")]
		[switch]$Force = $False,
		[Alias("r")]
		[switch]$Remote = $False
	)
	process
	{
		$Repository = Resolve-Path -Path $Repository
		Write-Verbose -Message "Deleting branch $Branch in $Repository"
		$ExtendedCLI = ""
		if ($Remote)
		{
			$ExtendedCLI += " -r"
		}
		if ($Force)
		{
			$ExtendedCLI += " -f"
		}
		$ErrorCount = $Error.Count
		$Output = (Invoke-Expression -Command "git -C $Repository branch$ExtendedCLI $Branch") 2>&1
		if ($Error.Count -gt $ErrorCount)
		{
			$Error | select -Skip $ErrorCount | ForEach-Object { Write-Error -ErrorRecord $_ }
			return
		}
		Write-Verbose -Message "Successfully deleted branch $Branch in $Repository"
	}
}