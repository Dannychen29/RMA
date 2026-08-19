[CmdletBinding()]
param([Parameter(Mandatory)][string]$InputPath,[Parameter(Mandatory)][string]$OutputPath,[string]$WorksheetName)
$ErrorActionPreference='Stop'
function Pick($row,[string[]]$names){foreach($n in $names){$p=$row.PSObject.Properties[$n];if($p -and -not [string]::IsNullOrWhiteSpace([string]$p.Value)){return ([string]$p.Value).Trim()}};return $null}
$resolved=(Resolve-Path -LiteralPath $InputPath).Path;$ext=[IO.Path]::GetExtension($resolved).ToLowerInvariant();$rows=@()
if($ext -eq '.csv'){$rows=Import-Csv -LiteralPath $resolved}
elseif($ext -eq '.xlsx'){
  $excel=New-Object -ComObject Excel.Application;$excel.Visible=$false;$excel.DisplayAlerts=$false
  try{$wb=$excel.Workbooks.Open($resolved);$ws=$null;$hr=0
    $candidates=if($WorksheetName){@($wb.Worksheets.Item($WorksheetName))}else{@($wb.Worksheets)}
    foreach($candidate in $candidates){$candidateUsed=$candidate.UsedRange;for($rr=1;$rr -le [Math]::Min(20,$candidateUsed.Rows.Count);$rr++){for($cc=1;$cc -le $candidateUsed.Columns.Count;$cc++){if(([string]$candidateUsed.Cells.Item($rr,$cc).Text).Trim() -eq 'BIC'){$ws=$candidate;$hr=$rr;break}};if($hr){break}};if($hr){break}}
    if($ws){$used=$ws.UsedRange}
    if(-not $hr){throw 'No header row containing BIC was found.'};$headers=@();for($cc=1;$cc -le $used.Columns.Count;$cc++){$headers+=([string]$used.Cells.Item($hr,$cc).Text).Trim()}
    for($rr=$hr+1;$rr -le $used.Rows.Count;$rr++){$o=[ordered]@{};for($cc=1;$cc -le $headers.Count;$cc++){if($headers[$cc-1]){$o[$headers[$cc-1]]=[string]$used.Cells.Item($rr,$cc).Text}};if(($o.Values -join '').Trim()){$rows+=[pscustomobject]$o}}
  }finally{if($wb){$wb.Close($false)};$excel.Quit();[Runtime.InteropServices.Marshal]::ReleaseComObject($excel)|Out-Null}
}else{throw 'Only .xlsx and .csv are supported.'}
if(-not $rows){throw 'Roster contains no data rows.'};$rowArray=@($rows);$hash=(Get-FileHash -Algorithm SHA256 -LiteralPath $resolved).Hash;$out=@();$seen=@{}
for($i=0;$i -lt $rowArray.Count;$i++){$props=@($rowArray[$i].PSObject.Properties);$legal=Pick $rowArray[$i] @('Legal Name','legal_name','Bank Name','English Name');if(-not $legal -and $props.Count -ge 3){$legal=[string]$props[2].Value};$bic=Pick $rowArray[$i] @('BIC','bic');if(-not $legal -or -not $bic){throw "Row $($i+1) lacks legal name or BIC."};$bic=$bic.ToUpperInvariant();if($seen.ContainsKey($bic)){throw "Duplicate BIC: $bic"};$seen[$bic]=$true
  $iso2=Pick $rowArray[$i] @('ISO2','iso2');if(-not $iso2){$isoProp=$props|Where-Object Name -like 'ISO*'|Select-Object -First 1;if($isoProp){$iso2=[string]$isoProp.Value}};$country=Pick $rowArray[$i] @('Country','country');if(-not $country -and $props.Count -ge 6){$country=[string]$props[5].Value};$countryRisk=Pick $rowArray[$i] @('Country Risk','country_risk');if(-not $countryRisk -and $props.Count -ge 8){$countryRisk=[string]$props[7].Value};if($countryRisk -match '[^\x00-\x7F]'){$countryRisk=$null}
  $out+=[ordered]@{row_id=('ROW-{0:D3}' -f ($i+1));legal_name=$legal;bic=$bic;iso2=$iso2;country=$country;country_risk=$countryRisk;source=[ordered]@{file_name='registered_roster';sha256=$hash;row_number=$i+1}}
}
$parent=Split-Path -Parent $OutputPath;if($parent){New-Item -ItemType Directory -Force -Path $parent|Out-Null};[IO.File]::WriteAllText($OutputPath,($out|ConvertTo-Json -Depth 6),(New-Object Text.UTF8Encoding($false)));Write-Output $OutputPath
