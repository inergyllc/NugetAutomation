<#
.SYNOPSIS
    Retrieves the latest versions of specified NuGet packages based on a dictionary of package names and pre-release status.

.DESCRIPTION
    This function takes a dictionary of NuGet package names and their pre-release status, and returns a dictionary where the keys are package names and the values are their latest versions.

.PARAMETER PackageDict
    A dictionary of NuGet package names and booleans indicating whether to include pre-release versions.

.EXAMPLE
    $packageDict = @{
        "Newtonsoft.Json" = $false
        "Azure.AI.OpenAI" = $true
    }
    $results = Get-LatestNuGetPackageVersions -PackageDict $packageDict
    $results
#>
function Get-LatestNuGetPackageVersions {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [hashtable]$PackageDict
    )

    # Initialize a dictionary to store the package names and their latest versions
    $results = @{}

    # Iterate over each package name and its pre-release status
    foreach ($packageName in $PackageDict.Keys) {
        $includePrerelease = $PackageDict[$packageName]
        
        # Get the latest version of the current package
        $latestVersion = Get-LatestNuGetPackageVersion -PackageName $packageName -IncludePrerelease:$includePrerelease

        # Add the package name and version to the dictionary
        $results[$packageName] = $latestVersion
    }

    # Return the dictionary of results
    return $results
}

<# Example usage for getting the latest versions of multiple packages
$packageDict = @{
    "Newtonsoft.Json" = $false
    "Azure.AI.OpenAI" = $true
    "Azure.AI.Vision.Core" = $true
}
$latestVersions = Get-LatestNuGetPackageVersions -PackageDict $packageDict

foreach ($package in $latestVersions.Keys) {
    if ($latestVersions[$package]) {
        Write-Output "The latest version of $package is $($latestVersions[$package])"
    } else {
        Write-Output "Could not find the latest version of $package"
    }
}
#>