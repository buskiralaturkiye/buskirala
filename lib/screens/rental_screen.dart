import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

// ── Kiralama Ana Ekranı ─────────────────────────────────────────────────────

class RentalScreen extends StatefulWidget {
  const RentalScreen({super.key});

  @override
  State<RentalScreen> createState() => _RentalScreenState();
}

class _RentalScreenState extends State<RentalScreen> {
  _RentalPage? _selectedPage;

  void _openPage(_RentalPage page) {
    setState(() => _selectedPage = page);
  }

  void _goBack() {
    setState(() => _selectedPage = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedPage != null) {
      return _RentalWebViewScreen(page: _selectedPage!, onBack: _goBack);
    }
    return _buildListScreen();
  }

  Widget _buildListScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(showBack: false),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Araç Kiralama', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 4),
                Text('Ne kiralamak istersiniz?', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTile(icon: Icons.directions_bus_rounded, title: 'Otobüs Kiralama', subtitle: '46 - 54 kişilik araçlar', url: '/otobus-kiralama/'),
                    const SizedBox(height: 16),
                    _buildTile(icon: Icons.airport_shuttle_rounded, title: 'Minibüs Kiralama', subtitle: '8 - 35 kişilik araçlar', url: '/minibus-kiralama/'),
                    const SizedBox(height: 16),
                    _buildTile(icon: Icons.directions_car_rounded, title: 'Otomobil Kiralama', subtitle: '1 - 4 kişilik araçlar', url: '/soforlu-arac-kiralama/'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar({required bool showBack}) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        toolbarHeight: 72,
        automaticallyImplyLeading: false,
        leading: showBack
            ? IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)), onPressed: _goBack)
            : null,
        title: Image.asset('assets/images/buskirala-logo.png', height: 42, fit: BoxFit.contain),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: Colors.grey.shade100)),
      ),
    );
  }

  Widget _buildTile({required IconData icon, required String title, required String subtitle, required String url}) {
    return GestureDetector(
      onTap: () => _openPage(_RentalPage(title: title, url: url)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: const Color(0xFFFF6600).withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: const Color(0xFFFF6600), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 3),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ]),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Kiralama WebView İç Sayfası ─────────────────────────────────────────────

class _RentalPage {
  final String title;
  final String url;
  const _RentalPage({required this.title, required this.url});
}

class _RentalWebViewScreen extends StatefulWidget {
  final _RentalPage page;
  final VoidCallback onBack;
  const _RentalWebViewScreen({required this.page, required this.onBack});

  @override
  State<_RentalWebViewScreen> createState() => _RentalWebViewScreenState();
}

class _RentalWebViewScreenState extends State<_RentalWebViewScreen> with WidgetsBindingObserver {
  WebViewController? _controller;
  bool _webViewReady = false;

  String get _cleanupScript => '''
    (function() {
      function hideOthers() {
        var widget = document.querySelector('bus-kirala-widget');
        if (!widget) return false;

        document.querySelector('#wpadminbar')?.remove();
        document.querySelector('#bk-header')?.remove();
        document.querySelector('footer')?.remove();
        document.querySelectorAll('header').forEach(function(e) { e.remove(); });

        var ancestors = new Set();
        var el = widget;
        while (el && el !== document.body) {
          ancestors.add(el);
          el = el.parentElement;
        }

        var elementorWrapper = document.querySelector('.elementor');
        if (elementorWrapper) {
          Array.from(elementorWrapper.children).forEach(function(child) {
            if (!ancestors.has(child)) child.style.display = 'none';
          });
        }

        Array.from(document.body.children).forEach(function(child) {
          if (!ancestors.has(child) && child.tagName !== 'SCRIPT' && child.tagName !== 'STYLE') {
            child.style.display = 'none';
          }
        });

        ancestors.forEach(function(ancestor) {
          if (ancestor !== widget) {
            ancestor.style.padding = '0';
            ancestor.style.margin = '0';
            ancestor.style.maxWidth = '100%';
            ancestor.style.width = '100%';
            ancestor.style.background = '#ffffff';
          }
        });

        // Başlık ve açıklamayı widget'ın üstüne enjekte et — kaydırınca kayar
        var existing = document.getElementById('bk-injected-header');
        if (!existing) {
          var header = document.createElement('div');
          header.id = 'bk-injected-header';
          header.style.padding = '20px 16px 0 16px';
          header.style.backgroundColor = '#ffffff';
          header.innerHTML =
            '<h2 style="margin:0 0 4px 0;font-size:20px;font-weight:700;color:#1A1A2E;font-family:sans-serif;">${widget.page.title}</h2>' +
            '<p style="margin:0 0 16px 0;font-size:13px;color:#9e9e9e;font-family:sans-serif;">Formu doldurarak talebinizi oluşturun.</p>';
          widget.parentElement.insertBefore(header, widget);
        }

        widget.parentElement.style.padding = '0 16px 16px 16px';
        document.body.style.margin = '0';
        document.body.style.padding = '0';
        document.body.style.backgroundColor = '#ffffff';

        window.open = function(url) {
          if (url) FlutterDownload.postMessage(url);
        };

        return true;
      }

      if (hideOthers()) return;

      var observer = new MutationObserver(function() {
        if (hideOthers()) observer.disconnect();
      });
      observer.observe(document.body, { childList: true, subtree: true });
      setTimeout(function() { observer.disconnect(); }, 15000);
    })();
  ''';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _controller?.runJavaScript('''
        if (document.body.innerText.includes('ERR_') ||
            document.body.innerText.includes('mevcut değil')) {
          window.location.reload();
        }
      ''');
    }
  }

  void _initController() {
    final ctrl = WebViewController();

    if (ctrl.platform is AndroidWebViewController) {
      final android = ctrl.platform as AndroidWebViewController;
      android.setMediaPlaybackRequiresUserGesture(false);
    }

    ctrl
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36')
      ..addJavaScriptChannel(
        'FlutterDownload',
        onMessageReceived: (message) async {
          final url = message.message;
          if (url.isNotEmpty) {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) setState(() => _webViewReady = false);
        },
        onPageFinished: (_) async {
          await ctrl.runJavaScript(_cleanupScript);
          await Future.delayed(const Duration(milliseconds: 600));
          if (mounted) setState(() => _webViewReady = true);
        },
        onWebResourceError: (error) {
          if (mounted) {
            setState(() => _webViewReady = false);
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) ctrl.loadRequest(Uri.parse('https://www.buskirala.com${widget.page.url}'));
            });
          }
        },
        onNavigationRequest: (request) {
          final url = request.url;
          if (url.contains('.pdf') || url.contains('download') ||
              url.contains('teklif') || url.contains('sozlesme')) {
            _launchExternal(url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse('https://www.buskirala.com${widget.page.url}'));

    if (mounted) setState(() => _controller = ctrl);
  }

  Future<void> _launchExternal(String url) async {
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
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
            onPressed: widget.onBack,
          ),
          title: Image.asset('assets/images/buskirala-logo.png', height: 42, fit: BoxFit.contain),
          bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: Colors.grey.shade100)),
        ),
      ),
      body: _controller == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6600), strokeWidth: 2.5))
          : Stack(
              children: [
                Opacity(
                  opacity: _webViewReady ? 1.0 : 0.0,
                  child: WebViewWidget(controller: _controller!),
                ),
                if (!_webViewReady)
                  const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF6600), strokeWidth: 2.5),
                  ),
              ],
            ),
    );
  }
}