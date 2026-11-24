import 'package:flutter/material.dart';

import '../../kos/models/kos.dart';
import '../providers/owner_kos_provider.dart';

class OwnerKosFormScreen extends StatefulWidget {
  const OwnerKosFormScreen({
    super.key,
    this.initialKos,
    this.onDraftCreated,
    this.onSave,
  });

  final Kos? initialKos;
  final ValueChanged<OwnerKosDraft>? onDraftCreated;
  final Future<void> Function(OwnerKosDraft draft)? onSave;

  bool get isEditing => initialKos != null;

  @override
  State<OwnerKosFormScreen> createState() => _OwnerKosFormScreenState();
}

class _OwnerKosFormScreenState extends State<OwnerKosFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _areaController;
  late final TextEditingController _priceController;
  late final TextEditingController _facilitiesController;
  late final TextEditingController _totalRoomsController;
  late final TextEditingController _availableRoomsController;
  bool _draftCreated = false;
  bool _isSaving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    final kos = widget.initialKos;
    _nameController = TextEditingController(text: kos?.name);
    _areaController = TextEditingController(text: kos?.addressArea);
    _priceController = TextEditingController(
      text: kos?.priceMonthly.toString(),
    );
    _facilitiesController = TextEditingController(
      text: kos?.facilities.join(', '),
    );
    _totalRoomsController = TextEditingController(
      text: kos?.totalRooms.toString(),
    );
    _availableRoomsController = TextEditingController(
      text: kos?.availableRooms.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _priceController.dispose();
    _facilitiesController.dispose();
    _totalRoomsController.dispose();
    _availableRoomsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final draft = OwnerKosDraft(
      name: _nameController.text.trim(),
      addressArea: _areaController.text.trim(),
      priceMonthly: int.parse(_priceController.text.trim()),
      facilities: _facilitiesController.text
          .split(',')
          .map((facility) => facility.trim())
          .where((facility) => facility.isNotEmpty)
          .toList(growable: false),
      totalRooms: int.parse(_totalRoomsController.text.trim()),
      availableRooms: int.parse(_availableRoomsController.text.trim()),
    );
    widget.onDraftCreated?.call(draft);
    if (widget.onSave == null) {
      setState(() => _draftCreated = true);
      return;
    }

    setState(() {
      _isSaving = true;
      _saveError = null;
    });
    try {
      await widget.onSave!(draft);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } on Exception catch (error) {
      if (mounted) {
        setState(() => _saveError = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Edit Kos' : 'Tambah Kos')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              key: const Key('owner-kos-name'),
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama kos'),
              validator: (value) =>
                  OwnerKosFormValidation.requiredText(value, 'Nama kos'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('owner-kos-area'),
              controller: _areaController,
              decoration: const InputDecoration(labelText: 'Alamat/wilayah'),
              validator: (value) =>
                  OwnerKosFormValidation.requiredText(value, 'Alamat/wilayah'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('owner-kos-price'),
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga per bulan'),
              validator: (value) =>
                  OwnerKosFormValidation.nonNegativeInteger(value, 'Harga'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('owner-kos-total-rooms'),
              controller: _totalRoomsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Total kamar'),
              validator: (value) =>
                  OwnerKosFormValidation.positiveInteger(value, 'Total kamar'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('owner-kos-available-rooms'),
              controller: _availableRoomsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Kamar tersedia'),
              validator: (value) => OwnerKosFormValidation.availableRooms(
                value,
                _totalRoomsController.text,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('owner-kos-facilities'),
              controller: _facilitiesController,
              decoration: const InputDecoration(
                labelText: 'Fasilitas',
                hintText: 'Pisahkan dengan koma, contoh: WiFi, AC',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('owner-kos-submit'),
              onPressed: _isSaving ? null : _submit,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.isEditing ? 'Simpan Perubahan' : 'Simpan Kos'),
            ),
            if (_saveError != null) ...[
              const SizedBox(height: 16),
              Text(
                _saveError!,
                key: const Key('owner-kos-save-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (_draftCreated) ...[
              const SizedBox(height: 16),
              const Text(
                'Draft kos sudah dibuat, tetapi penyimpanan backend belum '
                'diaktifkan.',
                key: Key('owner-kos-draft-message'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
