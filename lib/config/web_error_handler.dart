import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WebErrorHandler extends StatelessWidget {
  final Widget child;
  
  const WebErrorHandler({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return child;
    }

    // カスタムエラーハンドラー設定
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return Scaffold(
        appBar: AppBar(
          title: Text('エラーが発生しました'),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Webビルドでエラーが発生しました', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
              SizedBox(height: 20),
              Text('エラー詳細:'),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(12),
                color: Colors.grey[200],
                child: Text(
                  errorDetails.exceptionAsString(),
                  style: TextStyle(fontFamily: 'monospace'),
                ),
              ),
              SizedBox(height: 20),
              Text('アプリを通常モードで実行してください'),
            ],
          ),
        ),
      );
    };
    
    return child;
  }
}
