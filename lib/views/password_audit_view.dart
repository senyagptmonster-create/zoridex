import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ui/cipher_tokens.dart';
import '../viewmodels/vault_security_viewmodel.dart';

class PasswordAuditView extends StatefulWidget {
  const PasswordAuditView({super.key});

  @override
  State<PasswordAuditView> createState() => _PasswordAuditViewState();
}

class _PasswordAuditViewState extends State<PasswordAuditView> {
  final _pwController = TextEditingController();
  final _labelController = TextEditingController();
  bool _obscure = true;
  int _strength = 0;
  double _entropy = 0.0;

  static final RegExp _symbolRe = RegExp(r'[!@#\$%^&*()\-_=+\[\]{};:,.<>?/\\|~]');

  @override
  void dispose() {
    _pwController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String value, VaultSecurityViewModel vm) {
    setState(() {
      _strength = vm.calculateStrength(value);
      _entropy = vm.calculateEntropy(value);
    });
  }

  Color _strengthColor(int score) {
    if (score < 30) return const Color(0xFFFF3D3D);
    if (score < 55) return const Color(0xFFFF8C00);
    if (score < 75) return const Color(0xFFFFD600);
    return const Color(0xFF00E676);
  }

  String _strengthLabel(int score) {
    if (score < 30) return 'WEAK';
    if (score < 55) return 'FAIR';
    if (score < 75) return 'GOOD';
    return 'STRONG';
  }

  Widget _criterionRow(String label, bool met) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: met ? CipherPalette.kAccent : Colors.transparent,
              border: Border.all(
                color: met ? CipherPalette.kAccent : CipherPalette.kEdge,
                width: 1.5,
              ),
            ),
            child: met
                ? const Icon(Icons.check, size: 11, color: CipherPalette.kBg)
                : null,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontFamily: CipherTypography.fontFamily,
              fontSize: 11,
              color: met ? CipherPalette.kInk : CipherPalette.kEdge,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveToVault(VaultSecurityViewModel vm) async {
    final pw = _pwController.text.trim();
    final label = _labelController.text.trim();
    if (pw.isEmpty) {
      _showSnack('Enter a password first.');
      return;
    }
    if (label.isEmpty) {
      _showSnack('Enter a label for this entry.');
      return;
    }
    await vm.addEntry(label, pw);
    if (!mounted) return;
    _pwController.clear();
    _labelController.clear();
    setState(() {
      _strength = 0;
      _entropy = 0.0;
    });
    _showSnack('Saved to vault.');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: CipherPalette.kSurface,
        behavior: SnackBarBehavior.floating,
        content: Text(
          msg,
          style: const TextStyle(
            fontFamily: CipherTypography.fontFamily,
            color: CipherPalette.kAccent,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VaultSecurityViewModel>();
    final pw = _pwController.text;

    final hasLen = pw.length >= 12;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(pw);
    final hasLower = RegExp(r'[a-z]').hasMatch(pw);
    final hasDigit = RegExp(r'[0-9]').hasMatch(pw);
    final hasSym = _symbolRe.hasMatch(pw);

    return Scaffold(
      appBar: AppBar(title: const Text('PASSWORD AUDIT')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GlowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ANALYZE PASSWORD',
                    style: TextStyle(
                      fontFamily: CipherTypography.fontFamily,
                      fontSize: 11,
                      color: CipherPalette.kAccent2,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _pwController,
                    obscureText: _obscure,
                    onChanged: (v) => _onPasswordChanged(v, vm),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16,
                      color: CipherPalette.kInk,
                      letterSpacing: 2,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Enter password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                          color: CipherPalette.kAccent2,
                          size: 18,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'STRENGTH',
                        style: TextStyle(
                          fontFamily: CipherTypography.fontFamily,
                          fontSize: 10,
                          color: Color.fromARGB(150, 224, 247, 250),
                          letterSpacing: 1.5,
                        ),
                      ),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontFamily: CipherTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _strengthColor(_strength),
                          letterSpacing: 2,
                        ),
                        child: Text(_strengthLabel(_strength)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: _strength / 100),
                      duration: const Duration(milliseconds: 400),
                      builder: (context, v, child) => LinearProgressIndicator(
                        value: v,
                        minHeight: 10,
                        backgroundColor: CipherPalette.kEdge,
                        valueColor: AlwaysStoppedAnimation(_strengthColor(_strength)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: CipherPalette.kBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: CipherPalette.kEdge),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt, color: CipherPalette.kAccent, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'ENTROPY: ',
                          style: TextStyle(
                            fontFamily: CipherTypography.fontFamily,
                            fontSize: 10,
                            color: Color.fromARGB(150, 224, 247, 250),
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          '${_entropy.toStringAsFixed(1)} bits',
                          style: const TextStyle(
                            fontFamily: CipherTypography.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: CipherPalette.kAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _GlowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'STRENGTH CRITERIA',
                    style: TextStyle(
                      fontFamily: CipherTypography.fontFamily,
                      fontSize: 11,
                      color: CipherPalette.kAccent2,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _criterionRow('Minimum 12 characters', hasLen),
                  _criterionRow('Uppercase letters (A-Z)', hasUpper),
                  _criterionRow('Lowercase letters (a-z)', hasLower),
                  _criterionRow('Digits (0-9)', hasDigit),
                  _criterionRow('Special symbols (!@#...)', hasSym),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _GlowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SAVE TO VAULT',
                    style: TextStyle(
                      fontFamily: CipherTypography.fontFamily,
                      fontSize: 11,
                      color: CipherPalette.kAccent2,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _labelController,
                    style: const TextStyle(
                      fontFamily: CipherTypography.fontFamily,
                      fontSize: 13,
                      color: CipherPalette.kInk,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Entry label (e.g. Gmail)',
                      prefixIcon: Icon(Icons.label_outline,
                          color: CipherPalette.kAccent2, size: 18),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save_alt, size: 16),
                      label: const Text('SAVE PASSWORD'),
                      onPressed: () => _saveToVault(vm),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowCard extends StatelessWidget {
  const _GlowCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CipherPalette.kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CipherPalette.kEdge),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A00E5FF),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}
