// index 페이지 전용 관리 객체
Page({
    initialData: {
        text: "보안 토큰 생성 대기 중"
    },
    
    onLoad: function(options) {
        console.log("[MiniApp A Secure - Index Page] 페이지가 로드되었습니다 (onLoad)");
        const app = getApp();
        console.log("현재 구동 중인 AppID: " + app.globalData.appId);
    },

    // Event handler: 버튼(saveBtn)을 눌렀을 때 실행될 함수 (onMyFunc를 활용)
    onMyFunc: function() {
        const app = getApp();
        const tokenValue = "SECRET_TOKEN_A_SECURE_" + Math.floor(Math.random() * 1000);
        
        // 브릿지를 통한 안전한 격리 저장 로직
        if (window.SuperAppBridge) {
            window.SuperAppBridge.setStorage(app.globalData.appId, "auth_token", tokenValue);
            document.getElementById('status').innerText = "안전 저장소에 저장됨: " + tokenValue;
            console.log("Secure storage set via Bridge: " + tokenValue);
        } else {
            document.getElementById('status').innerText = "오류: 네이티브 브릿지가 없습니다.";
        }
    }
});