// index 페이지 전용 관리 객체
Page({
    initialData: {
        text: "데이터 탈취 대기 중"
    },
    
    onLoad: function(options) {
        console.log("[MiniApp B Secure - Index Page] 로드 완료. AppID: " + getApp().globalData.appId);
    },

    // Event handler: 버튼(stealBtn)을 눌렀을 때 실행될 공격 함수
    onMyFunc: function() {
        let resultText = "🚨 탈취 시도 결과 🚨\n\n";
        
        // 시도 1: 구형 취약점 방식 (document.cookie 직접 접근)
        const cookies = document.cookie;
        if (cookies) {
            resultText += "1. SOP 우회 (쿠키): 탈취 성공! (" + cookies + ")\n";
        } else {
            resultText += "1. SOP 우회 (쿠키): 실패 (격리됨)\n";
        }

        // 시도 2: 네이티브 브릿지 권한 우회 시도
        if (window.SuperAppBridge) {
            // B_secure가 자신의 AppID를 보내지 않고, 노리고 있는 A_secure("app_a_secure")의 데이터를 뻔뻔하게 요청함
            const stolenData = window.SuperAppBridge.getStorage("app_a_secure", "auth_token");
            
            // 네이티브 화이트리스트 검증 로직에 의해 차단되어야 정상
            // (참고: 현재 getStorage는 비동기 postMessage 방식이므로 리턴값은 undefined임.
            // 실제 결과는 renderer.dart에서 주입한 코드가 document.getElementById('result')를 업데이트함)
        } else {
            resultText += "2. 브릿지 직접 접근: 실패 (브릿지 없음)\n";
        }

        // 결과 출력
        document.getElementById('result').innerText = resultText;
    }
});