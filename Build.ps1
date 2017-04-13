vs2017
$SolutionDir = Get-Location
msbuild ObjectiveGit.pssproj /m /p:SolutionDir=$SolutionDir /p:Tags=Git%2cSvn /p:LicenseUri=https%3a%2f%2fgithub.com%2fSamuelEnglard%2fObjectiveGit%2fblob%2fmaster%2fLICENSE.txt /p:ProjectUri=https%3a%2f%2fgithub.com%2fSamuelEnglard%2fObjectiveGit /p:ReleaseNotes=Renamed%20commands%20and%20bug%20fixes