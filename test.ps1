. $PSScriptRoot\posh-winget\posh-winget.ps1

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

# Winget-List -id Microsoft.VisualStudio.2022.Enterprise-Preview
Winget-List Visual

# $line = "名前                                 ID                                   バージョン          利用可能           ソース"
# $line.Split(" ") | Where-Object { $_.Length -ne 0} | ForEach-Object {
#     $column = $_
#     Get-Width $line.Substring(0, $line.IndexOf($column))
# }


# $line = "Visual Studio Enterprise 2022 Previ… Microsoft.VisualStudio.2022.Enterpr… 17.0.0 Preview 2.0  17.0.0 Preview 2.1 winget"

# $index = Get-Index $line 113
# "[" + $line.Substring($index) + "]"
# $line = $line.Substring(0, $index)

# $index = Get-Index $line 94
# "[" + $line.Substring($index) + "]"
# $line = $line.Substring(0, $index)
# $index = Get-Index $line 74
# "[" + $line.Substring($index) + "]"
# $line = $line.Substring(0, $index)
# $index = Get-Index $line 37
# "[" + $line.Substring($index) + "]"
# $line = $line.Substring(0, $index)
# $index = Get-Index $line 0
# "[" + $line.Substring($index) + "]"
