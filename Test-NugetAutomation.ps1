# Example usage for getting the latest version of a package
$packageName = "Newtonsoft.Json"
$includePrerelease = $false  # Change this to $true if you want to include pre-release versions
$latestVersion = Get-LatestNuGetPackageVersion -PackageName $packageName -IncludePrerelease:$includePrerelease

if ($latestVersion) {
    Write-Output "The latest version of $packageName is $latestVersion"
} else {
    Write-Output "Could not find the latest version of $packageName"
}

# Example usage for getting the latest versions of multiple packages
$packageNames = @("Newtonsoft.Json", "Azure.AI.OpenAI")
$includePrerelease = $true  # Change this to $false if you want to exclude pre-release versions
$latestVersions = Get-LatestNuGetPackageVersions -PackageNames $packageNames -IncludePrerelease:$includePrerelease

foreach ($package in $latestVersions.Keys) {
    if ($latestVersions[$package]) {
        Write-Output "The latest version of $package is $($latestVersions[$package])"
    } else {
        Write-Output "Could not find the latest version of $package"
    }
}

# Example usage for adding a line to the .csproj file
$csprojPath = "path\to\your\project.csproj"
$lineToAdd = '<PackageReference Include="New.Package" Version="1.0.0" />'
Add-LineToCsproj -CsprojPath $csprojPath -LineToAdd $lineToAdd

# Example usage for adding dictionary entries to the .csproj file
Add-DictionaryToCsproj -CsprojPath $csprojPath -PackageVersions $latestVersions
