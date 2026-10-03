import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/core/responsive/screen_breakpoints.dart';
import 'package:online_food_ordering/core/models/food_model.dart';
import 'package:online_food_ordering/features/restaurant/providers/admin_menu_provider.dart';
import 'package:online_food_ordering/features/restaurant/widgets/admin_menu_tile.dart';
import 'package:online_food_ordering/shared/widgets/shimmer_loaders.dart';
import 'package:online_food_ordering/services/ai/ai_service.dart';

class MenuEditorScreen extends ConsumerStatefulWidget {
  const MenuEditorScreen({super.key});

  @override
  ConsumerState<MenuEditorScreen> createState() => _MenuEditorScreenState();
}

class _MenuEditorScreenState extends ConsumerState<MenuEditorScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final menuAsync = ref.watch(adminMenuProvider);
    final isDesktop = ScreenBreakpoints.isDesktop(context) || ScreenBreakpoints.isLargeDesktop(context);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Menu Management', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () => _showItemDialog(context), icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white)),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(),
            _buildCategoryFilter(),
            Expanded(
              child: menuAsync.when(
                data: (items) {
                  final filteredItems = items.where((item) {
                    final matchesSearch = item.title.toLowerCase().contains(_searchQuery.toLowerCase());
                    final matchesCat = _selectedCategory == 'All' || item.category == _selectedCategory;
                    return matchesSearch && matchesCat;
                  }).toList();

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: ResponsiveHelper.getAdaptivePadding(context, mobileValue: 16, desktopValue: 32),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: ResponsiveHelper.getMaxWidth(context)),
                        child: filteredItems.isEmpty
                            ? _buildEmptyState()
                            : isDesktop ? _buildDesktopGrid(filteredItems) : _buildMobileList(filteredItems),
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(hintText: 'Search your menu...', prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final cats = ['All', 'Burgers', 'Pizza', 'BBQ', 'Desserts', 'Drinks'];
    return Container(
      height: 50,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: cats.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == cats[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cats[index], style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 12)),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedCategory = cats[index]),
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 100), child: Text('No dishes found.', style: TextStyle(color: Colors.grey, fontSize: 16))));
  }

  Widget _buildDesktopGrid(List<FoodModel> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 400, mainAxisExtent: 110, crossAxisSpacing: 16, mainAxisSpacing: 16),
      itemCount: items.length,
      itemBuilder: (context, index) => AdminMenuTile(
        food: items[index],
        onEdit: () => _showItemDialog(context, food: items[index]),
        onDelete: () => _showDeleteConfirm(context, items[index]),
      ).animate().fadeIn(delay: (index * 30).ms).slideX(begin: 0.05),
    );
  }

  Widget _buildMobileList(List<FoodModel> items) {
    return Column(children: items.map((item) => AdminMenuTile(food: item, onEdit: () => _showItemDialog(context, food: item), onDelete: () => _showDeleteConfirm(context, item)).animate().fadeIn()).toList());
  }

  void _showItemDialog(BuildContext context, {FoodModel? food}) {
    showDialog(context: context, barrierDismissible: false, builder: (context) => _MenuFormDialog(food: food));
  }

  void _showDeleteConfirm(BuildContext context, FoodModel food) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dish?'),
        content: Text('Are you sure you want to remove "${food.title}" from the menu?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(adminMenuActionsProvider).deleteItem(food.id);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _MenuFormDialog extends ConsumerStatefulWidget {
  const _MenuFormDialog({this.food});
  final FoodModel? food;

  @override
  ConsumerState<_MenuFormDialog> createState() => _MenuFormDialogState();
}

class _MenuFormDialogState extends ConsumerState<_MenuFormDialog> {
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  late String _selectedCat;
  String? _pickedImagePath;
  Uint8List? _webBytes;
  bool _isLoading = false;
  bool _isGeneratingAI = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.food?.title ?? '');
    _priceController = TextEditingController(text: widget.food?.price.toString() ?? '');
    _descController = TextEditingController(text: widget.food?.description ?? '');
    _selectedCat = widget.food?.category ?? 'Burgers';
    _pickedImagePath = widget.food?.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _generateAIDescription() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a dish name first')));
      return;
    }

    setState(() => _isGeneratingAI = true);
    try {
      // CRITICAL FIX: Passing the text currently in the box as keywords
      final currentKeywords = _descController.text.trim();
      final description = await AIService().generateFoodDescription(
        _titleController.text, 
        keywords: currentKeywords,
      );
      if (description != null) {
        setState(() => _descController.text = description);
      }
    } finally {
      if (mounted) setState(() => _isGeneratingAI = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() { _webBytes = bytes; _pickedImagePath = image.name; });
      } else {
        setState(() => _pickedImagePath = image.path);
      }
    }
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final price = double.tryParse(_priceController.text) ?? 0.0;
      final actions = ref.read(adminMenuActionsProvider);
      if (widget.food != null) {
        await actions.updateItem(widget.food!.id, title: _titleController.text, price: price, category: _selectedCat, description: _descController.text, localPath: !kIsWeb ? _pickedImagePath : null, webBytes: _webBytes, webFileName: _pickedImagePath);
      } else {
        await actions.addItem(title: _titleController.text, price: price, category: _selectedCat, description: _descController.text, localPath: !kIsWeb ? _pickedImagePath : null, webBytes: _webBytes, webFileName: _pickedImagePath);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.food != null ? 'Updated successfully' : 'Added to menu'), behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.food != null;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Dish Details' : 'Add New Luxury Dish'),
      content: SingleChildScrollView(
        clipBehavior: Clip.none,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300, width: 2)),
                    child: (_pickedImagePath == null || _pickedImagePath == '') && _webBytes == null
                        ? GestureDetector(onTap: _pickImage, child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_rounded, color: Colors.grey, size: 28), Text('Add Photo', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))]))
                        : ClipRRect(borderRadius: BorderRadius.circular(18), child: _webBytes != null ? Image.memory(_webBytes!, fit: BoxFit.cover) : (_pickedImagePath!.startsWith('http') || _pickedImagePath!.startsWith('assets/') ? (_pickedImagePath!.startsWith('http') ? CachedNetworkImage(imageUrl: _pickedImagePath!, fit: BoxFit.cover) : Image.asset(_pickedImagePath!, fit: BoxFit.cover)) : Image.file(File(_pickedImagePath!), fit: BoxFit.cover))),
                  ),
                  Positioned(top: -12, right: -12, child: GestureDetector(onTap: _pickImage, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4))]), child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16)))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Dish Name')),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextField(controller: _priceController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Price (\$)'))),
                const SizedBox(width: 16),
                Expanded(child: DropdownButtonFormField<String>(value: _selectedCat, items: ['Burgers', 'Pizza', 'BBQ', 'Desserts', 'Drinks'].map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(), onChanged: (v) => setState(() => _selectedCat = v!), decoration: const InputDecoration(labelText: 'Category'))),
              ],
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: _descController,
                  minLines: 4,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Description / Keywords', 
                    hintText: 'Type keywords and tap magic pen...',
                    alignLabelWithHint: true,
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: _isGeneratingAI 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : IconButton(
                        onPressed: _generateAIDescription,
                        icon: const Icon(Icons.auto_awesome, color: Colors.purpleAccent, size: 20),
                        tooltip: 'Generate with AI',
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _isLoading ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
          child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(isEdit ? 'Update' : 'Add Dish'),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }
}
