import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static Future<File> _getLocalFile(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$filename');
  }

  static Future<void> writeJson(String filename, dynamic data) async {
    final file = await _getLocalFile(filename);
    await file.writeAsString(jsonEncode(data));
  }

  static Future<List<dynamic>> readJson(String filename) async {
    try {
      final file = await _getLocalFile(filename);
      if (!await file.exists()) return [];
      final contents = await file.readAsString();
      return jsonDecode(contents);
    } catch (_) {
      return [];
    }
  }
}
