import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../services/adk_api_service.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String serverUrl;
  final String appName;
  final String userId;
  final String sessionId;

  const ChatState({
    required this.messages,
    required this.isLoading,
    required this.serverUrl,
    required this.appName,
    required this.userId,
    required this.sessionId,
  });

  factory ChatState.initial() {
    return const ChatState(
      messages: [],
      isLoading: false,
      serverUrl: 'http://127.0.0.1:8000/run_sse',
      appName: 'multi_agent_workflow',
      userId: 'u_123',
      sessionId: 's_123',
    );
  }

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? serverUrl,
    String? appName,
    String? userId,
    String? sessionId,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      serverUrl: serverUrl ?? this.serverUrl,
      appName: appName ?? this.appName,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final AdkApiService _apiService;
  StreamSubscription<AdkResponseChunk>? _streamSubscription;

  ChatNotifier(this._apiService) : super(ChatState.initial());

  void updateSettings({
    String? serverUrl,
    String? appName,
    String? userId,
    String? sessionId,
  }) {
    state = state.copyWith(
      serverUrl: serverUrl ?? state.serverUrl,
      appName: appName ?? state.appName,
      userId: userId ?? state.userId,
      sessionId: sessionId ?? state.sessionId,
    );
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isLoading) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      text: trimmed,
      timestamp: DateTime.now(),
    );

    final assistantMessageId =
        (DateTime.now().millisecondsSinceEpoch + 1).toString();
    final assistantMessage = ChatMessage(
      id: assistantMessageId,
      role: MessageRole.assistant,
      text: '',
      isStreaming: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage, assistantMessage],
      isLoading: true,
    );

    try {
      final sseStream = _apiService.sendSseMessage(
        serverUrl: state.serverUrl,
        appName: state.appName,
        userId: state.userId,
        sessionId: state.sessionId,
        userText: trimmed,
      );

      _streamSubscription = sseStream.listen(
        (chunk) {
          _appendChunkToAssistantMessage(
            assistantMessageId,
            chunk.text,
            chunk.author,
          );
        },
        onError: (error) {
          _handleStreamError(assistantMessageId, error.toString());
        },
        onDone: () {
          _finishAssistantMessage(assistantMessageId);
        },
      );
    } catch (e) {
      _handleStreamError(assistantMessageId, e.toString());
    }
  }

  void _appendChunkToAssistantMessage(
    String messageId,
    String chunkText,
    String? author,
  ) {
    final updatedMessages = state.messages.map((msg) {
      if (msg.id == messageId) {
        // When author changes (e.g. from 'generator' to 'editor_agent'),
        // replace the draft text with the new agent's response.
        final bool isAuthorChanged = author != null &&
            author.isNotEmpty &&
            msg.author != null &&
            msg.author != author;

        final newText = isAuthorChanged ? chunkText : (msg.text + chunkText);

        return msg.copyWith(
          text: newText,
          author: author ?? msg.author,
          isStreaming: true,
        );
      }
      return msg;
    }).toList();

    state = state.copyWith(messages: updatedMessages);
  }

  void _finishAssistantMessage(String messageId) {
    final updatedMessages = state.messages.map((msg) {
      if (msg.id == messageId) {
        return msg.copyWith(isStreaming: false);
      }
      return msg;
    }).toList();

    state = state.copyWith(
      messages: updatedMessages,
      isLoading: false,
    );
    _streamSubscription = null;
  }

  void _handleStreamError(String messageId, String errorMessage) {
    final updatedMessages = state.messages.map((msg) {
      if (msg.id == messageId) {
        return msg.copyWith(
          isStreaming: false,
          error: errorMessage,
          text: msg.text.isEmpty
              ? 'Error: Unable to connect or stream from ADK server.'
              : msg.text,
        );
      }
      return msg;
    }).toList();

    state = state.copyWith(
      messages: updatedMessages,
      isLoading: false,
    );
    _streamSubscription = null;
  }

  void stopStreaming() {
    _streamSubscription?.cancel();
    _streamSubscription = null;

    if (state.messages.isNotEmpty) {
      final lastMsg = state.messages.last;
      if (lastMsg.role == MessageRole.assistant && lastMsg.isStreaming) {
        _finishAssistantMessage(lastMsg.id);
      }
    }
  }

  void clearChat() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    state = state.copyWith(
      messages: [],
      isLoading: false,
    );
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}

final adkApiServiceProvider = Provider<AdkApiService>((ref) {
  return AdkApiService();
});

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final apiService = ref.watch(adkApiServiceProvider);
  return ChatNotifier(apiService);
});
