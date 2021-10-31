function Winget-Install {
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
    $Packagess = ($list | Measure-Object -Line).Lines
    $Packagess -eq 5
}

function Winget-Import {
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
        $Packagess = ($list | Measure-Object -Line).Lines
        if($Packagess -lt 5) {
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

function Winget-List {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Query,
        [Parameter()]
        [string]
        $Id
    )
    if ($Id) {
        $listText = (Invoke-Winget list "--id $Id") -split "`r`n"
        if ($listText.Length -eq 1) {
            $null
        }
        else {
            Read-Package $listText
        }
    }
    else {
        $listText = (Invoke-Winget list $Query) -split "`r`n"
    }
}

function Read-Package {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string[]]
        $Packages
    )
    $result = @()
    if($Packages.Length -eq 1) {
        $result
    }

    $enc = [system.Text.Encoding]::UTF8 #GetEncoding('Shift_JIS')
    $header = $Packages[0].Trim()
    $header = $header.Substring($header.LastIndexOf("`r") + 1);
    $headerColumns = ($header -split ' ') | Where-Object { $_.length -ne 0 }
    $nameIndex;
    $idIndex;
    $versionIndex;
    $latestVersionIndex;
    $sourceIndex;
    if ($header.Length -eq 5) {
        $nameIndex = 0;
        $idIndex;
        $versionIndex;
        $latestVersionIndex;
        $sourceIndex;
    }
    # $header[0]
    # $header.IndexOf(' ')
    # $header.Substring(0, 18)
    # $data1 = $enc.GetBytes($header) 
    # $data1


    # $Packages
    # $header = $Packages[0]
    # $sourceIndex = $header.LastIndexOf(' ');
    # $package = $Packages[2]
    # $package.Substring($sourceIndex);
    # $temp = $Packages
    # $source = $temp.Substring($temp.LastIndexOf(' ')).Trim()
    # $source
    # $temp = $temp.Substring(0, $temp.LastIndexOf(' '))
    # $version = $temp.Substring($temp.LastIndexOf(' ')).Trim()
    # $version
    # $temp = $temp.Substring(0, $temp.LastIndexOf(' '))
    # $idPrefix = $temp.Substring($temp.LastIndexOf(' ')).Trim()
    # $idPrefix
    # $temp = $temp.Substring(0, $temp.LastIndexOf(' '))
    # $namePrefix = $temp.Substring($temp.LastIndexOf(' ')).Trim()
    # $namePrefix
}

function Invoke-Winget {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Command,
        [Parameter()]
        [string]
        $Arguments
    )
    $psi = New-Object Diagnostics.ProcessStartInfo
    $psi.FileName = $env:LOCALAPPDATA + "\Microsoft\WindowsApps\winget.exe"
    $psi.Arguments = "$Command $Arguments"
    $psi.UseShellExecute = $false
    $psi.StandardOutputEncoding = [Text.Encoding]::UTF8
    $psi.RedirectStandardOutput = $true
    Using-Object ($p = [Diagnostics.Process]::Start($psi)) {
        $s = $p.StandardOutput.ReadToEnd()
        $p.WaitForExit()
        $s.Trim()
    }
}

function Using-Object
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [AllowNull()]
        [Object]
        $InputObject,

        [Parameter(Mandatory = $true)]
        [scriptblock]
        $ScriptBlock
    )

    try
    {
        . $ScriptBlock
    }
    finally
    {
        if ($null -ne $InputObject -and $InputObject -is [System.IDisposable])
        {
            $InputObject.Dispose()
        }
    }
}