#!/bin/bash

# ==============================================================================
# Learning Coach - Database Setup Script
# ==============================================================================
# Bu script veritabanı migration'larını otomatik olarak çalıştırır.
# 
# Kullanım:
#   npm run db:setup          # Migration'ları çalıştır
#   npm run db:setup -- seed  # Migration + seed data
# ==============================================================================

set -e  # Hata olursa dur

# Renkler
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Learning Coach - Database Setup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# .env dosyası kontrolü
if [ ! -f ".env" ]; then
    echo -e "${RED}❌ Hata: .env dosyası bulunamadı!${NC}"
    echo ""
    echo "Lütfen önce .env dosyasını oluşturun:"
    echo "  1. Backend dizinine gidin: cd backend"
    echo "  2. .env.example varsa kopyalayın yoksa oluşturun."
    echo "  3. .env dosyasını düzenleyin ve DATABASE_URL'i ayarlayın"
    echo ""
    echo "Örnek DATABASE_URL:"
    echo "  DATABASE_URL=postgres://postgres:postgres@localhost:5432/Learning_Coach_DB?sslmode=disable"
    echo ""
    exit 1
fi

# .env dosyasını load et
echo -e "${BLUE}📄 .env dosyası yükleniyor...${NC}"
set -a
source .env
set +a

# DATABASE_URL kontrolü
if [ -z "$DATABASE_URL" ]; then
    echo -e "${RED}❌ Hata: DATABASE_URL .env dosyasında tanımlı değil!${NC}"
    echo ""
    echo "Lütfen .env dosyasına DATABASE_URL ekleyin:"
    echo "  DATABASE_URL=postgres://kullanici:sifre@localhost:5432/veritabani_adi?sslmode=disable"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓ DATABASE_URL bulundu${NC}"
echo -e "${YELLOW}  → $DATABASE_URL${NC}"
echo ""

# PostgreSQL bağlantısını test et
echo -e "${BLUE}🔌 Veritabanı bağlantısı test ediliyor...${NC}"
if ! psql "$DATABASE_URL" -c "SELECT 1" > /dev/null 2>&1; then
    echo -e "${RED}❌ Veritabanına bağlanılamadı!${NC}"
    echo ""
    echo "Kontrol listesi:"
    echo "  1. PostgreSQL çalışıyor mu? → pg_isready"
    echo "  2. Veritabanı oluşturuldu mu? → psql -l"
    echo "  3. Kullanıcı adı/şifre doğru mu?"
    echo "  4. Port doğru mu? (varsayılan: 5432)"
    echo ""
    exit 1
fi
echo -e "${GREEN}✓ Bağlantı başarılı${NC}"
echo ""

# Migration'ları çalıştır
echo -e "${BLUE}🔄 Migration'lar çalıştırılıyor...${NC}"
echo ""
npx dbmate --url "$DATABASE_URL" --migrations-dir ./db/migrations up
echo ""
echo -e "${GREEN}✓ Migration'lar başarıyla uygulandı${NC}"
echo ""

# Seed data (opsiyonel)
if [ "$1" = "seed" ]; then
    echo -e "${BLUE}🌱 Seed data ekleniyor...${NC}"
    echo ""
    psql "$DATABASE_URL" -f ./db/seed/seed.sql > /dev/null
    echo -e "${GREEN}✓ Seed data eklendi${NC}"
    echo ""
fi

# Migration durumunu göster
echo -e "${BLUE}📊 Migration Durumu:${NC}"
echo ""
npx dbmate --url "$DATABASE_URL" --migrations-dir ./db/migrations status
echo ""

# Özet
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✅ Veritabanı kurulumu tamamlandı!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Veritabanına bağlanmak için:"
echo -e "  ${YELLOW}npm run db:psql${NC}"
echo ""
