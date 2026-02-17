import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// --- Avatar Evolution Stages - 5 Stages Evolution Story ---
enum AvatarStage {
  seed, // Level 1-8   -> char_lvl1.jpeg (Tohum - Başlangıç)
  sprout, // Level 9-16  -> char_lvl2.jpeg (Filiz - Büyüme)
  bloom, // Level 17-25 -> char_lvl3.jpeg (Çiçek - Gelişim)
  tree, // Level 26-35 -> char_lvl4.jpeg (Ağaç - Olgunluk)
  forest, // Level 36+   -> char_lvl5.jpeg (Orman - Ustalık)
}

// --- Evolution Stage Features ---
class StageFeatures {
  final String title;
  final String description;
  final String powerName;
  final int xpBonus; // Extra XP percentage
  final int goldBonus; // Extra Gold percentage
  final String emoji;
  final Color primaryColor;
  final Color secondaryColor;

  const StageFeatures({
    required this.title,
    required this.description,
    required this.powerName,
    required this.xpBonus,
    required this.goldBonus,
    required this.emoji,
    required this.primaryColor,
    required this.secondaryColor,
  });
}

// --- Inventory Item ---
class InventoryItem extends Equatable {
  final String id;
  final String name;
  final ItemCategory category;
  final int goldCost;
  final String assetPath;
  final bool isPurchased;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.goldCost,
    required this.assetPath,
    this.isPurchased = false,
  });

  InventoryItem copyWith({bool? isPurchased}) {
    return InventoryItem(
      id: id,
      name: name,
      category: category,
      goldCost: goldCost,
      assetPath: assetPath,
      isPurchased: isPurchased ?? this.isPurchased,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    goldCost,
    assetPath,
    isPurchased,
  ];
}

enum ItemCategory { pot, background, companion }

// --- User Stats (Gamification State) ---
class UserStats extends Equatable {
  final int currentLevel;
  final int currentXP;
  final int totalGold;
  final AvatarStage stage;
  final Map<String, String> equippedItems;
  final List<String> purchasedItemIds;

  const UserStats({
    this.currentLevel = 1,
    this.currentXP = 0,
    this.totalGold = 100,
    this.stage = AvatarStage.seed, // Başlangıç evresi: Tohum
    this.equippedItems = const {},
    this.purchasedItemIds = const [],
  });

  // Convenience getters for easier access
  int get level => currentLevel;
  int get xp => currentXP;
  int get gold => totalGold;

  /// Calculate XP required for next level: level * 100
  int get xpRequiredForNextLevel => currentLevel * 100;

  /// Get progress to next level (0.0 to 1.0)
  double get progressToNextLevel {
    if (xpRequiredForNextLevel == 0) return 1.0;
    return (currentXP / xpRequiredForNextLevel).clamp(0.0, 1.0);
  }

  /// Get remaining XP to next level
  int get xpToNextLevel =>
      (xpRequiredForNextLevel - currentXP).clamp(0, xpRequiredForNextLevel);

  UserStats copyWith({
    int? currentLevel,
    int? currentXP,
    int? totalGold,
    AvatarStage? stage,
    Map<String, String>? equippedItems,
    List<String>? purchasedItemIds,
  }) {
    return UserStats(
      currentLevel: currentLevel ?? this.currentLevel,
      currentXP: currentXP ?? this.currentXP,
      totalGold: totalGold ?? this.totalGold,
      stage: stage ?? this.stage,
      equippedItems: equippedItems ?? this.equippedItems,
      purchasedItemIds: purchasedItemIds ?? this.purchasedItemIds,
    );
  }

  @override
  List<Object?> get props => [
    currentLevel,
    currentXP,
    totalGold,
    stage,
    equippedItems,
    purchasedItemIds,
  ];
}
