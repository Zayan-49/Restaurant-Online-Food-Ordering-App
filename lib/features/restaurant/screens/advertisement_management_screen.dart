import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:online_food_ordering/core/providers/promo_provider.dart';
import 'package:online_food_ordering/core/models/promo_model.dart';

class AdvertisementManagementScreen extends ConsumerStatefulWidget {
  const AdvertisementManagementScreen({super.key});

  @override
  ConsumerState<AdvertisementManagementScreen> createState() => _AdvertisementManagementScreenState();
}

class _AdvertisementManagementScreenState extends ConsumerState<AdvertisementManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final promosAsync = ref.watch(allPromosProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Advertisement Manager', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () => _showAddPromoDialog(context),
            icon: const Icon(Icons.add_photo_alternate_rounded, color: Colors.white),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: promosAsync.when(
        data: (promos) {
          if (promos.isEmpty) {
            return const Center(child: Text('No advertisements created yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: promos.length,
            itemBuilder: (context, index) => _PromoCard(promo: promos[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showAddPromoDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _AddPromoDialog(),
    );
  }
}

class _PromoCard extends ConsumerWidget {
  const _PromoCard({required this.promo});
  final PromoModel promo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: promo.imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey.shade100, child: const Center(child: CircularProgressIndicator())),
                errorWidget: (context, url, error) => Container(
                  height: 160,
                  color: Colors.grey.shade200,
                  child: const Center(child: Icon(Icons.broken_image_outlined, size: 40)),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Switch(
                  value: promo.isActive,
                  onChanged: (val) => ref.read(promoActionsProvider).togglePromoStatus(promo.id, val),
                  activeColor: Colors.green,
                ),
              ),
            ],
          ),
          ListTile(
            title: Text(promo.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(promo.subtitle, style: const TextStyle(fontSize: 12)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => ref.read(promoActionsProvider).deletePromo(promo.id),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPromoDialog extends ConsumerStatefulWidget {
  const _AddPromoDialog();

  @override
  ConsumerState<_AddPromoDialog> createState() => _AddPromoDialogState();
}

class _AddPromoDialogState extends ConsumerState<_AddPromoDialog> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  String? _pickedPath;
  Uint8List? _webBytes;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pick() async {
    final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return;
    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      setState(() { _webBytes = bytes; _pickedPath = image.name; });
    } else {
      setState(() => _pickedPath = image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return AlertDialog(
      title: const Text('Create Advertisement'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _pick,
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300)),
                child: (_pickedPath == null && _webBytes == null)
                    ? const Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 40)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _webBytes != null 
                          ? Image.memory(_webBytes!, fit: BoxFit.cover) 
                          : Image.file(File(_pickedPath!), fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Promo Title (e.g. MEGA DEAL)')),
            const SizedBox(height: 12),
            TextField(controller: _subtitleController, decoration: const InputDecoration(labelText: 'Subtitle (e.g. 50% Off Today)')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isLoading ? null : () async {
            if (_pickedPath == null && _webBytes == null) return;
            setState(() => _isLoading = true);
            try {
              await ref.read(promoActionsProvider).addPromo(
                title: _titleController.text,
                subtitle: _subtitleController.text,
                localPath: !kIsWeb ? _pickedPath : null,
                webBytes: _webBytes,
                webFileName: _pickedPath,
              );
              if (mounted) Navigator.pop(context);
            } catch (e) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
            } finally {
              if (mounted) setState(() => _isLoading = false);
            }
          },
          child: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
            : const Text('Publish Banner'),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }
}
