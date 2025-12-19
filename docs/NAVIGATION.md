# Navigasyon Dokümantasyonu

Bu doküman, Learning Coach uygulamasındaki navigasyon yapısını, rotaları ve navigasyon akışlarını açıklar.

## 🧭 Navigasyon Genel Bakış

Learning Coach, şunlarla deklaratif, tip-güvenli routing için **GoRouter** kullanır:
- Kalıcı alt sekmeler için **Stateful shell navigasyon**
- Özelliğe özgü akışlar için **İç içe navigasyon**
- Modaller ve bağımsız ekranlar için **Tam ekran rotalar**
- Varsayılan olarak **Deep linking desteği**

## 📍 Rota Yapısı

### Navigasyon Hiyerarşisi

```
Root Navigator (GlobalKey<NavigatorState>)
│
└── StatefulShellRoute (Alt Navigasyon)
    │
    ├── Home Branch (shellNavigatorHome)
    │   └── /home
    │
    ├── Study Branch (shellNavigatorStudy)
    │   ├── /study
    │   ├── /study/running *
    │   ├── /study/quiz *
    │   └── /study/summary *
    │
    ├── Docs Branch (shellNavigatorDocs)
    │   ├── /docs
    │   ├── /docs/detail *
    │   └── /docs/chat *
    │
    └── Profile Branch (shellNavigatorProfile)
        └── /profile

Global Rotalar (root navigator kullanır)
├── /kaizen *
└── /goal-detail *

* = Root navigator kullanır (alt navigasyonu gizler)
```

## 🗺️ Rota Referansı

### Alt Sekme Rotaları

| Rota | Ekran | Açıklama | Branch |
|------|-------|----------|--------|
| `/home` | `HomeScreen` | Genel bakış kartları ile ana sayfa | Home |
| `/study` | `StudyScreen` | Çalışma seansı başlangıç sayfası | Study |
| `/docs` | `DocumentsScreen` | Doküman kütüphanesi listesi | Docs |
| `/profile` | `ProfileScreen` | Kullanıcı profili ve ayarlar | Profile |

### Study Özelliği Rotaları

| Rota | Ekran | Açıklama | Navigasyon Tipi |
|------|-------|----------|-----------------|
| `/study/running` | `SessionRunningScreen` | Aktif çalışma seansı zamanlayıcısı | Tam ekran |
| `/study/quiz` | `SessionFinishScreen` | Seans sonrası quiz | Tam ekran |
| `/study/summary` | `SessionSummaryScreen` | Seans tamamlanma özeti | Tam ekran |

**Akış**: Study → Running → Quiz → Summary → Home

### Documents Özelliği Rotaları

| Rota | Ekran | Açıklama | Navigasyon Tipi | Extra Veri |
|------|-------|----------|-----------------|------------|
| `/docs/detail` | `DocumentDetailScreen` | Doküman önizleme ve bilgi | Tam ekran | `Document` nesnesi |
| `/docs/chat` | `DocumentChatScreen` | Dokümanla soru-cevap sohbeti | Tam ekran | `Document` nesnesi |

**Akış**: Docs Listesi → Detay → Chat (opsiyonel)

### Global Rotalar

| Rota | Ekran | Açıklama | Navigasyon Tipi | Extra Veri |
|------|-------|----------|-----------------|------------|
| `/kaizen` | `KaizenCheckinScreen` | Günlük yansıma formu | Modal/Tam ekran | Yok |
| `/goal-detail` | `GoalDetailScreen` | Hedef detayları ve görev listesi | Modal/Tam ekran | `Goal` nesnesi |

## 🎯 Navigasyon Desenleri

### 1. Alt Navigasyon

Uygulama, alt sekmeler arasında state'i korumak için `StatefulShellRoute` kullanır:

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) {
    return AppShell(navigationShell: navigationShell);
  },
  branches: [
    StatefulShellBranch(...), // Home
    StatefulShellBranch(...), // Study
    StatefulShellBranch(...), // Docs
    StatefulShellBranch(...), // Profile
  ],
)
```

**Faydaları**:
- Geçiş yapıldığında sekme state'i korunur
- Sekme başına bağımsız navigasyon stack'leri
- Pürüzsüz sekme geçişleri

### 2. Tam Ekran Navigasyon (Alt Navigasyonu Gizleme)

Sürükleyici deneyimler için (çalışma zamanlayıcısı, doküman sohbeti), alt navigasyonu gizleyin:

```dart
GoRoute(
  path: 'running',
  parentNavigatorKey: _rootNavigatorKey, // Root navigator kullan
  builder: (context, state) => const SessionRunningScreen(),
),
```

**Kullanım alanları**:
- Odaklanma modu (çalışma seansları)
- Detay görünümleri (doküman önizleme)
- Modaller/diyaloglar (Kaizen kontrolü)

### 3. Rotalar Arası Veri Geçişi

Tip-güvenli veri geçişi için `extra` parametresini kullanın:

```dart
// Bir rotaya GİTMEK
context.push('/goal-detail', extra: goalObject);

// Rotada ALMAK
GoRoute(
  path: '/goal-detail',
  builder: (context, state) {
    final goal = state.extra as Goal;
    return GoalDetailScreen(goal: goal);
  },
)
```

**Önemli**: 
- `state.extra`'yı her zaman beklenen tipe cast edin
- Navigate ederken verinin geçildiğinden emin olun
- Deep link'ler için bunun yerine query parametrelerini düşünün

### 4. Programatik Navigasyon

```dart
// Push (stack'e ekle)
context.push('/study/running');

// Go (mevcut rotayı değiştir)
context.go('/home');

// Pop (geri git)
context.pop();

// Sonuçla pop
context.pop(result);

// Replace (değiştir)
context.replace('/study/summary');
```

## 🔄 Kullanıcı Akışları

### Çalışma Seansı Akışı

```
HomeScreen
  ↓ (Çalışmayı Başlat'a dokun)
StudyScreen
  ↓ (Hedef seç, Başlat'a dokun)
SessionRunningScreen (tam ekran)
  ↓ (Zamanlayıcı biter)
SessionFinishScreen (quiz)
  ↓ (Quiz'i tamamla)
SessionSummaryScreen (sonuçlar)
  ↓ (Tamam'a dokun)
HomeScreen (ana sayfaya geri dön)
```

**Kod**:
```dart
// Seans başlat
context.push('/study/running');

// Zamanlayıcıdan sonra
context.replace('/study/quiz');

// Quiz'den sonra
context.replace('/study/summary');

// Ana sayfaya dön
context.go('/home');
```

### Doküman Etkileşim Akışı

```
DocumentsScreen (liste görünümü)
  ↓ (Dokümana dokun)
DocumentDetailScreen (önizleme)
  ↓ ("Soru Sor"a dokun)
DocumentChatScreen (Soru-Cevap)
  ↓ (Geri butonu)
DocumentDetailScreen
  ↓ (Geri butonu)
DocumentsScreen
```

**Kod**:
```dart
// Dokümanı görüntüle
context.push('/docs/detail', extra: document);

// Sohbet başlat
context.push('/docs/chat', extra: document);

// Geri git
context.pop();
```

### Hedef Yönetim Akışı

```
HomeScreen
  ↓ (Hedef kartına dokun)
GoalDetailScreen (modal)
  ↓ (Görevleri görüntüle/düzenle)
[Görev etkileşimleri]
  ↓ (Kapat)
HomeScreen (modal kapatıldı)
```

**Kod**:
```dart
// Hedef detayını aç
context.push('/goal-detail', extra: goal);

// Modalı kapat
context.pop();
```

## 🔗 Deep Linking

Tüm rotalar otomatik olarak deep linking'i destekler. Örnekler:

```
myapp://home
myapp://study
myapp://study/running
myapp://docs
myapp://kaizen
```

**Not**: `Extra` verisi olan rotalar (örn. `/goal-detail`) deep link'ler için özel ele alma gerektirir. Query parametrelerini eklemeyi düşünün:

```dart
// Gelecek implementasyon
GoRoute(
  path: '/goal-detail',
  builder: (context, state) {
    final goalId = state.uri.queryParameters['id'];
    final goal = findGoalById(goalId); // Repository'den getir
    return GoalDetailScreen(goal: goal);
  },
)

// Deep link: myapp://goal-detail?id=123
```

## 🛠️ Navigator Key'leri

Beş navigator key navigasyon bağlamlarını yönetir:

```dart
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHome = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorStudy = GlobalKey<NavigatorState>(debugLabel: 'shellStudy');
final _shellNavigatorDocs = GlobalKey<NavigatorState>(debugLabel: 'shellDocs');
final _shellNavigatorProfile = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');
```

**Kullanım**:
- **Root**: Tam ekran rotalar, modaller
- **Shell key'leri**: Sekme başına iç içe navigasyon

## 🎨 Navigasyon UI Bileşenleri

### AppShell (Alt Navigasyon Çubuğu)

Konum: `lib/app/shell/app_shell.dart`

```dart
class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          NavigationDestination(icon: Icon(Icons.book), label: 'Çalış'),
          NavigationDestination(icon: Icon(Icons.folder), label: 'Dosyalar'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
```

### Navigasyon En İyi Uygulamaları

1. **Her zaman context.push/go kullanın**: Manuel olarak `Navigator.push` oluşturmayın
2. **Rotanın var olduğunu kontrol edin**: Rotaların `app_router.dart`'ta tanımlı olduğundan emin olun
3. **Tip-güvenli veri geçişi**: İlkel tipler değil, modeller kullanın
4. **Geri navigasyonu ele alın**: Alt navigasyon gizlendiğinde açık geri butonları sağlayın
5. **Deep link'leri test edin**: Rotaların doğrudan URL'ler ile çalıştığını doğrulayın

## 📊 Rota Yapılandırma Kodu

Tüm rotalar `lib/app/router/app_router.dart`'ta tanımlıdır:

```dart
@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        // ... shell rota yapılandırması
      ),
      // ... global rotalar
    ],
  );
}
```

**Provider erişimi**:
```dart
final router = ref.watch(goRouterProvider);

MaterialApp.router(
  routerConfig: router,
  // ...
);
```

## 🚧 Gelecek Geliştirmeler

- **İç içe sekmeler**: Özellikler içinde alt sekmeler
- **Kimlik doğrulama koruması**: Giriş yapılmadıysa yönlendirme
- **Rota geçişleri**: Özel sayfa geçişleri
- **Rota gözlemcileri**: Analitik takibi
- **Hata yönetimi**: 404 sayfası, hata rotaları

## 📚 Kaynaklar

- [GoRouter Dokümantasyonu](https://pub.dev/packages/go_router)
- [GoRouter Migrasyon Kılavuzu](https://docs.flutter.dev/ui/navigation)
- [Stateful İç İçe Navigasyon](https://pub.dev/documentation/go_router/latest/topics/Nested%20navigation-topic.html)

---

Mimari detayları için [ARCHITECTURE.md](ARCHITECTURE.md) dosyasına bakınız.  
Rota implementasyonları için [app_router.dart](file:///Users/enesgeldi/Downloads/learning_coach/lib/app/router/app_router.dart) dosyasına bakınız.
