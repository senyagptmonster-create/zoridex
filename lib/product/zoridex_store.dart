import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ZoridexStore extends ChangeNotifier {
  List<Map<String, dynamic>> vaultItems = [];

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('zoridex_data');
    if (data != null) {
      final json = jsonDecode(data);
      if (json['vaultItems'] != null) {
        vaultItems = List<Map<String, dynamic>>.from(json['vaultItems']);
      }
    }
    notifyListeners();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final json = {'vaultItems': vaultItems};
    await prefs.setString('zoridex_data', jsonEncode(json));
  }
}
