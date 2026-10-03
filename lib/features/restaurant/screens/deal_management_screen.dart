import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:online_food_ordering/core/models/food_model.dart';
import 'package:online_food_ordering/features/restaurant/providers/admin_menu_provider.dart';
import 'package:online_food_ordering/features/restaurant/providers/deal_provider.dart';
import 'package:online_food_ordering/core/models/deal_model.dart';

class DealManagementScreen extends ConsumerStatefulWidget {
  const DealManagementScreen({super.key});

  @override
  ConsumerState<DealManagementScreen> createState() => _DealManagementScreenState();
}

class _DealManagementScreenState extends ConsumerState<DealManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final dealsAsync = ref.watch(allDealsProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Bundle Deal Manager', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () => _showCreateDealDialog(context),
            icon: const Icon(Icons.auto_awesome_motion_rounded, color: Colors.white),
            tooltip: 'Create New Combo',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: dealsAsync.when(
        data: (deals) {
          if (deals.isEmpty) {
            return const Center(child: Text('No bundle deals created yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: deals.length,
            itemBuilder: (context, index) => _DealListCard(deal: deals[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showCreateDealDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _CreateDealDialog(),
    );
  }
}

class _DealListCard extends ConsumerWidget {
  const _DealListCard({required this.deal});
  final DealModel deal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: deal.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey.shade100),
              ),
              Positioned(
                top: 15,
                right: 15,
                child: Switch(
                  value: deal.isActive,
                  onChanged: (val) => ref.read(dealActionsProvider).toggleDealStatus(deal.id, val),
                  activeColor: Colors.green,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(deal.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('\$${deal.dealPrice.toStringAsFixed(2)}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(deal.description, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const Divider(height: 32),
                const Text('INCLUDED ITEMS:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: deal.items.map((item) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                    child: Text(item.food?.title ?? 'Unknown Item', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  )).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => ref.read(dealActionsProvider).deleteDeal(deal.id),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Remove Deal'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, side: const BorderSide(color: Colors.redAccent)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateDealDialog extends ConsumerStatefulWidget {
  const _CreateDealDialog();

  @override
  ConsumerState<_CreateDealDialog> createState() => _CreateDealDialogState();
}

class _CreateDealDialogState extends ConsumerState<_CreateDealDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final List<String> _selectedFoodIds = [];
  String? _pickedPath;
  Uint8List? _webBytes;
  bool _isLoading = false;
  final _picker = ImagePicker();


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
    final menuAsync = ref.watch(adminMenuProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return AlertDialog(
      title: const Text('Create Premium Combo Deal'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
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
                          child: _webBytes != null ? Image.memory(_webBytes!, fit: BoxFit.cover) : Image.file(File(_pickedPath!), fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Deal Title (e.g. Duo Feast)')),
              const SizedBox(height: 12),
              TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Short Description')),
              const SizedBox(height: 12),
              TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Deal Price (\$)', prefixIcon: Icon(Icons.attach_money))),
              const SizedBox(height: 24),
              const Align(alignment: Alignment.centerLeft, child: Text('Select Items from Menu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              const SizedBox(height: 12),
              menuAsync.when(
                data: (foods) => Container(
                  constraints: const BoxConstraints(maxHeight: 200), // FIXED: Proper way to set maxHeight for a Container
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: foods.length,
                    itemBuilder: (context, index) {
                      final food = foods[index];
                      final isSelected = _selectedFoodIds.contains(food.id);
                      return CheckboxListTile(
                        title: Text(food.title, style: const TextStyle(fontSize: 14)),
                        subtitle: Text('\$${food.price}', style: const TextStyle(fontSize: 12)),
                        value: isSelected,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) _selectedFoodIds.add(food.id);
                            else _selectedFoodIds.remove(food.id);
                          });
                        },
                      );
                    },
                  ),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, s) => Text('Error: $e'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isLoading ? null : () async {
            if (_selectedFoodIds.isEmpty || (_pickedPath == null && _webBytes == null)) return;
            setState(() => _isLoading = true);
            try {
              await ref.read(dealActionsProvider).createBundleDeal(
                title: _titleController.text,
                description: _descController.text,
                price: double.tryParse(_priceController.text) ?? 0.0,
                selectedFoodIds: _selectedFoodIds,
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
          child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Create Bundle'),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }
}
