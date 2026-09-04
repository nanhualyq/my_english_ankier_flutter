import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for communicating with AnkiConnect plugin.
///
/// AnkiConnect runs an HTTP server on localhost:8765 when Anki is open.
/// Docs: https://git.sr.ht/~foosoft/anki-connect
class AnkiConnectService {
  final String baseUrl;

  AnkiConnectService({this.baseUrl = 'http://127.0.0.1:8765'});

  /// Invoke an AnkiConnect action.
  Future<dynamic> invoke(String action, [Map<String, dynamic>? params]) async {
    final body = jsonEncode({
      'action': action,
      'version': 6,
      'params': ?params,
    });

    final response = await http
        .post(
          Uri.parse(baseUrl),
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw AnkiConnectException(
        'AnkiConnect returned status ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final error = data['error'] as String?;

    if (error != null) {
      throw AnkiConnectException(error);
    }

    return data['result'];
  }

  /// Check if AnkiConnect is reachable.
  Future<bool> isAvailable() async {
    try {
      await invoke('version');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Open Anki's Add Cards dialog with prefilled fields.
  ///
  /// Returns the note ID (if user confirms) or null (if user cancels).
  Future<int?> guiAddCards({
    required String deckName,
    required String modelName,
    required Map<String, String> fields,
  }) async {
    final result = await invoke('guiAddCards', {
      'note': {
        'deckName': deckName,
        'modelName': modelName,
        'fields': fields,
      },
    });
    return result as int?;
  }
}

class AnkiConnectException implements Exception {
  final String message;
  AnkiConnectException(this.message);

  @override
  String toString() => 'AnkiConnectException: $message';
}
