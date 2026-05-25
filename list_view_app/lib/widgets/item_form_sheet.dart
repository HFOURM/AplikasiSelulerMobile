import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../item_model.dart';
import '../theme/app_theme.dart';

/// Modal bottom sheet for adding OR editing an [ItemModel].
///
/// Anti-pattern fix: The sheet pops itself *before* invoking [onSave], so
/// [onSave] can safely use the page's [BuildContext] without worrying about
/// the dialog being mounted.
class ItemFormSheet extends StatefulWidget {
  /// Pass an existing item to enter edit-mode; pass null to enter add-mode.
  final ItemModel? item;

  /// Called with (name, description) after the user confirms.
  /// The sheet will already be dismissed by the time this fires.
  final void Function(String name, String description) onSave;

  const ItemFormSheet({super.key, this.item, required this.onSave});

  @override
  State<ItemFormSheet> createState() => _ItemFormSheetState();
}

class _ItemFormSheetState extends State<ItemFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  final _formKey = GlobalKey<FormState>();

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.item?.name);
    _descCtrl = TextEditingController(text: widget.item?.description);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    // ✅ Dismiss the sheet FIRST using its own BuildContext, then run the
    //    async callback on the parent page — eliminates "use BuildContext
    //    across async gaps" completely.
    Navigator.of(context).pop();
    widget.onSave(name, desc);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Handle bar ────────────────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Title ─────────────────────────────────────────────────────
            Text(
              _isEdit ? 'Edit Item' : 'Tambah Item Baru',
              style: GoogleFonts.outfit(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _isEdit
                  ? 'Perbarui informasi item di bawah ini.'
                  : 'Isi form di bawah untuk menambahkan item baru.',
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),

            // ── Name field ────────────────────────────────────────────────
            TextFormField(
              controller: _nameCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.outfit(
                  color: AppColors.textPrimary, fontSize: 15),
              decoration: const InputDecoration(
                labelText: 'Nama Item',
                hintText: 'Contoh: Laptop Gaming',
                prefixIcon: Icon(Icons.label_outline_rounded),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Nama item tidak boleh kosong';
                }
                if (v.trim().length < 2) {
                  return 'Nama item minimal 2 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Description field ─────────────────────────────────────────
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              style: GoogleFonts.outfit(
                  color: AppColors.textPrimary, fontSize: 15),
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Deskripsi singkat item ini…',
                prefixIcon: Padding(
                  // Align icon to the first line of the multiline field.
                  padding: EdgeInsets.only(bottom: 48),
                  child: Icon(Icons.description_outlined),
                ),
                alignLabelWithHint: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Deskripsi tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),

            // ── Save button ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _isEdit ? 'Simpan Perubahan' : 'Tambah Item',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
