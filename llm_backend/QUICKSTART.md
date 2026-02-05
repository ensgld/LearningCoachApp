# 🚀 Hızlı Başlangıç - Veritabanı Kurulumu

Learning Coach projesine yeni katıldıysanız, veritabanını kurmak için bu adımları takip edin.

## Ön Gereksinimler

- **PostgreSQL 14+** kurulu ve çalışıyor olmalı
- **Node.js 18+** kurulu olmalı

## Adım Adım Kurulum

### 1. PostgreSQL Veritabanı Oluştur

```bash
# PostgreSQL'e bağlan
psql -U postgres

# Veritabanını oluştur
CREATE DATABASE "Learning_Coach_DB";

# Çık
\q
```

### 2. .env Dosyasını Ayarla

Proje kök dizininde `.env` dosyası oluştur:

```bash
# Proje kök dizininde
cd /path/to/learning_coach

# .env.example'ı kopyala
cp .env.example .env
```

`.env` dosyasını aç ve `DATABASE_URL`'i düzenle:

```bash
DATABASE_URL=postgres://postgres:postgres@localhost:5432/Learning_Coach_DB?sslmode=disable
```

**Değiştirilecek kısımlar:**
- `postgres:postgres` → `kullanici_adi:sifre`
- `Learning_Coach_DB` → Kendi veritabanı adınız

### 3. Backend Bağımlılıklarını Kur

```bash
cd backend
npm install
```

### 4. Tek Komutla Kurulum! 🎉

```bash
npm run db:setup
```

Bu komut:
- ✅ `.env` dosyasını kontrol eder
- ✅ Veritabanı bağlantısını test eder
- ✅ Tüm migration'ları çalıştırır
- ✅ Migration durumunu gösterir

**Seed data da eklemek için:**

```bash
npm run db:setup:seed
```

---

## ✅ Kurulum Doğrulaması

Migration'lar başarılı olduysa şu çıktıyı göreceksiniz:

```
✓ Migration'lar başarıyla uygulandı

📊 Migration Durumu:

[X] 20251226100000_extensions.sql
[X] 20251226100001_tables.sql
[X] 20251226100002_indexes.sql
[X] 20251226100003_triggers.sql

Applied: 4
Pending: 0
```

Veritabanına bağlanıp kontrol edin:

```bash
npm run db:psql

# PostgreSQL CLI'da:
\dt          # Tabloları listele (16 tablo görmelisiniz)
\dx          # Extension'ları kontrol et (pgcrypto, vector)
\q           # Çık
```

---

## ❌ Hata Çözümleri

### "❌ .env dosyası bulunamadı!"

`.env` dosyası proje **kök dizininde** olmalı (backend klasöründe değil):

```bash
learning_coach/
├── .env              ← Burası
├── backend/
│   └── scripts/
```

### "❌ DATABASE_URL .env dosyasında tanımlı değil!"

`.env` dosyasını açıp `DATABASE_URL` satırını ekleyin:

```bash
DATABASE_URL=postgres://kullanici:sifre@localhost:5432/veritabani_adi?sslmode=disable
```

### "❌ Veritabanına bağlanılamadı!"

Kontroller:

1. **PostgreSQL çalışıyor mu?**
   ```bash
   pg_isready
   # yanıt: accepting connections
   ```

2. **Veritabanı var mı?**
   ```bash
   psql -U postgres -l | grep Learning_Coach_DB
   ```

3. **Şifre doğru mu?**
   `.env` dosyasındaki şifre ile PostgreSQL şifreniz eşleşiyor mu?

### "extension vector does not exist"

pgvector kurulu değil. Kurun:

```bash
# macOS
brew install pgvector

# Ubuntu/Debian
sudo apt install postgresql-16-pgvector
```

Ardından veritabanına manuel ekleyin:

```bash
psql -U postgres -d Learning_Coach_DB -c "CREATE EXTENSION vector;"
```

---

## 🔄 Güncellemeler

Yeni migration'lar eklendiğinde:

```bash
# Yeni migration'ları çalıştır
npm run db:setup

# Veya sadece migrate
npm run db:migrate
```

---

## 📚 Diğer Komutlar

**Kurulum:** `npm run db:setup` ile otomatik  
**Diğer tüm komutlar:** Ana [README.md](./README.md) dosyasına bakın

---

**Sorun mu yaşıyorsunuz?** Ekip liderinize sorun veya [Issues](https://github.com/your-repo/issues) açın.
