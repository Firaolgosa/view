import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';

class WebViewScreen extends StatefulWidget {
  final String? url;
  const WebViewScreen({super.key, this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'flutter_inappwebview',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message == 'close') {
            Navigator.pop(context);
          } else if (message.message == 'navigate_to_google') {
            controller.loadRequest(Uri.parse('https://www.google.com'));
          }
        },
      );

    if (widget.url != null) {
      controller.loadRequest(Uri.parse(widget.url!));
    } else {
      controller.loadFlutterAsset('assets/web/index.html');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: controller),
    );
  }
}