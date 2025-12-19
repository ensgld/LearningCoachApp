# Mock Veri Dokümantasyonu

Bu doküman, Learning Coach uygulamasında mock verinin nasıl yönetildiğini ve geliştirme ve test için nasıl değiştirileceğini açıklar.

## 📍 Konum

Tüm mock veri merkezileştirilmiştir:
```
lib/shared/data/mock_data_repository.dart
```

Bu dosya, gerçek bir API olmadan tam UI işlevselliği için backend yanıtlarını simüle eden static veri içerir.

## 🎯 Amaç

Mock veri birkaç amaca hizmet eder:

1. **Bağımsız UI Geliştirme**: Backend bağımlılığı olmadan UI oluşturun ve test edin
2. **Tutarlı Test**: Widget ve entegrasyon testleri için öngörülebilir veri
3. **Demo ve Prototipleme**: Paydaşlara özellikleri sergileyin
4. **Katılım**: Yeni geliştiriciler uygulamayı hemen çalıştırabilir
5. **Gelecek Migrasyon**: Gerçek API çağrıları ile kolayca değiştirin

## 📊 Veri Yapısı

### Mevcut Mock Veri

`MockDataRepository` sınıfı şunları içerir:

```dart
class MockDataRepository {
  static final List<Goal> goals = [...];
  static final List<Document> documents = [...];
  static final List<CoachMessage> initialChat = [...];
  static final List<Source> mockSources = [...];
}
```

### 1. Hedefler (Goals)

**Tip**: `List<Goal>`

**Model**:
```dart
class Goal {
  final String id;
  final String title;
  final String description;
  final double progress;  // 0.0 ile 1.0 arası
  final List<GoalTask> tasks;
}

class GoalTask {
  final String title;
  final bool isCompleted;
}
```

**Mevcut Veri**:
- 3 örnek hedef (Flutter öğrenme, İngilizce kelime, Algoritma analizi)
- Her biri 2-3 görev ile
- %10 ile %45 arası ilerleme

**Değiştirmek için**:
- Daha fazla hedef ekleyin
- İlerleme değerlerini değiştirin
- Görev ekleyin/çıkarın
- Başlık ve açıklamaları güncelleyin

**Örnek**:
```dart
static final List<Goal> goals = [
  Goal(
    title: 'Yeni Hedefiniz',
    description: 'Hedef açıklaması buraya',
    progress: 0.33,
    tasks: [
      GoalTask(title: 'İlk görev', isCompleted: true),
      GoalTask(title: 'İkinci görev', isCompleted: false),
    ],
  ),
  // ... daha fazla hedef
];
```

### 2. Dokümanlar (Documents)

**Tip**: `List<Document>`

**Model**:
```dart
class Document {
  final String id;
  final String title;
  final String summary;
  final DocStatus status;        // ready, processing, failed
  final DateTime uploadedAt;
}

enum DocStatus { ready, processing, failed }
```

**Mevcut Veri**:
- 4 örnek doküman (PDF kılavuzları, notlar, proje gereksinimleri)
- Çeşitli durumlar (ready, processing, failed)
- Farklı yükleme zaman damgaları

**Değiştirmek için**:
- Yeni dokümanlar ekleyin
- UI durumlarını test etmek için durumları değiştirin
- Yükleme tarihlerini ayarlayın
- Dosya adlarını ve özetleri güncelleyin

**Örnek**:
```dart
static final List<Document> documents = [
  Document(
    title: 'Benim_Dokumanim.pdf',
    summary: 'Bu doküman şunlar hakkında bilgi içeriyor...',
    status: DocStatus.ready,
    uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  // ... daha fazla doküman
];
```

**Durum Testi**:
- `DocStatus.ready`: Doküman işlendi ve sohbet için hazır
- `DocStatus.processing`: Yükleniyor göstergesi gösterir
- `DocStatus.failed`: Hata durumu gösterir

### 3. Koç Mesajları (Coach Messages)

**Tip**: `List<CoachMessage>`

**Model**:
```dart
class CoachMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<Source>? sources;  // Opsiyonel alıntılar
}
```

**Mevcut Veri**:
- Koçtan 1 ilk karşılama mesajı

**Değiştirmek için**:
- Konuşma geçmişi ekleyin
- Kullanıcı vs. koç mesajlarını test edin
- Örnek alıntıları dahil edin (doküman sohbeti için)

**Örnek**:
```dart
static final List<CoachMessage> initialChat = [
  CoachMessage(
    text: 'Merhaba! Nasıl yardımcı olabilirim?',
    isUser: false,
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
  CoachMessage(
    text: 'Flutter öğrenmek istiyorum.',
    isUser: true,
    timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
  ),
  // ... daha fazla mesaj
];
```

### 4. Kaynaklar (Alıntılar)

**Tip**: `List<Source>`

**Model**:
```dart
class Source {
  final String docTitle;
  final String excerpt;
  final String pageLabel;
}
```

**Mevcut Veri**:
- Flutter Architecture Guide'dan 2 örnek alıntı

**Değiştirmek için**:
- Daha fazla alıntı örneği ekleyin
- Farklı doküman referanslarını test edin
- Alıntıları ve sayfa etiketlerini güncelleyin

**Örnek**:
```dart
static final List<Source> mockSources = [
  Source(
    docTitle: 'Flutter_Architecture_Guide.pdf',
    excerpt: 'Dokümantan ilgili alıntı...',
    pageLabel: 'Sayfa 15',
  ),
  // ... daha fazla kaynak
];
```

## 🔄 Mock Veri Akışı

### 1. Repository → Provider → UI

```dart
// 1. Mock Repository (veri kaynağı)
class MockDataRepository {
  static final List<Goal> goals = [...];
}

// 2. Riverpod Provider (state yönetimi)
@riverpod
List<Goal> goals(Ref ref) {
  return MockDataRepository.goals;
}

// 3. UI (veriyi tüket)
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);
    return ListView(children: goals.map(...).toList());
  }
}
```

### 2. Provider'ların Konumu

Mock veri provider'ları şurada:
```
lib/shared/data/providers.dart
```

**Örnek provider'lar**:
```dart
@riverpod
List<Goal> goals(Ref ref) {
  return MockDataRepository.goals;
}

@riverpod
List<Document> documents(Ref ref) {
  return MockDataRepository.documents;
}

@riverpod
List<CoachMessage> chatMessages(Ref ref) {
  return MockDataRepository.initialChat;
}
```

## ✏️ Mock Veriyi Değiştirme

### Adım Adım Kılavuz

1. **Dosyayı açın**:
   ```
   lib/shared/data/mock_data_repository.dart
   ```

2. **Değiştirmek istediğiniz veriyi bulun**:
   - Hedef takibi için `goals`
   - Doküman kütüphanesi için `documents`
   - Koç mesajları için `initialChat`
   - Alıntılar için `mockSources`

3. **Değişikliklerinizi yapın**:
   - Listelere yeni öğeler ekleyin
   - Mevcut öğeleri değiştirin
   - İhtiyacınız olmayan öğeleri kaldırın

4. **Uygulamayı hot reload edin**:
   - Terminalde `r`'ye basın (hot reload)
   - Veya tam yeniden başlatma için `R`

5. **Değişiklikleri UI'da doğrulayın**

### Yaygın Değişiklikler

#### Yeni Hedef Ekle

```dart
Goal(
  title: 'Backend Entegrasyonunu Tamamla',
  description: 'Node.js API kurun ve Flutter uygulaması ile bağlayın',
  progress: 0.0,
  tasks: [
    GoalTask(title: 'Express sunucusu kur', isCompleted: false),
    GoalTask(title: 'REST endpoint'leri oluştur', isCompleted: false),
    GoalTask(title: 'Flutter ile entegre et', isCompleted: false),
  ],
),
```

#### İşleniyor Durumunda Doküman Ekle

```dart
Document(
  title: 'Buyuk_Dosya_Yukleniyor.pdf',
  summary: '',
  status: DocStatus.processing,
  uploadedAt: DateTime.now(),
),
```

#### Başarısız Doküman Ekle

```dart
Document(
  title: 'Bozuk_Dosya.docx',
  summary: '',
  status: DocStatus.failed,
  uploadedAt: DateTime.now().subtract(const Duration(hours: 2)),
),
```

#### Sohbet Konuşması Ekle

```dart
static final List<CoachMessage> initialChat = [
  CoachMessage(
    text: 'Merhaba! Nasıl yardımcı olabilirim?',
    isUser: false,
    timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
  ),
  CoachMessage(
    text: 'Clean Architecture nedir?',
    isUser: true,
    timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
  ),
  CoachMessage(
    text: 'Clean Architecture yazılım tasarımı felsefesidir...',
    isUser: false,
    timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
    sources: mockSources, // Alıntıları dahil et
  ),
];
```

## 🧪 Farklı Senaryoları Test Etme

### UI Durum Testi

Mock veri edge case'leri test etmek için mükemmeldir:

#### Boş Durumlar
```dart
static final List<Goal> goals = []; // Boş liste
```

#### Yükleniyor Durumları
```dart
// İşleniyor simüle et
Document(
  status: DocStatus.processing,
  uploadedAt: DateTime.now(),
),
```

#### Hata Durumları
```dart
Document(
  status: DocStatus.failed,
  title: 'Hata_Dokumanı.pdf',
),
```

#### Büyük Listeler
```dart
static final List<Goal> goals = List.generate(
  20,
  (i) => Goal(
    title: 'Hedef ${i + 1}',
    description: 'Hedef ${i + 1} için açıklama',
    progress: (i + 1) / 20,
    tasks: [],
  ),
);
```

#### Uzun Metinler
```dart
Goal(
  title: 'UI Yerleşiminde Düzgün Sarılması Gereken Çok Uzun Hedef Başlığı',
  description: 'Birden fazla satıra yayılan çok detaylı açıklama...',
  // ...
),
```

## 🔮 Gerçek Backend'e Migrasyon

Gerçek bir backend'e geçiş yaparken:

### 1. Repository Interface Oluştur

```dart
// lib/shared/data/goal_repository.dart
abstract class GoalRepository {
  Future<List<Goal>> getGoals();
  Future<void> addGoal(Goal goal);
  Future<void> updateGoal(Goal goal);
  Future<void> deleteGoal(String id);
}
```

### 2. Mock Repository Uygula

```dart
class MockGoalRepository implements GoalRepository {
  @override
  Future<List<Goal>> getGoals() async {
    // Ağ gecikmesini simüle et
    await Future.delayed(const Duration(milliseconds: 500));
    return MockDataRepository.goals;
  }
  
  // ... diğer metodlar
}
```

### 3. Gerçek Repository Uygula

```dart
class ApiGoalRepository implements GoalRepository {
  final ApiClient client;
  
  @override
  Future<List<Goal>> getGoals() async {
    final response = await client.get('/goals');
    return (response.data as List)
        .map((json) => Goal.fromJson(json))
        .toList();
  }
  
  // ... diğer metodlar
}
```

### 4. Provider'ları Güncelle

```dart
// Önce (mock)
@riverpod
List<Goal> goals(Ref ref) {
  return MockDataRepository.goals;
}

// Sonra (gerçek API)
@riverpod
Future<List<Goal>> goals(Ref ref) async {
  final repository = ref.watch(goalRepositoryProvider);
  return await repository.getGoals();
}
```

### 5. UI'ı Güncelle (Async'i Ele Al)

```dart
// UI AsyncValue'yu ele alır
final goalsAsync = ref.watch(goalsProvider);

return goalsAsync.when(
  data: (goals) => ListView(...),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Hata: $err'),
);
```

## ⚙️ Gelişmiş: Dinamik Mock Veri

Daha gerçekçi test için mock veriyi dinamik yapabilirsiniz:

```dart
class MockDataRepository {
  static final List<Goal> _baseGoals = [...];
  
  static List<Goal> get goals => List.from(_baseGoals);
  
  static void addGoal(Goal goal) {
    _baseGoals.add(goal);
  }
  
  static void removeGoal(String id) {
    _baseGoals.removeWhere((g) => g.id == id);
  }
}
```

Sonra UI'dan güncelleyin:
```dart
void _addGoal() {
  final newGoal = Goal(...);
  MockDataRepository.addGoal(newGoal);
  ref.invalidate(goalsProvider); // UI'ı yenile
}
```

## 📝 En İyi Uygulamalar

1. **Gerçekçi tutun**: Production verisine benzer veri kullanın
2. **Edge case'leri test edin**: Boş, yükleniyor, hata durumları
3. **Zaman damgalarını akıllıca kullanın**: Göreceli zaman gösterimini test etmek için tarihleri değiştirin
4. **Değişiklikleri belgeleyin**: Belirli test verisi ekleme nedeninizi yorumlayın
5. **Kişisel veri commit etmeyin**: Mock veriyi genel tutun
6. **Testler arasında sıfırlayın**: Test izolasyonunu sağlayın

## 📚 İlgili Dosyalar

- **Mock Repository**: [lib/shared/data/mock_data_repository.dart](file:///Users/enesgeldi/Downloads/learning_coach/lib/shared/data/mock_data_repository.dart)
- **Provider'lar**: [lib/shared/data/providers.dart](file:///Users/enesgeldi/Downloads/learning_coach/lib/shared/data/providers.dart)
- **Modeller**: [lib/shared/models/models.dart](file:///Users/enesgeldi/Downloads/learning_coach/lib/shared/models/models.dart)

---

Mimari detayları için [ARCHITECTURE.md](ARCHITECTURE.md) dosyasına bakınız.
