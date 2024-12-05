import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'package:view/core/widgets/custom_modal.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';


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
            if (request.url.contains('https://cbrs-dashboard-8mig.vercel.app/')) {
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
        case 'get_auth_user':
          await _sendUserData();
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

  Future<void> _pickAndUploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final bytes = file.bytes;
        
        if (bytes != null) {
          final base64File = base64Encode(bytes);
          final mimeType = lookupMimeType(file.name ?? '') ?? 'application/octet-stream';

          await controller.runJavaScript('''
            receiveFileFromApp({
              name: '${file.name}',
              type: '${mimeType}',
              data: '$base64File'
            });
          ''');
        }
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  Future<void> _sendUserData() async {
    // Static user data
    final userData = {
      'action': 'auth_user_response',
      'data': {
        'name': 'Henok  ',
        'email': 'Henok.m@Eaglelion.com',
        'role': 'Senior Developer'
      }
    };

    // Send data to WebView
    await controller.runJavaScript('''
      window.postMessage('${jsonEncode(userData)}', '*');
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: WebViewWidget(controller: controller),
          floatingActionButton: FloatingActionButton(
            onPressed: _pickAndUploadFile,
            child: const Icon(Icons.upload_file),
            backgroundColor: Theme.of(context).primaryColor,
          ),
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