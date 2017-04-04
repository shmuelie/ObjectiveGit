vs2017
$SolutionDir = Get-Location
msbuild ObjectiveGit.pssproj /m /p:SolutionDir=$SolutionDir /p:Tags=Git%2cSvn