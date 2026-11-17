enum MessageRole { user, assistant, system }

class ChatMessage {
  final String id;
  final MessageRole role;
  final String? author;
  final String text;
  final bool isStreaming;
  final String? error;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.role,
    this.author,
    required this.text,
    this.isStreaming = false,
    this.error,
    required this.timestamp,
  });

  ChatMessage copyWith({
    String? id,
    MessageRole? role,
    String? author,
    String? text,
    bool? isStreaming,
    String? error,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      author: author ?? this.author,
      text: text ?? this.text,
      isStreaming: isStreaming ?? this.isStreaming,
      error: error ?? this.error,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
