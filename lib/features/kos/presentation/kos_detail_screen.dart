import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/kos_load_result.dart';
import '../data/kos_repository.dart';
import '../models/kos.dart';
import 'kos_detail_provider.dart';

class KosDetailScreen extends StatelessWidget {
  const KosDetailScreen({super.key, required this.kosId});

  final String kosId;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<KosRepository>();

    return ChangeNotifierProvider(
      create: (_) => KosDetailProvider(repository, kosId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Detail Kos')),
        body: Consumer<KosDetailProvider>(
          builder: (context, provider, _) {
            final state = provider.state;

            return switch (state.status) {
              KosLoadStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
              KosLoadStatus.notFound => _DetailMessage(
                icon: Icons.search_off_outlined,
                message: 'Kos tidak ditemukan.',
                actionLabel: 'Kembali',
                onAction: () => Navigator.pop(context),
              ),
              KosLoadStatus.error => _DetailMessage(
                icon: Icons.cloud_off_outlined,
                message: state.message ?? 'Tidak dapat memuat detail kos.',
                actionLabel: 'Coba lagi',
                onAction: provider.load,
              ),
              KosLoadStatus.empty => _DetailMessage(
                icon: Icons.search_off_outlined,
                message: 'Kos tidak ditemukan.',
                actionLabel: 'Kembali',
                onAction: () => Navigator.pop(context),
              ),
              KosLoadStatus.success => _KosDetail(kos: state.data!),
            };
          },
        ),
      ),
    );
  }
}

class _KosDetail extends StatelessWidget {
  const _KosDetail({required this.kos});

  final Kos kos;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(kos.name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(kos.addressArea),
        const SizedBox(height: 20),
        _DetailRow(label: 'Harga', value: _formatPrice(kos.priceMonthly)),
        _DetailRow(label: 'Status', value: kos.status),
        _DetailRow(
          label: 'Kamar tersedia',
          value: '${kos.availableRooms} dari ${kos.totalRooms}',
        ),
        _DetailRow(
          label: 'Fasilitas',
          value: kos.facilities.isEmpty
              ? 'Belum ada fasilitas'
              : kos.facilities.join(', '),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(value),
          ],
        ),
      ),
    );
  }
}

class _DetailMessage extends StatelessWidget {
  const _DetailMessage({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

String _formatPrice(int price) {
  final digits = price.toString();
  final formatted = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    formatted.write(digits[i]);
    if (i < digits.length - 1 && (digits.length - i - 1) % 3 == 0) {
      formatted.write('.');
    }
  }

  return 'Rp $formatted / bulan';
}
