import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import 'zoridex_store.dart';
import 'screens.dart';

class ProductApp extends StatelessWidget {
  const ProductApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final store = ZoridexStore();
        store.loadData();
        return store;
      },
      child: MaterialApp(
        title: 'Zoridex',
        theme: AppTheme.build(),
        home: const ZoridexHome(),
      ),
    );
  }
}
