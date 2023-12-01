function Backup-Changes
{
	<#
		.Synopsis
		Stash the changes in a dirty working directory away

		.Description
		Save your local modifications to a new stash and roll them back to HEAD (in the working tree and in the index)

		.Parameter Repository
		Path to the git repository. Can be relative or absolute. If not specified defaults to the current directory

		.Parameter KeepIndex
		All changes already added to the index are left intact.

		.Parameter IncludeUntracked
		All untracked files are also stashed and then cleaned up.

		.Parameter All
		Ignored files are stashed and cleaned in addition to the untracked files.

		.Parameter Message
		Description along with the stashed state

		.Link
		https://git-scm.com/docs/git-stash#git-stash-save-p--patch-k--no-keep-index-u--include-untracked-a--all-q--quietltmessagegt
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$False,Position=1,ValueFromPipeline=$True)]
		[string]$Repository = '.\',
		[Alias('k')]
		[switch]$KeepIndex = $False,
		[Alias('u')]
		[switch]$IncludeUntracked = $False,
		[Alias('a')]
		[switch]$All = $False,
		[Alias('m')]
		[string]$Message = $null
	)
	process
	{
		$Repository = Resolve-Path -Path $Repository
		Write-Verbose -Message "Stashing changes in $Repository"
		$ExtendedCLI = '';
		if ($KeepIndex)
		{
			$ExtendedCLI += ' --keep-index'
		}
		if ($IncludeUntracked)
		{
			$ExtendedCLI += ' --include--untracked'
		}
		if ($All)
		{
			$ExtendedCLI += ' --all'
		}
		if ($Message -ne $null)
		{
			$ExtendedCLI += " $Message"
		}
		$Output = (Invoke-Expression -Command "git -C $Repository stash save$ExtendedCLI") 2>&1
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