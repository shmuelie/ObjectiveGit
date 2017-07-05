function Get-Branch
{
	<#
		.Synopsis
		List branches.

		.Description
		Gets the local and remote branches for the repository.

		.Parameter Repository
		Path to the git repository. Can be relative or absolute. If not specified defaults to the current directory

		.Link
		https://git-scm.com/docs/git-branch
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$False,Position=1,ValueFromPipeline=$True)]
		[string]$Repository = ".\"
	)
	process
	{
		$Repository = Resolve-Path -Path $Repository
		Write-Verbose -Message "Getting local branches for $Repository"
		$Output = (git -C $Repository branch --no-color -vv --no-abbrev) 2>&1
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
		foreach ($line in $Output)
		{
			if ($line -imatch '(\*|\s)\s(\S+)\s+\-\>\s(\S+)')
			{
				Write-Output ([PSCustomObject]@{
					Current = ($Matches[1] -eq '*')
					Name = $Matches[2]
					Hash = ""
					Tracks = ""
					DifferenceFromTrack = 0
					PointsTo = $Matches[3]
					Remote = $false
					LastCommitMessage = ""
				})
			}
			elseif ($line -imatch '(\*|\s)\s(\S+)\s+([0-9a-f]{40})\s\[(\S+)\:\sbehind\s(\d+)\]\s(.+)')
			{
				Write-Output ([PSCustomObject]@{
					Current = ($Matches[1] -eq '*')
					Name = $Matches[2]
					Hash = $Matches[3]
					Tracks = $Matches[4]
					DifferenceFromTrack = (-1 * [int]::Parse($Matches[5]))
					PointsTo = ""
					Remote = $false
					LastCommitMessage = $Matches[6]
				})
			}
			elseif ($line -imatch '(\*|\s)\s(\S+)\s+([0-9a-f]{40})\s\[(\S+)\:\sahead\s(\d+)\]\s(.+)')
			{
				Write-Output ([PSCustomObject]@{
					Current = ($Matches[1] -eq '*')
					Name = $Matches[2]
					Hash = $Matches[3]
					Tracks = $Matches[4]
					DifferenceFromTrack = ([int]::Parse($Matches[5]))
					PointsTo = ""
					Remote = $false
					LastCommitMessage = $Matches[6]
				})
			}
			elseif ($line -imatch '(\*|\s)\s(\S+)\s+([0-9a-f]{40})\s\[(\S+)\]\s(.+)')
			{
				Write-Output ([PSCustomObject]@{
					Current = ($Matches[1] -eq '*')
					Name = $Matches[2]
					Hash = $Matches[3]
					Tracks = $Matches[4]
					DifferenceFromTrack = 0
					PointsTo = ""
					Remote = $false
					LastCommitMessage = $Matches[5]
				})
			}
			elseif ($line -imatch '(\*|\s)\s(\S+)\s+([0-9a-f]{40})\s(.+)')
			{
				Write-Output ([PSCustomObject]@{
					Current = ($Matches[1] -eq '*')
					Name = $Matches[2]
					Hash = $Matches[3]
					Tracks = ""
					DifferenceFromTrack = 0
					PointsTo = ""
					Remote = $false
					LastCommitMessage = $Matches[4]
				})
			}
		}
		Write-Verbose -Message "Getting remote branches for $Repository"
		$ErrorCount = $Error.Count
		$Output = (git -C $Repository branch --no-color -vv --no-abbrev -r) 2>&1
		if ($Error.Count -gt $ErrorCount)
		{
			$Error | select -Skip $ErrorCount | ForEach-Object { Write-Error -ErrorRecord $_ }
			return
		}
		foreach($line in $Output)
		{
			if ($line -imatch '(\*|\s)\s(\S+)\s+([0-9a-f]{40})\s(.+)')
			{
				Write-Output ([PSCustomObject]@{
					Current = ($Matches[1] -eq '*')
					Name = $Matches[2]
					Hash = $Matches[3]
					Tracks = ""
					DifferenceFromTrack = 0
					PointsTo = ""
					Remote = $true
					LastCommitMessage = $Matches[4]
				})
			}
			elseif ($line -imatch '(\*|\s)\s(\S+)\s+\-\>\s(\S+)')
			{
				Write-Output ([PSCustomObject]@{
					Current = ($Matches[1] -eq '*')
					Name = $Matches[2]
					Hash = ""
					Tracks = ""
					DifferenceFromTrack = 0
					PointsTo = $Matches[3]
					Remote = $true
					LastCommitMessage = ""
				})
			}
		}
	}
}