$readme = 'README.md'
$exts = '.jpg', '.jpeg', '.png', '.webp', '.gif', '.bmp'
$files = Get-ChildItem -File | Where-Object { $exts -contains $_.Extension.ToLower() } | Sort-Object { $_.Name.ToLower() }
$count = $files.Count

$cells = $files | ForEach-Object {
    $n = $_.Name
    '<td><a href="{0}"><img src="{0}" width="200"/></a></td>' -f $n
}

$lines = @()
for ($r = 0; $r -lt [math]::Ceiling($cells.Count / 4.0); $r++) {
    $lines += '<tr>'
    $cells | Select-Object -Skip ($r * 4) -First 4 | ForEach-Object { $lines += $_ }
    $lines += '</tr>'
}
$table = "<table>`n" + ($lines -join "`n") + "`n</table>"

$content = Get-Content -LiteralPath $readme
$start = ($content | Select-String -SimpleMatch '<!-- gallery-start -->' | Select-Object -First 1).LineNumber
$end = ($content | Select-String -SimpleMatch '<!-- gallery-end -->' | Select-Object -First 1).LineNumber
if (-not $start -or -not $end -or $start -ge $end) {
    Write-Error "README.md is missing the <!-- gallery-start --> / <!-- gallery-end --> markers."
    exit 1
}

$newContent = $content[0..($start - 1)] + ($table -split "`n") + $content[($end - 1)..($content.Count - 1)]

$out = $newContent | ForEach-Object {
    if ($_ -match '^A personal collection of \d+ desktop wallpapers\.$') {
        "A personal collection of $count desktop wallpapers."
    }
    else { $_ }
}

$out | Set-Content -LiteralPath $readme -Encoding utf8
Write-Host "README.md updated: $count wallpapers"