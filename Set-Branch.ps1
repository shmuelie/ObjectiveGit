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
		$Output = (Invoke-Expression -Command "git -C $Repository checkout$ExtendedCLI $Branch") 2>&1
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
		$ErrorsInOutput = $Output | Where-Object -FilterScript { ($_ -is [System.Management.Automation.ErrorRecord]) -and (-not $_.ToString().StartsWith("Switched to branch")) }
		if (($ErrorsInOutput | Measure-Object | Select-Object -ExpandProperty Count) -gt 0)
		{
			$ErrorsInOutput | ForEach-Object -Process { Write-Error -ErrorRecord $_ }
			return;
		}
		Write-Verbose -Message "Successfully checked out branch $Branch in $Repository"
	}
}