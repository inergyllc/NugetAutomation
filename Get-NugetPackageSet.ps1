<#
.SYNOPSIS
    Retrieves a dictionary of package names and their pre-release status based on a specified set name.

.DESCRIPTION
    This function reads a JSON file containing sets of NuGet packages. It then retrieves the set with the specified name and returns a dictionary where the keys are package names and the values are booleans indicating whether the package is a pre-release version.

.PARAMETER SetName
    The name of the set to retrieve from the JSON file.

.PARAMETER JsonFilePath
    The path and file name of the JSON file to read. Defaults to 'nuget.json' in the script's directory if not specified.

.RETURNS
    [hashtable] A dictionary with package names as keys and booleans indicating pre-release status as values.

.EXAMPLE
    Get-NuGetPackageSet -SetName "azmaps"

.EXAMPLE
    Get-NuGetPackageSet -SetName "azmaps" -JsonFilePath "C:\path\to\your\custom.json"
#>
function Get-NuGetPackageSet {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$SetName,

        [Parameter(Mandatory=$false)]
        [string]$JsonFilePath = "$PSScriptRoot\nuget.json"
    )

    # Check if the JSON file exists
    if (-Not (Test-Path -Path $JsonFilePath)) {
        throw "The JSON file '$JsonFilePath' does not exist. Please provide a valid path to a JSON file."
    }

    # Read the JSON content from the file
    $jsonContent = Get-Content -Path $JsonFilePath -Raw | ConvertFrom-Json

    # Find the set with the specified name
    $set = $jsonContent.sets | Where-Object { $_.name -eq $SetName }

    # Check if the set is found
    if ($null -eq $set) {
        throw "Set with name '$SetName' not found in the JSON file."
    }

    # Initialize an empty hashtable to store the package names and their pre-release status
    $packageDict = @{}

    # Iterate over each package in the set
    foreach ($package in $set.packages) {
        # Determine if the package version is pre-release
        $isPreRelease = if ($package.version -eq "prerelease") { $true } else { $false }
        # Add the package name and pre-release status to the dictionary
        $packageDict[$package.package] = $isPreRelease
    }

    # Return the dictionary of package names and pre-release status
    return $packageDict
}



<# Example usage
$setName = "azmaps"
$packageSet = Get-NuGetPackageSet -SetName $setName

# Output the results
$packageSet.GetEnumerator() | ForEach-Object { 
    Write-Output "Package: $($_.Key), Pre-release: $($_.Value)"
}

# Example usage
$setName = "azmaps"
$jsonFilePath = "C:\path\to\your\custom.json" # Or use default path
$packageSet = Get-NuGetPackageSet -SetName $setName -JsonFilePath $jsonFilePath

# Output the results
$packageSet.GetEnumerator() | ForEach-Object { 
    Write-Output "Package: $($_.Key), Pre-release: $($_.Value)"
}
#>