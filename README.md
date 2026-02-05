# Learning Coach 📚

Üniversite öğrencileri için tasarlanmış bir Flutter uygulaması. Öğrenme yolculuğunuzu yönetmenize yardımcı olur. Hedef takibi, çalışma seansları, Kaizen kontrolleri, doküman kütüphanesi ve yapay zeka destekli doküman soru-cevap özellikleri içerir.

> **Mevcut Durum**: Mock veri ile UI prototipi. Backend entegrasyonu, RAG (Retrieval-Augmented Generation) ve kimlik doğrulama gelecek sürümler için planlanmıştır.

## ✨ Özellikler

- **Kimlik Doğrulama**: Mock email/şifre girişi, sosyal giriş (Google/Apple), kayıt olma
- **Ana Sayfa**: ÇAlışma ilerlemesi, yaklaşan hedefler ve son aktivitelere genel bakış
- **Çalışma Seansları**: Pomodoro tarzı çalışma takibi ve odaklanma zamanlayıcıları
- **Hedef Yönetimi**: Öğrenme hedeflerini belirleyin, takip edin ve görev listesiyle tamamlayın
- **Kaizen Kontrolleri**: Günlük yansımalar ve sürekli gelişim takibi
- **Doküman Kütüphanesi**: Çalışma materyallerinizi yükleyin, düzenleyin ve yönetin
- **Doküman Soru-Cevap**: (Gelecek) RAG kullanarak dokümanlarınızla yapay zeka destekli sohbet
- **Profil ve Ayarlar**: Kullanıcı tercihleri, uygulama yapılandırması ve çıkış yapma

## 🏗️ Mimari

Bu proje, endişelerin net ayrımı ile **özellik-öncelikli (feature-first)** mimari desenini takip eder:

```
lib/
├── app/                    # Uygulama seviyesi yapılandırma
│   ├── router/             # GoRouter yapılandırması
│   ├── shell/              # Alt navigasyon ile uygulama kabuğu
│   └── theme/              # Material 3 tema yapılandırması
├── features/               # Özellik modülleri
│   ├── home/               # Ana sayfa
│   ├── study/              # Çalışma seansları
│   ├── goals/              # Hedef yönetimi
│   ├── kaizen/             # Günlük kontroller
│   ├── documents/          # Doküman kütüphanesi
│   ├── coach/              # Yapay zeka koçu (gelecek)
│   └── profile/            # Kullanıcı profili
├── shared/                 # Paylaşılan kaynaklar
│   ├── data/               # Mock veri deposu ve sağlayıcılar
│   ├── models/             # Veri modelleri
│   └── widgets/            # Yeniden kullanılabilir UI bileşenleri
└── core/                   # Temel yardımcılar
    ├── constants/          # Uygulama genelinde sabitler
    └── utils/              # Yardımcı fonksiyonlar
```

Detaylı mimari bilgisi için [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) dosyasına bakınız.

## 🚀 Başlangıç

### Gereksinimler

- **Flutter SDK**: 3.9.2 veya üzeri (stable kanal önerilir)
- **Dart SDK**: Flutter ile birlikte gelir
- **IDE**: VS Code (önerilir) veya Android Studio
- **Platform Desteği**: Desktop/web geliştirme için macOS, Windows veya Linux

Flutter kurulumunuzu kontrol etmek için:
```bash
flutter --version
flutter doctor
```

### Kurulum

1. **Depoyu klonlayın**
   ```bash
   git clone <depo-url>
   cd learning_coach
   ```

2. **Bağımlılıkları yükleyin**
   ```bash
   flutter pub get
   ```

3. **Kod üretin** (Riverpod ve routing için)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Uygulamayı çalıştırın**
   ```bash
   # Chrome/Web için
   flutter run -d chrome
   
   # macOS için
   flutter run -d macos
   
   # Windows için
   flutter run -d windows
   
   # Linux için
   flutter run -d linux
   ```

### Opsiyonel: FVM Kullanımı (Flutter Version Management)

Ekibiniz belirli bir Flutter versiyonunu zorlamak istiyorsa:

```bash
# FVM'i yükleyin
dart pub global activate fvm

# Belirli Flutter versiyonunu kullanın
fvm use 3.9.2

# Komutları FVM ile çalıştırın
fvm flutter run -d chrome
```

## 🧪 Geliştirme

### Kullanılabilir Komutlar

```bash
# Bağımlılıkları al
flutter pub get

# Kod üretimini çalıştır
dart run build_runner build --delete-conflicting-outputs

# Değişiklikleri izle ve yeniden üret (geliştirme sırasında kullanışlı)
dart run build_runner watch --delete-conflicting-outputs

# Kodu formatla
dart format .

# Kodu analiz et
flutter analyze

# Testleri çalıştır
flutter test

# Production için derle (web örneği)
flutter build web --release
```

### Kod Kalitesi

Bu proje `flutter_lints` tabanlı katı linting kuralları kullanır. Commit etmeden önce:

1. **Kodunuzu formatlayın**: `dart format .`
2. **Analyzer sorunlarını düzeltin**: `flutter analyze`
3. **Testleri çalıştırın**: `flutter test`

Tüm bu kontroller, pull request oluşturduğunuzda CI'da otomatik olarak çalışır.

## 🌿 Branch ve PR İş Akışı

Detaylı kurallar için lütfen [CONTRIBUTING.md](CONTRIBUTING.md) dosyasını okuyun. Kısa özet:

### Branch İsimlendirme

- `feature/<aciklama>` - Yeni özellikler (örn. `feature/hedef-takibi`)
- `fix/<aciklama>` - Hata düzeltmeleri (örn. `fix/navigasyon-hatasi`)
- `chore/<aciklama>` - Bakım görevleri (örn. `chore/bagimliliklari-guncelle`)

### Pull Request Süreci

1. `main`'den bir özellik branch'i oluşturun
2. Değişikliklerinizi yapın
3. Tüm kontrollerin geçtiğinden emin olun (format, analyze, test)
4. Push yapın ve şunlarla bir PR oluşturun:
   - Açık açıklama
   - Ekran görüntüleri (UI değişiklikleri varsa)
   - Tamamlanmış PR kontrol listesi
5. En az 1 onay alın
6. `main`'e squash merge yapın

## 📦 Bağımlılıklar

### Temel Bağımlılıklar

- **flutter_riverpod** (^3.0.3): State yönetimi
- **go_router** (^17.0.1): Deklaratif routing
- **google_fonts** (^6.3.3): Tipografi
- **intl** (^0.20.2): Uluslararasılaştırma ve tarih formatlama
- **uuid** (^4.5.2): Benzersiz tanımlayıcılar
- **equatable** (^2.0.7): Değer eşitliği

### Geliştirme Bağımlılıkları

- **flutter_lints** (^5.0.0): Linting kuralları
- **riverpod_generator** (^3.0.3): Riverpod için kod üretimi
- **build_runner** (^2.7.1): Kod üretim çalıştırıcısı
- **json_serializable** (^6.11.2): JSON serileştirme

## 🧭 Navigasyon

Uygulama, alt navigasyon için stateful shell ile GoRouter kullanır. Ana rotalar:

- `/home` - Ana sayfa
- `/study` - Çalışma seansları
  - `/study/running` - Aktif seans (tam ekran)
  - `/study/quiz` - Seans sonrası quiz (tam ekran)
  - `/study/summary` - Seans özeti (tam ekran)
- `/docs` - Doküman kütüphanesi
  - `/docs/detail` - Doküman detay görünümü
  - `/docs/chat` - Doküman soru-cevap sohbeti
- `/profile` - Kullanıcı profili
- `/kaizen` - Kaizen kontrolü (modal)
- `/goal-detail` - Hedef detay görünümü (modal)

Tam navigasyon akışı için [docs/NAVIGATION.md](docs/NAVIGATION.md) dosyasına bakınız.

## 💾 Mock Veri

Şu anda tüm veriler `lib/shared/data/mock_data_repository.dart` dosyasında mock edilmiştir. Bu, backend bağımlılığı olmadan UI'ın tam işlevsel olmasını sağlar.

Mock veriyi değiştirmek veya veri yapısını anlamak için [docs/MOCK_DATA.md](docs/MOCK_DATA.md) dosyasına bakınız.

## 🧪 Test Etme

Tüm testleri çalıştır:
```bash
flutter test
```

Belirli bir testi çalıştır:
```bash
flutter test test/widget_test.dart
```

Kapsama ile çalıştır:
```bash
flutter test --coverage
```

## 🐛 Sorun Giderme

### Kod üretim sorunları

Eksik `.g.dart` dosyaları hakkında hatalar görüyorsanız:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Pull sonrası derleme hataları

En son değişiklikleri çektikten sonra her zaman çalıştırın:
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Hot reload çalışmıyor

Bazen kod üretimi tam yeniden başlatma gerektirir. Uygulamayı durdurun ve tekrar çalıştırın:
```bash
flutter run -d chrome
```

### CI format kontrolünde hata

Push yapmadan önce yerel olarak çalıştırın:
```bash
dart format .
```

- [ ] Gelişmiş analitik panosu

## 🗄️ Backend ve Veritabanı

Learning Coach, PostgreSQL veritabanı şeması ve migration altyapısı içerir. Backend API henüz geliştirilmemiş olsa da, veritabanı tasarımı hazırdır.

### Hızlı Başlangıç

```bash
# Backend klasörüne git
cd backend

# Bağımlılıkları yükle
npm install

# .env dosyasını yapılandır
cp ../.env.example ../.env
# .env dosyasını açıp DATABASE_URL'i düzenleyin

# Tek komutla veritabanını kur!
npm run db:setup

# (Opsiyonel) Demo veri ile birlikte:
npm run db:setup:seed
```

**Not**: PostgreSQL'in kurulu ve çalışır olması gerekir. Detaylar için [backend/QUICKSTART.md](backend/QUICKSTART.md).

### Veritabanı Özellikleri

- **PostgreSQL 14+** with **pgvector** extension (RAG için)
- **UUID** primary keys
- **Soft delete** ve **timestamp tracking**
- **Auto-update triggers**
- **Performance indexes** (pgvector HNSW dahil)
- **16 tablo**: users, goals, study_sessions, documents, chat_messages, gamification ve daha fazlası

### npm Scriptleri

- `npm run db:setup` - **Tek komutla kurulum** (otomatik validation + migration)
- `npm run db:setup:seed` - Kurulum + demo veri
- `npm run db:migrate` - Migration'ları uygula
- `npm run db:reset` - DB'yi sıfırla (drop + migrate + seed)
- `npm run db:status` - Migration durumunu göster
- `npm run docker:up` - PostgreSQL Docker container'ı başlat

Detaylı dokümantasyon için [backend/README.md](backend/README.md) dosyasına bakınız.

## 🔮 Gelecek Yol Haritası

- [x] PostgreSQL veritabanı tasarımı ve migration'lar
- [ ] Backend entegrasyonu (Node.js/Python)
- [ ] Doküman soru-cevap için RAG implementasyonu
- [ ] Kullanıcı kimlik doğrulama (Firebase/Supabase)
- [ ] Cloud doküman depolama
- [ ] Mobil uygulama (iOS/Android)
- [ ] Gerçek zamanlı çalışma seansı senkronizasyonu
- [ ] Gelişmiş analitik panosu

## 📄 Lisans

Bu proje özeldir ve eğitim amaçlıdır.

## 🤝 Katkıda Bulunma

Katkı kuralları için [CONTRIBUTING.md](CONTRIBUTING.md) dosyasına bakınız.

---

**İyi Öğrenmeler! 🎓**
