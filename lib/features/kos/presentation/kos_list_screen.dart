import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/kos_load_result.dart';
import '../data/kos_repository.dart';
import '../models/kos.dart';
import '../providers/kos_filter_provider.dart';
import 'kos_detail_screen.dart';
import 'kos_filter_panel.dart';

class KosListScreen extends StatelessWidget {
  const KosListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<KosRepository?>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('KosFinder'),
        actions: [
          IconButton(
            key: const Key('about-button'),
            onPressed: () => Navigator.pushNamed(context, '/about'),
            icon: const Icon(Icons.info_outline),
            tooltip: 'About',
          ),
        ],
      ),
      body: repository == null
          ? const _ConfigurationError()
          : ChangeNotifierProvider(
              create: (_) => KosFilterProvider(repository),
              child: const Column(
                children: [
                  KosFilterPanel(),
                  Expanded(child: _KosListBody()),
                ],
              ),
            ),
    );
  }
}

class _ConfigurationError extends StatelessWidget {
  const _ConfigurationError();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Konfigurasi Supabase belum tersedia.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _KosListBody extends StatelessWidget {
  const _KosListBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<KosFilterProvider>(
      builder: (context, provider, _) {
        final state = provider.state;

        return switch (state.status) {
          KosLoadStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          KosLoadStatus.empty => const _MessageState(
            icon: Icons.home_work_outlined,
            message: 'Belum ada kos yang tersedia.',
          ),
          KosLoadStatus.error => _MessageState(
            icon: Icons.cloud_off_outlined,
            message: state.message ?? 'Tidak dapat memuat daftar kos.',
            actionLabel: 'Coba lagi',
            onAction: provider.load,
          ),
          KosLoadStatus.notFound => const _MessageState(
            icon: Icons.search_off_outlined,
            message: 'Kos tidak ditemukan.',
          ),
          KosLoadStatus.success => _KosList(
            kosList: state.data ?? const <Kos>[],
          ),
        };
      },
    );
  }
}

class _KosList extends StatelessWidget {
  const _KosList({required this.kosList});

  final List<Kos> kosList;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: kosList.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final kos = kosList[index];
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(kos.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(kos.addressArea),
                Text(_formatPrice(kos.priceMonthly)),
                Text('${kos.availableRooms} kamar tersedia • ${kos.status}'),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => KosDetailScreen(kosId: kos.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

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
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
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
