@echo off
setlocal enabledelayedexpansion
CHCP 65001 > NUL
title Learning Coach - Tam Otomatik Başlatıcı

echo ======================================================
echo 🚀 Learning Coach - Sistem Hazırlanıyor...
echo ======================================================

:: 1. OLLAMA KONTROLÜ
echo [1/4] Ollama servisi kontrol ediliyor...
tasklist /FI "IMAGENAME eq ollama.exe" 2>NUL | find /I /N "ollama.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [+] Ollama zaten arka planda çalışıyor.
) else (
    echo [!] Ollama kapalı. Sunucu modunda başlatılıyor...
    start /B ollama serve
    echo [!] Ollama serve komutu gönderildi. 5 saniye bekleniyor...
    timeout /t 5 >nul
)

:: 2. SANAL ORTAM KONTROLÜ VE OLUŞTURMA
echo.
echo [2/4] Python Sanal Ortam (.venv) kontrol ediliyor...
if not exist .venv (
    echo [!] .venv bulunamadı. Yeni sanal ortam oluşturuluyor...
    python -m venv .venv
    if errorlevel 1 (
        echo [X] HATA: Python yüklü mü? 'python' komutu çalışmıyor.
        pause
        exit /b
    )
    echo [+] Sanal ortam başarıyla oluşturuldu.
) else (
    echo [+] Sanal ortam mevcut.
)

:: 3. AKTİVASYON VE PAKET KONTROLÜ
echo.
echo [3/4] Paketler kontrol ediliyor ve yükleniyor...
call .venv\Scripts\activate

:: Pip'i güncelle ve paketleri yükle
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

:: 4. FASTAPI SUNUCUSUNU BAŞLATMA
echo.
echo [4/4] FastAPI Sunucusu başlatılıyor...
echo [*] Yerel IP: 172.24.0.198
:: Hataya sebep olan kısmı düzelttik: tırnak içine aldık.
echo "[*] Host: 0.0.0.0 - Port: 8000"
echo ------------------------------------------------------

uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

pause