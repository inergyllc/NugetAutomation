<#
.SYNOPSIS
    Aggregates multiple sets of NuGet packages into a single set.

.DESCRIPTION
    This function accepts an array of set names, retrieves the sets from a JSON file, and aggregates them into a single set.
    The function will fail if any sets do not exist. If there are duplicate package entries, it will keep the entry with
    greater reach (accepting pre-release versions if applicable).

.PARAMETER SetNames
    An array of set names to retrieve from the JSON file.

.PARAMETER JsonFilePath
    The path and file name of the JSON file to read. Defaults to 'nuget.json' in the script's directory if not specified.

.RETURNS
    [hashtable] A dictionary with aggregated package names as keys and booleans indicating pre-release status as values.

.EXAMPLE
    $setNames = @("azmaps", "azure-core")
    $results = Get-AggregatedNuGetPackageSet -SetNames $setNames
    $results
#>
function Get-AggregatedNuGetPackageSet {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$SetNames,

        [Parameter(Mandatory=$false)]
        [string]$JsonFilePath = "$PSScriptRoot\nuget.json"
    )

    # Check if the JSON file exists
    if (-Not (Test-Path -Path $JsonFilePath)) {
        throw "The JSON file '$JsonFilePath' does not exist. Please provide a valid path to a JSON file."
    }

    # Read the JSON content from the file
    $jsonContent = Get-Content -Path $JsonFilePath -Raw | ConvertFrom-Json

    # Initialize an empty hashtable to store the aggregated package names and their pre-release status
    $aggregatedPackageDict = @{}

    # Iterate over each set name
    foreach ($setName in $SetNames) {
        # Find the set with the specified name
        $set = $jsonContent.sets | Where-Object { $_.name -eq $setName }

        # Check if the set is found
        if ($null -eq $set) {
            throw "Set with name '$setName' not found in the JSON file."
        }

        # Iterate over each package in the set
        foreach ($package in $set.packages) {
            # Determine if the package version is pre-release
            $isPreRelease = if ($package.version -eq "prerelease") { $true } else { $false }

            # Check if the package already exists in the aggregated dictionary
            if ($aggregatedPackageDict.ContainsKey($package.package)) {
                # Replace the existing entry if the new one has greater reach (accepts pre-release)
                if ($isPreRelease -and -not $aggregatedPackageDict[$package.package]) {
                    $aggregatedPackageDict[$package.package] = $isPreRelease
                }
            } else {
                # Add the package name and pre-release status to the dictionary
                $aggregatedPackageDict[$package.package] = $isPreRelease
            }
        }
    }

    # Return the aggregated dictionary of package names and pre-release status
    return $aggregatedPackageDict
}

<# Example usage
$setNames = @("azmaps", "azure-core")
$aggregatedPackageSet = Get-AggregatedNuGetPackageSet -SetNames $setNames

# Output the results
$aggregatedPackageSet.GetEnumerator() | ForEach-Object { 
    Write-Output "Package: $($_.Key), Pre-release: $($_.Value)"
}

# Example usage with custom JSON file path
$jsonFilePath = "C:\path\to\your\custom.json"
$aggregatedPackageSet = Get-AggregatedNuGetPackageSet -SetNames $setNames -JsonFilePath $jsonFilePath

# Output the results
$aggregatedPackageSet.GetEnumerator() | ForEach-Object { 
    Write-Output "Package: $($_.Key), Pre-release: $($_.Value)"
}
#>