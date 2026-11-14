. "$PSScriptRoot/environment.ps1"
$ErrorActionPreference='Stop'
$rows=Import-Csv -Encoding UTF8 localization/strings.csv
$families=@(
    @('Arabic','ar','Noto Sans Arabic','notosansarabic'),
    @('Devanagari','hi','Noto Sans Devanagari','notosansdevanagari'),
    @('Thai','th','Noto Sans Thai','notosansthai'),
    @('JP','ja','Noto Sans JP','notosansjp'),
    @('KR','ko','Noto Sans KR','notosanskr'),
    @('SC','zh-CN','Noto Sans SC','notosanssc')
)
$manifest=@{}
foreach($entry in $families) {
    $text=($rows | ForEach-Object { $_.($entry[1]) }) -join ''
    $text+=-join (32..126 | ForEach-Object {[char]$_})
    $characters=@($text.ToCharArray() | ForEach-Object {[int]$_} | Sort-Object -Unique)
    $family=[Uri]::EscapeDataString($entry[2]+':wght@500..800')
    # Public CSS only. No text, characters, project identifiers, or file contents are sent.
    $request='https://fonts.googleapis.com/css2?family='+$family+'&display=swap'
    $response=Invoke-WebRequest -UseBasicParsing -Uri $request -UserAgent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36' -TimeoutSec 30
    $selected=@{}
    foreach($face in [regex]::Matches($response.Content,'@font-face\s*\{([^}]+)\}')) {
        $body=$face.Groups[1].Value
        $match=[regex]::Match($body,'url\((https://fonts\.gstatic\.com/[^)]+)\)')
        if(-not $match.Success) { continue }
        $range=[regex]::Match($body,'unicode-range:\s*([^;]+)')
        $needed=-not $range.Success
        if($range.Success) {
            foreach($item in $range.Groups[1].Value.Split(',')) {
                $hex=$item.Trim().Substring(2)
                $parts=$hex.Split('-')
                $low=[Convert]::ToInt32($parts[0].Replace('?','0'),16)
                $high=[Convert]::ToInt32($(if($parts.Count -gt 1){$parts[1]}else{$parts[0].Replace('?','F')}),16)
                foreach($code in $characters) { if($code -ge $low -and $code -le $high) { $needed=$true; break } }
                if($needed) { break }
            }
        }
        if($needed) { $selected[$match.Groups[1].Value]=$true }
    }
    if($selected.Count -eq 0) { throw ('No public font files selected for '+$entry[2]) }
    $files=@()
    $part=0
    foreach($url in ($selected.Keys | Sort-Object)) {
        $name='NotoSans'+$entry[0]+'-'+$part.ToString('000')+'.woff2'
        Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile ('assets/fonts/'+$name) -TimeoutSec 30
        $files+=('res://assets/fonts/'+$name)
        $part++
    }
    $manifest[$entry[0]]=$files
    Invoke-WebRequest -UseBasicParsing -Uri ('https://raw.githubusercontent.com/google/fonts/main/ofl/'+$entry[3]+'/OFL.txt') -OutFile ('assets/fonts/LICENSES/NotoSans'+$entry[0]+'-OFL.txt') -TimeoutSec 30
    Write-Output ('Downloaded existing public shards: '+$entry[2]+' files='+$files.Count)
}
$manifest | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8 assets/fonts/manifest.json
Get-ChildItem assets/fonts -File | Select-Object Name,Length
