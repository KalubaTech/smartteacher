import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:smart_teacher/components/kalubtn.dart';
import 'package:smart_teacher/helpers/common_methods.dart';
import 'package:smart_teacher/views/ebooks/pdf_reader.dart';
import '../../utils/colors.dart';
import 'package:get/get.dart';

class Ebooks extends StatefulWidget {
  const Ebooks({super.key});

  @override
  State<Ebooks> createState() => _EbooksState();
}

class _EbooksState extends State<Ebooks> {
  List<Map<String, dynamic>> _savedFiles = []; // Stores file and thumbnail path

  @override
  void initState() {
    super.initState();
    _loadSavedFiles();
  }

  Future<void> _loadSavedFiles() async {
    final appDir = await getApplicationDocumentsDirectory();
    final savedFilesDir = Directory('${appDir.path}/ebooks');

    if (await savedFilesDir.exists()) {
      setState(() {
        _savedFiles = savedFilesDir
            .listSync()
            .whereType<File>()
            .map((file) => {'file': file, 'thumbnail': '${file.path}.thumbnail.png'})
            .toList();
      });
    }
  }

  Future<void> _deleteFile(int index) async {
    try {
      final file = _savedFiles[index]['file'] as File;

      // Delete the file
      if (await file.exists()) {
        await file.delete();
      }

      // Delete the thumbnail if it exists
      final thumbnailPath = _savedFiles[index]['thumbnail'] as String?;
      if (thumbnailPath != null) {
        final thumbnailFile = File(thumbnailPath);
        if (await thumbnailFile.exists()) {
          await thumbnailFile.delete();
        }
      }

      // Update the state to remove the file from the list
      setState(() {
        _savedFiles.removeAt(index);
      });

      Get.back(); // Close the dialog after deleting
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  Future<void> _saveFile(File file) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final savedFilesDir = Directory('${appDir.path}/ebooks');

      if (!await savedFilesDir.exists()) {
        await savedFilesDir.create(recursive: true);
      }

      final newFile = File('${savedFilesDir.path}/${file.uri.pathSegments.last}');
      await file.copy(newFile.path);

      // Update the state
      setState(() {
        _savedFiles.add({'file': newFile, 'thumbnail': null});
      });
    } catch (e) {
      print('Error saving file: $e');
    }
  }

  Future<void> _pickAndSaveFiles() async {
    final files = await CommonMethods().pickFiles();
    if (files != null && files.isNotEmpty) {
      for (var file in files) {
        if (file.path!.endsWith('.pdf')) {
          await _saveFile(File(file.path!));
        } else {
          print('Only PDFs are supported for now.');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('eBOOKS'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Karas.danger,
        onPressed: _pickAndSaveFiles,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: _savedFiles.isEmpty
          ? Center(
        child: Image.asset('assets/empty-folder.png'),
      )
          : GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 235,
        ),
        shrinkWrap: true,
        itemCount: _savedFiles.length,
        itemBuilder: (context, index) {
          final item = _savedFiles[index];
          final file = item['file'] as File;

          return InkWell(
            onTap: () {
              // Handle file open or navigation
              Get.to(()=>PdfReader(path: file.path));
            },
            onLongPress: () {
              Get.defaultDialog(
                title: 'Delete File',
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Are you sure you want to delete this file?',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Kalubtn(
                            label: 'Cancel',
                            onclick: () {
                              Get.back(); // Close the dialog
                            },
                          ),
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                          child: Kalubtn(
                          width: 100,
                          label: 'Delete',
                          onclick: () {
                            _deleteFile(index); // Delete the file
                          },
                        ),
                        )
                      ],
                    ),
                  ],
                ),
              );
            },
            child: Container(
              width: 100,
              height: 100,
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: PdfViewer.openFile(
                  file.path,
                  params: const PdfViewerParams(
                    pageNumber: 1,
                    panEnabled: false,
                    scaleEnabled: false,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
