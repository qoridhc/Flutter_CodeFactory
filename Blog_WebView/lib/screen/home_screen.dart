import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeScreen extends StatelessWidget {
  WebViewController? controller;
  final homeUrl = 'https://blog.codefactory.ai';
  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Code Factory'),
        centerTitle: true, //앱바 글자 가운데 정렬
        actions: [
          IconButton(
            onPressed: () { // 버튼이 눌렸을 경우
              if(controller == null) { // 컨트롤러 NULL 처리
                return;
              }
              controller!.loadUrl(homeUrl); // homeUrl을 로드
            },
            icon: Icon(
              Icons.home,
            ),
          ), //Icon을 Button으로 만들어주는 위젯
        ],
      ),
      body: WebView(
        onWebViewCreated: (WebViewController controller) { // 컨트롤러 매개변수로 받아서 클래스 내부 컨트롤러에 저장
          this.controller = controller;
        },
        initialUrl: homeUrl,
        javascriptMode: JavascriptMode.unrestricted, // 유튜브 보려면 js 허락해줘야함
      ),
    );
  }
}
