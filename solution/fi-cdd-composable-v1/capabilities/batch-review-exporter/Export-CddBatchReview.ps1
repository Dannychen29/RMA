[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$RosterJson,
  [Parameter(Mandatory)][string]$CasesRoot,
  [Parameter(Mandatory)][string]$FieldMapCsv,
  [Parameter(Mandatory)][string]$OutputDirectory,
  [string[]]$IncludeBic,
  [switch]$WriteXlsx
)
$ErrorActionPreference = 'Stop'

function Get-FieldValue($case, [string]$fieldId) {
  if (-not $case) { return $null }
  $p = $case.fields.PSObject.Properties[$fieldId]
  if (-not $p) { return $null }
  return $p.Value.value
}

function Get-FieldStatus($case, [string]$fieldId) {
  if (-not $case) { return 'NOT_RUN' }
  $p = $case.fields.PSObject.Properties[$fieldId]
  if (-not $p) { return 'FIELD_MISSING' }
  return [string]$p.Value.status
}
function Get-FieldObject($case, [string]$fieldId) {
  if (-not $case) { return $null }
  $p = $case.fields.PSObject.Properties[$fieldId]
  if ($p) { return $p.Value }
  return $null
}

$sectionZh = @{ Review='審查類型'; 'Basic Information'='金融機構基本資料'; 'Required documentation'='徵提資料'; 'Risk Assessment'='審查項目'; Recommendation='建議與結論'; Approval='核決'; 'PEP persons'='PEP 人員' }
$labelZh = @{
  'New FI relationship'='新往來'; 'Periodic Review'='定期審查'; 'Risk classification'='風險分類'; 'Legal Name'='法定名稱'; Country='國家'; BIC='BIC'; Address='地址'; 'H.O. BIC'='母行 BIC（申請銀行為分行時填寫）';
  'Wolfsberg AML Questionnaire'='Wolfsberg 防制洗錢問卷'; 'Banking License'='銀行執照'; 'W-8BEN-E'='W-8BEN-E'; SSI='標準交割指示（SSI）'; 'AML/CTF Policy'='防制洗錢／打擊資恐政策';
  'Sanctions or internal watch list'='是否列入制裁、執法、官方名單或本行內部觀察名單'; 'FI or parent in prohibited country'='金融機構或其母行是否位於禁止往來國家'; 'Relationship with shell banks'='是否與空殼銀行往來'; 'Payable Through Accounts'='是否提供過渡帳戶服務';
  'PEP hit'='高階主管、有權簽章人或實質受益人是否命中 PEP'; 'PEP role'='PEP 在該銀行的角色'; 'PEP role suitability'='PEP 角色的適當性'; 'PEP influence'='PEP 對該銀行的影響力'; 'PEP risk to the Bank'='PEP 對本行的風險'; 'Resultant risk rating'='金融機構最終風險評級';
  'Acceptance or Rejection'='接受或拒絕'; Justification='理由說明'; 'EDD reference'='EDD 表單參照'; 'Maker name'='經辦姓名'; 'Maker date'='經辦日期'; 'Checker name'='覆核姓名'; 'Checker date'='覆核日期'; 'Approver name'='核准人姓名'; 'Approver date'='核准日期';
  'Is the FI one of Vostro Accounts'='是否為本行同存帳戶'; Name='姓名'; Position='職位'; 'AML System result'='AML 系統查詢結果'
}
function Get-BilingualLabel([string]$english) { $zh=$labelZh[$english]; if(-not $zh){$zh='中文名稱待確認'}; return "$zh`n$english" }
function Get-BilingualStatus([string]$status) {
  $z=@{CONFIRMED='已取得／已確認';AVAILABLE='已取得／文件可用';NOT_APPLICABLE='不適用';NO_RESULT='未取得／來源未發現';NOT_DIGITAL='未取得／非數位文件';DECLINED='未取得／對方未提供';DATA_PENDING='未取得／等待資料';ACCESS_BLOCKED='未取得／系統受阻';HUMAN_REVIEW='待人工判斷';FIELD_MISSING='欄位未建立';NOT_RUN='尚未執行'}[$status]
  if(-not $z){$z='待確認'}; return "$z / $status"
}
function Format-ReviewValue($value) { if($value -is [bool]){if($value){return '是 / Yes'}else{return '否 / No'}};if($null -eq $value -or [string]::IsNullOrWhiteSpace([string]$value)){return '—'};return [string]$value }

$rosterParsed = Get-Content -Raw -LiteralPath $RosterJson | ConvertFrom-Json
$roster = @($rosterParsed | ForEach-Object { $_ })
if ($IncludeBic) {
  $wanted = @($IncludeBic | ForEach-Object { $_.ToUpperInvariant() })
  $roster = @($roster | Where-Object { $wanted -contains ([string]$_.bic).ToUpperInvariant() })
}
$map = @(Import-Csv -LiteralPath $FieldMapCsv)
if ($roster.Count -eq 0) { throw 'Roster is empty.' }
if ($map.Count -eq 0) { throw 'Field map is empty.' }

$forms = @('CDD_CHECKLIST','CDD_RISK_ASSESSMENT')
$rowsByForm = @{}
$statusRows = @()
$caseByBic = @{}
foreach ($form in $forms) { $rowsByForm[$form] = @() }

foreach ($bank in $roster) {
  $casePath = Join-Path (Join-Path $CasesRoot ([string]$bank.bic)) 'cdd-case.json'
  if (-not (Test-Path -LiteralPath $casePath)) {
    $matched = @(Get-ChildItem -LiteralPath $CasesRoot -Recurse -File -Filter 'cdd-case.json' | Where-Object { $_.Directory.Name -eq [string]$bank.bic })
    if ($matched.Count -gt 1) { throw "Multiple case files found for BIC $($bank.bic)." }
    if ($matched.Count -eq 1) { $casePath = $matched[0].FullName }
  }
  $case = $null
  $runStatus = 'NOT_RUN_OPENCLI_PENDING'
  if (Test-Path -LiteralPath $casePath) {
    $case = Get-Content -Raw -LiteralPath $casePath | ConvertFrom-Json
    if ([string]$case.input.bic -ne [string]$bank.bic) { throw "Case/roster BIC mismatch: $($bank.bic)" }
    $runStatus = if ($case.audit.completion_status) { [string]$case.audit.completion_status } else { 'SOURCE_ACQUIRED_REVIEW_PENDING' }
  }
  $caseByBic[[string]$bank.bic] = $case

  foreach ($form in $forms) {
    $row = [ordered]@{
      BIC = [string]$bank.bic
      'Legal Name' = [string]$bank.legal_name
      Country = [string]$bank.country
      'Run Status' = $runStatus
    }
    foreach ($f in @($map | Where-Object form -eq $form | Sort-Object {[int]$_.order})) {
      $row[[string]$f.template_label] = Get-FieldValue $case ([string]$f.field_id)
      $row[([string]$f.template_label + ' [Status]')] = Get-FieldStatus $case ([string]$f.field_id)
    }
    $rowsByForm[$form] += [pscustomobject]$row
  }

  $statusRows += [pscustomobject][ordered]@{
    BIC = [string]$bank.bic
    'Legal Name' = [string]$bank.legal_name
    'Case Evidence' = if ($case) { $casePath } else { $null }
    'Acquisition Status' = if ($case) { [string]$case.acquisition.accuity_entity_status } else { 'NOT_RUN' }
    'CBDDQ Status' = if ($case) { [string]$case.acquisition.cbddq_status } else { 'NOT_RUN' }
    'CDD Completion Status' = $runStatus
    'Source Grounded' = [bool]$case
  }
}

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$OutputDirectory = (Resolve-Path -LiteralPath $OutputDirectory).Path
$checklistPath = Join-Path $OutputDirectory 'CDD_CHECKLIST_BATCH.csv'
$riskPath = Join-Path $OutputDirectory 'CDD_RISK_ASSESSMENT_BATCH.csv'
$statusPath = Join-Path $OutputDirectory 'BATCH_STATUS.csv'
$rowsByForm['CDD_CHECKLIST'] | Export-Csv -NoTypeInformation -Encoding UTF8 -LiteralPath $checklistPath
$rowsByForm['CDD_RISK_ASSESSMENT'] | Export-Csv -NoTypeInformation -Encoding UTF8 -LiteralPath $riskPath
$statusRows | Export-Csv -NoTypeInformation -Encoding UTF8 -LiteralPath $statusPath

$sourceGrounded = @($statusRows | Where-Object 'Source Grounded').Count
$summary = [ordered]@{
  roster_count = $roster.Count
  source_grounded_count = $sourceGrounded
  not_run_count = $roster.Count - $sourceGrounded
  batch_complete = ($sourceGrounded -eq $roster.Count -and @($statusRows | Where-Object { $_.'CDD Completion Status' -ne 'COMPLETED' }).Count -eq 0)
  generated_at = (Get-Date).ToString('o')
}
$summaryPath = Join-Path $OutputDirectory 'batch-summary.json'
[IO.File]::WriteAllText($summaryPath, ($summary | ConvertTo-Json), (New-Object Text.UTF8Encoding($false)))

if ($WriteXlsx) {
  $xlsxPath = Join-Path $OutputDirectory 'CDD_BATCH_REVIEW.xlsx'
  $excel = New-Object -ComObject Excel.Application
  $excel.Visible = $false; $excel.DisplayAlerts = $false
  try {
    $wb = $excel.Workbooks.Add()
    while ($wb.Worksheets.Count -lt 3) { $null = $wb.Worksheets.Add() }
    while ($wb.Worksheets.Count -gt 3) { $wb.Worksheets.Item($wb.Worksheets.Count).Delete() }
    $navy=0x6B3A13; $blue=0xD9EAF7; $green=0xD9EAD3; $yellow=0xCCFFFF; $red=0xD9D9FF; $gray=0xE7E6E6

    $overview=$wb.Worksheets.Item(1); $overview.Name='總覽 Overview'; $overview.Activate(); $overview.Application.ActiveWindow.DisplayGridlines=$false
    $overview.Range('A1:H1').Merge(); $overview.Range('A1').Value2='金融機構 CDD 查核總覽 / FI CDD Review Overview'; $overview.Range('A1:H1').Interior.Color=$navy; $overview.Range('A1:H1').Font.Color=0xFFFFFF; $overview.Range('A1:H1').Font.Bold=$true; $overview.Range('A1:H1').Font.Size=16; $overview.Rows.Item(1).RowHeight=30
    $overview.Range('A3:H3').Value2=@('BIC','法定名稱 / Legal Name','國家 / Country','已取得 / Retrieved','未取得 / Missing','待人工 / Human Review','完成狀態 / Completion Status','CBDDQ 狀態 / Status')
    $overview.Range('A3:H3').Interior.Color=$blue; $overview.Range('A3:H3').Font.Bold=$true; $overview.Range('A3:H3').WrapText=$true; $overview.Rows.Item(3).RowHeight=36
    $orow=4
    foreach($bank in $roster){$case=$caseByBic[[string]$bank.bic];$all=@($map|Where-Object form -eq 'CDD_CHECKLIST');$retrieved=0;$missing=0;$human=0;foreach($f in $all){$st=Get-FieldStatus $case $f.field_id;if($st -in @('CONFIRMED','AVAILABLE','NOT_APPLICABLE')){$retrieved++}elseif($st -eq 'HUMAN_REVIEW'){$human++}else{$missing++}}
      $overview.Cells.Item($orow,1)=[string]$bank.bic;$overview.Cells.Item($orow,2)=[string]$bank.legal_name;$overview.Cells.Item($orow,3)=[string]$bank.country;$overview.Cells.Item($orow,4)=$retrieved;$overview.Cells.Item($orow,5)=$missing;$overview.Cells.Item($orow,6)=$human;$overview.Cells.Item($orow,7)=[string]($statusRows|Where-Object BIC -eq $bank.bic).'CDD Completion Status';$overview.Cells.Item($orow,8)=if($case){[string]$case.acquisition.cbddq_status}else{'NOT_RUN'};$orow++}
    $overview.Range("A3:H$($orow-1)").AutoFilter()|Out-Null;$overview.Range("A4:H$($orow-1)").Borders.Color=0xD9D9D9;$overview.Range("D4:F$($orow-1)").HorizontalAlignment=-4108
    $overview.Range("D4:D$($orow-1)").Interior.Color=$green;$overview.Range("E4:E$($orow-1)").Interior.Color=$red;$overview.Range("F4:F$($orow-1)").Interior.Color=$yellow
    $overview.Columns.Item('A').ColumnWidth=14;$overview.Columns.Item('B').ColumnWidth=46;$overview.Columns.Item('C').ColumnWidth=18;$overview.Columns.Item('D').ColumnWidth=14;$overview.Columns.Item('E').ColumnWidth=14;$overview.Columns.Item('F').ColumnWidth=16;$overview.Columns.Item('G').ColumnWidth=34;$overview.Columns.Item('H').ColumnWidth=18
    $overview.Range('A8:H8').Merge();$overview.Range('A8').Value2='圖例 / Legend：綠色＝已取得；黃色＝待人工；紅色＝未取得或系統受阻。空白值必須搭配狀態與原因閱讀。';$overview.Range('A8').Interior.Color=$gray;$overview.Range('A8').WrapText=$true
    $overview.Application.ActiveWindow.SplitRow=3;$overview.Application.ActiveWindow.FreezePanes=$true;$overview.PageSetup.Orientation=2;$overview.PageSetup.Zoom=$false;$overview.PageSetup.FitToPagesWide=1;$overview.PageSetup.FitToPagesTall=1

    $sheetDefs=@(@{Index=2;Name='CDD Checklist 明細';Form='CDD_CHECKLIST';Title='金融機構 CDD 表 / CDD Checklist for Financial Institutions'},@{Index=3;Name='Risk Assessment 明細';Form='CDD_RISK_ASSESSMENT';Title='CDD 審查項目 / Risk Assessment'})
    foreach($def in $sheetDefs){$ws=$wb.Worksheets.Item($def.Index);$ws.Name=$def.Name;$ws.Activate();$ws.Application.ActiveWindow.DisplayGridlines=$false;$ws.Range('A1:I1').Merge();$ws.Range('A1').Value2=$def.Title;$ws.Range('A1:I1').Interior.Color=$navy;$ws.Range('A1:I1').Font.Color=0xFFFFFF;$ws.Range('A1:I1').Font.Bold=$true;$ws.Range('A1:I1').Font.Size=15;$ws.Rows.Item(1).RowHeight=28
      $headers=@('BIC','銀行 / Institution','區段 / Section','編號 / No.','欄位／題目（中文 / English）','查核結果 / Result','取得狀態 / Retrieval Status','來源位置 / Source Location','缺漏說明／依據 / Reason')
      for($c=0;$c -lt $headers.Count;$c++){$ws.Cells.Item(3,$c+1)=$headers[$c]};$ws.Range('A3:I3').Interior.Color=$blue;$ws.Range('A3:I3').Font.Bold=$true;$ws.Range('A3:I3').WrapText=$true;$ws.Rows.Item(3).RowHeight=36
      $rr=4
      foreach($bank in $roster){$case=$caseByBic[[string]$bank.bic];foreach($f in @($map|Where-Object form -eq $def.Form|Sort-Object {[int]$_.order})){$obj=Get-FieldObject $case $f.field_id;$status=Get-FieldStatus $case $f.field_id;$value=if($obj){Format-ReviewValue $obj.value}else{'—'};$sectionCn=$sectionZh[[string]$f.section];if(-not $sectionCn){$sectionCn='其他'}
          $ws.Cells.Item($rr,1)=[string]$bank.bic;$ws.Cells.Item($rr,2)=[string]$bank.legal_name;$ws.Cells.Item($rr,3)="$sectionCn`n$($f.section)";$ws.Cells.Item($rr,4)=[int]$f.order;$ws.Cells.Item($rr,5)=Get-BilingualLabel $f.template_label;$ws.Cells.Item($rr,6)=$value;$ws.Cells.Item($rr,7)=Get-BilingualStatus $status;$ws.Cells.Item($rr,8)=if($obj){[string]$obj.source_location}else{'尚未執行 / Not run'};$ws.Cells.Item($rr,9)=if($obj){[string]$obj.reason}else{'尚未取得來源證據 / Source evidence not acquired'}
          $fill=if($status -in @('CONFIRMED','AVAILABLE','NOT_APPLICABLE')){$green}elseif($status -eq 'HUMAN_REVIEW'){$yellow}else{$red};$ws.Cells.Item($rr,7).Interior.Color=$fill;$rr++}}
      $last=$rr-1;$ws.Range("A3:I$last").AutoFilter()|Out-Null;$ws.Range("A4:I$last").WrapText=$true;$ws.Range("A4:I$last").VerticalAlignment=-4160;$ws.Range("A4:I$last").Borders.Color=0xD9D9D9;$ws.Rows("4:$last").RowHeight=42
      $widths=@(13,36,20,8,48,32,28,38,55);for($c=1;$c -le 9;$c++){$ws.Columns.Item($c).ColumnWidth=$widths[$c-1]};$ws.Application.ActiveWindow.SplitRow=3;$ws.Application.ActiveWindow.SplitColumn=2;$ws.Application.ActiveWindow.FreezePanes=$true;$ws.PageSetup.Orientation=2;$ws.PageSetup.Zoom=$false;$ws.PageSetup.FitToPagesWide=1;$ws.PageSetup.FitToPagesTall=$false
    }
    $overview.Activate()
    $wb.SaveAs($xlsxPath, 51); $wb.Close($false)
  } finally { $excel.Quit(); [Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null }
}

[pscustomobject]@{ checklist=$checklistPath; risk_assessment=$riskPath; status=$statusPath; summary=$summaryPath; source_grounded=$sourceGrounded; roster_count=$roster.Count }
