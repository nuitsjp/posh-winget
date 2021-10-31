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
    $index = 0
    $indexs = @()
    $isSpace = $true;
    foreach ($char in $header.ToCharArray())
    {
        if(($isSpace) -and ($char -ne " ")) {
            $indexs += $index
        }
        if ($char -eq " ") {
            $isSpace = $true
        }
        else {
            $isSpace = $false
        }

        if ($enc.GetBytes($char).Length -eq 1) {
            $index += 1;
        }
        else {
            $index += 2;
        }
    }

    foreach ($x in $indexs) {
        $header.Substring($x);
    }
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