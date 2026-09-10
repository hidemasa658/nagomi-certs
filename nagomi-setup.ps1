# =========================================================
# なごみ株式会社 admin 証明書 セットアップ ウィザード
# =========================================================
# 使い方: 右クリック → PowerShell で実行
# または: powershell -ExecutionPolicy Bypass -File nagomi-setup.ps1
# =========================================================

$ErrorActionPreference = "Stop"
$Host.UI.RawUI.WindowTitle = "Nagomi Cert Setup"

# UTF-8 出力
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Banner($text, $color = "Cyan") {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor $color
    Write-Host "  $text" -ForegroundColor $color
    Write-Host "============================================================" -ForegroundColor $color
}

function Write-Step($num, $total, $text) {
    Write-Host ""
    Write-Host "[$num/$total] $text" -ForegroundColor Yellow
}

function Write-OK($text) {
    Write-Host "  OK: $text" -ForegroundColor Green
}

function Write-Err($text) {
    Write-Host "  ERROR: $text" -ForegroundColor Red
}

# ---- Banner ----
Clear-Host
Write-Banner "  なごみ株式会社 admin 証明書 セットアップ" "Cyan"
Write-Host ""
Write-Host "このウィザードは 以下 を自動で行います:" -ForegroundColor White
Write-Host "  1. GitHub から 7-Zip ツール + 証明書アーカイブ ダウンロード" -ForegroundColor Gray
Write-Host "  2. パスワードで 解凍" -ForegroundColor Gray
Write-Host "  3. CA 証明書を 信頼されたルート に インストール" -ForegroundColor Gray
Write-Host "  4. クライアント証明書 (keiei-pc.p12) を 個人用ストア に インストール" -ForegroundColor Gray
Write-Host "  5. ブラウザで 管理画面 を 開く" -ForegroundColor Gray
Write-Host ""
Write-Host "所要時間: 約 1-2分" -ForegroundColor Gray
Write-Host ""

$continue = Read-Host "続行しますか? (Y/N)"
if ($continue -notmatch "^[Yy]") {
    Write-Host "中断しました" -ForegroundColor Yellow
    Read-Host "Enter で終了"
    exit 0
}

# ---- Setup temp directory ----
$temp = Join-Path $env:TEMP "nagomi-setup"
if (Test-Path $temp) { Remove-Item $temp -Recurse -Force }
New-Item -ItemType Directory -Path $temp -Force | Out-Null
Set-Location $temp

# ---- Step 1: Download 7zr.exe ----
Write-Step 1 6 "7-Zip コマンドラインツール ダウンロード中..."
try {
    Invoke-WebRequest -Uri "https://www.7-zip.org/a/7zr.exe" `
        -OutFile "7zr.exe" -UseBasicParsing -TimeoutSec 30
    Write-OK "7zr.exe ダウンロード完了"
} catch {
    Write-Err "ダウンロード失敗: $_"
    Read-Host "Enter で終了"
    exit 1
}

# ---- Step 2: Download nagomi-certs.7z ----
Write-Step 2 6 "証明書アーカイブ ダウンロード中..."
try {
    Invoke-WebRequest -Uri "https://github.com/hidemasa658/nagomi-certs/raw/main/nagomi-certs.7z" `
        -OutFile "nagomi-certs.7z" -UseBasicParsing -TimeoutSec 30
    $size = (Get-Item "nagomi-certs.7z").Length
    Write-OK "nagomi-certs.7z ダウンロード完了 ($size bytes)"
} catch {
    Write-Err "ダウンロード失敗: $_"
    Read-Host "Enter で終了"
    exit 1
}

# ---- Step 3: Prompt 7z password ----
Write-Step 3 6 "7z 解凍パスワード 入力"
Write-Host ""
Write-Host "  7z 解凍パスワードを 入力してください" -ForegroundColor White
Write-Host "  (別途 手渡しされた パスワード)" -ForegroundColor Gray
Write-Host ""
$zipPass = Read-Host "  7z パスワード" -AsSecureString
$zipPassPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($zipPass)
)

# ---- Step 4: Extract ----
Write-Step 4 6 "解凍中..."
$extractResult = & ".\7zr.exe" x "-p$zipPassPlain" -y "nagomi-certs.7z" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Err "解凍失敗 (パスワード違い or ファイル破損)"
    Read-Host "Enter で終了"
    exit 1
}
Write-OK "解凍完了"

# Check files
$caPath = Join-Path $temp "nagomi-certs\nagomi-ca.crt"
$p12Path = Join-Path $temp "nagomi-certs\keiei-pc.p12"
if (-not (Test-Path $caPath)) {
    Write-Err "nagomi-ca.crt が 見つかりません"
    Read-Host "Enter で終了"
    exit 1
}
if (-not (Test-Path $p12Path)) {
    Write-Err "keiei-pc.p12 が 見つかりません"
    Read-Host "Enter で終了"
    exit 1
}

# ---- Step 5: Install CA certificate ----
Write-Step 5 6 "CA 証明書 を 信頼されたルート に インストール中..."
try {
    $result = Import-Certificate -FilePath $caPath -CertStoreLocation "Cert:\CurrentUser\Root" -ErrorAction Stop
    Write-OK "CA 証明書 インストール完了 ($($result.Subject))"
} catch {
    Write-Err "CA インストール失敗: $_"
    Read-Host "Enter で終了"
    exit 1
}

# ---- Step 6: Install p12 client certificate ----
Write-Step 6 6 "クライアント証明書 (keiei-pc.p12) インストール中..."
Write-Host ""
Write-Host "  p12 パスワードを 入力してください (別途 手渡し)" -ForegroundColor White
Write-Host ""
$p12Pass = Read-Host "  p12 パスワード" -AsSecureString

try {
    $result = Import-PfxCertificate -FilePath $p12Path `
        -CertStoreLocation "Cert:\CurrentUser\My" `
        -Password $p12Pass -Exportable -ErrorAction Stop
    Write-OK "クライアント証明書 インストール完了 ($($result.Subject))"
} catch {
    Write-Err "p12 インストール失敗: $_"
    Read-Host "Enter で終了"
    exit 1
}

# ---- Cleanup ----
Set-Location $env:TEMP
Remove-Item -Path $temp -Recurse -Force -ErrorAction SilentlyContinue

# ---- Complete ----
Write-Banner "  セットアップ完了 ✓" "Green"
Write-Host ""
Write-Host "  新しいタブで 以下 URL を開いてください:" -ForegroundColor White
Write-Host "  https://nagomi-admin.duckdns.org/gallery/nagomi-corp/" -ForegroundColor Cyan
Write-Host ""
Write-Host "  証明書選択ダイアログで [keiei-pc] を選んで OK" -ForegroundColor White
Write-Host ""

$open = Read-Host "今すぐ ブラウザで 開きますか? (Y/N)"
if ($open -match "^[Yy]") {
    Start-Process "https://nagomi-admin.duckdns.org/gallery/nagomi-corp/"
    Write-Host "  ブラウザを起動しました" -ForegroundColor Green
}

Write-Host ""
Read-Host "Enter で終了"
