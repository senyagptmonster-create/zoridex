import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ui/cipher_tokens.dart';
import 'viewmodels/vault_security_viewmodel.dart';
import 'views/cipher_settings_view.dart';
import 'views/entropy_lab_view.dart';
import 'views/password_audit_view.dart';
import 'views/vault_list_view.dart';

class ZoridexApp extends StatelessWidget {
  const ZoridexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VaultSecurityViewModel>(
      create: (_) => VaultSecurityViewModel(),
      child: MaterialApp(
        title: 'Zoridex',
        debugShowCheckedModeBanner: false,
        theme: CipherTheme.dark(),
        home: const _ZoridexShell(),
      ),
    );
  }
}

class _ZoridexShell extends StatefulWidget {
  const _ZoridexShell();

  @override
  State<_ZoridexShell> createState() => _ZoridexShellState();
}

class _ZoridexShellState extends State<_ZoridexShell> {
  int _selectedIndex = 0;

  static const _destinations = [
    NavigationDrawerDestination(
      icon: Icon(Icons.manage_search),
      label: Text('Password Audit'),
    ),
    NavigationDrawerDestination(
      icon: Icon(Icons.shield),
      label: Text('Vault'),
    ),
    NavigationDrawerDestination(
      icon: Icon(Icons.science_outlined),
      label: Text('Entropy Lab'),
    ),
    NavigationDrawerDestination(
      icon: Icon(Icons.settings),
      label: Text('Settings'),
    ),
  ];

  static const _views = [
    PasswordAuditView(),
    VaultListView(),
    EntropyLabView(),
    CipherSettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          Navigator.pop(context); // close drawer
        },
        children: [
          _DrawerHeader(),
          ..._destinations,
        ],
      ),
      // Nest the selected view (each has its own Scaffold + AppBar)
      body: IndexedStack(
        index: _selectedIndex,
        children: _views,
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 36, 20, 20),
      decoration: const BoxDecoration(
        color: CipherPalette.kSurface,
        border: Border(bottom: BorderSide(color: CipherPalette.kEdge)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: CipherPalette.kBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CipherPalette.kAccent.withAlpha(120)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3300E5FF),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.security,
              color: CipherPalette.kAccent,
              size: 26,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'ZORIDEX',
            style: TextStyle(
              fontFamily: CipherTypography.fontFamily,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CipherPalette.kAccent,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cipher Vault & Entropy Analyzer',
            style: TextStyle(
              fontFamily: CipherTypography.fontFamily,
              fontSize: 10,
              color: CipherPalette.kInk.withAlpha(150),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
