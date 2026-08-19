[CmdletBinding()]
param([Parameter(Mandatory)][string]$RosterPath,[Parameter(Mandatory)][string]$OutputDirectory,[string]$EvidenceDirectory)
$ErrorActionPreference='Stop';$root=Split-Path -Parent $PSScriptRoot;$recordsPath=Join-Path $OutputDirectory 'roster-records.json'
& (Join-Path $root 'capabilities\roster-reader\Read-CddRoster.ps1') -InputPath $RosterPath -OutputPath $recordsPath|Out-Null;$records=Get-Content -Raw -LiteralPath $recordsPath|ConvertFrom-Json
foreach($r in @($records)){$caseDir=Join-Path $OutputDirectory $r.bic;New-Item -ItemType Directory -Force -Path $caseDir|Out-Null;$recordPath=Join-Path $caseDir 'roster-record.json';[IO.File]::WriteAllText($recordPath,($r|ConvertTo-Json -Depth 8),(New-Object Text.UTF8Encoding($false)));$evidence=$null;if($EvidenceDirectory){$candidate=Join-Path $EvidenceDirectory ($r.bic+'.json');if(Test-Path -LiteralPath $candidate){$evidence=$candidate}}
  $casePath=Join-Path $caseDir 'cdd-case.json';& (Join-Path $root 'capabilities\case-mapper\Merge-CddEvidence.ps1') -RosterRecordPath $recordPath -EvidencePath $evidence -OutputPath $casePath|Out-Null
  & (Join-Path $root 'capabilities\case-validator\Test-CddCase.ps1') -Path $casePath|Out-Null
  & (Join-Path $root 'capabilities\cdd-review-exporter\Export-CddReviewTables.ps1') -CasePath $casePath -OutputDirectory (Join-Path $caseDir 'review-tables')|Out-Null
  $state=[ordered]@{run_id=(Split-Path $OutputDirectory -Leaf);case_id=(Get-Content -Raw $casePath|ConvertFrom-Json).case_id;state='HUMAN_REVIEW_REQUIRED';completed_capabilities=@('CAP-01','CAP-03','CAP-04','CAP-05');pending_capabilities=@('CAP-02','CAP-06');updated_at=(Get-Date).ToString('o')};$state|ConvertTo-Json -Depth 5|Set-Content -LiteralPath (Join-Path $caseDir 'run-state.json') -Encoding utf8
};Write-Output $OutputDirectory
