[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $NuGetApiKey
)

# Install-Module -Name PowerShellGet -AllowPrerelease -Force
Import-Module PowerShellGet
Publish-PSResource -path .\posh-winget -Repository PSGallery -apikey $NuGetApiKey
