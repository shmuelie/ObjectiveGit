function Export-SvnRepository
{
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$False,Position=1,ValueFromPipeline=$True)]
		[string]$Repository = ".\"
	)
	process
	{
		$Repository = Resolve-Path -Path $Repository
		Write-Verbose -Message "Committing SVN $Repository"
		$ErrorCount = $Error.Count
		$Output = (Invoke-Expression -Command "git -C $Repository svn dcommit") 2>&1
		if ($Error.Count -gt $ErrorCount)
		{
			$Error | select -Skip $ErrorCount | ForEach-Object { Write-Error -ErrorRecord $_ }
			return
		}
		$Output = [string[]]$Output;
		$CommitData = [PSCustomObject]@{}
		$Files = New-Object System.Collections.ArrayList
		for($i = 1; $i -lt $Output.Length; $i++)
		{
			$Line = $Output[$i]
			if ($Line -cmatch '\s+(\S+)\s+(\S+)')
			{
				$File = [PSCustomObject]@{}
				$File | Add-Member -MemberType NoteProperty -Name "Status" -Value ($Matches[1])
				$File | Add-Member -MemberType NoteProperty -Name "Path" -Value ($Matches[2])
				$Files.Add($File) | Out-Null
			}
			elseif ($Line -cmatch 'Committed r\d+')
			{
				$i += $Files.Count
			}
			elseif ($Line -cmatch '(r\d+)\s=\s([0-9a-f]{40}).*')
			{
				$CommitData | Add-Member -MemberType NoteProperty -Name "Files" -Value $Files
				$CommitData | Add-Member -MemberType NoteProperty -Name "SvnCommit" -Value ($Matches[1])
				$CommitData | Add-Member -MemberType NoteProperty -Name "GitCommit" -Value ($Matches[2])
				Write-Output $CommitData
				$CommitData = [PSCustomObject]@{}
				$Files = New-Object System.Collections.ArrayList
			}
		}
	}
}