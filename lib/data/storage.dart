import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../domain/app_state.dart';

class Storage {
  static const _fileName = 'state.json';

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<AppState> load() async {
    try {
      final f = await _file();
      if (!await f.exists()) return AppState.empty;
      final text = await f.readAsString();
      if (text.trim().isEmpty) return AppState.empty;
      final parsed = jsonDecode(text);
      if (parsed is! Map<String, dynamic>) return AppState.empty;
      return AppState.fromJson(parsed);
    } catch (_) {
      return AppState.empty;
    }
  }

  Future<void> save(AppState state) async {
    final f = await _file();
    await f.writeAsString(
      const JsonEncoder.withIndent('  ').convert(state.toJson()),
      flush: true,
    );
  }
}
