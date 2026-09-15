import 'dart:math';

import 'package:flutter/material.dart';

import '../ui/cipher_tokens.dart';

class EntropyLabView extends StatefulWidget {
  const EntropyLabView({super.key});

  @override
  State<EntropyLabView> createState() => _EntropyLabViewState();
}

class _EntropyLabViewState extends State<EntropyLabView> {
  double _length = 12;
  bool _useLower = true;
  bool _useUpper = true;
  bool _useDigits = true;
  bool _useSymbols = false;

  int get _poolSize {
    int p = 0;
    if (_useLower) p += 26;
    if (_useUpper) p += 26;
    if (_useDigits) p += 10;
    if (_useSymbols) p += 32;
    return p == 0 ? 1 : p;
  }

  double get _entropy {
    return _length * log(_poolSize) / ln2;
  }

  String _crackTime(double bits) {
    // Assume 10 billion guesses/sec (fast modern GPU)
    const guessesPerSec = 1e10;
    final combinations = pow(2, bits);
    final seconds = combinations / guessesPerSec / 2; // avg half
    if (seconds < 1) return 'Instantly';
    if (seconds < 60) return '${seconds.toStringAsFixed(0)} seconds';
    if (seconds < 3600) return '${(seconds / 60).toStringAsFixed(0)} minutes';
    if (seconds < 86400) return '${(seconds / 3600).toStringAsFixed(0)} hours';
    if (seconds < 31536000) return '${(seconds / 86400).toStringAsFixed(0)} days';
    final years = seconds / 31536000;
    if (years < 1e6) return '${years.toStringAsFixed(0)} years';
    if (years < 1e9) return '${(years / 1e6).toStringAsFixed(1)} million years';
    if (years < 1e12) return '${(years / 1e9).toStringAsFixed(1)} billion years';
    return '${(years / 1e12).toStringAsFixed(1)} trillion years';
  }

  Color _entropyColor(double bits) {
    if (bits < 40) return const Color(0xFFFF3D3D);
    if (bits < 60) return const Color(0xFFFF8C00);
    if (bits < 80) return const Color(0xFFFFD600);
    return const Color(0xFF00E676);
  }

  @override
  Widget build(BuildContext context) {
    final entropy = _entropy;
    final eBits = entropy.toStringAsFixed(2);
    final eColor = _entropyColor(entropy);
    final crackTime = _crackTime(entropy);

    return Scaffold(
      appBar: AppBar(title: const Text('ENTROPY LAB')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Entropy display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: CipherPalette.kSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: eColor.withAlpha(120), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: eColor.withAlpha(40),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    eBits,
                    style: TextStyle(
                      fontFamily: CipherTypography.fontFamily,
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: eColor,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'BITS OF ENTROPY',
                    style: TextStyle(
                      fontFamily: CipherTypography.fontFamily,
                      fontSize: 11,
                      color: CipherPalette.kInk.withAlpha(150),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Formula
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CipherPalette.kBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: CipherPalette.kEdge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FORMULA',
                    style: TextStyle(
                      fontFamily: CipherTypography.fontFamily,
                      fontSize: 10,
                      color: CipherPalette.kAccent2,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'H = L × log₂(N)',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 18,
                      color: CipherPalette.kAccent,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'H = ${_length.toInt()} × log₂($_poolSize)\n  = ${_length.toInt()} × ${(log(_poolSize) / ln2).toStringAsFixed(4)}\n  = $eBits bits',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: CipherPalette.kInk,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Crack time
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CipherPalette.kSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: CipherPalette.kEdge),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time,
                      color: CipherPalette.kAccent2, size: 20),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'EST. CRACK TIME (10B guesses/sec)',
                        style: TextStyle(
                          fontFamily: CipherTypography.fontFamily,
                          fontSize: 9,
                          color: CipherPalette.kAccent2,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        crackTime,
                        style: TextStyle(
                          fontFamily: CipherTypography.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: eColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Controls
            _SectionLabel('PASSWORD LENGTH: ${_length.toInt()} CHARS'),
            Slider(
              min: 8,
              max: 32,
              divisions: 24,
              value: _length,
              label: '${_length.toInt()}',
              onChanged: (v) => setState(() => _length = v),
            ),
            const SizedBox(height: 16),
            _SectionLabel('CHARACTER SETS'),
            const SizedBox(height: 8),
            _CharSetRow(
              label: 'Lowercase (a-z)',
              subtitle: '26 chars',
              value: _useLower,
              onChanged: (v) => setState(() => _useLower = v ?? _useLower),
            ),
            _CharSetRow(
              label: 'Uppercase (A-Z)',
              subtitle: '26 chars',
              value: _useUpper,
              onChanged: (v) => setState(() => _useUpper = v ?? _useUpper),
            ),
            _CharSetRow(
              label: 'Digits (0-9)',
              subtitle: '10 chars',
              value: _useDigits,
              onChanged: (v) => setState(() => _useDigits = v ?? _useDigits),
            ),
            _CharSetRow(
              label: 'Symbols (!@#\$…)',
              subtitle: '32 chars',
              value: _useSymbols,
              onChanged: (v) => setState(() => _useSymbols = v ?? _useSymbols),
            ),
            const SizedBox(height: 24),
            // Pool info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: CipherPalette.kBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: CipherPalette.kEdge),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatChip('POOL SIZE', '$_poolSize chars'),
                  _StatChip('LENGTH', '${_length.toInt()} chars'),
                  _StatChip('COMBINATIONS', _formatCombinations()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCombinations() {
    final c = pow(_poolSize.toDouble(), _length).toDouble();
    if (c < 1e6) return c.toStringAsExponential(1);
    if (c < 1e12) return '${(c / 1e9).toStringAsFixed(1)}B';
    return c.toStringAsExponential(2);
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: CipherTypography.fontFamily,
        fontSize: 10,
        color: CipherPalette.kAccent2,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _CharSetRow extends StatelessWidget {
  const _CharSetRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: CipherPalette.kSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value ? CipherPalette.kAccent.withAlpha(100) : CipherPalette.kEdge,
        ),
      ),
      child: Row(
        children: [
          Checkbox(value: value, onChanged: onChanged),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: CipherTypography.fontFamily,
                fontSize: 12,
                color: CipherPalette.kInk,
              ),
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: CipherTypography.fontFamily,
              fontSize: 10,
              color: CipherPalette.kAccent2.withAlpha(180),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: CipherTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: CipherPalette.kAccent,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: CipherTypography.fontFamily,
            fontSize: 8,
            color: CipherPalette.kInk.withAlpha(120),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
