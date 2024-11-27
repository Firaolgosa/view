import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'package:view/core/widgets/custom_modal.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';


class WebViewScreen extends StatefulWidget {
  final String? url;
  const WebViewScreen({super.key, this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;
  bool _showModal = false;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'flutter_inappwebview',
        onMessageReceived: (JavaScriptMessage message) {
          _handleWebMessage(message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('facebook.com/login')) {
              _showFacebookPermissionModal();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    if (widget.url != null) {
      controller.loadRequest(Uri.parse(widget.url!));
    } else {
      controller.loadFlutterAsset('assets/web/index.html');
    }
  }

  void _showPermissionModal() {
    setState(() => _showModal = true);
  }

  void _showFacebookPermissionModal() {
    showDialog(
      context: context,
      builder: (context) => CustomModal(
        title: 'Facebook Sign In',
        message: 'Would you like to proceed with Facebook sign in?',
        onConfirm: () {
          Navigator.pop(context);
          controller.loadRequest(Uri.parse('https://www.facebook.com/login'));
        },
        onCancel: () {
          Navigator.pop(context);
          context.go('/');
        },
      ),
    );
  }

  void _handleWebMessage(JavaScriptMessage message) {
    if (message.message == 'close') {
        Navigator.pop(context);
    } else if (message.message == 'navigate_to_instagram') {
        _showPermissionModal();
    } else {
        try {
            final data = jsonDecode(message.message);
            _processWebMessage(data);
        } catch (e) {
            debugPrint('Error processing message: $e');
        }
    }
  }

  Future<void> _processWebMessage(dynamic message) async {
    if (message is Map) {
      final action = message['action'];
      final data = message['data'];

      switch (action) {
        case 'connect':
          await _handleConnectRequest(data);
          break;
        case 'navigate_to_instagram':
          _showPermissionModal();
          break;
        case 'close':
          Navigator.pop(context);
          break;
        default:
          debugPrint('Unknown action: $action');
      }
    }
  }

  Future<void> _handleConnectRequest(Map<String, dynamic>? data) async {
    if (data != null) {
      await controller.runJavaScript('''
        window.postMessage({
          source: 'flutter',
          action: 'connectionStatus',
          data: {
            status: 'connected',
            timestamp: '${DateTime.now().toIso8601String()}'
          }
        }, '*');
      ''');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: WebViewWidget(controller: controller),
        ),
        if (_showModal)
          CustomModal(
            title: 'Permission Required',
            message: 'Would you like to proceed to Instagram.com to complete your purchase?',
            onConfirm: () {
              setState(() => _showModal = false);
              controller.loadRequest(Uri.parse('https://www.instagram.com'));
            },
            onCancel: () {
              setState(() => _showModal = false);
            },
          ),
      ],
    );
  }
}