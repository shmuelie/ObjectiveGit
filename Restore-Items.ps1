function Restore-Items
{
	<#
		.Synopsis
		Restore working tree files

		.Description
		Updates files in the working tree to match the version in the specified tree.

		.Parameter Files
		Working files to restore.

		.Parameter Repository
		Path to the git repository. Can be relative or absolute. If not specified defaults to the current directory

		.Parameter Force
		When checking out paths from the index, do not fail upon unmerged entries; instead, unmerged entries are ignored.

		.Parameter Source
		Restore the item from a tree-ish location.

		.Link
		https://git-scm.com/docs/git-checkout
	#>
	param(
		[Parameter(Mandatory=$True,Position=1,ValueFromPipeline=$True)]
		[string[]]$Files,
		[Parameter(Mandatory=$False)]
		[string]$Repository = ".\",
		[Alias("f")]
		[switch]$Force = $False,
		[Parameter(Mandatory=$False)]
		[string]$Source = $null
	)
	process
	{
		$Repository = Resolve-Path -Path $Repository
		Write-Verbose -Message "Checking out files $Files in $Repository"
		$ExtendedCLI = "";
		if ($Force)
		{
			$ExtendedCLI += " -f"
		}
		if ([string]::IsNullOrWhiteSpace($Source) -eq $false)
		{
			$ExtendedCLI += " $Source"
		}
		$ErrorCount = $Error.Count
		$Output = (Invoke-Expression -Command "git -C $Repository checkout$ExtendedCLI -- $Files") 2>&1
		if ($Error.Count -gt $ErrorCount)
		{
			$Error | select -Skip $ErrorCount | ForEach-Object { Write-Error -ErrorRecord $_ }
			return
		}
		Write-Verbose -Message "Successfully checked out files $Files in $Repository"
	}
}