function Add-PackageDictionaryToCsproj {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$CsprojPath,

        [Parameter(Mandatory=$true)]
        [hashtable]$PackageVersions
    )

    # Iterate over each package and its version in the dictionary
    foreach ($package in $PackageVersions.Keys) {
        $version = $PackageVersions[$package]
        if ($version) {
            # Create the line to add
            $lineToAdd = "<PackageReference Include=`"$package`" Version=`"$version`" />"
            # Add the line to the .csproj file
            Add-PackageLineToCsproj -CsprojPath $CsprojPath -LineToAdd $lineToAdd
        }
    }
}
