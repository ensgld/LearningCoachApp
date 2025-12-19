# Mimari Dokümantasyonu

Bu doküman, Learning Coach uygulamasında kullanılan mimari ve tasarım desenlerini açıklar.

## 🏛️ Genel Mimari

Learning Coach, net endişe ayrımı ile **özellik-öncelikli (feature-first) mimari** desenini takip eder. Bu yaklaşım, uygulama büyüdükçe **modülerlik**, **ölçeklenebilirlik** ve **sürdürülebilirlik** sağlar.

### Mimari Prensipler

1. **Özellik-Öncelikli Organizasyon**: Kod, teknik katmana göre değil, özellik/domain'e göre düzenlenir
2. **Endişelerin Ayrılması**: UI, state ve veri katmanları arasında net sınırlar
3. **Bağımlılık Tersine Çevirme**: Üst seviye modüller alt seviye modüllere bağımlı değildir; ikisi de soyutlamalara bağımlıdır
4. **Tek Sorumluluk**: Her modül/sınıf değişmek için bir nedene sahiptir
5. **Test Edilebilirlik**: Tasarım, unit, widget ve entegrasyon testlerini kolaylaştırır

## 📁 Klasör Yapısı

```
lib/
├── app/                          # Uygulama seviyesi yapılandırma
│   ├── router/                   # Routing yapılandırması
│   │   ├── app_router.dart       # Tüm rotalarla GoRouter kurulumu
│   │   └── app_router.g.dart     # Üretilen routing kodu
│   ├── shell/                    # Uygulama kabuğu (navigasyon yapısı)
│   │   └── app_shell.dart        # Alt navigasyon kabuğu
│   └── theme/                    # Temalama ve görsel tasarım
│       └── app_theme.dart        # Material 3 tema yapılandırması
│
├── features/                     # Özellik modülleri (iş domainleri)
│   ├── home/                     # Ana sayfa özelliği
│   │   └── presentation/         # UI katmanı
│   │       ├── home_screen.dart
│   │       └── widgets/          # Özelliğe özgü widget'lar
│   ├── study/                    # Çalışma seansları özelliği
│   │   └── presentation/
│   │       ├── study_screen.dart
│   │       ├── session_running_screen.dart
│   │       ├── session_finish_screen.dart
│   │       └── session_summary_screen.dart
│   ├── goals/                    # Hedef yönetimi özelliği
│   ├── kaizen/                   # Günlük kontroller özelliği
│   ├── documents/                # Doküman kütüphanesi özelliği
│   ├── coach/                    # Yapay zeka koçu özelliği (gelecek)
│   └── profile/                  # Kullanıcı profili özelliği
│
├── shared/                       # Özellikler arası paylaşılan kod
│   ├── data/                     # Veri katmanı
│   │   ├── mock_data_repository.dart  # Mock veri kaynağı
│   │   ├── providers.dart        # Paylaşılan Riverpod provider'lar
│   │   └── providers.g.dart      # Üretilen provider kodu
│   ├── models/                   # Veri modelleri
│   │   └── models.dart           # Tüm domain modelleri
│   └── widgets/                  # Yeniden kullanılabilir UI bileşenleri (gelecek)
│
└── core/                         # Temel yardımcılar (framework-agnostic)
    ├── constants/                # Uygulama genelinde sabitler
    │   └── app_strings.dart      # String sabitleri
    └── utils/                    # Yardımcı fonksiyonlar (gelecek)
```

## 🧩 Katman Sorumlulukları

### 1. App Katmanı (`app/`)

**Amaç**: Uygulamayı başlatan uygulama seviyesi yapılandırma.

- **Router**: GoRouter kullanarak tüm navigasyon rotalarını tanımlar
- **Shell**: Ana navigasyon yapısını sağlar (örn. alt navigasyon)
- **Theme**: Material 3 temasını, renkleri, tipografiyi yapılandırır

**Önemli Dosyalar**:
- `app_router.dart`: İç içe navigasyon ile deklaratif routing
- `app_shell.dart`: Alt sekmeler için StatefulShellRoute wrapper'ı
- `app_theme.dart`: Tema data yapılandırması

### 2. Features Katmanı (`features/`)

**Amaç**: İş domainlerini kapsüller. Her özellik bağımsız ve kendi içinde tamamlanmıştır.

**Yapı (özellik başına)**:
```
feature_name/
├── presentation/       # UI bileşenleri
│   ├── screens/        # Tam ekranlar
│   ├── widgets/        # Özelliğe özgü widget'lar
│   └── providers/      # Özelliğe özgü state (opsiyonel)
├── domain/             # İş mantığı (gelecek)
└── data/               # Veri kaynakları (gelecek)
```

**Mevcut Durum**: Sadece `presentation/` katmanı mevcut. Gelecek eklemeler:
- **Domain katmanı**: Use case'ler, iş kuralları, entity'ler
- **Data katmanı**: Repository'ler, API client'ları, yerel depolama

**Örnekler**:
- `features/home/`: Genel bakış kartları ile ana sayfa
- `features/study/`: Çalışma seansı zamanlayıcısı ve takip
- `features/documents/`: Doküman kütüphanesi CRUD operasyonları

### 3. Shared Katmanı (`shared/`)

**Amaç**: Birden fazla özellik arasında paylaşılan kod.

- **Data**: Tüm özelliklere veri sağlayan mock repository
- **Models**: Uygulama boyunca kullanılan domain modelleri
- **Widgets**: Yeniden kullanılabilir UI bileşenleri (butonlar, kartlar vb.)

**Önemli**: Her şeyi buraya koymayın. Sadece gerçekten paylaşılan kodu ekleyin.

### 4. Core Katmanı (`core/`)

**Amaç**: Framework-agnostic yardımcılar ve sabitler.

- **Constants**: Uygulama adı, API URL'leri, varsayılan değerler
- **Utils**: Tarih formatlayıcılar, validator'lar, extension'lar

**Kural**: Core asla `app/`, `features/` veya `shared/`'dan import etmemelidir.

## 🔄 State Yönetimi

State yönetimi için **kod üretimi** ile **Riverpod** kullanıyoruz.

### Neden Riverpod?

- **Derleme zamanı güvenliği**: Hatalar çalışma zamanından önce yakalanır
- **Test Edilebilirlik**: Provider'ları mock etmek kolay
- **Performans**: Granüler yeniden derlemeler
- **BuildContext bağımlılığı yok**: State her yerden erişilebilir

### Provider Tipleri

```dart
// 1. Basit provider (değişmez, hesaplanmış değer)
@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(...);
}

// 2. Future provider (async veri)
@riverpod
Future<List<Goal>> goals(Ref ref) async {
  return await repository.getGoals();
}

// 3. Stream provider (reaktif veri)
@riverpod
Stream<int> timer(Ref ref) {
  return Stream.periodic(Duration(seconds: 1), (i) => i);
}

// 4. Notifier (değişebilir state)
@riverpod
class GoalList extends _$GoalList {
  @override
  List<Goal> build() => MockDataRepository.goals;
  
  void addGoal(Goal goal) {
    state = [...state, goal];
  }
}
```

### Provider Organizasyonu

- **Uygulama seviyesi provider'lar**: `app/router/app_router.dart`, `shared/data/providers.dart`
- **Özellik provider'ları**: `features/<name>/presentation/providers/` içinde
- **Üretilen dosyalar**: Her zaman commit edilir (`.g.dart` dosyaları)

### Kod Üretimi

```bash
# Tek seferlik derleme
dart run build_runner build --delete-conflicting-outputs

# İzleme modu (değişikliklerde otomatik yeniden üret)
dart run build_runner watch --delete-conflicting-outputs
```

## 🧭 Navigasyon Mimarisi

Kalıcı alt navigasyon için **StatefulShellRoute** ile **GoRouter** kullanıyoruz.

### Rota Yapısı

```
Root Navigator (tam ekran rotalar)
├── StatefulShellRoute (alt sekmeler)
│   ├── Home Branch (/home)
│   ├── Study Branch (/study)
│   │   ├── /study/running (root navigator kullanır)
│   │   ├── /study/quiz (root navigator kullanır)
│   │   └── /study/summary (root navigator kullanır)
│   ├── Docs  Branch (/docs)
│   │   ├── /docs/detail (root navigator kullanır)
│   │   └── /docs/chat (root navigator kullanır)
│   └── Profile Branch (/profile)
├── /kaizen (modal - root navigator)
└── /goal-detail (modal - root navigator)
```

### Navigasyon En İyi Uygulamaları

1. **İsimlendirilmiş rotalar kullanın**: Tüm rotalar `app_router.dart`'ta tanımlı
2. **Tip-güvenli navigasyon**: Tipli nesneleri `extra` parametresi ile geçirin
3. **Shell vs Root**: Alt navigasyonu gizlemek için `parentNavigatorKey: _rootNavigatorKey` kullanın
4. **Deep linking**: Tüm rotalar varsayılan olarak deep linking destekler

Örnek:
```dart
// Tipli veri ile navigasyon
context.push('/goal-detail', extra: goalObject);

// Rota tanımında
GoRoute(
  path: '/goal-detail',
  builder: (context, state) {
    final goal = state.extra as Goal;
    return GoalDetailScreen(goal: goal);
  },
)
```

## 💾 Veri Katmanı (Mevcut: Mock)

Şu anda tüm veriler `MockDataRepository`'den gelir. Bu gerçek bir backend'i simüle eder.

### Mock Veri Stratejisi

**Konum**: `lib/shared/data/mock_data_repository.dart`

**Kullanım**:
```dart
class MockDataRepository {
  static final List<Goal> goals = [...];
  static final List<Document> documents = [...];
  static final List<CoachMessage> initialChat = [...];
}
```

**Provider'lar aracılığıyla erişim**:
```dart
@riverpod
List<Goal> goals(Ref ref) {
  return MockDataRepository.goals;
}
```

**Faydaları**:
- Backend bağımlılığı olmadan UI geliştirme
- Öngörülebilir test verisi
- Daha sonra gerçek API ile değiştirmek kolay

### Gelecek: Gerçek Backend Entegrasyonu

Gerçek bir backend entegre ederken:

1. **Domain katmanında repository interface'leri oluşturun**
2. **Data katmanında API client implementasyonu yapın**
3. **Mock repository'yi gerçek implementasyon ile değiştirin**
4. **Provider'ları async veri kaynakları kullanacak şekilde güncelleyin**
5. **Hata yönetimi ve loading state'leri ekleyin**

Örnek migrasyon:
```dart
// Önce (mock)
@riverpod
List<Goal> goals(Ref ref) {
  return MockDataRepository.goals;
}

// Sonra (gerçek backend)
@riverpod
Future<List<Goal>> goals(Ref ref) async {
  final repository = ref.watch(goalRepositoryProvider);
  return await repository.fetchGoals();
}
```

## 🎨 UI/Presentation Yönergeleri

### Material 3 Tasarım

- Flutter SDK'dan Material 3 bileşenlerini kullanın
- Tema `app/theme/app_theme.dart`'ta yapılandırılmıştır
- Tutarlı boşluk: 8px grid sistemi
- Renk şeması: Temada tanımlı

### Widget Organizasyonu

1. **Screen widget'ları**: Üst seviye rotalar (örn. `HomeScreen`)
2. **Feature widget'ları**: Bir özellik içinde kullanılan bileşenler
3. **Shared widget'lar**: Özellikler arası yeniden kullanılabilir (`shared/widgets/`'ta)

### Widget En İyi Uygulamaları

```dart
// 1. Const constructor'ları tercih edin
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Text('Merhaba');
  }
}

// 2. Karmaşık widget'ları çıkarın
class ComplexScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildContent(),
          _buildFooter(),
        ],
      ),
    );
  }
  
  Widget _buildHeader() => ...;
  Widget _buildContent() => ...;
  Widget _buildFooter() => ...;
}

// 3. State için Riverpod kullanın
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);
    return ListView(children: goals.map((g) => ...).toList());
  }
}
```

## 📊 Veri Modelleri

Tüm modeller `lib/shared/models/models.dart`'ta tanımlıdır.

### Model Tasarımı

```dart
class Goal {
  final String id;
  final String title;
  final String description;
  final double progress;
  final List<GoalTask> tasks;

  const Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.tasks,
  });
}
```

**Gelecekte JSON serileştirme için**:
```dart
import 'package:json_annotation/json_annotation.dart';

part 'goal.g.dart';

@JsonSerializable()
class Goal {
  final String id;
  final String title;
  
  Goal({required this.id, required this.title});
  
  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
  Map<String, dynamic> toJson() => _$GoalToJson(this);
}
```

## 🧪 Test Stratejisi

### Test Organizasyonu

```
test/
├── unit/               # Saf Dart mantık testleri
├── widget/             # Widget testleri
├── integration/        # Tam uygulama akış testleri
└── smoke_test.dart     # Uygulama başlatma doğrulaması
```

### Test Prensipleri

1. **Unit testler**: İş mantığı, utils, modeller
2. **Widget testler**: UI bileşenleri, kullanıcı etkileşimleri
3. **Entegrasyon testleri**: Tam kullanıcı akışları
4. **Mock provider'lar**: Riverpod'un override sistemini kullanın

Örnek widget testi:
```dart
testWidgets('HomeScreen hedefleri gösterir', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        goalsProvider.overrideWith((ref) => mockGoals),
      ],
      child: MaterialApp(home: HomeScreen()),
    ),
  );
  
  expect(find.text('Hedefim'), findsOneWidget);
});
```

## 🔮 Gelecek Mimari Evrimi

Uygulama büyüdükçe, şunları tanıtacağız:

1. **Domain Katmanı**: Use case'ler, entity'ler, repository interface'leri
2. **Data Katmanı**: API client'ları, yerel veritabanı, önbellekleme
3. **Hata Yönetimi**: Result tipleri, özel exception'lar
4. **Dependency Injection**: Repository'ler için service locator
5. **Feature Modülleri**: Büyük özellikler için Dart paketleri
6. **Test Altyapısı**: Entegrasyon testleri, golden testler

### Clean Architecture Katmanları (Gelecek)

```
Presentation (UI, State)
    ↓
Domain (İş Mantığı, Entity'ler, Use Case'ler)
    ↓
Data (Repository'ler, Veri Kaynakları, DTO'lar)
```

**Bağımlılık Kuralı**: İç katmanlar dış katmanları bilmez.

## 📚 Ek Kaynaklar

- [Riverpod Dokümantasyonu](https://riverpod.dev)
- [GoRouter Dokümantasyonu](https://pub.dev/packages/go_router)
- [Flutter Mimari Örnekleri](https://github.com/brianegan/flutter_architecture_samples)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)

---

Navigasyon detayları için [NAVIGATION.md](NAVIGATION.md) dosyasına bakınız.  
Mock veri yönetimi için [MOCK_DATA.md](MOCK_DATA.md) dosyasına bakınız.
