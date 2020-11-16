import 'dart:io';
import 'package:path_provider/path_provider.dart';

// 加载缓存
Future<String> loadCache() async {
  Directory tempDir = await getTemporaryDirectory();
  double value = await _getTotalSizeOfFilesInDir(tempDir);
  /*tempDir.list(followLinks: false,recursive: true).listen((file){
          //打印每个缓存文件的路径
        print(file.path);
      });*/
  print('临时目录大小: ' + value.toString());
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
