import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'zoridex_store.dart';
import '../app/theme.dart';

class ZoridexHome extends StatelessWidget {
  const ZoridexHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Audit Dashboard', style: AppTheme.display())),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Text('Zoridex Menu', style: AppTheme.display())),
            ListTile(
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Generator'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GeneratorScreen()));
              },
            ),
            ListTile(
              title: const Text('Vault Storage'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const VaultScreen()));
              },
            ),
            ListTile(
              title: const Text('Checklist'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChecklistScreen()));
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Overall Strength', style: AppTheme.text()),
            const SizedBox(height: 16),
            Text('85/100', style: AppTheme.display().copyWith(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}

class GeneratorScreen extends StatelessWidget {
  const GeneratorScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generator')),
      body: Center(child: Text('Password Generator', style: AppTheme.text())),
    );
  }
}

class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = context.watch<ZoridexStore>();
    return Scaffold(
      appBar: AppBar(title: const Text('Vault Storage')),
      body: ListView.builder(
        itemCount: store.vaultItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(store.vaultItems[index]['title'] ?? '', style: AppTheme.text()),
            subtitle: const Text('********'),
          );
        },
      ),
    );
  }
}

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security Checklist')),
      body: ListView(
        children: const [
          CheckboxListTile(value: true, onChanged: null, title: Text('Use 2FA')),
          CheckboxListTile(value: false, onChanged: null, title: Text('Update Passwords')),
        ],
      ),
    );
  }
}
