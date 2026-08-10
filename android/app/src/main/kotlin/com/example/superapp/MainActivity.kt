package com.example.superapp

import android.os.Bundle
import android.webkit.CookieManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {

    // 앱이 실행될 때 가장 먼저 호출되는 onCreate 단계에서 쿠키 설정을 강제합니다.
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // CookieManager 인스턴스 획득
        val cookieManager = CookieManager.getInstance()

        // 1. 모든 웹뷰에서 기본 쿠키 허용
        cookieManager.setAcceptCookie(true)

        // 2. [중요] file:// 스킴에서 쿠키를 허용하도록 강제 설정
        // 이 옵션이켜져 있어야 로컬 에셋(HTML) 간에 CMCS 쿠키 공유가 성공적으로 이루어집니다.
        CookieManager.setAcceptFileSchemeCookies(true)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
}