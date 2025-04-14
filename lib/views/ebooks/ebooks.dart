import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_thumbnail/pdf_thumbnail.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:smart_teacher/components/kalubtn.dart';
import 'package:smart_teacher/helpers/common_methods.dart';
import 'package:smart_teacher/views/ebooks/pdf_reader.dart';
import '../../utils/colors.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts;

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
        title: const Text('eBOOKS',style: TextStyle(fontWeight: FontWeight.bold),),
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
          : Column(
            children: [
              Column(
                children: [
                  SizedBox(height: 20,),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text('My Books', style: gfonts.GoogleFonts.gabarito(fontSize: 18, fontWeight: FontWeight.bold),),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _savedFiles.length,
                      scrollDirection: Axis.horizontal,
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
                            height: 200,
                            width: 120,
                            color: Karas.primary,
                            child: PdfThumbnail.fromFile(
                              file.path,
                              currentPage: 1,
                              backgroundColor: Colors.white,
                              scrollToCurrentPage: false,
                              onPageClicked: (p){
                                Get.to(()=>PdfReader(path: file.path));
                              },
                              loadingIndicator:  Shimmer(
                                duration: Duration(seconds: 3), //Default value
                                interval: Duration(seconds: 5), //Default value: Duration(seconds: 0)
                                color: Colors.white, //Default value
                                colorOpacity: 0, //Default value
                                enabled: true, //Default value
                                direction: ShimmerDirection.fromLTRB(),  //Default Value
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Karas.background,
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Center(
                                      child: LoadingAnimationWidget.flickr(size: 20, leftDotColor: Karas.primary, rightDotColor: Karas.secondary)
                                  ),

                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    height: 200,
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(height: 20,),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text('Public Library', style: gfonts.GoogleFonts.gabarito(fontSize: 18, fontWeight: FontWeight.bold),),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _savedFiles.length,
                      scrollDirection: Axis.horizontal,
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
                            height: 200,
                            width: 120,
                            color: Karas.primary,
                            child: PdfThumbnail.fromFile(
                              file.path,
                              currentPage: 1,
                              backgroundColor: Colors.white,
                              scrollToCurrentPage: false,
                              onPageClicked: (p){
                                Get.to(()=>PdfReader(path: file.path));
                              },
                              loadingIndicator: Shimmer(
                                duration: Duration(seconds: 3), //Default value
                                interval: Duration(seconds: 5), //Default value: Duration(seconds: 0)
                                color: Colors.white, //Default value
                                colorOpacity: 0, //Default value
                                enabled: true, //Default value
                                direction: ShimmerDirection.fromLTRB(),  //Default Value
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Karas.background,
                                    borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Center(
                                      child: LoadingAnimationWidget.flickr(size: 20, leftDotColor: Karas.primary, rightDotColor: Karas.secondary)
                                  ),
                                  
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    height: 200,
                  ),
                ],
              ),
            ],
          ),
    );
  }
}
