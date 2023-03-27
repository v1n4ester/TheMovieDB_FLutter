import 'dart:convert';
import 'dart:io';

import 'package:movie_list/configuration/configuration.dart';

import 'api_client_exception.dart';

class NetworkClient {
  final _client = HttpClient();

  Uri _makeUri(String path, [Map<String, dynamic>? parametrs]) {
    final uri = Uri.parse('${Configuration.host}$path');
    if (parametrs != null) {
      return uri.replace(queryParameters: parametrs);
    } else {
      return uri;
    }
  }

  Future<T> get<T>(
    String path,
    T Function(dynamic json) parser, [
    Map<String, dynamic>? parametrs,
  ]) async {
    final url = _makeUri(path, parametrs);
    try {
      final HttpClientRequest request =
          await _client.getUrl(url); // буде помилка якщо нема мережі
      final response = request.close(); // буде помилка якщо сервер недоступний
      final json = await (await response)
          .jsonDecode(); // буде помилка якщо неправильний пасинг

      await validateResponse(response, json);

      final result = parser(json); // буде помилка якщо нема токена
      return result;
    } on SocketException {
      throw ApiClientException(ApiClientExceptionType.network);
    } on ApiClientException {
      rethrow; // перекидаємо помилку вище
    } catch (_) {
      throw ApiClientException(ApiClientExceptionType.other);
    }
  }

  Future<T> post<T>({
    required String path,
    required T Function(dynamic json) parser,
    required Map<String, dynamic> bodyParametrs,
    Map<String, dynamic>? urlParametrs,
  }) async {
    try {
      final url = _makeUri(path, urlParametrs);

      final request = await _client.postUrl(url);
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(bodyParametrs)); // записуєм в body
      final response = request.close();
      if((await response).statusCode == 201) return 1 as T;
      final json = await (await response).jsonDecode();

      await validateResponse(response, json);

      final result = parser(json);
      return result;
    } on SocketException {
      throw ApiClientException(ApiClientExceptionType.network);
    } on ApiClientException {
      rethrow; // перекидаємо помилку вище
    } catch (_) {
      throw ApiClientException(ApiClientExceptionType.other);
    }
  }

  Future<void> validateResponse(
      Future<HttpClientResponse> response, dynamic json) async {
    if ((await response).statusCode == 401) {
      final status = json['status_code'];
      final code = status is int ? status : 0;
      if (code == 30) {
        throw ApiClientException(ApiClientExceptionType.auth);
      } else if (code == 3) {
        throw ApiClientException(ApiClientExceptionType.sessionExpired);
      }else {
        throw ApiClientException(ApiClientExceptionType.other);
      }
    }
  }
}

extension HttpClientResponseJsonDecode on HttpClientResponse {
  dynamic jsonDecode() {
    return transform(utf8.decoder)
        .toList()
        .then((value) => value.join())
        .then((v) => json.decode(v));
  }
}