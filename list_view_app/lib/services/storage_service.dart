import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../item_model.dart';

/// All available sort orders for the item list.
/// Uses enhanced enum syntax (Dart 2.17+) to embed a display label.
enum SortOrder {
  nameAsc('A → Z'),
  nameDesc('Z → A'),
  newest('Terbaru'),
  oldest('Terlama');

  const SortOrder(this.label);
  final String label;
}

/// Centralised persistence layer.
///
/// All SharedPreferences I/O is isolated here so that UI code never
/// imports [SharedPreferences] directly. Using a singleton with lazy
/// initialisation avoids calling [SharedPreferences.getInstance] on every
/// read/write (each call re-opens the backing store on some platforms).
class StorageService {
  // ----- Keys ---------------------------------------------------------------
  static const _itemsKey = 'items_list_v2';
  static const _sortOrderKey = 'sort_order_v2';

  // ----- Singleton ----------------------------------------------------------
  StorageService._();
  static final StorageService instance = StorageService._();

  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ----- Items --------------------------------------------------------------

  /// Loads the persisted item list. Returns an empty list on first launch or
  /// if the stored data is corrupted (graceful degradation).
  Future<List<ItemModel>> loadItems() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_itemsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((e) => ItemModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Corrupted data – reset gracefully instead of crashing.
      return [];
    }
  }

  /// Persists the full item list atomically.
  Future<void> saveItems(List<ItemModel> items) async {
    final prefs = await _getPrefs();
    await prefs.setString(
      _itemsKey,
      json.encode(items.map((e) => e.toMap()).toList()),
    );
  }

  // ----- Sort Order ---------------------------------------------------------

  Future<SortOrder> loadSortOrder() async {
    final prefs = await _getPrefs();
    final value = prefs.getString(_sortOrderKey);
    return SortOrder.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SortOrder.newest,
    );
  }

  Future<void> saveSortOrder(SortOrder order) async {
    final prefs = await _getPrefs();
    await prefs.setString(_sortOrderKey, order.name);
  }
}
