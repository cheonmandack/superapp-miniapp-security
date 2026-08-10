import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:superapp/miniapp/logic_layer/message_handler.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class Renderer extends StatefulWidget {
  Renderer({Key key, this.url}): super(key: key);

  final String url;

  @override
  _RenderedViewState createState() => _RenderedViewState();
}

class _RenderedViewState extends State<Renderer> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    // 1. widget.url이 없으면 기본 index.html을, 있으면 전달받은 경로(미니앱A or B)를 사용합니다.
    String targetAsset = widget.url ?? 'assets/miniapp/index.html';

    // 2. data:uri 대신 안드로이드 네이티브 에셋의 절대 경로(file:// 스킴)를 구성합니다.
    String sharedFileUrl = 'file:///android_asset/flutter_assets/$targetAsset';

    return WebView(
      // 3. about:blank와 _loadHtmlFromAssets() 대신, 구성한 경로를 바로 로드합니다.
      initialUrl: sharedFileUrl,

      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        _controller.complete(webViewController);
      },
      javascriptChannels: <JavascriptChannel>[
        logicMessageHandler(context, _controller),
      ].toSet(),
    );
  }
}