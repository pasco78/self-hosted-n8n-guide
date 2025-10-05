# --- 설정 ---
$composeDir = "D:\Projects\n8n_class\self-hosted-ai-starter-kit"  # 폴더 경로로 바꿔도 됨
$ngrokExe   = "ngrok.exe"   # PATH에 있으면 파일명만, 아니면 전체 경로
$localPort  = 5678          # n8n 포트
$profile    = ""            # 예: "--profile cpu" / "--profile gpu-nvidia" (없으면 빈 문자열)

# --- 실행 디렉터리 이동 ---
Set-Location $composeDir

# --- ngrok 실행 (이미 켜져 있으면 건너뜀) ---
$ngrokRunning = Get-Process | Where-Object { $_.ProcessName -eq "ngrok" } | Measure-Object
if ($ngrokRunning.Count -eq 0) {
  Start-Process -NoNewWindow -FilePath $ngrokExe -ArgumentList "http $localPort"
  Start-Sleep -Seconds 3
}

# --- ngrok 공개 URL 조회 (https 우선) ---
try {
  $tunnels = Invoke-RestMethod http://127.0.0.1:4040/api/tunnels
  $ngrokUrl = ($tunnels.tunnels | Where-Object {$_.proto -eq "https"} | Select-Object -First 1).public_url
} catch {
  Write-Host "❌ ngrok API에서 URL을 못 가져왔어요. ngrok이 켜졌는지 확인하세요." -ForegroundColor Red
  exit 1
}

if (-not $ngrokUrl) {
  Write-Host "❌ ngrok URL이 비어있어요." -ForegroundColor Red
  exit 1
}

Write-Host "✅ ngrok URL: $ngrokUrl"

# --- .env 파일 업데이트 (라인이 없으면 추가, 있으면 치환) ---
$envPath = Join-Path $composeDir ".env"
if (-not (Test-Path $envPath)) {
  Write-Host "❌ .env 파일이 없어요: $envPath" -ForegroundColor Red
  exit 1
}

$content = Get-Content $envPath -Raw

function Upsert-Line($text, $key, $value) {
  if ($text -match "(?m)^$key=.*$") {
    return ($text -replace "(?m)^$key=.*$", "$key=$value")
  } else {
    return ($text.TrimEnd() + "`r`n" + "$key=$value" + "`r`n")
  }
}

$content = Upsert-Line $content "WEBHOOK_URL" $ngrokUrl
$content = Upsert-Line $content "N8N_EDITOR_BASE_URL" $ngrokUrl

# 저장 (UTF-8 with BOM 아님 → 일반 UTF-8)
[System.IO.File]::WriteAllText($envPath, $content, [System.Text.UTF8Encoding]::new($false))

Write-Host "🔄 .env 업데이트 완료" -ForegroundColor Green

# --- 컨테이너 재기동 (env 반영) ---
docker compose down
if ($LASTEXITCODE -ne 0) { Write-Host "⚠️ docker compose down 경고 (무시해도 됨)" -ForegroundColor Yellow }

if ([string]::IsNullOrWhiteSpace($profile)) {
  docker compose up -d
} else {
  docker compose $profile up -d
}

if ($LASTEXITCODE -ne 0) {
  Write-Host "❌ docker compose up 실패" -ForegroundColor Red
  exit 1
}

Write-Host ""
Write-Host "✅ 완료!"
Write-Host " - 비활성 테스트: $ngrokUrl/webhook-test/<your-webhook-id>"
Write-Host " - 활성화 후:    $ngrokUrl/webhook/<your-webhook-id>"
