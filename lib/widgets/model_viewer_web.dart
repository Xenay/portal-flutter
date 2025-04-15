import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ModelViewerWeb extends StatefulWidget {
  const ModelViewerWeb({Key? key}) : super(key: key);

  @override
  _ModelViewerWebState createState() => _ModelViewerWebState();
}

class _ModelViewerWebState extends State<ModelViewerWeb> {
  late final WebViewController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset('assets/model_viewer.html');
  }
  
  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
