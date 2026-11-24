$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -LiteralPath $projectRoot

$configPath = Join-Path $projectRoot 'supabase.local.json'
if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
  Write-Error 'File supabase.local.json tidak ditemukan di root project.'
  exit 1
}

& flutter run -d chrome "--dart-define-from-file=$configPath"
exit $LASTEXITCODE
