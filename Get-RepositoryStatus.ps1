function Get-RepositoryStatus
{
	<#
		.Synopsis
		Gets the working tree status.

		.Description
		Gets paths that have differences between the index file and the current HEAD commit, paths that have differences between the working tree and the index file, and paths in the working tree that are not tracked by Git. The first are what you would commit by running git commit; the second and third are what you could commit by running git add before running git commit.

		.Parameter Repository
		Path to the git repository. Can be relative or absolute. If not specified defaults to the current directory

		.Link
		https://git-scm.com/docs/git-status
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$False,Position=1,ValueFromPipeline=$True)]
		[string]$Repository = ".\"
	)
	process
	{
		$Repository = Resolve-Path -Path $Repository
		Write-Verbose -Message "Getting status of $Repository"
		$RepositoryData = [PSCustomObject]@{}
		$Files = New-Object System.Collections.ArrayList
		$RepositoryData | Add-Member -MemberType NoteProperty -Name 'RepoPath' -Value $Repository
		$ErrorCount = $Error.Count
		$Output = (git -C $Repository status --porcelain=2 -b) 2>&1
		if ($Error.Count -gt $ErrorCount)
		{
			$Error | select -Skip $ErrorCount | ForEach-Object { Write-Error -ErrorRecord $_ }
			return
		}
		foreach ($line in $Output)
		{
			if ($line.StartsWith("# branch.oid"))
			{
				$RepositoryData | Add-Member -MemberType NoteProperty -Name "CurrentCommit" -Value ($line.Substring(13))
			}
			elseif ($line.StartsWith("# branch.head"))
			{
				$RepositoryData | Add-Member -MemberType NoteProperty -Name "CurrentBranch" -Value ($line.Substring(14))
			}
			elseif ($line -cmatch '1\s([\.MADRCU\?\!][\.MDUA]?)\s(N\.\.\.)\s([0-7]{6})\s([0-7]{6})\s([0-7]{6})\s([0-9a-f]{40})\s([0-9a-f]{40})\s(\S+)')
			{
				#   1    2     3    4    5    6    7    8
				#1 <XY> <sub> <mH> <mI> <mW> <hH> <hI> <path>
				$Files.Add([PSCustomObject]@{
					Path = (Join-Path -Path $Repository -ChildPath $matches[8])
					Status = $matches[1]
				}) | Out-Null
			}
			elseif ($line -cmatch '2\s([\.MADRCU\?\!][\.MDUA]?)\s(N\.\.\.)\s([0-7]{6})\s([0-7]{6})\s([0-7]{6})\s([0-9a-f]{40})\s([0-9a-f]{40})\s([XC])(\d{3})\s(\S+)`t(\S*)')
			{
				#   1    2     3    4    5    6    7    8  9       10         11
				#2 <XY> <sub> <mH> <mI> <mW> <hH> <hI> <X><score> <path><sep><origPath>
				$Files.Add([PSCustomObject]@{
					Path = (Join-Path -Path $Repository -ChildPath $matches[10])
					Status = $matches[1]
					OriginalPath = (Join-Path -Path $Repository -ChildPath $matches[11])
					IsMove = ($matches[8] -eq "C")
				}) | Out-Null
			}
			elseif ($line -cmatch '\?\s(\S+)')
			{
				$Files.Add([PSCustomObject]@{
					Path = (Join-Path -Path $Repository -ChildPath $matches[1])
					Status = "??"
				}) | Out-Null
			}
			else
			{
				Write-Verbose -Message "Ignoring $line"
			}
		}
		$RepositoryData | Add-Member -MemberType NoteProperty -Name "Files" -Value $Files
		Write-Output $RepositoryData
	}
}