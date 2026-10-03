import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:online_food_ordering/core/providers/restaurant_profile_provider.dart';
import 'package:online_food_ordering/core/config/supabase_config.dart';
import 'package:online_food_ordering/services/storage/supabase_storage_service.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _taglineController;
  late TextEditingController _addressController;
  late TextEditingController _minOrderController;
  late TextEditingController _deliveryFeeController;
  late TextEditingController _estTimeController;
  
  String _openTime = '09:00';
  String _closeTime = '22:00';
  bool _isClosed = false;
  
  String? _logoUrl;
  bool _isLoading = false;

  final _storage = SupabaseStorageService();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _taglineController = TextEditingController();
    _addressController = TextEditingController();
    _minOrderController = TextEditingController();
    _deliveryFeeController = TextEditingController();
    _estTimeController = TextEditingController();
  }

  void _populateFields(dynamic profile) {
    if (profile == null) return;
    _nameController.text = profile.name;
    _taglineController.text = profile.tagline;
    _addressController.text = profile.address;
    _minOrderController.text = profile.minOrderValue.toString();
    _deliveryFeeController.text = profile.defaultDeliveryFee.toString();
    _estTimeController.text = profile.defaultEstimatedTime;
    _openTime = profile.openTimeStr;
    _closeTime = profile.closeTimeStr;
    _isClosed = profile.isTemporarilyClosed;
    _logoUrl = profile.logoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    _addressController.dispose();
    _minOrderController.dispose();
    _deliveryFeeController.dispose();
    _estTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadLogo() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 70,
      maxWidth: 512,
    );
    if (image == null) return;

    setState(() => _isLoading = true);
    try {
      String url;
      final fileName = 'logo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        url = await _storage.uploadImageWeb(bytes, fileName, 'branding', 'logo');
      } else {
        url = await _storage.uploadBrandingImage(image.path, 'logo');
      }
      
      setState(() => _logoUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logo upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAll() async {
    setState(() => _isLoading = true);
    try {
      await SupabaseConfig.client.from('restaurant_settings').update({
        'name': _nameController.text,
        'tagline': _taglineController.text,
        'address': _addressController.text,
        'min_order_value': double.tryParse(_minOrderController.text) ?? 20.0,
        'default_delivery_fee': double.tryParse(_deliveryFeeController.text) ?? 2.0,
        'default_estimated_time': _estTimeController.text,
        'open_time_str': _openTime,
        'close_time_str': _closeTime,
        'is_temporarily_closed': _isClosed,
        'logo_url': _logoUrl,
      }).eq('id', 1);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings published successfully!'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(restaurantProfileProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Elite Store Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          if (_isLoading)
            const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (_nameController.text.isEmpty) _populateFields(profile);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    _buildBrandingSection(primaryColor),
                    const SizedBox(height: 32),
                    _buildOperationsSection(primaryColor),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveAll,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Save & Publish to App', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildBrandingSection(Color primaryColor) {
    return _buildCard('Restaurant Identity', [
      Row(
        children: [
          GestureDetector(
            onTap: () => _pickAndUploadLogo(),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage: _logoUrl != null ? CachedNetworkImageProvider(_logoUrl!) : null,
                  child: _logoUrl == null ? const Icon(Icons.store_rounded, color: Colors.grey, size: 40) : null,
                ),
                Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white))),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [
                _buildField('Restaurant Name', _nameController),
                const SizedBox(height: 16),
                _buildField('Tagline', _taglineController),
              ],
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _buildOperationsSection(Color primaryColor) {
    return _buildCard('Business Operations', [
      _buildField('Store Address', _addressController, icon: Icons.location_on_outlined),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(child: _buildField('Min Order (\$)', _minOrderController, icon: Icons.shopping_bag_outlined, isNum: true)),
          const SizedBox(width: 16),
          Expanded(child: _buildField('Delivery Fee (\$)', _deliveryFeeController, icon: Icons.delivery_dining_rounded, isNum: true)),
        ],
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(child: _buildField('Est. Time', _estTimeController, icon: Icons.timer_outlined, hint: 'e.g. 30-40 min')),
          const SizedBox(width: 16),
          Expanded(
            child: SwitchListTile(
              title: const Text('Temp. Closed', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              value: _isClosed,
              onChanged: (v) => setState(() => _isClosed = v),
              activeThumbColor: Colors.redAccent,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      const Text('Operating Hours', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(child: _buildTimeInput('Opening', _openTime, (v) => setState(() => _openTime = v))),
          const SizedBox(width: 16),
          Expanded(child: _buildTimeInput('Closing', _closeTime, (v) => setState(() => _closeTime = v))),
        ],
      ),
    ]);
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 10))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, {IconData? icon, bool isNum = false, String? hint}) {
    return TextField(
      controller: controller,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label, hintText: hint, prefixIcon: icon != null ? Icon(icon, size: 20) : null, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200))),
    );
  }

  Widget _buildTimeInput(String label, String val, Function(String) onSet) {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
        if (time != null) onSet('${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(val, style: const TextStyle(fontWeight: FontWeight.bold)), const Icon(Icons.access_time, size: 18, color: Colors.grey)]),
      ),
    );
  }
}
