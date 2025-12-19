import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_coach/core/constants/app_strings.dart';
import 'package:learning_coach/features/auth/application/auth_controller.dart';

/// Profile Screen
///
/// Kullanıcı profili ve ayarlar ekranı.
/// Mock auth ile çıkış yapma özelliği eklendi.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _notificationsEnabled = true;
  double _dailyGoal = 60;
  String _language = 'Türkçe';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.navProfile)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Info
          const Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Öğrenci Adı',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),

          Text(
            AppStrings.profileSettings,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Daily Goal
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        AppStrings.dailyGoalLabel,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('${_dailyGoal.round()} dk'),
                    ],
                  ),
                  Slider(
                    value: _dailyGoal,
                    min: 15,
                    max: 180,
                    divisions: 11,
                    onChanged: (val) => setState(() => _dailyGoal = val),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Notifications
          SwitchListTile(
            title: const Text(AppStrings.notificationsLabel),
            value: _notificationsEnabled,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
            secondary: const Icon(Icons.notifications),
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          const SizedBox(height: 16),

          // Language
          ListTile(
            title: const Text(AppStrings.languageLabel),
            subtitle: Text(_language),
            leading: const Icon(Icons.language),
            trailing: const Icon(Icons.chevron_right),
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            onTap: () {
              // Mock Language Switch
              setState(() {
                _language = _language == 'Türkçe' ? 'English' : 'Türkçe';
              });
            },
          ),

          const SizedBox(height: 32),

          // Çıkış Yap butonu
          /// Logout Button
          ///
          /// Mock auth ile çıkış yap ve welcome ekranına dön.
          /// Gerçekte: Secure storage'dan token temizlenir
          ListTile(
            title: const Text(
              'Çıkış Yap',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            leading: const Icon(Icons.logout, color: Colors.red),
            tileColor: Colors.red.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.red.shade100),
            ),
            onTap: () {
              // Logout onayı göster
              showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Çıkış Yap'),
                  content: const Text(
                    'Çıkış yapmak istediğinize emin misiniz?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('İptal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        'Çıkış Yap',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ).then((confirmed) {
                if (confirmed == true) {
                  // Logout yap
                  ref.read(authControllerProvider.notifier).logout();
                  // Welcome ekranına git
                  context.go('/welcome');
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
