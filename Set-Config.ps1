function Set-Config
{
	<#
		.Synopsis
		Set configuration property

		.Description
		Set configuration property for local, global, or system.

		.Parameter Property
		The property to set

		.Parameter Value
		The value to set to the property

		.Parameter Repository
		Path to the git repository. Can be relative or absolute. If not specified defaults to the current directory

		.Parameter Location
		If the property should be set locally, globally, or system wide.

		.Link
		https://git-scm.com/docs/git-config
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$True,Position=0)]
		[string]$Property,
		[Parameter(Mandatory=$True,Position=1)]
		[string]$Value,
		[string]$Repository = ".\",
		[ValidateSet("local","global","system")]
		[string]$Location = "local"
	)
	process
	{
		$Repository = Resolve-Path -Path $Repository
		Write-Verbose -Message "Setting $Property to `"$Value`" in $Repository"
		$Output = (Invoke-Expression -Command "git -C $Repository config --$Location $Property `"$Value`"") 2>&1
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
		if ($LASTEXITCODE -eq 1)
		{
			Write-Error -Message "Invalid Property" -Category InvalidArgument
			return
		}
		if ($LASTEXITCODE -eq 3)
		{
			Write-Error -Message "Configuration data is corrupt" -Category ReadError
			return
		}
		if ($LASTEXITCODE -eq 4)
		{
			Write-Error -Message "Cannot write configuration" -Category WriteError
			return
		}
		$ErrorsInOutput = $Output | Where-Object -FilterScript { $_ -is [System.Management.Automation.ErrorRecord] }
		if (($ErrorsInOutput | Measure-Object | Select-Object -ExpandProperty Count) -gt 0)
		{
			$ErrorsInOutput | ForEach-Object -Process { Write-Error -ErrorRecord $_ }
			return;
		}
		Write-Verbose -Message "Successfully set $Property to `"$Value`" in $Repository"
	}
}