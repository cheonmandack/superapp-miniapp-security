// 미니앱 전체를 관장하는 전역 객체
App({
    onLaunch: function(options) {
        console.log("[MiniApp B Secure] 공격자 앱이 실행되었습니다 (onLaunch)");
    },
    onShow: function(options) {
        console.log("[MiniApp B Secure] 앱이 화면에 나타났습니다 (onShow)");
    },
    onHide: function() {
        console.log("[MiniApp B Secure] 앱이 백그라운드로 전환되었습니다 (onHide)");
    },
    onError: function(msg) {
        console.error("[MiniApp B Secure] 에러 발생: ", msg);
    },
    // 모든 페이지가 공유하는 전역 데이터
    globalData: {
        appId: "app_b_secure",
        version: "1.0.0"
    }
});