import 'package:flutter/material.dart';

class PdfReader extends StatelessWidget {
  String path;
  PdfReader({required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Container() /*PdfViewer.file(path, params: PdfViewerParams(
        backgroundColor: Colors.white
      )*/,

    );
  }
}
