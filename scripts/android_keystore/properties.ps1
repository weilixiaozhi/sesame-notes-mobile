#requires -Version 7.0
<# .SYNOPSIS 按 Java Properties 语法转义，保留空格、反斜杠及非 ASCII 凭据。 #>
function ConvertTo-PropertyValue([string]$Value) {
    -join ($Value.ToCharArray() | ForEach-Object {
        $Code = [int]$_
        if ($Code -le 32 -or $Code -gt 126 -or $_ -in @('\', '=', ':', '#', '!')) {
            '\u{0:x4}' -f $Code
        } else { [string]$_ }
    })
}
