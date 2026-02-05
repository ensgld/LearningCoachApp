<<<<<<< HEAD
# Learning Coach Backend

## Run

```bash
pip install -r requirements.txt
uvicorn app.main:app --reload
```
=======
# Learning Coach - Backend

Bu klasör Learning Coach uygulamasının backend altyapısını içerir: veritabanı migration'ları, seed data ve yardımcı scriptler.

---

## ⚡ Hızlı Başlangıç (Yeni Geliştiriciler İçin)

```bash
# 1. .env dosyasını oluştur ve düzenle
cp ../.env.example ../.env
# DATABASE_URL'i ayarla

# 2. Backend klasörüne git
cd backend

# 3. Bağımlılıkları kur
npm install

# 4. Tek komutla veritabanını kur!
npm run db:setup
```

✅ **İşte bu kadar!** Migration'lar uygulandı, veritabanı hazır.

Detaylı kurulum için [QUICKSTART.md](./QUICKSTART.md) dosyasına bakın.

---

## 📁 Klasör Yapısı

```
backend/
├── db/
│   ├── migrations/       # Veritabanı migration dosyaları (dbmate formatı)
│   │   ├── 20251226100000_extensions.sql
│   │   ├── 20251226100001_tables.sql
│   │   ├── 20251226100002_indexes.sql
│   │   └── 20251226100003_triggers.sql
│   └── seed/
│       └── seed.sql      # Geliştirme için örnek veri
├── scripts/              # Yardımcı scriptler (gelecek)
├── docker-compose.yml    # PostgreSQL Docker yapılandırması
└── package.json          # npm scriptleri ve bağımlılıklar
```

## 🚀 Hızlı Başlangıç

### 1. Ön Gereksinimler

- **Node.js** 18+ (npm scriptleri için)
- **PostgreSQL** 14+ (yerel kurulum veya Docker)
- **pgvector extension** (RAG için gerekli)

### 2. Kurulum

```bash
# Backend klasörüne git
cd backend

# Bağımlılıkları yükle
npm install

# .env dosyasını oluştur
cp ../.env.example ../.env

# .env dosyasını düzenle ve DATABASE_URL'i ayarla
# Örnek: DATABASE_URL=postgres://postgres:postgres@localhost:5432/learning_coach_dev?sslmode=disable
```

### 3. Veritabanını Başlat

#### Seçenek A: Docker ile (Önerilen)

```bash
# PostgreSQL'i Docker'da başlat (pgvector dahil)
npm run docker:up

# Logları kontrol et
npm run docker:logs

# Veritabanı hazır olduğunda migration'ları çalıştır
npm run db:migrate

# Seed data ekle (opsiyonel - geliştirme için)
npm run db:seed
```

#### Seçenek B: Yerel PostgreSQL

```bash
# PostgreSQL'in kurulu ve çalışır olduğundan emin ol
# pgvector extension'ı yükle (https://github.com/pgvector/pgvector)

# Veritabanını oluştur (eğer yoksa)
createdb learning_coach_dev

# Migration'ları çalıştır
npm run db:migrate

# Seed data ekle (opsiyonel)
npm run db:seed
```

## 📦 npm Scriptleri

| Script | Açıklama |
|--------|----------|
| `npm run db:migrate` | Tüm pending migration'ları uygula |
| `npm run db:rollback` | Son migration'ı geri al |
| `npm run db:status` | Migration durumunu göster (applied/pending) |
| `npm run db:reset` | DB'yi sıfırla: drop → migrate → seed |
| `npm run db:seed` | Seed data'yı çalıştır |
| `npm run db:psql` | PostgreSQL CLI'a bağlan |
| `npm run docker:up` | Docker PostgreSQL'i başlat |
| `npm run docker:down` | Docker PostgreSQL'i durdur |
| `npm run docker:logs` | Docker loglarını göster |

## 🗄️ Veritabanı Şeması

### Tablolar

- **users** - Kullanıcı kimlik doğrulama ve profil
- **goals** - Öğrenme hedefleri
- **goal_tasks** - Hedeflere ait görevler
- **study_sessions** - Çalışma seansları (Pomodoro)
- **quizzes** - Quiz'ler
- **quiz_questions** - Quiz soruları
- **quiz_attempts** - Kullanıcı quiz denemeleri
- **kaizen_checkins** - Günlük Kaizen yansımaları
- **documents** - Yüklenen dokümanlar
- **document_chunks** - RAG için doküman parçaları (pgvector embeddings)
- **chat_threads** - Sohbet oturumları
- **chat_messages** - Sohbet mesajları
- **message_sources** - Mesaj kaynak alıntıları
- **user_stats** - Gamification istatistikleri
- **inventory_items** - Mağaza ürünleri
- **user_inventory** - Kullanıcı envanteri

### Özellikler

- ✅ UUID primary keys
- ✅ Timestamp tracking (created_at, updated_at)
- ✅ Soft delete (deleted_at)
- ✅ Auto-update triggers
- ✅ Performance indexes
- ✅ pgvector HNSW index (RAG için)
- ✅ Foreign key constraints
- ✅ Check constraints

## 🔧 Migration Yönetimi

### Yeni Migration Oluşturma

```bash
npm run db:create -- create_new_table
```

Bu, `db/migrations/` altında timestamp'li yeni bir migration dosyası oluşturur.

### Migration Formatı

Migrations dbmate formatını takip eder:

```sql
-- migrate:up
CREATE TABLE example (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid()
);

-- migrate:down
DROP TABLE IF EXISTS example;
```

### Migration Rollback

Son migration'ı geri almak için:

```bash
npm run db:rollback
```

**Not**: pgvector index gibi bazı işlemler rollback sonrası manuel müdahale gerektirebilir.

## 🌱 Seed Data

`db/seed/seed.sql` geliştirme için örnek veri içerir:

- 1 demo kullanıcı (`demo@learningcoach.com`)
- 2 hedef + görevler
- 1 çalışma seansı + quiz
- 1 Kaizen check-in
- 2 doküman + chunk'lar (mock embeddings)
- 1 sohbet thread + mesajlar
- 4 inventory item

Seed çalıştırma:

```bash
npm run db:seed
```

**Not**: Seed ON CONFLICT kullanır, tekrar çalıştırmak güvenlidir.

## 🐳 Docker Kullanımı

`docker-compose.yml` pgvector extension'lı PostgreSQL 16 içerir.

```bash
# Başlat
npm run docker:up

# Durdur
npm run docker:down

# Logları izle
npm run docker:logs

# Container'a bağlan
docker exec -it learning_coach_db psql -U postgres -d learning_coach_dev
```

### Volume Yönetimi

Veri volume'u silinip yeniden başlamak için:

```bash
npm run docker:down
docker volume rm backend_postgres_data
npm run docker:up
npm run db:migrate
npm run db:seed
```

## 🔒 pgvector Kurulumu

### Docker (Otomatik)

Docker image (`pgvector/pgvector:pg16`) pgvector extension'ı içerir, kurulum gerekmez.

### Yerel PostgreSQL

macOS (Homebrew):
```bash
brew install pgvector
```

Ubuntu/Debian:
```bash
sudo apt install postgresql-16-pgvector
```

Ardından PostgreSQL'de:
```sql
CREATE EXTENSION vector;
```

## 🧪 Veritabanını Test Etme

Migration'ları çalıştırdıktan sonra:

```bash
# psql'e bağlan
npm run db:psql

# Tabloları listele
\dt

# Extension'ları kontrol et
\dx

# Örnek sorgu
SELECT * FROM users LIMIT 1;

# pgvector test
SELECT embedding <=> '[0.1, 0.2, ...]'::vector FROM document_chunks LIMIT 1;
```

## ❓ Sık Karşılaşılan Sorunlar

### 1. "database does not exist"

```bash
# Manuel oluştur:
createdb learning_coach_dev

# Veya psql ile:
psql -U postgres -c "CREATE DATABASE learning_coach_dev;"
```

### 2. "extension vector does not exist"

pgvector extension'ı yüklü değil. Yukarıdaki [pgvector Kurulumu](#-pgvector-kurulumu) bölümüne bakın.

### 3. "permission denied"

PostgreSQL kullanıcı izinlerini kontrol edin:

```sql
GRANT ALL PRIVILEGES ON DATABASE learning_coach_dev TO postgres;
```

### 4. "port 5432 already in use"

Başka bir PostgreSQL instance çalışıyor. Onu durdurun veya `.env`'de farklı port kullanın.

### 5. Docker "network error"

```bash
npm run docker:down
npm run docker:up
```

## 🔮 Gelecek Planlar

- [ ] Backend API (Node.js/Express veya Python/FastAPI)
- [ ] RAG implementasyonu (LangChain/LlamaIndex)
- [ ] Authentication endpoints
- [ ] REST/GraphQL API
- [ ] CI/CD pipeline
- [ ] Production deployment scriptleri

## 📚 Kaynaklar

- [dbmate Dokümantasyonu](https://github.com/amacneil/dbmate)
- [pgvector Dokümantasyonu](https://github.com/pgvector/pgvector)
- [PostgreSQL Dokümantasyonu](https://www.postgresql.org/docs/)

---

**İyi Geliştirmeler! 🚀**
>>>>>>> e4c47be (Database & Backend Updates)
