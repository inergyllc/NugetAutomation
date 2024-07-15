. ./Add-PackageDictionaryToCsproj.ps1

<#
.SYNOPSIS
    Combines multiple sets of NuGet packages into a single set and adds them to a .csproj file.

.DESCRIPTION
    This function retrieves multiple sets of NuGet packages from a JSON file, aggregates them into a single set, and adds them to a specified .csproj file. It ensures that the packages are added correctly, handling duplicates appropriately.

.PARAMETER SetNames
    An array of set names to retrieve from the JSON file.

.PARAMETER CsprojPath
    The path to the .csproj file to which the packages should be added.

.PARAMETER JsonFilePath
    The path and file name of the JSON file to read. Defaults to 'nuget.json' in the script's directory if not specified.

.RETURNS
    None

.EXAMPLE
    $setNames = @("azmaps", "azure-core")
    $csprojPath = "C:\path\to\your\project.csproj"
    Add-NuGetPackagesToCsproj -SetNames $setNames -CsprojPath $csprojPath
#>
function Add-NuGetPackagesToCsproj {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$SetNames,

        [Parameter(Mandatory=$true)]
        [string]$CsprojPath,

        [Parameter(Mandatory=$false)]
        [string]$JsonFilePath = "$PSScriptRoot\nuget.json"
    )

    # Function to get aggregated NuGet package set
    function Get-AggregatedNuGetPackageSet {
        param (
            [string[]]$SetNames,
            [string]$JsonFilePath
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

    <# Function to add packages to a .csproj file
    function Add-NuGetPackageDictionaryToCsproj {
        param (
            [hashtable]$PackageDict,
            [string]$CsprojPath
        )

        # Read the content of the .csproj file
        $csprojContent = Get-Content -Path $CsprojPath

        # Find the line where the last ItemGroup starts
        $itemGroupIndex = $csprojContent.LastIndexOf("<ItemGroup>")

        if ($itemGroupIndex -ne -1) {
            # Find the closing tag of the last ItemGroup
            $endItemGroupIndex = $csprojContent.IndexOf("</ItemGroup>", $itemGroupIndex)
            
            # If the ItemGroup is found, add the new line before the closing tag
            if ($endItemGroupIndex -ne -1) {
                foreach ($package in $PackageDict.Keys) {
                    $version = if ($PackageDict[$package]) { "prerelease" } else { "latest" }
                    $lineToAdd = "    <PackageReference Include=`"$package`" Version=`"$version`" />"
                    $csprojContent.Insert($endItemGroupIndex, "    $lineToAdd`n") | Out-Null
                }
                Set-Content -Path $CsprojPath -Value $csprojContent -Force
                Write-Output "Packages added to .csproj file successfully."
            } else {
                Write-Error "Closing </ItemGroup> tag not found."
            }
        } else {
            # Add a new ItemGroup if none exists
            $newItemGroup = "<ItemGroup>`n"
            foreach ($package in $PackageDict.Keys) {
                $version = if ($PackageDict[$package]) { "prerelease" } else { "latest" }
                $newItemGroup += "    <PackageReference Include=`"$package`" Version=`"$version`" />`n"
            }
            $newItemGroup += "</ItemGroup>`n"
            $csprojContent += $newItemGroup
            Set-Content -Path $CsprojPath -Value $csprojContent -Force
            Write-Output "ItemGroup added to .csproj file successfully."
        }
    }
    #>

    # Get the aggregated NuGet package set
    $aggregatedPackageSet = Get-AggregatedNuGetPackageSet -SetNames $SetNames -JsonFilePath $JsonFilePath
    $aggregatedPackageVersionDict = Get-LatestNuGetPackageVersions -PackageDict $aggregatedPackageSet
    Add-NuGetPackageDictionaryToCsproj -PackageDict $aggregatedPackageVersionDict -CsprojPath $CsprojPath
}

# Example usage
$setNames = @("azmaps", "azure-core")
$csprojPath = "D:\source\AzureOpenaiResponseSetValidation\AzureOpenaiResponseSetValidation\AzureOpenaiResponseSetValidation.csproj"
Add-NuGetPackagesToCsproj -SetNames $setNames -CsprojPath $csprojPath
