import 'dart:isolate';
import 'dart:ui';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';

const debug = true;

class MyDownTester extends StatefulWidget with WidgetsBindingObserver {
  final TargetPlatform? platform;

  MyDownTester({Key? key, this.title, this.platform}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyDownTester> {
  final _documents = [
    {
      'name': 'Learning Android Studio',
      'link':
      'http://barbra-coco.dyndns.org/student/learning_android_studio.pdf'
    },
    {
      'name': 'Android Programming Cookbook',
      'link':
      'http://enos.itcollege.ee/~jpoial/allalaadimised/reading/Android-Programming-Cookbook.pdf'
    },
    {
      'name': 'iOS Programming Guide',
      'link':
      'http://darwinlogic.com/uploads/education/iOS_Programming_Guide.pdf'
    },
    {
      'name': 'Objective-C Programming (Pre-Course Workbook',
      'link':
      'https://www.bignerdranch.com/documents/objective-c-prereading-assignment.pdf'
    },
  ];

  final _images = [
    {
      'name': 'Arches National Park',
      'link':
      'https://r1---sn-fapo3ox25a-3uh6.googlevideo.com/videoplayback?'
          'expire=1626301244&ei=3A7vYKXQArjf4-EP37KzaA&ip=27.34.'
          '13.122&id=o-AGknl2wIr0IVY_esX0f8-LxoBIc4EFjzr6FeIqC2'
          'qRNq&itag=18&source=youtube&requiressl=yes&mh=J0'
          '&mm=31%2C26&mn=sn-fapo3ox25a-3uh6%2Csn-h557snl6&ms=au'
          '%2Conr&mv=m&mvi=1&pl=24&initcwndbps=535000&vprv=1&mime='
          'video%2Fmp4&ns=-aR-47k92BaP-Prbucfx1esG&gir=yes&clen=299'
          '6333&ratebypass=yes&dur=191.448&lmt=1625883703022750&mt=1626279'
          '197&fvip=1&fexp=24001373%2C24007246&c=WEB&txp=5310222&n=bAw1'
          'o76KPJIGJHeeqF&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%'
          '2Crequiressl%2Cvprv%2Cmime%2Cns%2Cgir%2Cclen%2Cratebypass%2Cdur'
          '%2Clmt&lsparams=mh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Cinitcwn'
          'dbps&lsig=AG3C_xAwRQIgS5wOrMavzlTIq1lIl4pJlwZZ0fU9GymmRtay'
          'stwzVy0CIQDoQ8FkX7A27dXNkFccYdni6bgyvk0RL5WQPudYPxMStw%3D%3'
          'D&sig=AOq0QJ8wRgIhAPJKKE_H_-bKnoMOWFsi02-NCj-4JfbnWNBr6nKLOV'
          'COAiEAjUi5o1UGpvKsydazvjHMLx1YkF-9bx6z3mxvNb9KwO8='
    },
    {
      'name': 'Canyonlands National Park',
      'link':
      'https://r4---sn-fapo3ox25a-3uh6.googlevideo.com/videoplayback?e'
          'xpire=1626302148&ei=ZBLvYJaSDLzz4-EPvKKDyAc&ip=27.34.13.12'
          '2&id=o-AJCZSfH2PKqo-sMf9zE1weB7iFXCACmKehm6-oTNu-FX&itag=1'
          '8&source=youtube&requiressl=yes&mh=Le&mm=31%2C26&mn=sn-fa'
          'po3ox25a-3uh6%2Csn-h5576n7r&ms=au%2Conr&mv=m&mvi=4&pl=24&'
          'initcwndbps=548750&vprv=1&mime=video%2Fmp4&ns=98fmM97Homk'
          'AoXzDOTQlbt8G&gir=yes&clen=20761391&ratebypass=yes&dur=330'
          '.861&lmt=1610667038172202&mt=1626279672&fvip=4&fexp=24001373%2'
          'C24007246&c=WEB&txp=5430434&n=_8MVImkwSIWdGI7Nrp&sparams=expire'
          '%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cvprv%2Cmime'
          '%2Cns%2Cgir%2Cclen%2Cratebypass%2Cdur%2Clmt&lsparams=mh%2Cmm'
          '%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Cinitcwndbps&lsig=AG3C_xAwRQIhA'
          'MPcxEnaFJhETD3y2ExDMPniim_lOD8ed5MnNIjZYbDSAiAtOW_ZAQRrsLmv'
          'z-WCytUBIg0TbXaB9fo7JUR0Fv1XiQ%3D%3D&sig=AOq0QJ8wRgIhAM6fE'
          'U4QDS3j4uiJTiykE-xaao0ukGMhhcSZwKzY42J3AiEAlAzMrtMIypZmJq6'
          'YQokFbqG8bGtpsHUFdjZ-aODXhaw='
    },
    {
      'name': 'Death Valley National Park',
      'link':
      'https://upload.wikimedia.org/wikipedia/commons/b/b2/Sand_Dunes_in_Death_Valley_National_Park.jpg'
    },
    {
      'name': 'Gates of the Arctic National Park and Preserve',
      'link':
      'https://upload.wikimedia.org/wikipedia/commons/e/e4/GatesofArctic.jpg'
    }
  ];

  final _videos = [
    {
      'name': 'Big Buck Bunny',
      'link':
      'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'
    },
    {
      'name': 'Elephant Dream',
      'link':
      'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4'
    }
  ];

  List<_TaskInfo>? _tasks;
  late List<_ItemHolder> _items;
  late bool _isLoading;
  late bool _permissionReady;
  late String _localPath;
  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();

    _bindBackgroundIsolate();

    FlutterDownloader.registerCallback(downloadCallback);

    _isLoading = true;
    _permissionReady = false;

    _prepare();
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      if (debug) {
        print('UI Isolate Callback: $data');
      }
      String? id = data[0];
      DownloadTaskStatus? status = data[1];
      int? progress = data[2];

      if (_tasks != null && _tasks!.isNotEmpty) {
        final task = _tasks!.firstWhere((task) => task.taskId == id);
        setState(() {
          task.status = status;
          task.progress = progress;
        });
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    if (debug) {
      print(
          'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    }
    final SendPort send =
    IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(""),
      ),
      body: Builder(
          builder: (context) => _isLoading
              ? new Center(
            child: new CircularProgressIndicator(),
          )
              : _permissionReady
              ? _buildDownloadList()
              : _buildNoPermissionWarning()),
    );
  }

  Widget _buildDownloadList() => Container(
    child: ListView(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      children: _items
          .map((item) => item.task == null
          ? _buildListSection(item.name!)
          : DownloadItem(
        data: item,
        onItemClick: (task) {
          _openDownloadedFile(task).then((success) {
            if (!success) {
              print('open failed');
              Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('Cannot open this file')));
            }
          });
        },
        onActionClick: (task) {
          if (task.status == DownloadTaskStatus.undefined) {
            _requestDownload(task: task,title: "");
          } else if (task.status == DownloadTaskStatus.running) {
            _pauseDownload(task);
          } else if (task.status == DownloadTaskStatus.paused) {
            _resumeDownload(task);
          } else if (task.status == DownloadTaskStatus.complete) {
            _delete(task);
          } else if (task.status == DownloadTaskStatus.failed) {
            _retryDownload(task);
          }
        },
      ))
          .toList(),
    ),
  );

  Widget _buildListSection(String title) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Text(
      title,
      style: TextStyle(
          fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 18.0),
    ),
  );

  Widget _buildNoPermissionWarning() => Container(
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Please grant accessing storage permission to continue -_-',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey, fontSize: 18.0),
            ),
          ),
          SizedBox(
            height: 32.0,
          ),
          FlatButton(
              onPressed: () {
                _retryRequestPermission();
              },
              child: Text(
                'Retry',
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0),
              ))
        ],
      ),
    ),
  );

  Future<void> _retryRequestPermission() async {
    final hasGranted = await _checkPermission();

    if (hasGranted) {
      await _prepareSaveDir();
    }

    setState(() {
      _permissionReady = hasGranted;
    });
  }

  void _requestDownload({_TaskInfo? task,String? title}) async {
    task!.taskId = await FlutterDownloader.enqueue(
        url: task.link!,
        fileName: title,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: _localPath,
        showNotification: true,
        openFileFromNotification: true);
  }

  void _cancelDownload(_TaskInfo task) async {
    await FlutterDownloader.cancel(taskId: task.taskId!);
  }

  void _pauseDownload(_TaskInfo task) async {
    await FlutterDownloader.pause(taskId: task.taskId!);
  }

  void _resumeDownload(_TaskInfo task) async {
    String? newTaskId = await FlutterDownloader.resume(taskId: task.taskId!);
    task.taskId = newTaskId;
  }

  void _retryDownload(_TaskInfo task) async {
    String? newTaskId = await FlutterDownloader.retry(taskId: task.taskId!);
    task.taskId = newTaskId;
  }

  Future<bool> _openDownloadedFile(_TaskInfo? task) {
    if (task != null) {
      return FlutterDownloader.open(taskId: task.taskId!);
    } else {
      return Future.value(false);
    }
  }

  void _delete(_TaskInfo task) async {
    await FlutterDownloader.remove(
        taskId: task.taskId!, shouldDeleteContent: true);
    await _prepare();
    setState(() {});
  }

  Future<bool> _checkPermission() async {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }

    return false;
  }

  Future<Null> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();

    int count = 0;
    _tasks = [];
    _items = [];

    _tasks!.addAll(_documents.map((document) =>
        _TaskInfo(name: document['name'], link: document['link'])));

    _items.add(_ItemHolder(name: 'Documents'));
    for (int i = count; i < _tasks!.length; i++) {
      _items.add(_ItemHolder(name: _tasks![i].name, task: _tasks![i]));
      count++;
    }

    _tasks!.addAll(_images
        .map((image) => _TaskInfo(name: image['name'], link: image['link'])));

    _items.add(_ItemHolder(name: 'Images'));
    for (int i = count; i < _tasks!.length; i++) {
      _items.add(_ItemHolder(name: _tasks![i].name, task: _tasks![i]));
      count++;
    }

    _tasks!.addAll(_videos
        .map((video) => _TaskInfo(name: video['name'], link: video['link'])));

    _items.add(_ItemHolder(name: 'Videos'));
    for (int i = count; i < _tasks!.length; i++) {
      _items.add(_ItemHolder(name: _tasks![i].name, task: _tasks![i]));
      count++;
    }

    tasks!.forEach((task) {
      for (_TaskInfo info in _tasks!) {
        if (info.link == task.url) {
          info.taskId = task.taskId;
          info.status = task.status;
          info.progress = task.progress;
        }
      }
    });

    _permissionReady = await _checkPermission();

    if (_permissionReady) {
      await _prepareSaveDir();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _prepareSaveDir() async {
    _localPath =
        (await _findLocalPath())! + Platform.pathSeparator + 'Download';

    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String?> _findLocalPath() async {
    final directory = widget.platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory?.path;
  }
}

class DownloadItem extends StatelessWidget {
  final _ItemHolder? data;
  final Function(_TaskInfo?)? onItemClick;
  final Function(_TaskInfo)? onActionClick;

  DownloadItem({this.data, this.onItemClick, this.onActionClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16.0, right: 8.0),
      child: InkWell(
        onTap: data!.task!.status == DownloadTaskStatus.complete
            ? () {
          onItemClick!(data!.task);
        }
            : null,
        child: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 64.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      data!.name!,
                      maxLines: 1,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: _buildActionForTask(data!.task!),
                  ),
                ],
              ),
            ),
            data!.task!.status == DownloadTaskStatus.running ||
                data!.task!.status == DownloadTaskStatus.paused
                ? Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: LinearProgressIndicator(
                value: data!.task!.progress! / 100,
              ),
            )
                : Container()
          ].toList(),
        ),
      ),
    );
  }

  Widget? _buildActionForTask(_TaskInfo task) {
    if (task.status == DownloadTaskStatus.undefined) {
      return RawMaterialButton(
        onPressed: () {
          onActionClick!(task);
        },
        child: Icon(Icons.file_download),
        shape: CircleBorder(),
        constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.running) {
      return RawMaterialButton(
        onPressed: () {
          onActionClick!(task);
        },
        child: Icon(
          Icons.pause,
          color: Colors.red,
        ),
        shape: CircleBorder(),
        constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.paused) {
      return RawMaterialButton(
        onPressed: () {
          onActionClick!(task);
        },
        child: Icon(
          Icons.play_arrow,
          color: Colors.green,
        ),
        shape: CircleBorder(),
        constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.complete) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Ready',
            style: TextStyle(color: Colors.green),
          ),
          RawMaterialButton(
            onPressed: () {
              onActionClick!(task);
            },
            child: Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
            shape: CircleBorder(),
            constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else if (task.status == DownloadTaskStatus.canceled) {
      return Text('Canceled', style: TextStyle(color: Colors.red));
    } else if (task.status == DownloadTaskStatus.failed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Failed', style: TextStyle(color: Colors.red)),
          RawMaterialButton(
            onPressed: () {
              onActionClick!(task);
            },
            child: Icon(
              Icons.refresh,
              color: Colors.green,
            ),
            shape: CircleBorder(),
            constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else if (task.status == DownloadTaskStatus.enqueued) {
      return Text('Pending', style: TextStyle(color: Colors.orange));
    } else {
      return null;
    }
  }
}

class _TaskInfo {
  final String? name;
  final String? link;

  String? taskId;
  int? progress = 0;
  DownloadTaskStatus? status = DownloadTaskStatus.undefined;

  _TaskInfo({this.name, this.link});
}

class _ItemHolder {
  final String? name;
  final _TaskInfo? task;

  _ItemHolder({this.name, this.task});
}