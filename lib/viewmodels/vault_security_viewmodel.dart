import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/vault_entry_item.dart';

class VaultSecurityViewModel extends ChangeNotifier {
  VaultSecurityViewModel() {
    _load();
  }

  static const _kPrefKey = 'zoridex_vault_entries';
  static const _kAutoLockKey = 'zoridex_auto_lock';

  final List<VaultEntryItem> _entries = [];
  int _autoLockMinutes = 5;

  List<VaultEntryItem> get entries => List.unmodifiable(_entries);
  int get autoLockMinutes => _autoLockMinutes;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPrefKey);
    if (raw != null) {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      _entries
        ..clear()
        ..addAll(
          decoded.map((e) => VaultEntryItem.fromJson(e as Map<String, dynamic>)),
        );
    }
    _autoLockMinutes = prefs.getInt(_kAutoLockKey) ?? 5;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(_kPrefKey, encoded);
  }

  Future<void> addEntry(String label, String rawPassword) async {
    final entry = VaultEntryItem(
      id: _generateId(),
      label: label,
      encryptedValue: VaultEntryItem.obfuscate(rawPassword),
      strengthScore: calculateStrength(rawPassword),
      createdAt: DateTime.now(),
    );
    _entries.add(entry);
    notifyListeners();
    await _persist();
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
    await _persist();
  }

  Future<void> clearAll() async {
    _entries.clear();
    notifyListeners();
    await _persist();
  }

  Future<void> setAutoLock(int minutes) async {
    _autoLockMinutes = minutes;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kAutoLockKey, minutes);
  }

  static final RegExp _symbolRe = RegExp(r'[!@#\$%^&*()\-_=+\[\]{};:,.<>?/\\|~]');

  /// Returns 0-100 strength score.
  int calculateStrength(String password) {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 8) score += 15;
    if (password.length >= 12) score += 15;
    if (password.length >= 16) score += 10;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 15;
    if (RegExp(r'[a-z]').hasMatch(password)) score += 15;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 15;
    if (_symbolRe.hasMatch(password)) score += 15;
    return score.clamp(0, 100);
  }

  /// Calculates Shannon entropy in bits: H = L * log2(N).
  double calculateEntropy(String password) {
    if (password.isEmpty) return 0.0;
    int pool = 0;
    if (RegExp(r'[a-z]').hasMatch(password)) pool += 26;
    if (RegExp(r'[A-Z]').hasMatch(password)) pool += 26;
    if (RegExp(r'[0-9]').hasMatch(password)) pool += 10;
    if (_symbolRe.hasMatch(password)) pool += 32;
    if (pool == 0) pool = 26;
    return password.length * log(pool) / ln2;
  }

  double calculateEntropyFromPool(int length, int poolSize) {
    if (length == 0 || poolSize == 0) return 0;
    return length * log(poolSize) / ln2;
  }

  String _generateId() {
    final rng = Random.secure();
    final values = List<int>.generate(16, (_) => rng.nextInt(256));
    return values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
