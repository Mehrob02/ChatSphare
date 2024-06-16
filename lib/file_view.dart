// ignore_for_file: unused_import

import 'dart:io';

import 'package:chatsphere/home_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class FileView extends StatefulWidget {
  const FileView({super.key, required this.fileUrl});
  final String fileUrl;

  @override
  State<FileView> createState() => _FileViewState();
}

class _FileViewState extends State<FileView> {
  bool isFileDownloaded = true;
  String? localFilePath;
  Future<void> s()async{
    final storage= await _getDownloadsDirectory();
   localFilePath= storage.path;
  }
  @override
  void initState() {
 if(!kIsWeb) s();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
     return
    // !isFileDownloaded? Row(
    //   mainAxisSize: MainAxisSize.min,
    //   crossAxisAlignment: CrossAxisAlignment.center,
    //   children: [
    //     IconButton(onPressed: (){
    //       openFile(widget.fileUrl);
    //     }, icon: const Icon(Icons.download_rounded)),
    //     Icon(
    //        Icons.description_rounded,
    //       size: IconTheme.of(context).size! * 2,
    //     ),
    //   ],
    // ):
   GestureDetector(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(localFilePath??"",),
          Icon(
               Icons.description_rounded,
              size: IconTheme.of(context).size! * 2,
            ),
        ],
      ),
      onDoubleTap: () {
        pickFile();
      },
      onTap: (){
    launchUrl(Uri.parse(widget.fileUrl));
      },
    );
  }
  Future pickFile()async{
try {
  final appStorage =await getDownloadsDirectory();
    final file = File("${appStorage!.path}/$url");
    OpenFile.open(file.path);
} catch (e) {
  launchUrl(Uri.parse(widget.fileUrl));
  debugPrint("$e");
}
  }
  Future openFile(String url)async{
   final file= await downloadFile(url);
   if(file!=null){
 OpenFile.open(file.path);
   }else{
    
   }
  }
  Future<File?> downloadFile(String url)async{
try {
  final appStorage =await getApplicationDocumentsDirectory();
  final file = File("${appStorage.path}/$url");
  final response = await Dio().get(url, options: Options(responseType: ResponseType.bytes,receiveTimeout:Duration.zero,followRedirects: false ));
  final raf= file.openSync(mode: FileMode.write);
  raf.writeFromSync(response.data);
  await raf.close();
  return file;
} on Exception catch (e) {
  debugPrint("$e");
  return null;
}
  }
  Future<Directory> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      return await  getApplicationDocumentsDirectory();
    } else if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}
