import 'dart:math';
import 'package:flutter/material.dart';

class VaultItem {
  final String title;
  final String secret;
  final DateTime createdAt;

  VaultItem({required this.title, required this.secret, required this.createdAt});
}

class VaultScopeData {
  final List<VaultItem> items;
  final double passwordLength;
  final bool includeSymbols;
  final bool includeNumbers;
  final Function(double) setLength;
  final Function(bool) setSymbols;
  final Function(bool) setNumbers;
  final Function(String, String) addItem;

  VaultScopeData({
    required this.items,
    required this.passwordLength,
    required this.includeSymbols,
    required this.includeNumbers,
    required this.setLength,
    required this.setSymbols,
    required this.setNumbers,
    required this.addItem,
  });

  String generatePassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const nums = '0123456789';
    const syms = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String pool = chars;
    if (includeNumbers) pool += nums;
    if (includeSymbols) pool += syms;

    final rand = Random();
    return List.generate(passwordLength.round(), (index) => pool[rand.nextInt(pool.length)]).join();
  }

  double get entropyBits {
    int poolSize = 52;
    if (includeNumbers) poolSize += 10;
    if (includeSymbols) poolSize += 30;
    return passwordLength * (log(poolSize) / ln2);
  }
}

class VaultScope extends InheritedWidget {
  final VaultScopeData data;

  const VaultScope({
    super.key,
    required this.data,
    required super.child,
  });

  static VaultScopeData of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<VaultScope>();
    assert(scope != null, 'No VaultScope found in context');
    return scope!.data;
  }

  @override
  bool updateShouldNotify(covariant VaultScope oldWidget) => true;
}
