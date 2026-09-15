import 'dart:convert';

/// Represents a single password entry stored in the vault.
class VaultEntryItem {
  VaultEntryItem({
    required this.id,
    required this.label,
    required this.encryptedValue,
    required this.strengthScore,
    required this.createdAt,
  });

  factory VaultEntryItem.fromJson(Map<String, dynamic> json) {
    return VaultEntryItem(
      id: json['id'] as String,
      label: json['label'] as String,
      encryptedValue: json['encryptedValue'] as String,
      strengthScore: json['strengthScore'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String id;
  final String label;

  /// XOR-obfuscated password stored as base64.
  final String encryptedValue;
  final int strengthScore;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'encryptedValue': encryptedValue,
        'strengthScore': strengthScore,
        'createdAt': createdAt.toIso8601String(),
      };

  /// XOR-obfuscate the raw password with a fixed key and return base64.
  static String obfuscate(String raw) {
    const key = 0x5A; // 'Z'
    final bytes = utf8.encode(raw);
    final xored = bytes.map((b) => b ^ key).toList();
    return base64Encode(xored);
  }

  /// Reverse the XOR obfuscation.
  static String deobfuscate(String encoded) {
    const key = 0x5A;
    final bytes = base64Decode(encoded);
    final xored = bytes.map((b) => b ^ key).toList();
    return utf8.decode(xored);
  }
}
