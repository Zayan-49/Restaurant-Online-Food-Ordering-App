import 'package:flutter/material.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.getAdaptiveSize(context, mobile: 16, tablet: 24, desktop: 32);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        title: const Text('Privacy & Security', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: ResponsiveHelper.getMaxWidth(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  context,
                  'Account Security',
                  [
                    _buildTile(Icons.lock_outline_rounded, 'Change Password', 'Update your account password regularly.'),
                    _buildTile(Icons.phonelink_lock_rounded, 'Two-Factor Authentication', 'Add an extra layer of security to your account.'),
                  ],
                ),
                const SizedBox(height: 32),
                _buildSection(
                  context,
                  'Data & Privacy',
                  [
                    _buildTile(Icons.data_usage_rounded, 'Personal Data', 'Manage what data we collect and how we use it.'),
                    _buildTile(Icons.delete_forever_rounded, 'Request Account Deletion', 'Permanently delete your account and all associated data.'),
                  ],
                ),
                const SizedBox(height: 32),
                _buildSection(
                  context,
                  'Legal',
                  [
                    _buildTile(Icons.description_outlined, 'Terms of Service', 'Read our rules and regulations for using the app.'),
                    _buildTile(Icons.privacy_tip_outlined, 'Privacy Policy', 'Learn more about how we protect your privacy.'),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      onTap: () {},
    );
  }
}
