import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../item_model.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/item_card.dart';
import '../widgets/item_form_sheet.dart';
import '../widgets/sort_sheet.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage>
    with SingleTickerProviderStateMixin {
  // ── Data state ─────────────────────────────────────────────────────────────
  List<ItemModel> _allItems = [];
  List<ItemModel> _filteredItems = [];
  SortOrder _sortOrder = SortOrder.newest;
  bool _isLoading = true;

  // ── Search state ───────────────────────────────────────────────────────────
  bool _isSearchVisible = false;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  // ── Search bar animation ───────────────────────────────────────────────────
  late final AnimationController _searchAnimCtrl;
  late final Animation<double> _searchAnim;

  // ── Seed data (used on first launch only) ──────────────────────────────────
  static final List<ItemModel> _seed = [
    ItemModel(
      id: 1,
      name: 'Laptop Gaming',
      description: 'Laptop berperforma tinggi untuk gaming & desain grafis.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    ItemModel(
      id: 2,
      name: 'Mouse Wireless',
      description: 'Mouse ergonomis dengan koneksi 2.4 GHz, baterai 12 bulan.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    ItemModel(
      id: 3,
      name: 'Keyboard Mechanical',
      description: 'Keyboard with RGB backlight dan switch Cherry MX Red.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ItemModel(
      id: 4,
      name: 'Monitor 4K',
      description: 'Monitor IPS 27 inci, 144 Hz, sRGB 99%.',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _searchAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _searchAnim = CurvedAnimation(
      parent: _searchAnimCtrl,
      curve: Curves.easeInOut,
    );
    _loadAll();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _searchAnimCtrl.dispose();
    super.dispose();
  }

  // ── Persistence ────────────────────────────────────────────────────────────

  Future<void> _loadAll() async {
    final storage = StorageService.instance;
    // Load items and sort-order concurrently.
    final results = await Future.wait([
      storage.loadItems(),
      storage.loadSortOrder(),
    ]);

    if (!mounted) return;

    final items = results[0] as List<ItemModel>;
    final order = results[1] as SortOrder;

    if (items.isEmpty) {
      // First launch – seed with demo data and persist it.
      await storage.saveItems(_seed);
      if (!mounted) return;
      _allItems = List.from(_seed);
    } else {
      _allItems = items;
    }

    _sortOrder = order;
    _isLoading = false;
    _applyFilters();
  }

  // ── Filter + sort (pure, synchronous) ─────────────────────────────────────

  void _applyFilters() {
    final query = _searchQuery.toLowerCase().trim();
    var result = List<ItemModel>.from(_allItems);

    if (query.isNotEmpty) {
      result = result.where((item) {
        return item.name.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query);
      }).toList();
    }

    switch (_sortOrder) {
      case SortOrder.nameAsc:
        result.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case SortOrder.nameDesc:
        result.sort(
            (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      case SortOrder.newest:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case SortOrder.oldest:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    setState(() => _filteredItems = result);
  }

  // ── CRUD operations ────────────────────────────────────────────────────────

  Future<void> _addItem(String name, String description) async {
    // Generate a new unique id (max existing id + 1).
    final newId = _allItems.isEmpty
        ? 1
        : (_allItems.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);

    final item = ItemModel(
      id: newId,
      name: name,
      description: description,
      createdAt: DateTime.now(),
    );

    final updated = [..._allItems, item];
    await StorageService.instance.saveItems(updated);

    if (!mounted) return;

    // ✅ Capture ScaffoldMessenger before any re-entrancy can occur.
    final messenger = ScaffoldMessenger.of(context);
    _allItems = updated;
    _applyFilters();

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text('✓  "$name" berhasil ditambahkan'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _editItem(int id, String name, String description) async {
    final updated = _allItems.map((item) {
      if (item.id == id) return item.copyWith(name: name, description: description);
      return item;
    }).toList();

    await StorageService.instance.saveItems(updated);

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    _allItems = updated;
    _applyFilters();

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text('✓  "$name" berhasil diperbarui'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteItem(int id) async {
    // Capture target BEFORE mutation so undo can restore it.
    final target = _allItems.firstWhere((e) => e.id == id);
    final updated = _allItems.where((e) => e.id != id).toList();

    await StorageService.instance.saveItems(updated);

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    _allItems = updated;
    _applyFilters();

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text('"${target.name}" dihapus'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Urungkan',
          textColor: AppColors.primary,
          onPressed: () => _restoreItem(target),
        ),
      ),
    );
  }

  Future<void> _restoreItem(ItemModel item) async {
    // Guard against double-undo.
    if (_allItems.any((e) => e.id == item.id)) return;

    final restored = [..._allItems, item];
    await StorageService.instance.saveItems(restored);

    if (!mounted) return;
    _allItems = restored;
    _applyFilters();
  }

  // ── Sort persistence ───────────────────────────────────────────────────────

  Future<void> _changeSortOrder(SortOrder order) async {
    await StorageService.instance.saveSortOrder(order);
    if (!mounted) return;
    _sortOrder = order;
    _applyFilters();
  }

  // ── UI actions ─────────────────────────────────────────────────────────────

  void _toggleSearch() {
    setState(() => _isSearchVisible = !_isSearchVisible);
    if (_isSearchVisible) {
      _searchAnimCtrl.forward();
      _searchFocus.requestFocus();
    } else {
      _searchAnimCtrl.reverse();
      _searchCtrl.clear();
      _searchQuery = '';
      _applyFilters();
    }
  }

  void _showItemForm({ItemModel? item}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ItemFormSheet(
          item: item,
          // ✅ No BuildContext is captured across the await gap here.
          //    The sheet pops itself first; then _addItem / _editItem runs
          //    on the page context with a mounted-check inside.
          onSave: (name, desc) {
            if (item != null) {
              _editItem(item.id, name, desc);
            } else {
              _addItem(name, desc);
            }
          },
        ),
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SortSheet(
          currentOrder: _sortOrder,
          onOrderChanged: _changeSortOrder,
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildInfoRow(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  // ── Header (title + icon buttons) ─────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 12, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Gradient icon
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 20),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Items',
                  style: GoogleFonts.outfit(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _isLoading
                        ? 'Memuat data…'
                        : '${_allItems.length} item tersimpan',
                    key: ValueKey(_isLoading ? 'loading' : _allItems.length),
                    style: GoogleFonts.outfit(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Sort button
          _HeaderBtn(
            icon: Icons.sort_rounded,
            showBadge: _sortOrder != SortOrder.newest,
            onTap: _showSortSheet,
          ),
          const SizedBox(width: 6),
          // Search toggle
          _HeaderBtn(
            icon: _isSearchVisible
                ? Icons.search_off_rounded
                : Icons.search_rounded,
            onTap: _toggleSearch,
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  // ── Animated search bar ────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return SizeTransition(
      sizeFactor: _searchAnim,
      child: FadeTransition(
        opacity: _searchAnim,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
          child: TextField(
            controller: _searchCtrl,
            focusNode: _searchFocus,
            style: GoogleFonts.outfit(
                color: AppColors.textPrimary, fontSize: 15),
            onChanged: (v) {
              setState(() => _searchQuery = v);
              _applyFilters();
            },
            decoration: InputDecoration(
              hintText: 'Cari nama atau deskripsi item…',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                        _applyFilters();
                      },
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  // ── Info row (count + sort chip) ───────────────────────────────────────────

  Widget _buildInfoRow() {
    if (_isLoading || _allItems.isEmpty) {
      return const SizedBox(height: 18);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _searchQuery.isNotEmpty
                  ? '${_filteredItems.length} hasil untuk "$_searchQuery"'
                  : '${_filteredItems.length} item',
              style: GoogleFonts.outfit(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ),
          GestureDetector(
            onTap: _showSortSheet,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.swap_vert_rounded,
                      size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 5),
                  Text(
                    _sortOrder.label,
                    style: GoogleFonts.outfit(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Main body ──────────────────────────────────────────────────────────────

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: _buildListContent(),
    );
  }

  Widget _buildListContent() {
    if (_allItems.isEmpty) {
      return EmptyStateWidget(
        key: const ValueKey('empty_no_items'),
        type: EmptyStateType.noItems,
        onAction: _showItemForm,
      );
    }

    if (_filteredItems.isEmpty) {
      return const EmptyStateWidget(
        key: ValueKey('empty_no_results'),
        type: EmptyStateType.noSearchResults,
      );
    }

    return ListView.builder(
      key: const ValueKey('list'),
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 110),
      itemCount: _filteredItems.length,
      itemBuilder: (_, index) {
        final item = _filteredItems[index];
        return ItemCard(
          key: ValueKey(item.id),
          item: item,
          index: index,
          onEdit: () => _showItemForm(item: item),
          onDelete: () => _deleteItem(item.id),
        );
      },
    );
  }

  // ── FAB ────────────────────────────────────────────────────────────────────

  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: _showItemForm,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      icon: const Icon(Icons.add_rounded, size: 22),
      label: Text(
        'Tambah',
        style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    );
  }
}

// ── Reusable header icon button ─────────────────────────────────────────────

class _HeaderBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool showBadge;

  const _HeaderBtn({
    required this.icon,
    required this.onTap,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon),
          color: AppColors.textSecondary,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.cardBorder),
            ),
            padding: const EdgeInsets.all(10),
            minimumSize: const Size(42, 42),
          ),
        ),
        if (showBadge)
          Positioned(
            top: 7,
            right: 7,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
