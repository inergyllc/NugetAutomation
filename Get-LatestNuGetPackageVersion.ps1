<#
.SYNOPSIS
    Retrieves the latest version of specified NuGet packages from the NuGet API and updates the .csproj file.

.DESCRIPTION
    This script defines functions that query the NuGet V3 API to get the latest version of specified NuGet packages.
    It includes an option to include or exclude pre-release versions. Additionally, it defines functions to process
    an array of package names, return a dictionary with package names and their latest versions, and update the .csproj file.

.PARAMETER PackageName
    The name of the NuGet package for which to retrieve the latest version.

.PARAMETER IncludePrerelease
    A switch indicating whether to include pre-release versions in the search.

.PARAMETER PackageNames
    An array of NuGet package names to process.

.PARAMETER CsprojPath
    The path to the .csproj file to update.

.PARAMETER LineToAdd
    The line to add to the .csproj file.

.EXAMPLE
    Get-LatestNuGetPackageVersion -PackageName "Newtonsoft.Json" -IncludePrerelease:$true

.EXAMPLE
    $packages = @("Newtonsoft.Json", "Azure.AI.OpenAI")
    $results = Get-LatestNuGetPackageVersions -PackageNames $packages -IncludePrerelease:$false
    $results

.EXAMPLE
    Add-LineToCsproj -CsprojPath "path\to\your\project.csproj" -LineToAdd '<PackageReference Include="New.Package" Version="1.0.0" />'

.EXAMPLE
    $packages = @("Newtonsoft.Json", "Azure.AI.OpenAI")
    $results = Get-LatestNuGetPackageVersions -PackageNames $packages -IncludePrerelease:$false
    Add-DictionaryToCsproj -CsprojPath "path\to\your\project.csproj" -PackageVersions $results
#>

function Get-LatestNuGetPackageVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$PackageName,

        [Parameter(Mandatory=$false)]
        [switch]$IncludePrerelease
    )

    # Construct the URL for the NuGet API to get the versions of the specified package
    $nugetUrl = "https://api.nuget.org/v3-flatcontainer/$PackageName/index.json"

    try {
        # Send an HTTP GET request to the NuGet API
        $response = Invoke-RestMethod -Uri $nugetUrl -Method Get
        if ($response.versions) {
            # Get the list of versions from the response
            $versions = $response.versions

            # Filter out pre-release versions if the switch is not set
            if (-not $IncludePrerelease) {
                $versions = $versions -notmatch '-'
            }

            # Return null if no versions are found
            if ($versions.Count -eq 0) {
                return $null
            }

            # Return the latest version (the last item in the list)
            $latestVersion = $versions[-1]
            return $latestVersion
        } else {
            # Return null if no versions are found
            return $null
        }
    } catch {
        # Return null if an error occurs
        return $null
    }
}


<# Example usage for getting the latest version of a package
$packageName = "Newtonsoft.Json"
$includePrerelease = $false  # Change this to $true if you want to include pre-release versions
$latestVersion = Get-LatestNuGetPackageVersion -PackageName $packageName -IncludePrerelease:$includePrerelease

if ($latestVersion) {
    Write-Output "The latest version of $packageName is $latestVersion"
} else {
    Write-Output "Could not find the latest version of $packageName"
}

$packageName = "Azure.Ai.OpenAI"
$includePrerelease = $false  # Change this to $true if you want to include pre-release versions
$latestVersion = Get-LatestNuGetPackageVersion -PackageName $packageName -IncludePrerelease:$includePrerelease

if ($latestVersion) {
    Write-Output "The latest version of $packageName is $latestVersion"
} else {
    Write-Output "Could not find the latest version of $packageName"
}

$packageName = "Azure.Ai.OpenAI"
$includePrerelease = $true  # Change this to $true if you want to include pre-release versions
$latestVersion = Get-LatestNuGetPackageVersion -PackageName $packageName -IncludePrerelease:$includePrerelease

if ($latestVersion) {
    Write-Output "The latest version of $packageName is $latestVersion"
} else {
    Write-Output "Could not find the latest version of $packageName"
}
#>