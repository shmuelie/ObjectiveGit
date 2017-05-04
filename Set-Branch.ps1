function Set-Branch
{
	<#
		.Synopsis
		Switch branches

		.Description
		Updates files in the working tree to match the version in the specified tree.

		.Parameter Branch
		Branch to checkout

		.Parameter Repository
		Path to the git repository. Can be relative or absolute. If not specified defaults to the current directory

		.Parameter CreateNew
		Create a new branch

		.Parameter Force
		When switching branches, proceed even if the working tree differs from HEAD. This is used to throw away local changes.

		.Parameter Track
		When creating a new branch, set up "upstream" configuration.

		.Link
		https://git-scm.com/docs/git-checkout
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$True,ValueFromPipeline=$True)]
		[string]$Branch,
		[string]$Repository = ".\",
		[Alias("b")]
		[switch]$CreateNew = $False,
		[Alias("f")]
		[switch]$Force = $False,
		[Alias("t")]
		[switch]$Track = $False
	)
	process
	{
		$Repository = Resolve-Path -Path $Repository
		Write-Verbose -Message "Checking out branch $Branch in $Repository"
		$ExtendedCLI = ""
		if ($CreateNew)
		{
			$ExtendedCLI += " -b"
		}
		if ($Force)
		{
			$ExtendedCLI += " -f"
		}
		if ($Track)
		{
			$ExtendedCLI += " --track"
		}
		$ErrorCount = $Error.Count
		$Output = (Invoke-Expression -Command "git -C $Repository checkout$ExtendedCLI $Branch") 2>&1
		if ($Error.Count -gt $ErrorCount)
		{
			$Error | select -Skip $ErrorCount | ForEach-Object { Write-Error -ErrorRecord $_ }
			return
		}
		Write-Verbose -Message "Successfully checked out branch $Branch in $Repository"
	}
}