import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AdkResponseChunk {
  final String text;
  final String? author;

  const AdkResponseChunk({
    required this.text,
    this.author,
  });
}

class AdkApiService {
  final http.Client _client;

  AdkApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Sends a user message to the ADK SSE endpoint and streams incoming text responses.
  Stream<AdkResponseChunk> sendSseMessage({
    required String serverUrl,
    required String appName,
    required String userId,
    required String sessionId,
    required String userText,
  }) async* {
    final Uri uri;
    try {
      uri = Uri.parse(serverUrl);
    } catch (e) {
      throw Exception('Invalid server URL: $serverUrl');
    }

    final request = http.Request('POST', uri);
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = '*/*';

    final payload = {
      "appName": appName,
      "userId": userId,
      "sessionId": sessionId,
      "newMessage": {
        "role": "user",
        "parts": [
          {"text": userText}
        ]
      },
      "streaming": true
    };

    request.body = jsonEncode(payload);

    http.StreamedResponse response;
    try {
      response = await _client.send(request);
    } catch (e) {
      final errorStr = e.toString();
      if (kIsWeb && (errorStr.contains('Failed to fetch') || errorStr.contains('ClientException'))) {
        throw Exception(
          'CORS / Network Connection Error on Web ($serverUrl).\n'
          'Browsers block cross-origin requests unless CORS is enabled on your backend server.\n\n'
          'To fix this in your ADK Python/FastAPI server:\n'
          '1. Add CORSMiddleware to your FastAPI app:\n'
          '   from fastapi.middleware.cors import CORSMiddleware\n'
          '   app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])\n'
          '2. Ensure your backend server is running and accessible at $serverUrl.'
        );
      }
      throw Exception('Failed to connect to ADK server ($serverUrl): $e');
    }

    if (response.statusCode != 200) {
      final errorResponseBody = await response.stream.bytesToString();
      throw Exception(
          'ADK Server HTTP ${response.statusCode}: $errorResponseBody');
    }

    final lineStream = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lineStream) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      if (trimmedLine.startsWith('data:')) {
        final dataContent = trimmedLine.substring(5).trim();

        if (dataContent == '[DONE]' || dataContent == 'DONE') {
          break;
        }

        if (dataContent.isEmpty) continue;

        try {
          final decoded = jsonDecode(dataContent);
          final extractedText = _extractTextFromAdkEvent(decoded);
          final author = _extractAuthorFromAdkEvent(decoded);
          if (extractedText != null && extractedText.isNotEmpty) {
            yield AdkResponseChunk(
              text: extractedText,
              author: author,
            );
          }
        } catch (_) {
          // If dataContent is raw string chunk instead of JSON object
          yield AdkResponseChunk(text: dataContent);
        }
      }
    }
  }

  /// Helper to extract text content from various ADK event JSON structures.
  String? _extractTextFromAdkEvent(dynamic decoded) {
    if (decoded == null) return null;

    if (decoded is String) {
      return decoded;
    }

    if (decoded is Map<String, dynamic>) {
      // Direct text property
      if (decoded['text'] is String) {
        return decoded['text'] as String;
      }

      // Content property can be a Map or String
      if (decoded['content'] != null) {
        final content = decoded['content'];
        if (content is String) return content;

        if (content is Map<String, dynamic>) {
          if (content['parts'] is List) {
            final parts = content['parts'] as List;
            final buffer = StringBuffer();
            for (final part in parts) {
              if (part is Map && part['text'] is String) {
                buffer.write(part['text']);
              }
            }
            if (buffer.isNotEmpty) return buffer.toString();
          }
          if (content['text'] is String) {
            return content['text'] as String;
          }
        }
      }

      // Direct parts list
      if (decoded['parts'] is List) {
        final parts = decoded['parts'] as List;
        final buffer = StringBuffer();
        for (final part in parts) {
          if (part is Map && part['text'] is String) {
            buffer.write(part['text']);
          }
        }
        if (buffer.isNotEmpty) return buffer.toString();
      }

      // Delta map structure
      if (decoded['delta'] is Map) {
        final delta = decoded['delta'] as Map;
        if (delta['text'] is String) return delta['text'] as String;
      }

      // Nested event structure
      if (decoded['event'] != null) {
        return _extractTextFromAdkEvent(decoded['event']);
      }
    }

    return null;
  }

  /// Helper to extract author (e.g. "editor_agent") from ADK event JSON.
  String? _extractAuthorFromAdkEvent(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      if (decoded['author'] is String && (decoded['author'] as String).isNotEmpty) {
        return decoded['author'] as String;
      }
      if (decoded['event'] != null) {
        return _extractAuthorFromAdkEvent(decoded['event']);
      }
      if (decoded['content'] is Map<String, dynamic> &&
          decoded['content']['author'] is String) {
        return decoded['content']['author'] as String;
      }
    }
    return null;
  }
}
