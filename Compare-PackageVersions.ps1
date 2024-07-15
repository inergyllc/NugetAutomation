<#
.SYNOPSIS
    Compares two version strings to determine if the second version is later than the first.

.DESCRIPTION
    This function takes two version strings, including pre-release versions, and compares them to determine if the second version is later than the first version.

.PARAMETER Version1
    The first version string to compare.

.PARAMETER Version2
    The second version string to compare.

.RETURNS
    [bool] indicating whether the second version is later than the first version.

.EXAMPLE
    Compare-PackageVersions -Version1 "1.0.0" -Version2 "1.0.1"

.EXAMPLE
    Compare-PackageVersions -Version1 "1.0.0-beta" -Version2 "1.0.0"

.EXAMPLE
    Compare-PackageVersions -Version1 "1.0.0-beta.1" -Version2 "1.0.0-beta.11"
#>
function Compare-PackageVersions {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Version1,

        [Parameter(Mandatory=$true)]
        [string]$Version2
    )

    function Parse-Version {
        param (
            [string]$Version
        )
        $parts = $Version -split '-'
        $versionPart = [Version]$parts[0]
        $preReleasePart = if ($parts.Length -gt 1) { $parts[1] } else { $null }
        return [PSCustomObject]@{
            Version = $versionPart
            PreRelease = $preReleasePart
        }
    }

    function Compare-PreRelease {
        param (
            [string]$PreRelease1,
            [string]$PreRelease2
        )

        # Define the order for pre-release labels
        $preReleaseOrder = @{
            "alpha" = 0
            "beta" = 1
            "rc" = 2
        }

        $label1, $number1 = $PreRelease1 -split '\.', 2
        $label2, $number2 = $PreRelease2 -split '\.', 2

        $order1 = $preReleaseOrder[$label1.ToLower()] + 0
        $order2 = $preReleaseOrder[$label2.ToLower()] + 0

        if ($order1 -lt $order2) {
            return -1
        } elseif ($order1 -gt $order2) {
            return 1
        } else {
            # Compare numeric part if labels are the same
            if ([int]$number1 -lt [int]$number2) {
                return -1
            } elseif ([int]$number1 -gt [int]$number2) {
                return 1
            } else {
                return 0
            }
        }
    }

    $ver1 = Parse-Version -Version $Version1
    $ver2 = Parse-Version -Version $Version2

    if ($ver1.Version -lt $ver2.Version) {
        return $true
    } elseif ($ver1.Version -gt $ver2.Version) {
        return $false
    } else {
        if ($null -eq $ver1.PreRelease -and $null -ne $ver2.PreRelease) {
            return $true
        } elseif ($null -ne $ver1.PreRelease -and $null -eq $ver2.PreRelease) {
            return $false
        } elseif ($null -eq $ver1.PreRelease -and $null -eq $ver2.PreRelease) {
            return $false
        } else {
            return Compare-PreRelease -PreRelease1 $ver1.PreRelease -PreRelease2 $ver2.PreRelease -gt 0
        }
    }
}

<# Example usage
$version1 = "1.0.0-beta.1"
$version2 = "1.0.0-beta.11"
$isLater = Compare-PackageVersions -Version1 $version1 -Version2 $version2

if ($isLater) {
    Write-Output "$version2 is later than $version1"
} else {
    Write-Output "$version2 is not later than $version1"
}

$version1 = "1.0.0-alpha"
$version2 = "1.0.0-beta"
$isLater = Compare-PackageVersions -Version1 $version1 -Version2 $version2

if ($isLater) {
    Write-Output "$version2 is later than $version1"
} else {
    Write-Output "$version2 is not later than $version1"
}

$version1 = "1.0.0-beta"
$version2 = "1.0.0-rc"
$isLater = Compare-PackageVersions -Version1 $version1 -Version2 $version2

if ($isLater) {
    Write-Output "$version2 is later than $version1"
} else {
    Write-Output "$version2 is not later than $version1"
}
#>