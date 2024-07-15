<#
.SYNOPSIS
    Adds a specified line to the .csproj file within an ItemGroup.

.DESCRIPTION
    This function takes the path to a .csproj file and a line to add. It inserts the specified line before the closing
    </ItemGroup> tag in the .csproj file. If no ItemGroup exists, it adds a new ItemGroup with the specified line.
    It also ensures that duplicate package references are not added.

.PARAMETER CsprojPath
    The path to the .csproj file to update.

.PARAMETER LineToAdd
    The line to add to the .csproj file.

.EXAMPLE
    Add-LineToCsproj -CsprojPath "path\to\your\project.csproj" -LineToAdd '<PackageReference Include="New.Package" Version="1.0.0" />'
#>
function Add-PackageLineToCsproj {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$CsprojPath,

        [Parameter(Mandatory=$true)]
        [string]$LineToAdd
    )

    # Read the content of the .csproj file
    $csprojContent = Get-Content -Path $CsprojPath -Raw

    # Check if the line to add already exists in the .csproj file
    if ($csprojContent -like "*$LineToAdd*") {
        Write-Output "The line already exists in the .csproj file."
        return
    }

    # Find the line where the last ItemGroup starts
    $itemGroupIndex = $csprojContent.LastIndexOf("<ItemGroup>")

    if ($itemGroupIndex -ne -1) {
        # Find the closing tag of the last ItemGroup
        $endItemGroupIndex = $csprojContent.IndexOf("</ItemGroup>", $itemGroupIndex)
        
        # If the ItemGroup is found, add the new line before the closing tag
        if ($endItemGroupIndex -ne -1) {
            $csprojContent = $csprojContent.Insert($endItemGroupIndex, "    $LineToAdd`n")
            Set-Content -Path $CsprojPath -Value $csprojContent -Force
            Write-Output "Line added to .csproj file successfully."
        } else {
            Write-Error "Closing </ItemGroup> tag not found."
        }
    } else {
        # Add a new ItemGroup if none exists
        $csprojContent += @"
<ItemGroup>
    $LineToAdd
</ItemGroup>
"@
        Set-Content -Path $CsprojPath -Value $csprojContent -Force
        Write-Output "ItemGroup added to .csproj file successfully."
    }
}
