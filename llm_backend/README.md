# 🚀 Learning Coach - LLM Backend Kurulum Rehberi (Windows)

Bu rehber, yapay zeka servisinin Windows sunucunuzda (IP: `172.24.0.198`) doğru şekilde çalıştırılması için gerekli adımları içerir.

## 1. Ollama Yapılandırması (Kritik)

Ollama bazen arayüz modunda (System Tray) çalışırken API isteklerini bekletebilir veya kısıtlayabilir. En sağlıklı yöntem **Server** modunda çalıştırmaktır.

- **Mevcut Ollama'yı Kapatın:**
- Ekranın sağ altındaki (Sistem Tepsisi) Ollama ikonuna sağ tıklayıp **Quit Ollama** deyin.
- Emin olmak için **Görev Yöneticisi**'ni açıp `ollama.exe` sürecinin çalışmadığından emin olun.

- **Ollama'yı Sunucu Modunda Başlatın:**
- Yeni bir Terminal (CMD veya PowerShell) açın ve şu komutu yazın:

```cmd
ollama serve
```

- **Not:** Bu terminal penceresini kapatmayın. Ollama artık arka planda bir servis gibi çalışmaktadır.

## 2. Ortam Değişkenleri (`.env`)

Sunucu üzerindeki `llm_backend` klasöründe bir `.env` dosyası oluşturun. Git bu dosyayı otomatik getirmez. Dosya içeriği tam olarak şu şekilde olmalıdır:

```ini
PORT=8000
OLLAMA_URL=http://localhost:11434/api/chat
MODEL_NAME=llama4:latest
EMBEDDING_MODEL=nomic-embed-text
OLLAMA_EMBEDDINGS_URL=http://localhost:11434/api/embeddings
```

## 3. Python Sunucusunu Çalıştırma

Python backend'ini dış dünyaya (telefona) açmak için `--host 0.0.0.0` parametresi ile başlatmanız şarttır.

1. Yeni bir terminal açın ve `llm_backend` dizinine gidin.
2. Gerekli kütüphaneleri yükleyin:

```cmd
pip install -r requirements.txt
```

3. Sunucuyu başlatın:

```cmd
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

## 4. Windows Güvenlik Duvarı (Firewall) İzni

Dışarıdan (telefondan) gelen isteklerin 8000 portuna ulaşabilmesi için izin vermeniz gerekir:

1. **Denetim Masası > Sistem ve Güvenlik > Windows Defender Güvenlik Duvarı** yolunu izleyin.
2. **Gelişmiş Ayarlar**'a tıklayın.
3. **Gelen Kuralları (Inbound Rules) > Yeni Kural (New Rule)** deyin.
4. **Bağlantı Noktası (Port)** seçeneğini işaretleyip **8000** yazın.
5. **Bağlantıya izin ver** diyerek kuralı kaydedin.

## 5. Flutter Uygulama Ayarı

Uygulamanızın sunucuya bağlanabilmesi için `api_service.dart` dosyasındaki adresin şu olduğundan emin olun:

- **URL:** `http://172.24.0.198:8000/chat`

---

**Sunucu IP Adresiniz:** `172.24.0.198`

**Backend Portu:** `8000`
