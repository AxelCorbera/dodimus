import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:dodimus/components/message_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class Home extends StatefulWidget {
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ReceivePort _port = ReceivePort();
  String directory = '';
  String fileName = '';
  String _downloadTaskId = '';
  String cookiesString = '';
  String id = '';
  DownloadTaskStatus status = DownloadTaskStatus(0);
  late InAppWebViewController controller;
  RenameFile renameFile = RenameFile();

  @override
  void initState() {
    CookieManager().deleteAllCookies();
    super.initState();

    findDirectory();
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static Future<void> downloadCallback(
      String id, DownloadTaskStatus status, int progress) async {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await controller.canGoBack()) {
          controller.goBack();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        bottomNavigationBar: Platform.isIOS?Container(
          color: Colors.black,
          height: MediaQuery.of(context).size.height/15,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width: MediaQuery.of(context).size.width/2,
                child: IconButton(onPressed: () async {
                  if (await controller.canGoBack()) {
                  controller.goBack();
                  } else {
                    SystemNavigator.pop();
                  }
                }, icon: const Icon(Icons.arrow_back_ios,
                color: Colors.white,
                size: 30,)),
              ),
              Container(
                width: MediaQuery.of(context).size.width/2,
                child: IconButton(onPressed: (){
                  controller.reload();
                }, icon: const Icon(Icons.refresh,
                    color: Colors.white,
                  size: 30,)),
              )
            ],
          ),
        ):null,
        body: Padding(
            padding: EdgeInsets.only(top: 40.0),
            child: InAppWebView(
              onWebViewCreated: (controller) {
                this.controller = controller;
              },
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(useOnDownloadStart: true),
              ),
              onLoadStop: (controller, url) async {
                if (url != null) {
                  await updateCookies(url);
                }
                setState(() {});
              },
              initialUrlRequest:
                  URLRequest(url: Uri.parse('https://dodimus.com/')),
              onDownloadStart: (controller, url) async {
                Message_Snack(context, 'Descargando...');
                _downloadTaskId = await FlutterDownloader.enqueue(
                  headers: {
                    HttpHeaders.connectionHeader: 'keep-alive',
                    HttpHeaders.cookieHeader: cookiesString,
                  },
                  saveInPublicStorage: true,
                  url: url.toString(),
                  // url: Uri.dataFromString(url.toString(),
                  //         mimeType: 'text/html',
                  //         encoding: Encoding.getByName('utf-8'))
                  //     .toString(),
                  savedDir: directory,
                  showNotification: true,
                  openFileFromNotification: true,
                ).toString();
                _bindBackgroundIsolate();
              },
            )),
      ),
    );
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    if (!_port.isBroadcast) {
      _port.forEach((element) async {
        final status = element[1];
        if (status == DownloadTaskStatus.complete) {
          Message_Snack(context, 'Archivo descargado correctamente!');
          final task = (await FlutterDownloader.loadTasks())!
            .last;
          findTask(task);
        }
      });
    } else {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
    }
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists())
          directory = await getExternalStorageDirectory();
      }
    } catch (err, stack) {
      print("Cannot get download folder path");
    }
    return directory?.path;
  }

  Future<void> updateCookies(Uri url) async {
    List<Cookie> cookies = await CookieManager().getCookies(url: url);
    cookiesString = '';
    for (Cookie cookie in cookies) {
      cookiesString += '${cookie.name}=${cookie.value};';
    }
  }

  void findDirectory() async {
    directory = (await getDownloadPath())!;
  }

  findTask(DownloadTask task) {
      renameFile._directory = directory;
      renameFile._fileName = task.filename!;
      renameFile.rename();
  }
}

class RenameFile {
  String _fileName = '';
  String _directory = '';

  Future<void> rename() async {
    String format = '.'+_fileName.split('.').last;
    String newFilename = '/file-'+DateTime.now().toIso8601String();
    newFilename = newFilename.replaceAll('.', '_');
    newFilename = newFilename.replaceAll(':', '-');
    File file = File(_directory + "/" + _fileName);
    if (file.existsSync()) {
      file.rename(_directory + newFilename+format);
    } else {
    }
  }
}
