import '../../../core/api/api_client.dart';
import '../domain/assistant_reply.dart';

class AssistantApi {
  AssistantApi(this._client);

  final ApiClient _client;

  Future<AssistantReply> sendMessage(
    String message, {
    String? bearerToken,
  }) async {
    final payload = await _client.postJson(
      '/api/assistant/message',
      {'message': message},
      bearerToken: bearerToken,
    );
    return AssistantReply.fromJson(payload);
  }
}
