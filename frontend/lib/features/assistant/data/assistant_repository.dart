import '../domain/assistant_reply.dart';
import 'assistant_api.dart';

class AssistantRepository {
  AssistantRepository(this._api);

  final AssistantApi _api;

  Future<AssistantReply> sendMessage(
    String message, {
    String? bearerToken,
  }) =>
      _api.sendMessage(message, bearerToken: bearerToken);
}
