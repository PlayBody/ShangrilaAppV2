import 'dart:async';

import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
import 'package:shangrila/src/interface/component/form/main_form.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../common/globals.dart' as globals;

class ConnectSale extends StatefulWidget {
  final String url;
  const ConnectSale({required this.url, super.key});

  @override
  _ConnectSale createState() => _ConnectSale();
}

class _ConnectSale extends State<ConnectSale> {
  late Future<List> loadData;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    loadData = loadSiteData();
    
    // Initialize WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    globals.connectHeaerTitle = '通販';
    return MainForm(
        title: '通販',
        render: FutureBuilder<List>(
          future: loadData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                  // padding: EdgeInsets.only(left: 10, right: 10),
                  child: WebViewWidget(
                controller: _controller,
              ));
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner.
            return Center(child: CircularProgressIndicator());
          },
        ));
  }

  Future<List> loadSiteData() async {
    print(widget.url);
    return [];
  }
}
