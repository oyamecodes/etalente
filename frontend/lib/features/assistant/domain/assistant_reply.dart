/// Mirrors the backend `AssistantMessageResponse` from
/// `POST /api/assistant/message`.
class AssistantReply {
  const AssistantReply({
    required this.reply,
    required this.timestamp,
    required this.source,
  });

  final String reply;

  /// ISO-8601 instant string as emitted by the server.
  final String timestamp;

  /// One of `canned`, `gemini`, `fallback`. See backend `AssistantProvider`
  /// implementations; `fallback` means a primary provider failed and the
  /// canned reply was returned instead.
  final String source;

  factory AssistantReply.fromJson(Map<String, dynamic> json) {
    return AssistantReply(
      reply: json['reply'] as String,
      timestamp: json['timestamp'] as String,
      source: json['source'] as String,
    );
  }
}
