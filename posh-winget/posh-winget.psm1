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

function Import-Winget {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Path
    )

    $config = Get-Content -Path $Path | ConvertFrom-Yaml
    $config | ForEach-Object {
        $package = $_
        $list = winget list --id $package.id
        $lines = ($list | Measure-Object -Line).Lines
        if($lines -lt 5) {
            $arguments = @()
            $arguments += 'install'
            if($package.silent -ne $false) {
                $arguments += '--silent'
            }
            $arguments += '--id'
            $arguments += $package.id

            if($null -ne $package.packageParameters) {
                $arguments += '--override'
                $arguments += "`"$($package.packageParameters)`""
            }

            $argumentList = [string]::Join(' ', $arguments)
            Start-Process winget -NoNewWindow -Wait -ArgumentList $argumentList
        } else {
            Write-Host "$($package.id) is installed."
        }
    }
}