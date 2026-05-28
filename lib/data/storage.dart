import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../domain/app_state.dart';

abstract class Storage {
  Future<AppState> load();
  Future<void> save(AppState state);
}

class FileStorage implements Storage {
  static const _fileName = 'state.json';

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  @override
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

  @override
  Future<void> save(AppState state) async {
    try {
      final f = await _file();
      await f.writeAsString(
        const JsonEncoder.withIndent('  ').convert(state.toJson()),
        flush: true,
      );
    } catch (_) {
      // Persistence failure shouldn't break the UI flow. On a supported
      // platform the file write always succeeds; on web there is no file
      // path, so we swallow and accept the lack of persistence.
    }
  }
}

class MemoryStorage implements Storage {
  AppState _state;
  MemoryStorage([AppState initial = AppState.empty]) : _state = initial;

  @override
  Future<AppState> load() async => _state;

  @override
  Future<void> save(AppState state) async {
    _state = state;
  }
}
