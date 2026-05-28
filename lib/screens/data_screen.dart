import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/dates.dart';
import '../data/export.dart';
import '../providers/app_state_provider.dart';
import '../theme/palette.dart';
import '../widgets/primary_button.dart';

class DataScreen extends ConsumerStatefulWidget {
  const DataScreen({super.key});

  @override
  ConsumerState<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends ConsumerState<DataScreen> {
  final _importController = TextEditingController();
  Timer? _flashTimer;
  String? _flash;
  String? _error;

  @override
  void dispose() {
    _flashTimer?.cancel();
    _importController.dispose();
    super.dispose();
  }

  void _showFlash(String msg) {
    _flashTimer?.cancel();
    setState(() {
      _flash = msg;
      _error = null;
    });
    _flashTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _flash = null);
      _flashTimer = null;
    });
  }

  Future<void> _copyExport() async {
    final state = ref.read(appStateProvider).requireValue;
    final text = exportText(state);
    await Clipboard.setData(ClipboardData(text: text));
    _showFlash('Copied to clipboard');
  }

  Future<void> _saveExport() async {
    try {
      final state = ref.read(appStateProvider).requireValue;
      final text = exportText(state);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/intention-${todayKey()}.txt');
      await file.writeAsString(text);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/plain')],
        subject: 'Intention backup',
      );
      if (!mounted) return;
      _showFlash('Exported');
    } catch (e) {
      if (kDebugMode) debugPrint('Save export failed: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Could not save the file on this device.';
        _flash = null;
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['txt', 'json'],
      );
      if (result == null || result.files.single.path == null) return;
      final file = File(result.files.single.path!);
      final text = await file.readAsString();
      if (!mounted) return;
      _importController.text = text;
      setState(() => _error = null);
    } catch (e) {
      if (kDebugMode) debugPrint('Pick file failed: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Could not open the file.';
        _flash = null;
      });
    }
  }

  Future<void> _restore() async {
    final raw = _importController.text.trim();
    if (raw.isEmpty) {
      setState(() {
        _error = 'Paste your backup contents above.';
        _flash = null;
      });
      return;
    }
    try {
      final parsed = importText(raw);
      final current = ref.read(appStateProvider).requireValue;
      final next = applyImport(current, parsed);
      await ref.read(appStateProvider.notifier).replace(next);
      if (!mounted) return;
      _importController.clear();
      _showFlash('Restored');
    } on ImportException catch (e) {
      setState(() {
        _error = e.message;
        _flash = null;
      });
    } on FormatException catch (e) {
      setState(() {
        _error = 'Could not read the JSON — ${e.message}';
        _flash = null;
      });
    } catch (_) {
      setState(() {
        _error = 'Could not read this backup.';
        _flash = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final state = ref.watch(appStateProvider).requireValue;
    final sits = state.sessions.length;
    final mins = state.sessions.fold<int>(0, (a, s) => a + s.minutes);
    final preview = _previewLines(exportText(state), maxLines: 14);

    return Scaffold(
      backgroundColor: p.bg,
      appBar: AppBar(
        backgroundColor: p.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: p.ink2),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Your data',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 15,
            fontStyle: FontStyle.italic,
            color: p.ink2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 4, 28, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 24),
            child: Text(
              'Everything you keep lives in one plain-text file. Move it across devices, or read it in any text editor.',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 15,
                fontStyle: FontStyle.italic,
                color: p.ink2,
                height: 1.55,
              ),
            ),
          ),
          _SectionTitle('EXPORT'),
          const SizedBox(height: 12),
          Text(
            '$sits sits · $mins min',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 18,
              color: p.ink,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'A copy of what Intention knows about your practice.',
            style: TextStyle(fontSize: 13, color: p.ink3, height: 1.55),
          ),
          const SizedBox(height: 14),
          _CodePreview(text: preview),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              GhostButton(label: 'Save file…', onPressed: _saveExport),
              GhostButton(label: 'Copy to clipboard', onPressed: _copyExport),
              if (_flash != null)
                Text(
                  _flash!,
                  style: TextStyle(
                    fontSize: 12,
                    color: p.ink2,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 36),
          Container(height: 1, color: p.lineSoft),
          const SizedBox(height: 28),
          _SectionTitle('IMPORT'),
          const SizedBox(height: 12),
          Text(
            'Open a backup file or paste its contents below — the # comment lines are fine to keep.',
            style: TextStyle(fontSize: 13, color: p.ink3, height: 1.55),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _pickFile,
              icon: Icon(Icons.folder_open_outlined, color: p.ink2, size: 16),
              label: Text('Open file…',
                  style: TextStyle(
                      fontSize: 13,
                      color: p.ink2,
                      letterSpacing: 0.2)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _importController,
            maxLines: 8,
            minLines: 5,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: p.ink2,
              height: 1.55,
            ),
            cursorColor: p.gold,
            decoration: InputDecoration(
              hintText: '{ "sessions": [ … ] }',
              hintStyle: TextStyle(
                color: p.ink3,
                fontStyle: FontStyle.italic,
              ),
              filled: true,
              fillColor: p.bgSunk,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: p.lineSoft),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: p.line),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              PrimaryButton(
                label: 'Restore',
                onPressed: _restore,
                large: false,
              ),
              const SizedBox(width: 12),
              if (_error != null)
                Expanded(
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB0432A),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(Icons.lock_outline, color: p.ink3, size: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Nothing in this app reaches the network. Your records live only on this device.',
                  style: TextStyle(
                    fontSize: 12,
                    color: p.ink3,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          ],
        ),
      ),
    );
  }

  String _previewLines(String full, {int maxLines = 14}) {
    final lines = full.split('\n');
    if (lines.length <= maxLines) return full.trimRight();
    return '${lines.take(maxLines).join('\n')}\n…';
  }
}

class _CodePreview extends StatelessWidget {
  final String text;
  const _CodePreview({required this.text});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: p.bgSunk,
        borderRadius: BorderRadius.circular(6),
      ),
      constraints: const BoxConstraints(maxHeight: 220),
      child: SingleChildScrollView(
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: p.ink3,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        color: p.ink3,
        letterSpacing: 2.6,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
