function Import-SvnRepository
{
	<#
		.Synopsis
		This fetches revisions from the SVN parent of the current HEAD and rebases the current (uncommitted to SVN) work against it.

		.Description
		This works similarly to svn update or git pull except that it preserves linear history with git rebase instead of git merge for ease of dcommitting with git svn.

		.Parameter Repository
		Path to the git repository. Can be relative or absolute. If not specified defaults to the current directory

		.Parameter LocalTime
		Store Git commit times in the local time zone instead of UTC.

		.Parameter Parent
		Fetch only from the SVN parent of the current HEAD.

		.Parameter IgnorePaths
		This allows one to specify a Perl regular expression that will cause skipping of all matching paths from checkout from SVN.

		.Parameter IncludePaths
		This allows one to specify a Perl regular expression that will cause the inclusion of only matching paths from checkout from SVN.

		.Parameter LogWindowSize
		Fetch <n> log entries per request when scanning Subversion history. The default is 100.

		.Parameter Local
		Do not fetch remotely; only run git rebase against the last fetched commit from the upstream SVN.

		.Link
		https://git-scm.com/docs/git-svn#git-svn-emrebaseem
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$False,Position=1,ValueFromPipeline=$True)]
		[string]$Repository = '.\',
		[switch]$LocalTime = $False,
		[switch]$Parent = $False,
		[regex]$IgnorePaths = $null,
		[regex]$IncludePaths = $null,
		[int]$LogWindowSize = 100,
		[Alias('l')]
		[switch]$Local = $False
	)
	process
	{
		$Repository = Resolve-Path -Path $Repository
		Write-Verbose "Rebasing Svn $Repository"
		$ExtendedCLI = ''
		if ($LocalTime)
		{
			$ExtendedCLI += ' --localtime'
		}
		if ($Parent)
		{
			$ExtendedCLI += ' --parent'
		}
		if ($IgnorePaths -ne $null)
		{
			$ExtendedCLI += ' --ignore-paths=$IgnorePaths'
		}
		if ($IncludePaths -ne $null)
		{
			$ExtendedCLI += ' --include-paths=$IncludePaths'
		}
		if ($Local)
		{
			$ExtendedCLI += ' --local'
		}
		$Output = (Invoke-Expression -Command "git -C $Repository svn rebase --log-window-size=$LogWindowSize$ExtendedCLI") 2>&1
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
		if (($Output.GetType().Name -ieq 'string') -and ($Output -cmatch 'Current branch\s\S+\sis up to date.'))
		{
			Write-Verbose -Message $Output
			return
		}
		foreach($line in $Output)
		{
			if ($line -cmatch '(.+)\:\sneeds\supdate')
			{
				$file = $Matches[1]
				Write-Error -Message "$file is not commited. Either Backup-Changes or commit" -Category InvalidOperation
			}
		}
	}
}