import 'package:flutter/material.dart';
import 'ui/cipher_tokens.dart';
import 'ui/entropy_gauge_painter.dart';
import 'state/vault_scope.dart';

class ZoridexApp extends StatefulWidget {
  const ZoridexApp({super.key});

  @override
  State<ZoridexApp> createState() => _ZoridexAppState();
}

class _ZoridexAppState extends State<ZoridexApp> {
  double _len = 16.0;
  bool _syms = true;
  bool _nums = true;
  final List<VaultItem> _vault = [
    VaultItem(title: 'Master Seed Recovery', secret: 'k9#vL2!mP90@xW', createdAt: DateTime.now()),
    VaultItem(title: 'Proton Encrypted Mail', secret: '8x!_zQ9@aR22#b', createdAt: DateTime.now()),
  ];

  int _selectedDrawerIndex = 0;

  @override
  Widget build(BuildContext context) {
    final data = VaultScopeData(
      items: _vault,
      passwordLength: _len,
      includeSymbols: _syms,
      includeNumbers: _nums,
      setLength: (v) => setState(() => _len = v),
      setSymbols: (v) => setState(() => _syms = v),
      setNumbers: (v) => setState(() => _nums = v),
      addItem: (t, s) => setState(() => _vault.insert(0, VaultItem(title: t, secret: s, createdAt: DateTime.now()))),
    );

    return VaultScope(
      data: data,
      child: MaterialApp(
        title: 'Zoridex Vault Cipher',
        debugShowCheckedModeBanner: false,
        theme: CipherTokens.theme,
        home: _ZoridexDrawerScaffold(
          selectedIndex: _selectedDrawerIndex,
          onSelectIndex: (idx) => setState(() => _selectedDrawerIndex = idx),
        ),
      ),
    );
  }
}

class _ZoridexDrawerScaffold extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelectIndex;

  const _ZoridexDrawerScaffold({required this.selectedIndex, required this.onSelectIndex});

  @override
  Widget build(BuildContext context) {
    final titles = ['Entropy Generator', 'Secure Vault', 'Security Audit', 'Cipher Handbook'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[selectedIndex], style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      drawer: Drawer(
        backgroundColor: CipherTokens.darkTerminal,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: CipherTokens.cyberCard),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.shield_outlined, color: CipherTokens.neonEmerald, size: 36),
                  SizedBox(height: 10),
                  Text('Zoridex Cryptographic Vault',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Zero-Knowledge Offline Storage',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            _drawerItem(context, 0, Icons.vpn_key, 'Generator'),
            _drawerItem(context, 1, Icons.lock_outline, 'Saved Vault Items'),
            _drawerItem(context, 2, Icons.fact_check_outlined, 'Audit Checklist'),
            _drawerItem(context, 3, Icons.menu_book_outlined, 'Cipher Handbook'),
          ],
        ),
      ),
      body: [
        const _GeneratorView(),
        const _VaultView(),
        const _AuditView(),
        const _HandbookView(),
      ][selectedIndex],
    );
  }

  Widget _drawerItem(BuildContext context, int index, IconData icon, String title) {
    final isSel = selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSel ? CipherTokens.neonEmerald : Colors.grey),
      title: Text(title, style: TextStyle(fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
      selected: isSel,
      selectedTileColor: CipherTokens.cyberCard,
      onTap: () {
        Navigator.pop(context);
        onSelectIndex(index);
      },
    );
  }
}

class _GeneratorView extends StatefulWidget {
  const _GeneratorView();

  @override
  State<_GeneratorView> createState() => _GeneratorViewState();
}

class _GeneratorViewState extends State<_GeneratorView> {
  String _generated = '';

  @override
  Widget build(BuildContext context) {
    final data = VaultScope.of(context);
    final entropy = data.entropyBits;
    final ratio = entropy / 128.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            width: 220,
            height: 120,
            child: CustomPaint(
              painter: EntropyGaugePainter(entropyRatio: ratio),
            ),
          ),
          Text('${entropy.toStringAsFixed(1)} Bits Entropy',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: CipherTokens.neonEmerald)),
          const Text('Recommended: 80+ Bits for Quantum Resistance', style: TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CipherTokens.cyberCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SelectableText(
                  _generated.isEmpty ? data.generatePassword() : _generated,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => setState(() => _generated = data.generatePassword()),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reroll Password'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Text('Length: ${data.passwordLength.round()} chars')),
              Slider(
                value: data.passwordLength,
                min: 8,
                max: 32,
                divisions: 24,
                onChanged: data.setLength,
              ),
            ],
          ),
          SwitchListTile(
            title: const Text('Include Special Symbols (!@#%)'),
            value: data.includeSymbols,
            onChanged: data.setSymbols,
          ),
          SwitchListTile(
            title: const Text('Include Numbers (0-9)'),
            value: data.includeNumbers,
            onChanged: data.setNumbers,
          ),
        ],
      ),
    );
  }
}

class _VaultView extends StatelessWidget {
  const _VaultView();

  @override
  Widget build(BuildContext context) {
    final data = VaultScope.of(context);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.items.length,
      itemBuilder: (context, idx) {
        final item = data.items[idx];
        return Card(
          color: CipherTokens.cyberCard,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.key, color: CipherTokens.neonEmerald),
            title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(item.secret, style: const TextStyle(fontFamily: 'monospace')),
          ),
        );
      },
    );
  }
}

class _AuditView extends StatelessWidget {
  const _AuditView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: Icon(Icons.check_circle, color: CipherTokens.neonEmerald),
          title: Text('No dictionary words in passphrases'),
        ),
        ListTile(
          leading: Icon(Icons.check_circle, color: CipherTokens.neonEmerald),
          title: Text('Offline hardware salt active'),
        ),
        ListTile(
          leading: Icon(Icons.check_circle, color: CipherTokens.neonEmerald),
          title: Text('2FA hardware security key enabled'),
        ),
      ],
    );
  }
}

class _HandbookView extends StatelessWidget {
  const _HandbookView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Shannon Information Entropy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 10),
          Text(
            'Password strength is fundamentally quantified in bits of entropy: E = L * log2(R). An 80-bit password requires over a septillion guesses to crack via distributed brute force.',
            style: TextStyle(color: Colors.grey, height: 1.4),
          ),
        ],
      ),
    );
  }
}
