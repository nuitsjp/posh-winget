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
    if($Packages.Length -eq 1) {
        @()
    }

    $header = $Packages[0]
    $header = $header.Substring($header.LastIndexOf("`r") + 1).Trim()
    $indexs = @()
    $header.Split(" ") | Where-Object { $_.Length -ne 0} | ForEach-Object {
        $column = $_
        $indexs += Get-Width $header.Substring(0, $header.IndexOf($column))
    }

    # $indexs
    [array]::Reverse( $indexs )

    $result = @()
    $Packages | Select-Object -Skip 2 | ForEach-Object {
        $line = $_
        $columns = @()
        $indexs | ForEach-Object {
            $index = Get-Index $line $_
            $column = $line.Substring($index).Trim()
            if ($column.EndsWith("…")) {
                $column = $column.Substring(0, $column.Length - 1)
            }
            $columns += $column
            $line = $line.Substring(0, $index)
        }
        if ($columns.Length -eq 5) {
            $result += [PSCustomObject]@{
                NamePrefix = $columns[4]
                IdPrefix = $columns[3]
                Version = $columns[2]
                Available = $columns[1]
                Source = $columns[0]
            }
        }
        els {
            $result += [PSCustomObject]@{
                NamePrefix = $columns[3]
                IdPrefix = $columns[3]
                Version = $columns[1]
                Source = $columns[0]
            }
        }
    }
    $result
}

function Get-Width
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $str
    )
    $encoding = [system.Text.Encoding]::UTF8
    $charArray = $str.ToCharArray()
    $width = 0
    for ($i = 0; $i -lt $charArray.Count; $i++) {
        $char = $charArray[$i]
        if($char -eq "…") {
            $width += 1;
        }
        elseif ($encoding.GetBytes($char).Length -eq 1) {
            $width += 1;
        }
        else {
            $width += 2;
        }
    }
    $width
}

function Get-Index
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Word,
        [Parameter()]
        [int]
        $halfCharIndex
    )
    $encoding = [system.Text.Encoding]::UTF8

    if ($halfCharIndex -eq 0) {
        0
        return
    }

    $wordChars = $Word.ToCharArray()
    $currentIndex = 0
    for ($i = 0; $i -lt $wordChars.Count; $i++) {
        $current = $Word[$i]
        if($current -eq "…") {
            $currentIndex += 1;
        }
        elseif ($encoding.GetBytes($current).Length -eq 1) {
            $currentIndex += 1;
        }
        else {
            $currentIndex += 2;
        }
        if($currentIndex -eq $halfCharIndex) {
            ($i + 1)
            break
        }
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