import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfReader extends StatelessWidget {
  String path;
  PdfReader({required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: PdfViewer.file(path, params: PdfViewerParams(
        backgroundColor: Colors.white
      ),),
    );
  }
}
