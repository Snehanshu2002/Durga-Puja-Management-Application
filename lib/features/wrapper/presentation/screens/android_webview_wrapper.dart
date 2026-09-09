import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:durgapuja_manager/core/constants/app_constants.dart';

/// Lightweight Android WebView Wrapper for Durga Puja Manager Web App.
/// Loads https://durga-puja-manager.web.app with back navigation, session
/// persistence, and offline retry screen.
class AndroidWebViewWrapper extends StatefulWidget {
  const AndroidWebViewWrapper({super.key});

  @override
  State<AndroidWebViewWrapper> createState() => _AndroidWebViewWrapperState();
}

class _AndroidWebViewWrapperState extends State<AndroidWebViewWrapper> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/app_logo.png'), context);
  }

  void _initWebView() {
    final WebViewController controller = WebViewController();

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFF9F2))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            // Only capture main frame errors for full error screen
            if (error.isForMainFrame ?? true) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _hasError = true;
                  _errorMessage = error.description;
                });
              }
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final String url = request.url.toLowerCase();
            // Allow app domain and standard auth domains
            if (url.startsWith('https://durga-puja-manager.web.app') ||
                url.startsWith('https://durga-puja-manager.firebaseapp.com') ||
                url.contains('accounts.google.com') ||
                url.contains('firebase') ||
                url.contains('googleapis.com')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('${AppConstants.webAppUrl}?t=${DateTime.now().millisecondsSinceEpoch}'));

    _controller = controller;
  }

  Future<void> _reload() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    final String timestampUrl = '${AppConstants.webAppUrl}?t=${DateTime.now().millisecondsSinceEpoch}';
    await _controller.loadRequest(Uri.parse(timestampUrl));
  }

  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }
    if (!mounted) return true;
    final bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Exit Durga Puja Manager?'),
          content: const Text('Are you sure you want to exit the application?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B1E2B),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        final bool shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF9F2),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              // Main WebView Widget
              if (!_hasError)
                WebViewWidget(controller: _controller),

              // Animated Dynamic Splash & Loading Overlay (Pulsing Logo + Rotating Gold Ring)
              if (_isLoading && !_hasError)
                const AnimatedSplashOverlay(),

              // Offline / Error Screen
              if (_hasError)
                Container(
                  color: const Color(0xFF121212),
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0x26FF9800),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.wifi_off_rounded,
                            size: 56,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No Internet Connection',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Unable to connect to ${AppConstants.appName}. Please check your mobile data or Wi-Fi network and tap Retry.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                            height: 1.4,
                          ),
                        ),
                        if (_errorMessage.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7B1E2B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _reload,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text(
                            'Retry Connection',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dynamic Animated Splash Overlay with Pulsing Logo & Rotating Gold Halo
class AnimatedSplashOverlay extends StatefulWidget {
  const AnimatedSplashOverlay({super.key});

  @override
  State<AnimatedSplashOverlay> createState() => _AnimatedSplashOverlayState();
}

class _AnimatedSplashOverlayState extends State<AnimatedSplashOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.96, end: 1.05).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.05, end: 0.96).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
    ]).animate(_controller);

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF9F2),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Dynamic Animated Rotating Gold Ring & Pulsing Logo Card
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Rotating Gold Ring Accent
                    RotationTransition(
                      turns: _rotationAnimation,
                      child: Container(
                        width: 236,
                        height: 236,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              const Color(0xFFD4A72C).withValues(alpha: 0.85),
                              const Color(0xFF7B1E2B).withValues(alpha: 0.15),
                              const Color(0xFFEBC764).withValues(alpha: 0.85),
                              const Color(0xFF7B1E2B).withValues(alpha: 0.15),
                              const Color(0xFFD4A72C).withValues(alpha: 0.85),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Inner Soft Padding Container
                    Container(
                      width: 224,
                      height: 224,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF9F2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Pulsing Center Logo Card
                    Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(36),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4A72C).withValues(alpha: 0.4),
                              blurRadius: 28,
                              spreadRadius: 3,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: const Color(0xFF7B1E2B).withValues(alpha: 0.18),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.temple_hindu,
                              size: 90,
                              color: Color(0xFF7B1E2B),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              AppConstants.appName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B1E2B),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppConstants.appTagline,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B6060),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 40),
            // Dynamic Circular Progress Indicator + Action Text
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B1E2B)),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Opening Durga Puja Manager...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7B1E2B),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
