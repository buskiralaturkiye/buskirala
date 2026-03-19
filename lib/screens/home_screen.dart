import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'transfer_screen.dart';
import 'rental_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Geri tuşunu kendimiz yönetiyoruz
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Giriş sekmesinde değilsek → Giriş'e dön
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return;
        }

        // Giriş sekmesindeyken geri basılırsa → çıkmak istiyor musun? sor
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: const Text('Çıkış', style: TextStyle(fontWeight: FontWeight.w700)),
            content: const Text('Uygulamadan çıkmak istiyor musunuz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Hayır', style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Evet', style: TextStyle(color: Color(0xFFFF6600), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );

        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            _WelcomeScreen(),
            TransferScreen(),
            RentalScreen(),
            ContactScreen(),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: const Color(0xFFFF6600),
        unselectedItemColor: Colors.grey.shade400,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Giriş'),
          BottomNavigationBarItem(icon: Icon(Icons.flight_land_rounded), label: 'Transfer'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_bus_rounded), label: 'Kiralama'),
          BottomNavigationBarItem(icon: Icon(Icons.headset_mic_rounded), label: 'İletişim'),
        ],
      ),
    );
  }
}

// ── Giriş (Welcome) Ekranı ──────────────────────────────────────────────────

class _WelcomeScreen extends StatelessWidget {
  const _WelcomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hoş Geldiniz',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ne yapmak istersiniz?',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 40),
                _buildServiceTile(
                  context: context,
                  icon: Icons.flight_land_rounded,
                  title: 'Transfer',
                  subtitle: 'Havalimanı & şehirlerarası transfer rezervasyonu',
                  tabIndex: 1,
                ),
                const SizedBox(height: 16),
                _buildServiceTile(
                  context: context,
                  icon: Icons.directions_bus_rounded,
                  title: 'Araç Kiralama',
                  subtitle: 'Otobüs, minibüs ve otomobil kiralama',
                  tabIndex: 2,
                ),
                const SizedBox(height: 48),
                Center(
                  child: Text(
                    '444 50 72',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade400, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        toolbarHeight: 72,
        title: Image.asset(
          'assets/images/buskirala-logo.png',
          height: 42,
          fit: BoxFit.contain,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade100),
        ),
      ),
    );
  }

  Widget _buildServiceTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required int tabIndex,
  }) {
    return GestureDetector(
      onTap: () {
        final homeState = context.findAncestorStateOfType<_HomeScreenState>();
        homeState?.setState(() => homeState._currentIndex = tabIndex);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6600).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFFF6600), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 3),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── İletişim Ekranı ─────────────────────────────────────────────────────────

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.white,
          centerTitle: true,
          toolbarHeight: 72,
          title: Image.asset(
            'assets/images/buskirala-logo.png',
            height: 42,
            fit: BoxFit.contain,
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: Colors.grey.shade100),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text('Bize Ulaşın', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 4),
            Text('7/24 hizmetinizdeyiz', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            const SizedBox(height: 32),
            _buildItem(icon: Icons.phone_rounded, title: 'Çağrı Merkezi', subtitle: '444 50 72', onTap: () => _launch('tel:4445072')),
            _buildDivider(),
            _buildItem(icon: Icons.chat_rounded, title: 'WhatsApp', subtitle: '+90 850 840 52 50', onTap: () => _launch('https://wa.me/908508405250')),
            _buildDivider(),
            _buildItem(icon: Icons.mail_outline_rounded, title: 'E-Posta', subtitle: 'info@buskirala.com', onTap: () => _launch('mailto:info@buskirala.com')),
            _buildDivider(),
            _buildItem(icon: Icons.language_rounded, title: 'Web Sitesi', subtitle: 'www.buskirala.com', onTap: () => _launch('https://www.buskirala.com')),
          ],
        ),
      ),
    );
  }

  Widget _buildItem({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: const Color(0xFFFF6600), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() => Divider(height: 1, color: Colors.grey.shade100);
}