import 'package:movie_list/domain/api_client/network_client.dart';

import '../../configuration/configuration.dart';

enum MediaType { movie, tv }

extension MovieTypeAsString on MediaType {
  String asString() {
    switch (this) {
      case MediaType.movie:
        return 'movie';
      case MediaType.tv:
        return 'tv';
    }
  }
}

class AccountApiClient {
  final _networkClient = NetworkClient();

  Future<int> getAccountInfo(
    String sessionId,
  ) async {
    int parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final result = jsonMap['id'] as int;
      return result;
    }

    final result = _networkClient.get(
      '/account',
      parser,
      {'api_key': Configuration.apiKey, 'session_id': sessionId},
    );
    return result;
  }

  Future<int> markAsFavorite(
      {required int accountId,
      required String sessionId,
      required MediaType mediaType,
      required int mediaId,
      required bool isFavorite}) async {
    int parser(dynamic json) {
      return 1;
    }

    final parametrs = <String, dynamic>{
      'media_type': mediaType.asString(),
      'media_id': mediaId,
      'favorite': isFavorite
    };
    final result = _networkClient.post(
      path: '/account/$accountId/favorite',
      urlParametrs: {
        'api_key': Configuration.apiKey,
        'session_id': sessionId,
      },
      bodyParametrs: parametrs,
      parser: parser,
    );
    return result;
  }
}
