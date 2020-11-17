import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:oktoast/oktoast.dart'; // 1. import library
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:path_provider/path_provider.dart';
import './home_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OKToast(
        // 这一步
        child: MaterialApp(
      title: 'ImageCropper',
      theme: ThemeData.light().copyWith(primaryColor: Colors.red),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(
        title: '鸿宇购图片编辑',
      ),
    ));
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  MyHomePage({this.title});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum AppState {
  free,
  picked,
  cropped,
}

class _MyHomePageState extends State<MyHomePage> {
  AppState state;
  File imageFile;
  File primaryFile;
  File compressedFile;

  final picker = ImagePicker();
  var time = 0;
  @override
  void initState() {
    super.initState();
    state = AppState.free;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        //如果使用侧边栏则此处不可以添加图标
        // leading:
        // IconButton(
        //   icon: Icon(Icons.menu),
        //   onPressed: () => Scaffold.of(context).openDrawer(),
        // ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _clearImage();
            },
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              ImageGallerySaver.saveFile(imageFile.path);
              print(imageFile.path);
              showToast("保存成功，请到相册查找"); // 可选属性看自己需求
              _clearImage();
            },
          )
        ],
      ),
      body: Center(
          child: imageFile != null
              ? Image.file(imageFile)
              //: Container(),
              : Image.asset('images/logo.png')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        onPressed: () {
          if (state == AppState.free)
            // _openGallery();
            _pickImage();
          else if (state == AppState.picked)
            _cropImage();
          else if (state == AppState.cropped) _clearImage();
        },
        child: _buildButtonIcon(),
      ),
      drawer: _drawer,
    );
  }

  Widget _buildButtonIcon() {
    if (state == AppState.free)
      return Icon(Icons.add);
    else if (state == AppState.picked)
      return Icon(Icons.crop);
    else if (state == AppState.cropped)
      return Icon(Icons.clear);
    else
      return Container();
  }

//抽屉菜单
  get _drawer => Drawer(
        //MediaQuery.removePadding可以移除Drawer内的一些空白间距
        child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(20.0),
                  color: Colors.blue,
                  child: Row(
                    children: <Widget>[
                      //圆形图标
                      ClipOval(
                        child: Image.asset(
                          'images/logo.png',
                          width: 100.0,
                          height: 100.0,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 20.0),
                        child: Text(
                          "图片工具",
                          style: TextStyle(fontSize: 20.0, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  //ListView列表组件
                  child: ListView(
                    children: <Widget>[
                      //ListView的项
                      ListTile(
                        leading: Icon(
                          Icons.shop,
                          color: Colors.orange,
                        ),
                        title: Text("鸿宇购H5"),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) {
                            return new WebMain();
                          }));
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.shop,
                          color: Colors.orange,
                        ),
                        title: Text("鸿宇购(商家)"),
                        onTap: () {
                          //待开发
                          // Navigator.pop(context);
                          // Navigator.push(context,
                          //     MaterialPageRoute(builder: (_) {
                          //   return new WebMain();
                          // }));
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.data_usage,
                          color: Colors.orange,
                        ),
                        title: Text("软件版权声明"),
                        onTap: () {
                          showDialog<Null>(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return new AlertDialog(
                                title: new Text('软件版权声明'),
                                content: new SingleChildScrollView(
                                  child: new ListBody(
                                    children: <Widget>[
                                      new Text(
                                          '软件代码主要来自image_cropper和image_picker的演示代码，进行相关整合，软件仅为学习测试使用。'),
                                      new Text('本软件免费使用，永久免费，无广告'),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  new FlatButton(
                                    child: new Text('确定'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          ).then((val) {
                            print(val);
                          });
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.bookmark,
                          color: Colors.orange,
                        ),
                        title: Text("软件使用说明"),
                        onTap: () {
                          showDialog<Null>(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return new AlertDialog(
                                title: new Text('使用简介'),
                                content: new SingleChildScrollView(
                                  child: new ListBody(
                                    children: <Widget>[
                                      Text.rich(
                                        TextSpan(
                                          style: TextStyle(
                                            fontSize: 17,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: '1.',
                                            ),
                                            WidgetSpan(
                                              child: Icon(
                                                Icons.add,
                                                color: Colors.orange,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '添加图片到显示界面',
                                            )
                                          ],
                                        ),
                                      ),
                                      Text.rich(
                                        TextSpan(
                                          style: TextStyle(
                                            fontSize: 17,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: '2.',
                                            ),
                                            WidgetSpan(
                                              child: Icon(
                                                Icons.crop,
                                                color: Colors.orange,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '进入到裁剪图片界面',
                                            )
                                          ],
                                        ),
                                      ),
                                      Text.rich(
                                        TextSpan(
                                          style: TextStyle(
                                            fontSize: 17,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: '3.',
                                            ),
                                            WidgetSpan(
                                              child: Icon(
                                                Icons.check,
                                                color: Colors.orange,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '完成裁剪回到显示界面',
                                            )
                                          ],
                                        ),
                                      ),
                                      Text.rich(
                                        TextSpan(
                                          style: TextStyle(
                                            fontSize: 17,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: '4.',
                                            ),
                                            WidgetSpan(
                                              child: Icon(
                                                Icons.save,
                                                color: Colors.orange,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '保存裁剪结果到相册',
                                            )
                                          ],
                                        ),
                                      ),
                                      Text.rich(
                                        TextSpan(
                                          style: TextStyle(
                                            fontSize: 17,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: '0.',
                                            ),
                                            WidgetSpan(
                                              child: Icon(
                                                Icons.clear,
                                                color: Colors.orange,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '清除当前图片(放弃编辑)',
                                            )
                                          ],
                                        ),
                                      ),
                                      new Text('按数字顺序操作即可(非零)'),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  new FlatButton(
                                    child: new Text('确定'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          ).then((val) {
                            print(val);
                          });
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.wallpaper,
                          color: Colors.orange,
                        ),
                        title: Text("隐私权限声明"),
                        onTap: () {
                          showDialog<Null>(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return new AlertDialog(
                                title: new Text('隐私权限声明'),
                                content: new SingleChildScrollView(
                                  child: new ListBody(
                                    children: <Widget>[
                                      new Text(
                                          '本软件只调用了相册读写权限，用于打开图片和保存图片。无网络调用和上传任何信息。'),
                                      new Text('如果不放心的请卸载本软件！'),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  new FlatButton(
                                    child: new Text('同意'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  new FlatButton(
                                    //不同意关闭软件
                                    child: new Text('不同意'),
                                    onPressed: () {
                                      exit(0);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          ).then((val) {
                            print(val);
                          });
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.clear,
                          color: Colors.orange,
                        ),
                        title: Text("缓存清理"),
                        onTap: () async {
                          Directory tempDir = await getTemporaryDirectory();
                          double value =
                              await _getTotalSizeOfFilesInDir(tempDir);
                          //showToast(_renderSize(value));
                          showDialog<Null>(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return new AlertDialog(
                                title: new Text('缓存清理'),
                                content: new SingleChildScrollView(
                                  child: new ListBody(
                                    children: <Widget>[
                                      new Text('只清除本软件的缓存，请放心使用！'),
                                      new Text('缓存大小：${_renderSize(value)}'),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  new FlatButton(
                                    child: new Text('返回'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  new FlatButton(
                                    child: new Text('清空'),
                                    onPressed: () {
                                      _clearCache();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          ).then((val) {
                            print(val);
                          });
                          // _clearCache();
                          // loadCache(); //获取缓存文件大小
                          // _clearCache();
                          // getTemporaryDirectory().then((value) => print(value));
                        },
                      ),
                    ],
                  ),
                )
              ],
            )),
      );
  /*拍照*/
  _takePhoto() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      ImageProperties properties =
          await FlutterNativeImage.getImageProperties(image.path);
      File compressedFile = await FlutterNativeImage.compressImage(image.path,
          quality: 90,
          targetWidth: 1600,
          targetHeight: (properties.height * 1600 / properties.width).round());
      setState(() => image = compressedFile);
      setState(() {
        imageFile = image;
        state = AppState.picked;
      });
    }
  }

  /*相册*/
  _openGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      ImageProperties properties =
          await FlutterNativeImage.getImageProperties(image.path);
      File compressedFile = await FlutterNativeImage.compressImage(image.path,
          quality: 90,
          targetWidth: 1600,
          targetHeight: (properties.height * 1600 / properties.width).round());
      setState(() => image = compressedFile);
      setState(() {
        imageFile = image;
        state = AppState.picked;
      });
    }
  }

  //加载图片
  Future<Null> _pickImage() async {
    showDialog<Null>(
      context: context,
      builder: (BuildContext context) {
        return new SimpleDialog(
          title: new Text('选择图片来源'),
          children: <Widget>[
            new SimpleDialogOption(
              child: new Text('相机'),
              onPressed: () {
                _takePhoto();
                Navigator.of(context).pop();
              },
            ),
            new SimpleDialogOption(
              child: new Text('相册'),
              onPressed: () {
                _openGallery();
                Navigator.of(
                  context,
                ).pop();
              },
            ),
          ],
        );
      },
    ).then((val) {
      print(val);
    });
  }

  //裁剪图片
  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: Platform.isAndroid
          ? [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ]
          : [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio5x3,
              CropAspectRatioPreset.ratio5x4,
              CropAspectRatioPreset.ratio7x5,
              CropAspectRatioPreset.ratio16x9
            ],
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: '编辑',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      iosUiSettings: IOSUiSettings(
        title: 'Cropper',
      ),
    );

    if (croppedFile != null) {
      imageFile = croppedFile;
      setState(() {
        state = AppState.cropped;
      });
    }
  }

//清空
  void _clearImage() {
    imageFile = null;
    print('test');
    setState(() {
      state = AppState.free;
    });
  }

  /// 清理缓存
  ///
  void _clearCache() async {
    Directory tempDir = await getTemporaryDirectory();
    //删除缓存目录
    await _delDir(tempDir);
    await loadCache();
    showToast("清除缓存成功"); // 可选属性看自己需求
  }

  // 递归方式删除目录
  Future<Null> _delDir(FileSystemEntity file) async {
    if (file is Directory) {
      final List<FileSystemEntity> children = file.listSync();
      for (final FileSystemEntity child in children) {
        await _delDir(child);
      }
    }
    await file.delete();
  }

// 加载缓存
  Future<String> loadCache() async {
    Directory tempDir = await getTemporaryDirectory();
    double value = await _getTotalSizeOfFilesInDir(tempDir);
    /*tempDir.list(followLinks: false,recursive: true).listen((file){
          //打印每个缓存文件的路径
        print(file.path);
      });*/
    //print('临时目录大小: ' + _renderSize(value).toString());
    showToast(_renderSize(value));
    return _renderSize(value);
  }

// 循环计算文件的大小（递归）
  Future<double> _getTotalSizeOfFilesInDir(final FileSystemEntity file) async {
    if (file is File) {
      int length = await file.length();
      return double.parse(length.toString());
    }
    if (file is Directory) {
      final List<FileSystemEntity> children = file.listSync();
      double total = 0;
      if (children != null)
        for (final FileSystemEntity child in children)
          total += await _getTotalSizeOfFilesInDir(child);
      return total;
    }
    return 0;
  }

// 计算大小
  _renderSize(double value) {
    if (null == value) {
      return 0;
    }
    List<String> unitArr = List()..add('B')..add('K')..add('M')..add('G');
    int index = 0;
    while (value > 1024) {
      index++;
      value = value / 1024;
    }
    String size = value.toStringAsFixed(2);
    if (size == '0.00') {
      return '0M';
    }
    // print('size:${size == 0}\n ==SIZE${size}');
    return size + unitArr[index];
  }
}
