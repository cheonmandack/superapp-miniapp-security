import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:superapp/miniapp/view_layer/renderer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SuperApp DashBoard',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MiniAppListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MiniAppListPage extends StatefulWidget {
  @override
  _MiniAppListPageState createState() => _MiniAppListPageState();
}

class _MiniAppListPageState extends State<MiniAppListPage> {
  List _miniapps = [];

  @override
  void initState() {
    super.initState();
    _loadMiniAppList();
  }

  // assets/miniapps.json에서 미니앱 목록을 로드합니다.
  Future<void> _loadMiniAppList() async {
    try {
      final String response = await rootBundle.loadString('assets/miniapps.json');
      final data = json.decode(response);
      setState(() {
        _miniapps = data;
      });
    } catch (e) {
      print("미니앱 목록 로드 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('슈퍼앱 미니 프로그램 대시보드'),
        centerTitle: true,
      ),
      body: _miniapps.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _miniapps.length,
              itemBuilder: (context, index) {
                final app = _miniapps[index];

                // 미니앱 A와 B에 따라 아이콘과 색상을 다르게 부여하여 시인성 확보
                bool isAttacker = app['id'] == 'app_b';

                return Card(
                  elevation: 4,
                  margin: EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    leading: CircleAvatar(
                      backgroundColor: isAttacker ? Colors.red.withOpacity(0.1) : Colors.indigo.withOpacity(0.1),
                      child: Icon(
                        isAttacker ? Icons.bug_report : Icons.security,
                        color: isAttacker ? Colors.red : Colors.indigo,
                      ),
                    ),
                    title: Text(
                      app['name'] ?? '알 수 없는 앱',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(isAttacker ? '권한 없이 데이터 탈취 시도' : '권한을 통해 쿠키 생성'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(title: Text(app['name'])),
                            body: Renderer(url: app['path']),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}