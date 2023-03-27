import 'package:movie_list/domain/api_client/network_client.dart';

import '../../configuration/configuration.dart';

class AuthApiClient {
  final _networkClient = NetworkClient();

  Future<String> auth({
    required String userName,
    required String password,
  }) async {
    final token = await _makeToken();
    final validToken = await _validateUser(
      userName: userName,
      password: password,
      requestToken: token,
    );
    final sessionid = await _makeSession(requestToken: validToken);
    return sessionid;
  }

  Future<String> _makeToken() async {
    String parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final token =
          jsonMap['request_token'] as String; // буде помилка якщо нема токена
      return token;
    }
    final result =
        _networkClient.get('/authentication/token/new', parser, {'api_key': Configuration.apiKey});
    return result;
  }
  
  Future<String> _validateUser({
    required String userName,
    required String password,
    required String requestToken,
  }) async {
    String parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final token =
          jsonMap['request_token'] as String; // буде помилка якщо нема токена
      return token;
    }
    final parametrs = <String, dynamic>{
      'username': userName,
      'password': password,
      'request_token': requestToken
    };
    final result = await _networkClient.post(
      path: '/authentication/token/validate_with_login',
      urlParametrs: {'api_key': Configuration.apiKey},
      bodyParametrs: parametrs,
      parser: parser,
    );
    return result;
  }

  Future<String> _makeSession({
    required String requestToken,
  }) async {
    String parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final sessionId = jsonMap['session_id'] as String;
      return sessionId;
    }
    final parametrs = <String, dynamic>{'request_token': requestToken};
    final result = _networkClient.post(
      path: '/authentication/session/new',
      urlParametrs: {'api_key': Configuration.apiKey},
      bodyParametrs: parametrs,
      parser: parser,
    );
    return result;
  }
}