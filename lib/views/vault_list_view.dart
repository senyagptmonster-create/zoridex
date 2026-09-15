import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vault_entry_item.dart';
import '../ui/cipher_tokens.dart';
import '../viewmodels/vault_security_viewmodel.dart';

class VaultListView extends StatefulWidget {
  const VaultListView({super.key});

  @override
  State<VaultListView> createState() => _VaultListViewState();
}

class _VaultListViewState extends State<VaultListView> {
  final Set<String> _revealedIds = {};

  Color _scoreColor(int score) {
    if (score < 30) return const Color(0xFFFF3D3D);
    if (score < 55) return const Color(0xFFFF8C00);
    if (score < 75) return const Color(0xFFFFD600);
    return const Color(0xFF00E676);
  }

  String _scoreLabel(int score) {
    if (score < 30) return 'WEAK';
    if (score < 55) return 'FAIR';
    if (score < 75) return 'GOOD';
    return 'STRONG';
  }

  Future<void> _confirmDelete(
      BuildContext context, VaultSecurityViewModel vm, String id, String label) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: CipherPalette.kSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: CipherPalette.kEdge),
        ),
        title: const Text(
          'DELETE ENTRY',
          style: TextStyle(
            fontFamily: CipherTypography.fontFamily,
            color: CipherPalette.kAccent,
            fontSize: 14,
            letterSpacing: 1.5,
          ),
        ),
        content: Text(
          'Delete "$label" from the vault?',
          style: const TextStyle(
            fontFamily: CipherTypography.fontFamily,
            color: CipherPalette.kInk,
            fontSize: 12,
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
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await vm.deleteEntry(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VaultSecurityViewModel>();
    final entries = vm.entries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('VAULT'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: CipherPalette.kAccent),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${entries.length} ENTRIES',
                  style: const TextStyle(
                    fontFamily: CipherTypography.fontFamily,
                    fontSize: 10,
                    color: CipherPalette.kAccent,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: entries.isEmpty
          ? _EmptyVault()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: entries.length,
              itemBuilder: (context, i) {
                final entry = entries[i];
                final revealed = _revealedIds.contains(entry.id);
                return _VaultCard(
                  entry: entry,
                  revealed: revealed,
                  scoreColor: _scoreColor(entry.strengthScore),
                  scoreLabel: _scoreLabel(entry.strengthScore),
                  onTap: () => setState(() {
                    if (revealed) {
                      _revealedIds.remove(entry.id);
                    } else {
                      _revealedIds.add(entry.id);
                    }
                  }),
                  onLongPress: () => _confirmDelete(context, vm, entry.id, entry.label),
                );
              },
            ),
    );
  }
}

class _VaultCard extends StatelessWidget {
  const _VaultCard({
    required this.entry,
    required this.revealed,
    required this.scoreColor,
    required this.scoreLabel,
    required this.onTap,
    required this.onLongPress,
  });

  final VaultEntryItem entry;
  final bool revealed;
  final Color scoreColor;
  final String scoreLabel;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final pw = revealed ? VaultEntryItem.deobfuscate(entry.encryptedValue) : null;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CipherPalette.kSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: revealed ? CipherPalette.kAccent : CipherPalette.kEdge,
            width: revealed ? 1.5 : 1,
          ),
          boxShadow: revealed
              ? const [
                  BoxShadow(
                    color: Color(0x2200E5FF),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.label,
                    style: const TextStyle(
                      fontFamily: CipherTypography.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: CipherPalette.kInk,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: scoreColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: scoreColor.withAlpha(150)),
                  ),
                  child: Text(
                    '$scoreLabel ${entry.strengthScore}',
                    style: TextStyle(
                      fontFamily: CipherTypography.fontFamily,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: revealed
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: CipherPalette.kBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock, color: CipherPalette.kEdge, size: 14),
                    const SizedBox(width: 8),
                    Text(
                      '• • • • • • • • • •',
                      style: TextStyle(
                        fontSize: 12,
                        color: CipherPalette.kInk.withAlpha(80),
                        letterSpacing: 3,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'TAP TO REVEAL',
                      style: TextStyle(
                        fontFamily: CipherTypography.fontFamily,
                        fontSize: 8,
                        color: CipherPalette.kAccent2.withAlpha(150),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              secondChild: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: CipherPalette.kBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: CipherPalette.kAccent.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_open,
                        color: CipherPalette.kAccent, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pw ?? '',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          color: CipherPalette.kAccent,
                          letterSpacing: 1.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Created ${_formatDate(entry.createdAt)}',
              style: TextStyle(
                fontFamily: CipherTypography.fontFamily,
                fontSize: 9,
                color: CipherPalette.kInk.withAlpha(100),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${_p(dt.month)}-${_p(dt.day)} ${_p(dt.hour)}:${_p(dt.minute)}';
  }

  String _p(int v) => v.toString().padLeft(2, '0');
}

class _EmptyVault extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CipherPalette.kSurface,
              border: Border.all(color: CipherPalette.kEdge),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A00E5FF),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: CipherPalette.kAccent,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'VAULT IS EMPTY',
            style: TextStyle(
              fontFamily: CipherTypography.fontFamily,
              fontSize: 14,
              color: CipherPalette.kAccent,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Audit a password and save it here.',
            style: TextStyle(
              fontFamily: CipherTypography.fontFamily,
              fontSize: 11,
              color: CipherPalette.kInk.withAlpha(120),
            ),
          ),
        ],
      ),
    );
  }
}
