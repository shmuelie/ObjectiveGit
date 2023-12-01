$usingNewJoinPath = (Get-Command Join-Path | Select-Object -ExpandProperty ParameterSets | Select-Object -ExpandProperty Parameters | Select-Object -ExpandProperty Name) -contains "AdditionalChildPath"
function JoinPaths {
    param(
    [string[]]$parts
    )
    if ($usingNewJoinPath -eq $true -and $parts.Length -gt 2) {
        Write-Output (Join-Path -Path $parts[0] -ChildPath $parts[1] -AdditionalChildPath ($parts | Select-Object -Skip 2))
    } else {
        if ($parts.Length -eq 2) {
            Write-Output (Join-Path -Path $parts[0] -ChildPath $parts[1])
        } else {
            Write-Output (Join-Path -Path $parts[0] -ChildPath (JoinPaths($parts | Select-Object -Skip 1)))
        }
    }
}

$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$moduleName = Split-Path -Path $moduleRoot -Leaf
$moduleInfo = (Get-Content -Path (JoinPaths($moduleRoot,'src',"$moduleName.psd1")) -Raw | Invoke-Expression)
$installLocations = $env:PSModulePath -split ';'

if ($Args.Count -eq 1) {
    $userChoice = [int]$Args[0]
    if ($userChoice -lt 0 -or $userChoice -ge $installLocations.Count) {
        Write-Error -Exception 'Invalid installation location' -Category InvalidArgument -ErrorAction Stop
    }
} else {
    Write-Host "Select location to $moduleName" -ForegroundColor Green
    for ($i=0; $i -lt $installLocations.Count; $i++) {
        Write-Host "[$i] $($installLocations[$i])" -ForegroundColor Gray
    }
    Write-Host "[$($installLocations.Count)] Quit"
    $userChoice = -1
    while ($userChoice -lt 0 -or $userChoice -gt $installLocations.Count) {
        $userChoice = Read-Host -Prompt 'Install Location'
    }
    if ($userChoice -eq $installLocations.Count) {
        return
    }
}
$installLocation = JoinPaths(($installLocations[$userChoice]),$moduleName,($moduleInfo.ModuleVersion))
Write-Host "Installing $moduleName in $installLocation" -ForegroundColor Yellow
if ([System.IO.Directory]::Exists("$installLocation") -eq $false) {
    New-Item -Path "$installLocation" -ItemType Directory | Out-Null
} else {
    Get-ChildItem -Path "$installLocation" -Recurse -Force | Remove-Item
}
Copy-Item -Path (Get-ChildItem -Path (JoinPaths("$moduleRoot",'src')) | Select-Object -ExpandProperty FullName) -Destination "$installLocation"

foreach ($dependency in $moduleInfo.RequiredModules) {
    if ($null -eq (get-module -Name $dependency -ListAvailable)) {
        Write-Host "Installing $dependency" -ForegroundColor Yellow
        Install-Module -Name $dependency -Scope CurrentUser
    }
}

