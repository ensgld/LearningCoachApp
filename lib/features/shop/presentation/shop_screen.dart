import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_coach/core/constants/app_strings.dart';
import 'package:learning_coach/core/providers/locale_provider.dart';
import 'package:learning_coach/shared/data/providers.dart';
import 'package:learning_coach/shared/models/gamification_models.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ItemCategory _selectedCategory = ItemCategory.pot;

  // Garden Shop Items
  final List<InventoryItem> _shopItems = [
    // Pots (Saksılar)
    const InventoryItem(
      id: 'pot_terracotta',
      name: '🪴 Terracotta Saksı',
      category: ItemCategory.pot,
      goldCost: 0,
      assetPath: 'pot_terracotta',
    ),
    const InventoryItem(
      id: 'pot_ceramic',
      name: '🏺 Seramik Saksı',
      category: ItemCategory.pot,
      goldCost: 0,
      assetPath: 'pot_ceramic',
    ),
    const InventoryItem(
      id: 'pot_wooden',
      name: '🪵 Ahşap Saksı',
      category: ItemCategory.pot,
      goldCost: 0,
      assetPath: 'pot_wooden',
    ),
    const InventoryItem(
      id: 'pot_gold',
      name: '✨ Altın Saksı',
      category: ItemCategory.pot,
      goldCost: 0,
      assetPath: 'pot_gold',
    ),
    const InventoryItem(
      id: 'pot_crystal',
      name: '💎 Kristal Saksı',
      category: ItemCategory.pot,
      goldCost: 0,
      assetPath: 'pot_crystal',
    ),

    // Backgrounds (Arka Planlar)
    const InventoryItem(
      id: 'bg_night',
      name: '🌙 Gece Gökyüzü',
      category: ItemCategory.background,
      goldCost: 0,
      assetPath: 'space_bg',
    ),
    const InventoryItem(
      id: 'bg_forest',
      name: '🌲 Orman Arka Planı',
      category: ItemCategory.background,
      goldCost: 0,
      assetPath: 'forest_bg',
    ),
    const InventoryItem(
      id: 'bg_ocean',
      name: '🌊 Okyanus Arka Planı',
      category: ItemCategory.background,
      goldCost: 0,
      assetPath: 'ocean_bg',
    ),
    const InventoryItem(
      id: 'bg_sunny',
      name: '☀️ Güneşli Park',
      category: ItemCategory.background,
      goldCost: 0,
      assetPath: 'sunny_bg',
    ),
    const InventoryItem(
      id: 'bg_rainbow',
      name: '🌈 Gökkuşağı',
      category: ItemCategory.background,
      goldCost: 0,
      assetPath: 'rainbow_bg',
    ),

    // Companions (Dostlar)
    const InventoryItem(
      id: 'comp_cat',
      name: '🐱 Uyuyan Kedi',
      category: ItemCategory.companion,
      goldCost: 0,
      assetPath: 'cat_companion',
    ),
    const InventoryItem(
      id: 'comp_bird',
      name: '🐦 Cıvıldayan Kuş',
      category: ItemCategory.companion,
      goldCost: 0,
      assetPath: 'bird_companion',
    ),
    const InventoryItem(
      id: 'comp_butterfly',
      name: '🦋 Kelebek',
      category: ItemCategory.companion,
      goldCost: 0,
      assetPath: 'butterfly_companion',
    ),
    const InventoryItem(
      id: 'comp_owl',
      name: '🦉 Bilge Baykuş',
      category: ItemCategory.companion,
      goldCost: 0,
      assetPath: 'owl_companion',
    ),
    const InventoryItem(
      id: 'comp_dragon',
      name: '🐉 Mini Ejderha',
      category: ItemCategory.companion,
      goldCost: 0,
      assetPath: 'dragon_companion',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedCategory = ItemCategory.values[_tabController.index];
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final userStats = ref.watch(userStatsProvider);
    final filteredItems = _shopItems
        .where((item) => item.category == _selectedCategory)
        .toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F3FF),
              Color(0xFFFDF4FF),
              Color(0xFFF0FDFA),
              Color(0xFFFEF3F2),
            ],
            stops: [0.0, 0.33, 0.66, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with Gold Balance
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    Text(
                      AppStrings.getShopTitle(locale),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    // Gold removed
                    const SizedBox.shrink(),
                  ],
                ),
              ),

              // Category Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black54,
                      tabs: [
                        Tab(text: AppStrings.getPotsTab(locale)),
                        Tab(text: AppStrings.getBackgroundsTab(locale)),
                        const Tab(text: '🐾 Dostlar'),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Items Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final isPurchased = userStats.purchasedItemIds.contains(
                      item.id,
                    );
                    final isEquipped =
                        userStats.equippedItems[item.category.name] == item.id;
                    final canAfford = userStats.gold >= item.goldCost;

                    return _ShopItemCard(
                      item: item,
                      isPurchased: isPurchased,
                      isEquipped: isEquipped,
                      canAfford: canAfford,
                      onTap: () => _handleItemTap(
                        item,
                        isPurchased,
                        isEquipped,
                        canAfford,
                        locale,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleItemTap(
    InventoryItem item,
    bool isPurchased,
    bool isEquipped,
    bool canAfford,
    String locale,
  ) {
    if (!isPurchased) {
      // Purchase item
      if (canAfford) {
        showDialog(
          context: context,
          builder: (context) => _PurchaseConfirmDialog(
            item: item,
            onConfirm: () {
              ref
                  .read(userStatsProvider.notifier)
                  .purchaseItem(item.id, item.goldCost);
              Navigator.of(context).pop();
              _showPurchaseSuccess(item, locale);
            },
          ),
        );
      } else {
        _showInsufficientFunds(item, locale);
      }
    } else if (!isEquipped) {
      // Equip item
      ref
          .read(userStatsProvider.notifier)
          .equipItem(item.category.name, item.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppStrings.getShopItemName(item.id, locale)} ${AppStrings.getItemEquipped(locale)}',
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showPurchaseSuccess(InventoryItem item, String locale) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shopping_bag_rounded,
                size: 64,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.getPurchased(locale),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.getShopItemName(item.id, locale),
                style: const TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF10B981),
                ),
                child: const Text('Harika!'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInsufficientFunds(InventoryItem item, String locale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💰 Yetersiz Altın'),
        content: Text(
          AppStrings.getInsufficientGold(
            locale,
            item.goldCost - ref.read(userStatsProvider).gold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}

class _ShopItemCard extends ConsumerWidget {
  final InventoryItem item;
  final bool isPurchased;
  final bool isEquipped;
  final bool canAfford;
  final VoidCallback onTap;

  const _ShopItemCard({
    required this.item,
    required this.isPurchased,
    required this.isEquipped,
    required this.canAfford,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isEquipped
              ? Border.all(color: const Color(0xFF6366F1), width: 3)
              : null,
          boxShadow: [
            BoxShadow(
              color: isEquipped
                  ? const Color(0xFF6366F1).withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: isEquipped ? 16 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Lock overlay for locked items
            if (!isPurchased && !canAfford)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Item Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context).colorScheme.secondaryContainer,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        AppStrings.getShopItemName(
                          item.id,
                          locale,
                        ).split(' ')[0],
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Item Name
                  Text(
                    AppStrings.getShopItemName(
                      item.id,
                      locale,
                    ).split(' ').skip(1).join(' '),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // Status/Price
                  if (isEquipped)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        AppStrings.getEquipped(locale),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    )
                  else if (isPurchased)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        AppStrings.getEquip(locale),
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Ücretsiz', // Free
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurchaseConfirmDialog extends ConsumerWidget {
  final InventoryItem item;
  final VoidCallback onConfirm;

  const _PurchaseConfirmDialog({required this.item, required this.onConfirm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return AlertDialog(
      title: Text(AppStrings.getBuyBtn(locale)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.getShopItemName(item.id, locale),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Ücretsiz',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF10B981),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppStrings.getCancel(locale)),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          child: Text(AppStrings.getBuyBtn(locale)),
        ),
      ],
    );
  }
}
