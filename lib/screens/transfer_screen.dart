import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> with WidgetsBindingObserver {
  late final WebViewController _controller;
  bool _isLoading = false;

  WebViewController? _paymentController;
  bool _paymentLoading = false;

  bool _isPaymentUrl(String url) {
    return url.contains('iyzico') ||
        url.contains('iyzilink') ||
        url.contains('iyzipay') ||
        url.contains('3ds') ||
        url.contains('3dsecure') ||
        url.contains('payment') ||
        url.contains('odeme') ||
        url.contains('garanti') ||
        url.contains('akbank') ||
        url.contains('isbank') ||
        url.contains('yapikredi') ||
        url.contains('ziraatbank') ||
        url.contains('halkbank');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initMainController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _controller.runJavaScript('''
        if (document.body.innerText.includes('ERR_') ||
            document.body.innerText.includes('mevcut değil')) {
          window.location.reload();
        }
      ''');
    }
  }

  void _initMainController() {
    _controller = WebViewController();

    if (_controller.platform is AndroidWebViewController) {
      final android = _controller.platform as AndroidWebViewController;
      android.setMediaPlaybackRequiresUserGesture(false);
    }

    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36')
      // İyzico iframe URL'sini yakalamak için kanal
      ..addJavaScriptChannel(
        'FlutterPayment',
        onMessageReceived: (message) {
          final url = message.message;
          if (url.isNotEmpty) _openPaymentWebView(url);
        },
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) setState(() => _isLoading = true);
        },
        onPageFinished: (url) async {
          if (!_isPaymentUrl(url)) {
            await _controller.runJavaScript('''
              document.querySelector('#wpadminbar')?.remove();
              document.querySelector('header')?.remove();
              document.querySelector('footer')?.remove();
              document.querySelector('.aioseo-breadcrumbs')?.remove();
              document.querySelector('#bk-header')?.remove();

              var widget = document.querySelector('buskirala-widget');
              if (widget) {
                document.body.innerHTML = '';
                document.body.appendChild(widget);
                document.body.style.margin = '0';
                document.body.style.padding = '0';
                document.body.style.backgroundColor = '#ffffff';
                document.body.style.boxSizing = 'border-box';
                widget.style.width = '100%';
                widget.style.maxWidth = '480px';
                widget.style.display = 'block';
                widget.style.margin = '0 auto';

                // Başlık ve açıklamayı widget'ın üstüne enjekte et — kaydırınca kayar
                var existing = document.getElementById('bk-transfer-header');
                if (!existing) {
                  var header = document.createElement('div');
                  header.id = 'bk-transfer-header';
                  header.style.padding = '20px 16px 0 16px';
                  header.style.backgroundColor = '#ffffff';
                  header.innerHTML =
                    '<h2 style="margin:0 0 4px 0;font-size:20px;font-weight:700;color:#1A1A2E;font-family:sans-serif;">Transfer Rezervasyonu</h2>' +
                    '<p style="margin:0 0 16px 0;font-size:13px;color:#9e9e9e;font-family:sans-serif;">Havalimanı & şehirlerarası transfer için hızlıca rezervasyon yapın.</p>';
                  document.body.insertBefore(header, widget);
                }
              }

              // Shadow DOM içindeki iframe'i izle — iyzico ödeme URL'sini yakala
              function watchForIframe() {
                var buskiralaWidget = document.querySelector('buskirala-widget');
                if (!buskiralaWidget || !buskiralaWidget.shadowRoot) {
                  setTimeout(watchForIframe, 500);
                  return;
                }
                var shadowRoot = buskiralaWidget.shadowRoot;
                var observer = new MutationObserver(function(mutations) {
                  mutations.forEach(function(mutation) {
                    mutation.addedNodes.forEach(function(node) {
                      if (node.tagName === 'IFRAME' && node.src && node.src.length > 0) {
                        FlutterPayment.postMessage(node.src);
                        observer.disconnect();
                      }
                    });
                    if (mutation.type === 'attributes' && mutation.target.tagName === 'IFRAME') {
                      var src = mutation.target.src;
                      if (src && src.length > 0) {
                        FlutterPayment.postMessage(src);
                        observer.disconnect();
                      }
                    }
                  });
                });
                observer.observe(shadowRoot, {
                  childList: true,
                  subtree: true,
                  attributes: true,
                  attributeFilter: ['src']
                });
              }
              watchForIframe();
            ''');
          }

          if (mounted) setState(() => _isLoading = false);
        },
        onNavigationRequest: (request) => NavigationDecision.navigate,
        onWebResourceError: (error) {
          debugPrint('WebView hata: ${error.description}');
        },
      ))
      ..loadRequest(
        Uri.parse('https://www.buskirala.com/havalimani-transfer/'),
        headers: {
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Language': 'tr-TR,tr;q=0.9',
        },
      );
  }

  void _openPaymentWebView(String url) {
    final ctrl = WebViewController();

    if (ctrl.platform is AndroidWebViewController) {
      final android = ctrl.platform as AndroidWebViewController;
      android.setMediaPlaybackRequiresUserGesture(false);
    }

    ctrl
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36')
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) setState(() => _paymentLoading = true);
        },
        onPageFinished: (currentUrl) async {
          await ctrl.runJavaScript('''
            document.body.style.overflow = 'auto';
            document.documentElement.style.overflow = 'auto';
            document.body.style.height = 'auto';
            document.documentElement.style.height = 'auto';
            document.body.style.minHeight = 'unset';
          ''');

          if (mounted) setState(() => _paymentLoading = false);

          // Ödeme tamamlandı mı?
          if (currentUrl.contains('buskirala.com') &&
              (currentUrl.contains('bt_payment_status') ||
                  currentUrl.contains('bt_order_id') ||
                  currentUrl.contains('bt_reset'))) {
            _controller.loadRequest(Uri.parse(currentUrl));
            if (mounted) setState(() => _paymentController = null);
          }
        },
        onNavigationRequest: (request) => NavigationDecision.navigate,
      ))
      ..loadRequest(Uri.parse(url));

    if (mounted) {
      setState(() {
        _paymentController = ctrl;
        _paymentLoading = true;
      });
    }
  }

  PreferredSizeWidget _buildAppBar({bool showBack = false}) {
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
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
                onPressed: () => setState(() => _paymentController = null),
              )
            : null,
        title: Image.asset('assets/images/buskirala-logo.png', height: 42, fit: BoxFit.contain),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade100),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ödeme ekranı
    if (_paymentController != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(showBack: true),
        body: Stack(
          children: [
            WebViewWidget(controller: _paymentController!),
            if (_paymentLoading)
              Container(
                color: Colors.white,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFFFF6600), strokeWidth: 2.5),
                      SizedBox(height: 16),
                      Text('Güvenli ödeme sayfası yükleniyor...', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // Ana transfer ekranı
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6600), strokeWidth: 2.5),
            ),
        ],
      ),
    );
  }
}