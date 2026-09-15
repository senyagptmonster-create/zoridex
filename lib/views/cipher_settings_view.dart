import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ui/cipher_tokens.dart';
import '../viewmodels/vault_security_viewmodel.dart';

class CipherSettingsView extends StatelessWidget {
  const CipherSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VaultSecurityViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('SETTINGS')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Auto-lock section
          _SectionHeader('AUTO-LOCK TIMEOUT'),
          const SizedBox(height: 10),
          _SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lock vault after inactivity',
                  style: TextStyle(
                    fontFamily: CipherTypography.fontFamily,
                    fontSize: 12,
                    color: CipherPalette.kInk,
                  ),
                ),
                const SizedBox(height: 14),
                _AutoLockDropdown(
                  current: vm.autoLockMinutes,
                  onChanged: (v) => vm.setAutoLock(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Danger zone
          _SectionHeader('DANGER ZONE'),
          const SizedBox(height: 10),
          _SettingsCard(
            glowColor: const Color(0x22FF3D3D),
            borderColor: const Color(0x44FF3D3D),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Clear All Vault Entries',
                  style: TextStyle(
                    fontFamily: CipherTypography.fontFamily,
                    fontSize: 12,
                    color: CipherPalette.kInk,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Permanently deletes all saved passwords. This action cannot be undone.',
                  style: TextStyle(
                    fontFamily: CipherTypography.fontFamily,
                    fontSize: 10,
                    color: CipherPalette.kInk.withAlpha(120),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete_sweep, size: 16),
                    label: const Text('CLEAR ALL ENTRIES'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3D3D),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _confirmClear(context, vm),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About
          _SectionHeader('ABOUT'),
          const SizedBox(height: 10),
          _SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: CipherPalette.kBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: CipherPalette.kAccent.withAlpha(80)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x2200E5FF),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.security,
                        color: CipherPalette.kAccent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ZORIDEX',
                          style: TextStyle(
                            fontFamily: CipherTypography.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: CipherPalette.kAccent,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          'v1.0.0  •  org.zoridex.cipher.vault',
                          style: TextStyle(
                            fontFamily: CipherTypography.fontFamily,
                            fontSize: 9,
                            color: CipherPalette.kAccent2,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: CipherPalette.kEdge),
                const SizedBox(height: 12),
                _AboutRow(
                  icon: Icons.shield_outlined,
                  label: 'Security Model',
                  value: 'XOR + Base64 offline storage',
                ),
                const SizedBox(height: 8),
                _AboutRow(
                  icon: Icons.wifi_off,
                  label: 'Connectivity',
                  value: '100% offline — no data leaves device',
                ),
                const SizedBox(height: 8),
                _AboutRow(
                  icon: Icons.analytics_outlined,
                  label: 'Entropy Engine',
                  value: 'Shannon entropy  H = L × log₂(N)',
                ),
                const SizedBox(height: 8),
                _AboutRow(
                  icon: Icons.lock_outline,
                  label: 'Persistence',
                  value: 'SharedPreferences (local JSON)',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClear(
      BuildContext context, VaultSecurityViewModel vm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: CipherPalette.kSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0x44FF3D3D)),
        ),
        title: const Text(
          'CLEAR VAULT',
          style: TextStyle(
            fontFamily: CipherTypography.fontFamily,
            fontSize: 14,
            color: Color(0xFFFF3D3D),
            letterSpacing: 1.5,
          ),
        ),
        content: const Text(
          'This will permanently delete ALL vault entries. Are you absolutely sure?',
          style: TextStyle(
            fontFamily: CipherTypography.fontFamily,
            color: CipherPalette.kInk,
            fontSize: 12,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3D3D),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CLEAR ALL'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await vm.clearAll();
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: CipherTypography.fontFamily,
        fontSize: 10,
        color: CipherPalette.kAccent2,
        letterSpacing: 2,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.child,
    this.glowColor = const Color(0x1A00E5FF),
    this.borderColor = CipherPalette.kEdge,
  });

  final Widget child;
  final Color glowColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CipherPalette.kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AutoLockDropdown extends StatelessWidget {
  const _AutoLockDropdown({
    required this.current,
    required this.onChanged,
  });

  final int current;
  final ValueChanged<int> onChanged;

  static const _options = [1, 5, 15, 30];
  static const _labels = ['1 minute', '5 minutes', '15 minutes', '30 minutes'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: CipherPalette.kBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CipherPalette.kEdge),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          dropdownColor: CipherPalette.kSurface,
          value: current,
          style: const TextStyle(
            fontFamily: CipherTypography.fontFamily,
            fontSize: 12,
            color: CipherPalette.kInk,
          ),
          icon: const Icon(Icons.expand_more, color: CipherPalette.kAccent2, size: 18),
          items: List.generate(
            _options.length,
            (i) => DropdownMenuItem(
              value: _options[i],
              child: Text(_labels[i]),
            ),
          ),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: CipherPalette.kAccent2, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: CipherTypography.fontFamily,
                  fontSize: 10,
                  color: CipherPalette.kAccent2,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: CipherTypography.fontFamily,
                  fontSize: 11,
                  color: CipherPalette.kInk,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
