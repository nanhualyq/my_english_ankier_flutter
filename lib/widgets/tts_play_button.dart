import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/tts_service.dart';

/// TTS 播放按钮
/// 点击合成并播放音频，播完后再次点击即重播。
/// 使用 PowerShell SoundPlayer 播放 wav，零第三方音频依赖。
class TtsPlayButton extends StatefulWidget {
  final String text;
  final TtsService? ttsService;

  const TtsPlayButton({super.key, required this.text, this.ttsService});

  @override
  State<TtsPlayButton> createState() => _TtsPlayButtonState();
}

class _TtsPlayButtonState extends State<TtsPlayButton> {
  late final TtsService _ttsService;
  bool _isLoading = false;
  bool _isPlaying = false;
  String? _currentPath;
  Process? _playProcess;

  @override
  void initState() {
    super.initState();
    _ttsService = widget.ttsService ?? TtsService();
  }

  @override
  void dispose() {
    _stopPlayback();
    if (widget.ttsService == null) _ttsService.dispose();
    super.dispose();
  }

  void _stopPlayback() {
    if (_playProcess != null) {
      _playProcess!.kill();
      _playProcess = null;
    }
    _isPlaying = false;
  }

  Future<void> _onTap() async {
    // 正在播放则停止
    if (_isPlaying) {
      _stopPlayback();
      if (mounted) setState(() {});
      return;
    }

    // 合成
    if (_currentPath == null) {
      setState(() => _isLoading = true);
      final path = await _ttsService.synthesize(widget.text);
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (path == null) return;
      _currentPath = path;
    }

    // 播放
    _isPlaying = true;
    if (mounted) setState(() {});

    try {
      final path = _currentPath!;
      _playProcess = await Process.start(
        'powershell',
        ['-NoProfile', '-Command', '([System.Media.SoundPlayer]::new("$path")).PlaySync()'],
      );
      await _playProcess!.exitCode;
    } catch (_) {}

    if (mounted) {
      _isPlaying = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return IconButton(
      icon: Icon(
        _isPlaying ? Icons.stop : Icons.volume_up,
        size: 20,
      ),
      onPressed: _onTap,
    );
  }
}
