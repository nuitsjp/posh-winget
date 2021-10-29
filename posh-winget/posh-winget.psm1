function Install-Winget {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Id
    )

    if((Test-InstalledWinget -Id $Id) -eq $false) {
        winget install --id $Id
        $true
    }
    else {
        $false
    }
}

function Test-InstalledWinget
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Id
    )
  
    $list = winget list --id $Id
    $lines = ($list | Measure-Object -Line).Lines
    $lines -eq 5
}