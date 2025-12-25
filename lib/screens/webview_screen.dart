import 'package:flutter/material.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import '../theme/app_theme.dart';

// Minimized browser bilgilerini tutacak model
class MinimizedBrowser {
  final String url;
  final String title;
  final Color themeColor;
  final String currentUrl;

  MinimizedBrowser({
    required this.url,
    required this.title,
    required this.themeColor,
    required this.currentUrl,
  });
}

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;
  final Color themeColor;
  final Function(MinimizedBrowser)? onMinimize;

  const WebViewScreen({
    super.key,
    required this.url,
    required this.title,
    this.themeColor = AppTheme.neonBlue,
    this.onMinimize,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebKitWebViewController _controller;
  bool _isLoading = true;
  double _loadingProgress = 0;
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;
    _initWebView();
  }

  void _initWebView() {
    final params = WebKitWebViewControllerCreationParams(
      allowsInlineMediaPlayback: true,
      mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
    );

    _controller = WebKitWebViewController(params);
    
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    
    final navigationDelegate = WebKitNavigationDelegate(
      WebKitNavigationDelegateCreationParams(),
    );
    
    navigationDelegate.setOnPageStarted((String url) {
      setState(() {
        _isLoading = true;
        _currentUrl = url;
      });
    });
    
    navigationDelegate.setOnPageFinished((String url) {
      setState(() {
        _isLoading = false;
        _currentUrl = url;
      });
    });
    
    navigationDelegate.setOnProgress((int progress) {
      setState(() {
        _loadingProgress = progress / 100;
      });
    });

    _controller.setPlatformNavigationDelegate(navigationDelegate);
    _controller.loadRequest(LoadRequestParams(uri: Uri.parse(widget.url)));
  }

  void _minimizeWindow() {
    final minimized = MinimizedBrowser(
      url: widget.url,
      title: widget.title,
      themeColor: widget.themeColor,
      currentUrl: _currentUrl,
    );
    
    if (widget.onMinimize != null) {
      widget.onMinimize!(minimized);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.cardColor,
        elevation: 0,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red.shade400, size: 24),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Kapat',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            IconButton(
              icon: Icon(Icons.minimize, color: AppTheme.neonBlue, size: 24),
              onPressed: _minimizeWindow,
              tooltip: 'Simge Durumuna Küçült',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ],
        ),
        leadingWidth: 90,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.themeColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIconForTitle(widget.title),
                color: widget.themeColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: widget.themeColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _currentUrl,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white.withOpacity(0.7)),
            onPressed: () async {
              if (await _controller.canGoBack()) {
                await _controller.goBack();
              }
            },
            tooltip: 'Geri',
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.7)),
            onPressed: () async {
              if (await _controller.canGoForward()) {
                await _controller.goForward();
              }
            },
            tooltip: 'İleri',
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white.withOpacity(0.7)),
            onPressed: () => _controller.reload(),
            tooltip: 'Yenile',
          ),
          const SizedBox(width: 8),
        ],
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: _loadingProgress,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.themeColor),
                ),
              )
            : null,
      ),
      body: WebKitWebViewWidget(
        WebKitWebViewWidgetCreationParams(controller: _controller),
      ).build(context),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'e-Devlet':
        return Icons.account_balance;
      case 'UYAP':
        return Icons.gavel;
      case 'GİB - Dijital Vergi Dairesi':
        return Icons.receipt_long;
      default:
        return Icons.language;
    }
  }
}
