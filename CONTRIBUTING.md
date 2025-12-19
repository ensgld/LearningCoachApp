# Learning Coach Projesine Katkıda Bulunma

Learning Coach projesine katkıda bulunduğunuz için teşekkür ederiz! Bu doküman, ekip iş akışımızı, kodlama standartlarımızı ve en iyi uygulamalarımızı açıklar.

## 📋 İçindekiler

- [Başlangıç](#başlangıç)
- [Branch İsimlendirme](#branch-isimlendirme)
- [Commit Mesajları](#commit-mesajları)
- [Pull Request Süreci](#pull-request-süreci)
- [Kod Standartları](#kod-standartları)
- [PR Kontrol Listesi](#pr-kontrol-listesi)
- [Kod İnceleme Yönergeleri](#kod-inceleme-yönergeleri)

## 🚀 Başlangıç

Katkıda bulunmaya başlamadan önce:

1. **Depoyu fork edin veya klonlayın**
2. **Ortamınızı kurun** [README.md](README.md) dosyasını takip ederek
3. **Uygulamayı çalıştırın** her şeyin çalıştığından emin olmak için
4. **Issue'ları kontrol edin** üzerinde çalışılacak görevler için

## 🌿 Branch İsimlendirme

Tüm branch'ler `main`'den oluşturulmalı ve şu isimlendirme kurallarını izlemelidir:

### Format

```
<tip>/<kisa-aciklama>
```

### Tipler

- **feature/** - Yeni özellikler veya geliştirmeler
  - Örnek: `feature/pomodoro-zamanlayici`
  - Örnek: `feature/hedef-kategorileri`

- **fix/** - Hata düzeltmeleri
  - Örnek: `fix/navigasyon-geri-butonu`
  - Örnek: `fix/calisma-zamanlayici-tasma`

- **chore/** - Bakım, refactoring veya araçlar
  - Örnek: `chore/bagimliliklari-guncelle`
  - Örnek: `chore/importlari-temizle`

- **docs/** - Dokümantasyon güncellemeleri
  - Örnek: `docs/mimari-kilavuzu-ekle`
  - Örnek: `docs/readme-guncelle`

### Kurallar

- **Küçük harf** ve **tire ile ayrılmış kelimeler** kullanın
- Açıklamaları **kısa ama açıklayıcı** tutun (2-4 kelime)
- **Boşluk yok**, tire kullanın
- Branch isimlerinde issue numarası kullanmayın (commit/PR'larda referans verin)

### Örnekler

✅ İyi:
- `feature/dokuman-yukleme`
- `fix/zamanlayici-durmuyor`
- `chore/mock-veri-refactor`

❌ Kötü:
- `benim-branchim` (tip öneki yok)
- `feature/CokluDosyaYuklemesiIcinYeniOzellikEkleme` (çok uzun, tire yok)
- `hata duzelt` (boşluklar)

## 💬 Commit Mesajları

Net ve tutarlı commit geçmişi için [Conventional Commits](https://www.conventionalcommits.org/) spesifikasyonunu takip ediyoruz.

### Format

```
<tip>(<kapsam>): <açıklama>

[opsiyonel gövde]

[opsiyonel altbilgi]
```

### Tipler

- **feat**: Yeni özellik
- **fix**: Hata düzeltmesi
- **docs**: Dokümantasyon değişiklikleri
- **style**: Kod stili değişiklikleri (formatlama, noktalı virgül eksikliği vb.)
- **refactor**: Kod refactoring
- **test**: Test ekleme veya güncelleme
- **chore**: Bakım görevleri

### Kapsam (Opsiyonel)

Kapsam, kod tabanının hangi kısmının etkilendiğini belirtmelidir:
- `home`, `study`, `goals`, `docs`, `profile`, `kaizen`
- `router`, `theme`, `models`
- `mock-data`, `ci`

### Örnekler

```bash
feat(study): pomodoro zamanlayıcısı ve mola aralıkları eklendi

fix(navigation): doküman detayından geri navigasyon düzeltildi

docs(readme): kurulum talimatları güncellendi

refactor(mock-data): repository yapısı yeniden düzenlendi

test(home): ana sayfa kartları için widget testi eklendi

chore(deps): riverpod v3.0.4'e güncellendi
```

### Kurallar

- **Emir kipi** kullanın ("özellik ekle" değil "özellik eklendi")
- Tip ve açıklama için **küçük harf**
- Açıklama sonunda **nokta yok**
- **İlk satırı 72 karakterin altında** tutun
- Karmaşık değişiklikler için gövde ekleyin (neyi değil, neden açıklayın)

## 🔄 Pull Request Süreci

### 1. PR Oluşturmadan Önce

- [ ] `main`'den en son değişiklikleri çekin
- [ ] `flutter pub get` çalıştırın
- [ ] `dart run build_runner build --delete-conflicting-outputs` çalıştırın
- [ ] Kodu formatlayın: `dart format .`
- [ ] Analyzer sorunlarını düzeltin: `flutter analyze`
- [ ] Testleri çalıştırın: `flutter test`
- [ ] Uygulamayı manuel olarak test edin

### 2. PR Oluşturma

1. **Branch'inizi push edin** uzak depoya
2. **Pull request oluşturun** `main`'i hedefleyerek
3. **PR şablonunu doldurun** (aşağıya bakın)

### 3. PR Başlığı

Commit mesajlarıyla aynı formatı kullanın:
```
<tip>(<kapsam>): <açıklama>
```

Örnek: `feat(study): mola aralıkları ile pomodoro zamanlayıcısı eklendi`

### 4. PR Açıklama Şablonu

```markdown
## Açıklama
Bu PR'ın ne yaptığına ve neden yapıldığına dair kısa açıklama.

## Değişiklikler
- Ana değişikliklerin listesi
- Madde işaretleri ile

## Ekran Görüntüleri (varsa)
[UI değişiklikleri için ekran görüntüleri ekleyin]

## İlgili Issue'lar
Closes #123

## Kontrol Listesi
- [ ] Kod proje stil kurallarına uygun
- [ ] Kodumu kendi kendime gözden geçirdim
- [ ] Karmaşık mantığı yorumladım
- [ ] Gerekirse dokümantasyonu güncelledim
- [ ] Analyzer'dan yeni uyarı yok
- [ ] Gerektiği gibi test ekledim/güncelledim
- [ ] Tüm testler geçiyor
- [ ] UI manuel olarak test edildi (uygulanabilirse)
```

### 5. PR İncelemesi

- Merge etmeden önce **en az 1 onay gerekli**
- Tüm inceleme yorumlarına cevap verin
- PR kapsamını odaklı tutun (PR başına bir özellik/düzeltme)
- Geri bildirimlere hızlı yanıt verin

### 6. Merge Etme

- PR'ların tüm CI kontrollerini geçmesi gerekir
- **Squash merge** stratejisi kullanın (varsayılan)
- Merge ettikten sonra branch'i silin

## 📏 Kod Standartları

### Dart/Flutter Stili

- [Effective Dart](https://dart.dev/guides/language/effective-dart) kurallarını takip edin
- Otomatik formatlamak için `dart format .` kullanın
- `analysis_options.yaml`'deki linter kurallarına uyun

### Dosya Organizasyonu

```dart
// 1. Dart/Flutter import'ları
import 'package:flutter/material.dart';

// 2. Paket import'ları
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 3. Yerel import'lar (alfabetik)
import 'package:learning_coach/app/theme/app_theme.dart';
import 'package:learning_coach/shared/models/models.dart';
```

### İsimlendirme Kuralları

- **Dosyalar**: `snake_case.dart` (örn. `study_screen.dart`)
- **Sınıflar**: `PascalCase` (örn. `StudyScreen`)
- **Değişkenler/Fonksiyonlar**: `camelCase` (örn. `startStudySession`)
- **Sabitler**: `lowerCamelCase` (örn. `defaultDuration`) veya global sabitler için `kConstantName`
- **Private**: Alt çizgi ile önekleyin `_privateMethod`

### Widget En İyi Uygulamaları

- Mümkün olduğunda **const constructor'lar tercih edin**
- Karmaşıklaştıklarında **widget'ları çıkarın** (>50 satır)
- Çıkarılan widget'lar için **anlamlı isimler** kullanın
- **Build metodlarını temiz tutun** - mantığı metodlara/provider'lara çıkarın

### State Yönetimi (Riverpod)

- Provider'lar için **kod üretimi** kullanın (`@riverpod` annotation)
- **Provider isimlendirme**: `Provider` ile bitirin (örn. `goalsProvider`)
- Provider'ları uygun dosyalarda tutun (özelliğe özgü veya paylaşılan)

### Yorumlar

- Dokümantasyon yorumları için `///` kullanın
- Implementasyon yorumları için `//` kullanın
- **Nedenini** yorumlayın, **neyi** değil (kod kendini açıklamalı)

```dart
/// MM:SS formatında formatlanmış süreyi döndürür.
/// 
/// Çalışma seansı zamanlayıcılarını görüntülemek için kullanılır.
String formatDuration(Duration duration) {
  // İmplementasyon...
}
```

## ✅ PR Kontrol Listesi

İnceleme istemeden önce emin olun:

- [ ] **Testler**: Mevcut tüm testler geçiyor
- [ ] **Format**: Kod formatlanmış (`dart format .`)
- [ ] **Analyze**: Analyzer uyarısı yok (`flutter analyze`)
- [ ] **Build**: Uygulama başarıyla derleniyor
- [ ] **Manuel Test**: Değişiklikler manuel olarak test edildi
- [ ] **Dokümantasyon**: Gerekirse dokümanlar güncellendi
- [ ] **Ekran Görüntüleri**: UI değişiklikleri için eklendi
- [ ] **Bağımlılıklar**: Gereksiz bağımlılık eklenmedi
- [ ] **Üretilen Kod**: Uygulanabilirse `.g.dart` dosyaları commit edildi

## 👀 Kod İnceleme Yönergeleri

### İnceleyici Olarak

- **Yapıcı** ve saygılı olun
- Değişiklik isterken **nedenini açıklayın**
- Değişiklikler iyi görünüyorsa **hızlıca onaylayın**
- Önemli değişiklikler için **yerel olarak test edin**
- Odaklanın:
  - Doğruluk
  - Kod kalitesi ve sürdürülebilirlik
  - Performans etkileri
  - Güvenlik endişeleri
  - UX sorunları

### Yazar Olarak

- **Tüm yorumlara yanıt verin** (sadece kabul etsek bile)
- **Geri bildirimi kişisel algılamayın** - hepimiz öğreniyoruz
- Geri bildirim belirsizse **soru sorun**
- Geri bildirimlere göre **PR'ı güncelleyin**
- Ele aldıktan sonra **konuşmaları çözümlendi olarak işaretleyin**

## 🚫 Yapılmaması Gerekenler

- ❌ Doğrudan `main`'e commit yapmayın
- ❌ İlgisiz değişikliklerle PR oluşturmayın
- ❌ CI'dan geçmeyen kod push etmeyin
- ❌ Linter uyarılarını görmezden gelmeyin
- ❌ Manuel testi atlayın
- ❌ Yorum satırı yapılmış kod bırakmayın
- ❌ Gerekçe olmadan `// ignore:` kullanmayın
- ❌ Tartışmadan bağımlılık eklemeyin

## 💡 İpuçları

- **Küçük PR'lar** incelemesi daha kolay ve daha hızlı merge olur
- İmplementasyonunuzda **edge case'leri test edin**
- Veri yapısı değişirse **mock veriyi güncelleyin**
- Değişiklikleri çektikten sonra **kod üretimini çalıştırın**
- Takılırsanız **yardım isteyin** - tartışmaları veya issue'ları kullanın

## 🤝 Yardım Alma

- Mevcut [dokümantasyonu](docs/) kontrol edin
- Mevcut issue'ları ve PR'ları arayın
- Ekip tartışmalarında sorun
- Projeyi yönetenlere ulaşın

---

**Learning Coach'a katkıda bulunduğunuz için teşekkürler! 🎓**
