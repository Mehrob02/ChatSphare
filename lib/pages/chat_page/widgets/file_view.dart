// ignore_for_file: unused_import

import 'dart:io';

import 'package:chatsphere/pages/home_page/pages/home_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;

class FileView extends StatefulWidget {
  const FileView({super.key, required this.fileUrl, this.fileName});
  final String fileUrl;
  final String? fileName;
  @override
  State<FileView> createState() => _FileViewState();
}

class _FileViewState extends State<FileView> {
  bool isFileDownloaded = true;
  String? localFilePath;
  double _progress = 0.0;

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
         if(_progress>0||_progress>99) Text(_progress.toString()),
          Icon(
               Icons.description_rounded,
              size: IconTheme.of(context).size! * 2,
            ),
        ],
      ),
      onDoubleTap: () {
      downloadFile();
      },
      onTap: (){
    launchUrl(Uri.parse(widget.fileUrl));
   
      },
    );
  }
  void downloadFile()async{
     final permissionStatus = await Permission.storage.request();

   if (permissionStatus.isGranted) {
    try {
    FileDownloader.downloadFile(
      url: widget.fileUrl,
      name: (widget.fileName??path.basename(Uri.parse(widget.fileUrl).path)),
      onProgress: (fileName, progress) {
        setState(() {
          _progress = progress;
        });
      },
      // onDownloadCompleted: (path) {
      //   OpenFile.open(path);
      // },
      );}
      catch(e){   
        if (kDebugMode) {
          print(e.toString());
        }
      }}

  }
// void openFile(String url) async {
//   final permissionStatus = await Permission.storage.request();

//   if (permissionStatus.isGranted) {
//     try {
//       final externalDir = await getExternalStorageDirectory();
//       final savePath = "${externalDir!.path}/downloads";

//       final taskId = await FlutterDownloader.enqueue(
//         url: url,
//         savedDir: savePath,
//         showNotification: true,
//         openFileFromNotification: true,
//         saveInPublicStorage: true, // Добавьте этот параметр
//       );

//       if (taskId != null) {
//         // Получение пути к загруженному файлу и его открытие
//         String? localFilePath = await getDownloadedFilePath(taskId);
//         if (localFilePath != null && localFilePath.isNotEmpty) {
//           OpenFile.open(localFilePath);
//         }
//       }
//     } catch (e) {
//       debugPrint("Ошибка при загрузке файла: $e");
//     }
//   } else {
//     if (kDebugMode) {
//       print('Permission denied');
//     }
//   }
// }

// Future<String?> getDownloadedFilePath(String taskId) async {
//   List<DownloadTask>? tasks = await FlutterDownloader.loadTasksWithRawQuery(query: "SELECT * FROM task WHERE task_id='$taskId'");
//   if (tasks!.isNotEmpty) {
//     return '${tasks.first.savedDir}/${tasks.first.filename!}';
//   }
//   return null;
// }
 }