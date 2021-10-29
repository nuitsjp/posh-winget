[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $NuGetApiKey
)

Import-Module PowerShellGet
Publish-PSResource -path .\posh-winget -Repository PSGallery -apikey $NuGetApiKey
