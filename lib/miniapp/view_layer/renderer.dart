import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:superapp/miniapp/logic_layer/message_handler.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

// [보안 포인트] 모든 미니앱이 공유하지 않는, 네이티브 계층의 격리된 저장소
// 구조: { "app_id": { "key": "value" } }
Map<String, Map<String, String>> secureNativeStorage = {};

class Renderer extends StatefulWidget {
  Renderer({Key key, this.url}): super(key: key);

  final String url;

  @override
  _RenderedViewState createState() => _RenderedViewState();
}

class _RenderedViewState extends State<Renderer> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  // [핵심] 웹뷰 내부에 SuperAppBridge 객체를 생성해주는 자바스크립트 코드
  String get _bridgeInjectionCode => """
    window.SuperAppBridge = {
      setStorage: function(appId, key, value) {
        var msg = JSON.stringify({action: 'set', appId: appId, key: key, value: value});
        window.SuperAppBridgeChannel.postMessage(msg);
      },
      getStorage: function(appId, key) {
        // 동기 리턴은 어려우므로, 결과는 다시 브릿지를 통해 콜백으로 받는 구조가 정석이지만
        // PoC를 위해 간단한 알림 형태로 구현하거나 로직을 단순화합니다.
        var msg = JSON.stringify({action: 'get', appId: appId, key: key});
        window.SuperAppBridgeChannel.postMessage(msg);
      }
    };
  """;

  @override
  Widget build(BuildContext context) {
    String targetAsset = widget.url ?? 'assets/miniapp/index.html';
    String sharedFileUrl = 'file:///android_asset/flutter_assets/$targetAsset';

    return WebView(
      initialUrl: sharedFileUrl,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        _controller.complete(webViewController);
      },
      onPageFinished: (url) {
        // 페이지 로드가 끝나면 브릿지 인터페이스를 주입합니다.
        _controller.future.then((controller) {
          controller.evaluateJavascript(_bridgeInjectionCode);
        });
      },
      javascriptChannels: <JavascriptChannel>[
        logicMessageHandler(context, _controller),
        _createSuperAppBridge(context), // 보안 브릿지 채널 추가
      ].toSet(),
    );
  }

  // [보안 로직] 네이티브에서 실행되는 브릿지 핸들러
  JavascriptChannel _createSuperAppBridge(BuildContext context) {
    return JavascriptChannel(
      name: 'SuperAppBridgeChannel',
      onMessageReceived: (JavascriptMessage message) {
        try {
          final data = json.decode(message.message);
          String action = data['action'];
          String appId = data['appId'];
          String key = data['key'];

          // [방어 포인트] 현재 실행 중인 미니앱의 경로를 확인하여 권한 검증
          // (실제 상용 앱은 세션이나 토큰으로 검증하지만, PoC에서는 URL 기반으로 검증 모사)
          bool isAuthorized = widget.url.contains(appId) ||
                             (appId == "app_a_secure" && widget.url.contains("miniapp_A_secure")) ||
                             (appId == "app_b_secure" && widget.url.contains("miniapp_B_secure"));

          if (action == 'set') {
            if (isAuthorized) {
              secureNativeStorage[appId] ??= {};
              secureNativeStorage[appId][key] = data['value'];
              print("✅ [Native Bridge] 저장 성공 ($appId): $key");
            } else {
              print("❌ [Native Bridge] 보안 경고: $appId 가 데이터 저장을 시도했으나 권한이 거부됨!");
            }
          } else if (action == 'get') {
            if (isAuthorized) {
              String val = (secureNativeStorage[appId] != null) ? secureNativeStorage[appId][key] : "null";
              _controller.future.then((c) => c.evaluateJavascript("console.log('Native Storage Data: $val')"));

              // 화면 결과 업데이트를 위해 결과창에 성공 메시지 전달 (공격 성공 시나리오용)
              if (widget.url.contains("secure")) {
                 _controller.future.then((c) => c.evaluateJavascript("if(document.getElementById('result')) document.getElementById('result').innerText += '\\n3. 브릿지 직접 접근: 성공 ($val)'"));
              }
            } else {
              print("❌ [Native Bridge] 보안 경고: 타 앱($appId)의 데이터 접근 차단됨!");
              if (widget.url.contains("secure")) {
                 _controller.future.then((c) => c.evaluateJavascript("if(document.getElementById('result')) document.getElementById('result').innerText += '\\n3. 브릿지 직접 접근: 실패 (권한 거부)'"));
              }
            }
          }
        } catch (e) {
          print("Bridge Error: $e");
        }
      },
    );
  }
}