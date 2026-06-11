$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

$Python = Join-Path (Split-Path $Root -Parent) ".venv\Scripts\python.exe"
if (-not (Test-Path $Python)) {
    Write-Error "Virtual env not found. Create it from project root: python -m venv .venv"
    exit 1
}

Get-ChildItem (Split-Path $Python -Parent | Split-Path -Parent) -Recurse -Include *.pyd,*.dll -ErrorAction SilentlyContinue |
    Unblock-File -ErrorAction SilentlyContinue

Get-NetTCPConnection -LocalPort 8501 -ErrorAction SilentlyContinue |
    ForEach-Object { Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue }

& $Python -m streamlit run app.py --server.headless true
