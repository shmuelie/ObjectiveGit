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
		$Output = (Invoke-Expression -Command "git -C $Repository checkout$ExtendedCLI -- $Files") 2>&1
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
		Write-Verbose -Message "Successfully checked out files $Files in $Repository"
	}
}