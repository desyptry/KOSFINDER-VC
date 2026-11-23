import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/kos_filter_provider.dart';

class KosFilterPanel extends StatefulWidget {
  const KosFilterPanel({super.key});

  static const facilityOptions = ['AC', 'WiFi', 'Kamar Mandi Dalam'];

  @override
  State<KosFilterPanel> createState() => _KosFilterPanelState();
}

class _KosFilterPanelState extends State<KosFilterPanel> {
  final _areaController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _selectedFacilities = <String>{};

  @override
  void dispose() {
    _areaController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<KosFilterProvider>();

    return ExpansionTile(
      key: const Key('filter-panel'),
      initiallyExpanded: false,
      leading: const Icon(Icons.tune),
      title: const Text('Filter kos'),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        TextField(
          key: const Key('area-filter'),
          controller: _areaController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Wilayah',
            hintText: 'Contoh: Singaraja',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('min-price-filter'),
                controller: _minPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga minimum',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                key: const Key('max-price-filter'),
                controller: _maxPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga maksimum',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: KosFilterPanel.facilityOptions.map((facility) {
              final selected = _selectedFacilities.contains(facility);
              return FilterChip(
                key: Key('facility-$facility'),
                label: Text(facility),
                selected: selected,
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _selectedFacilities.add(facility);
                    } else {
                      _selectedFacilities.remove(facility);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                key: const Key('apply-filter'),
                onPressed: () => _apply(provider),
                child: const Text('Terapkan filter'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                key: const Key('reset-filter'),
                onPressed: () => _reset(provider),
                child: const Text('Reset'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _apply(KosFilterProvider provider) {
    provider.setArea(_areaController.text);
    provider.setPriceRange(
      _parsePrice(_minPriceController.text),
      _parsePrice(_maxPriceController.text),
    );
    provider.setFacilities(_selectedFacilities.toList(growable: false));
    provider.apply();
  }

  void _reset(KosFilterProvider provider) {
    setState(() {
      _areaController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      _selectedFacilities.clear();
    });
    provider.clear();
  }
}

int? _parsePrice(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  return int.tryParse(trimmed.replaceAll('.', '').replaceAll(',', ''));
}
