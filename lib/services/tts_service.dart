import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

/// TTS 服务，通过 PowerShell 调用 Windows System.Speech.Synthesis
/// 将英文文本合成为 wav 文件。
///
/// 特性：
/// - 文本 hash 缓存，同一文本不重复合成
/// - 串行队列，同一时间仅运行一个 PowerShell 进程
/// - 优先级机制，用户触发的请求可插队
class TtsService {
  /// 内存缓存：text hash → wav 文件路径
  final Map<String, String> _cache = {};

  /// 正在合成的 Completer（防止重复触发）
  final Map<String, Completer<String?>> _inProgress = {};

  /// 串行合成队列：存入 (text, completer, isPriority)
  final Queue<_SynthesisTask> _queue = Queue();

  /// 队列是否正在处理
  bool _isProcessing = false;

  /// 预合成任务的 cancellation token
  final Set<String> _preSynthKeys = {};

  /// 合成文本到 wav 文件，返回文件路径。
  /// 命中缓存则直接返回。合成失败返回 null。
  Future<String?> synthesize(String text) async {
    if (text.trim().isEmpty) return null;

    final key = _hashText(text);

    // 命中缓存
    if (_cache.containsKey(key)) return _cache[key];

    // 已有相同任务在队列中，等待其结果
    if (_inProgress.containsKey(key)) return _inProgress[key]!.future;

    final completer = Completer<String?>();
    _inProgress[key] = completer;

    // 用户触发的请求：取消所有预合成任务，插入队列前端
    _cancelPendingPreSynth();
    _queue.addFirst(_SynthesisTask(text, key, completer, isPriority: true));

    _processQueue();
    return completer.future;
  }

  /// 后台预合成（fire-and-forget），不阻塞调用方。
  /// 预合成任务优先级低于用户触发的 synthesize。
  void preSynthesize(String text) {
    if (text.trim().isEmpty) return;

    final key = _hashText(text);

    // 已缓存或已在队列中
    if (_cache.containsKey(key) || _inProgress.containsKey(key)) return;

    final completer = Completer<String?>();
    _inProgress[key] = completer;
    _preSynthKeys.add(key);

    _queue.addLast(_SynthesisTask(text, key, completer, isPriority: false));

    _processQueue();
  }

  /// 取消所有未执行的预合成任务
  void _cancelPendingPreSynth() {
    final toRemove = <_SynthesisTask>[];
    for (final task in _queue) {
      if (!task.isPriority && _preSynthKeys.contains(task.key)) {
        toRemove.add(task);
        task.completer.complete(null);
        _inProgress.remove(task.key);
        _preSynthKeys.remove(task.key);
      }
    }
    for (final task in toRemove) {
      _queue.remove(task);
    }
  }

  /// 串行处理队列
  Future<void> _processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    while (_queue.isNotEmpty) {
      final task = _queue.removeFirst();

      // 已被取消（预合成任务）
      if (task.completer.isCompleted) continue;

      final result = await _doSynthesize(task.text, task.key);
      _inProgress.remove(task.key);
      _preSynthKeys.remove(task.key);

      if (!task.completer.isCompleted) {
        task.completer.complete(result);
      }
    }

    _isProcessing = false;
  }

  /// 实际调用 PowerShell 合成 wav 文件
  Future<String?> _doSynthesize(String text, String key) async {
    // 命中缓存（可能在排队期间被其他路径写入）
    if (_cache.containsKey(key)) return _cache[key];

    final tempDir = Directory.systemTemp;
    final outPath = '${tempDir.path}\\tts_$key.wav';

    // 文件已存在（之前的缓存残留）
    if (File(outPath).existsSync()) {
      _cache[key] = outPath;
      return outPath;
    }

    // PowerShell 脚本：转义文本中的特殊字符
    final escapedText = _escapeForPowerShell(text);

    final script = '''
Add-Type -AssemblyName System.Speech
\$s = New-Object System.Speech.Synthesis.SpeechSynthesizer
\$s.Rate = 0
\$s.SetOutputToWaveFile("$outPath")
\$s.Speak(\$("$escapedText"))
\$s.Dispose()
''';

    try {
      stderr.writeln('[TTS] Synthesizing: "$text"');
      stderr.writeln('[TTS] Output path: $outPath');
      stderr.writeln('[TTS] Script:\n$script');

      final result = await Process.run(
        'powershell',
        ['-NoProfile', '-Command', script],
      ).timeout(const Duration(seconds: 10));

      stderr.writeln('[TTS] exitCode: ${result.exitCode}');
      stderr.writeln('[TTS] stdout: ${result.stdout}');
      stderr.writeln('[TTS] stderr: ${result.stderr}');

      if (result.exitCode == 0 && File(outPath).existsSync()) {
        final fileSize = File(outPath).lengthSync();
        stderr.writeln('[TTS] Success! File size: $fileSize bytes');
        _cache[key] = outPath;
        return outPath;
      }
      stderr.writeln('[TTS] FAILED: exitCode=${result.exitCode}, fileExists=${File(outPath).existsSync()}');
      return null;
    } on TimeoutException {
      stderr.writeln('[TTS] FAILED: Timeout after 10 seconds');
      return null;
    } catch (e, st) {
      stderr.writeln('[TTS] FAILED: Exception: $e');
      stderr.writeln('[TTS] Stack trace: $st');
      return null;
    }
  }

  /// 计算文本 hash，取前 8 位 hex（确定性 hash，基于内容）
  String _hashText(String text) {
    final bytes = utf8.encode(text.trim());
    // FNV-1a 32-bit hash，确定性
    int hash = 0x811c9dc5;
    for (final byte in bytes) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  /// 转义 PowerShell 字符串中的特殊字符
  String _escapeForPowerShell(String text) {
    return text
        .replaceAll(r'\', r'\\')
        .replaceAll('"', r'\"')
        .replaceAll("'", r"''")
        .replaceAll('\$', r'`\$');
  }

  /// 清理资源
  void dispose() {
    _cancelPendingPreSynth();
    _queue.clear();
    _inProgress.clear();
    _cache.clear();
  }
}

/// 合成任务
class _SynthesisTask {
  final String text;
  final String key;
  final Completer<String?> completer;
  final bool isPriority;

  _SynthesisTask(this.text, this.key, this.completer,
      {this.isPriority = false});
}
