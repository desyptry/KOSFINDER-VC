import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../kos/models/kos.dart';
import '../data/owner_kos_repository.dart';
import '../providers/owner_kos_provider.dart';
import 'owner_kos_form_screen.dart';

class OwnerKosListScreen extends StatelessWidget {
  const OwnerKosListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<OwnerKosProvider>(
        builder: (context, provider, _) {
          final state = provider.state;
          final content = switch (state.status) {
            OwnerKosStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            OwnerKosStatus.empty => _OwnerMessage(
              message: 'Anda belum memiliki kos.',
              action: () => _addKos(context, provider),
            ),
            OwnerKosStatus.error => _OwnerMessage(
              message: state.message ?? 'Kos milik Anda gagal dimuat.',
              action: provider.load,
              actionLabel: 'Coba lagi',
            ),
            OwnerKosStatus.success => _KosItems(kosList: state.data),
          };
          return Stack(
            children: [
              content,
              if (provider.isDeleting)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x66000000),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('owner-add-kos'),
        onPressed: () => _addKos(context, context.read<OwnerKosProvider>()),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kos'),
      ),
    );
  }

  Future<void> _addKos(BuildContext context, OwnerKosProvider provider) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => OwnerKosFormScreen(
          onSave: (draft) => provider.saveDraft(draft: draft),
        ),
      ),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kos berhasil disimpan.')));
    }
  }
}

class _KosItems extends StatelessWidget {
  const _KosItems({required this.kosList});

  final List<Kos> kosList;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: kosList.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final kos = kosList[index];
        return Card(
          child: ListTile(
            title: Text(kos.name),
            subtitle: Text(
              '${kos.addressArea}\nRp ${kos.priceMonthly} / bulan • ${kos.status}',
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  key: Key('owner-edit-${kos.id}'),
                  onPressed: () => _editKos(context, kos),
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit',
                ),
                IconButton(
                  key: Key('owner-delete-${kos.id}'),
                  onPressed: () => _confirmDelete(context, kos),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Hapus',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editKos(BuildContext context, Kos kos) async {
    final provider = context.read<OwnerKosProvider>();
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => OwnerKosFormScreen(
          initialKos: kos,
          onSave: (draft) => provider.saveDraft(draft: draft, existingKos: kos),
        ),
      ),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kos berhasil diperbarui.')));
    }
  }

  Future<void> _confirmDelete(BuildContext context, Kos kos) async {
    final provider = context.read<OwnerKosProvider>();
    if (provider.isDeleting) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus kos?'),
        content: Text('Kos "${kos.name}" akan dihapus.'),
        actions: [
          TextButton(
            key: const Key('owner-delete-cancel'),
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            key: const Key('owner-delete-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await provider.deleteKos(kos.id);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Kos berhasil dihapus.')));
      }
    } on OwnerKosException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }
}

class _OwnerMessage extends StatelessWidget {
  const _OwnerMessage({
    required this.message,
    required this.action,
    this.actionLabel = 'Tambah Kos',
  });

  final String message;
  final VoidCallback action;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: action, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
