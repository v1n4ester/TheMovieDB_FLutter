import 'package:movie_list/domain/entity/movie_details.dart';
import 'package:movie_list/domain/entity/popular_movie_response.dart';

import '../../configuration/configuration.dart';
import 'network_client.dart';

class MovieApiClient {
  final _networkClient = NetworkClient();

  Future<PopularMovieResponse> popularMovie(int page, String locale, String apiKey) async {
    PopularMovieResponse parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final response = PopularMovieResponse.fromJson(jsonMap);
      return response;
    }
    final result = await _networkClient.get('/movie/popular', parser,
        {'api_key': apiKey, 'page': page.toString(), 'language': locale});
    return result;
  }

  Future<PopularMovieResponse> searchMovie(
    int page,
    String locale,
    String query,
    String apiKey
  ) async {
    PopularMovieResponse parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final response = PopularMovieResponse.fromJson(jsonMap);
      return response;
    }
    final result = _networkClient.get(
      '/search/movie',
      parser,
      {
        'api_key': apiKey,
        'page': page.toString(),
        'language': locale,
        'query': query,
        'include_adult': true.toString(),
      },
    );
    return result;
  }

  Future<MovieDetails> movieDetails(
    int movieId,
    String locale,
  ) async {
    MovieDetails parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final response = MovieDetails.fromJson(jsonMap);
      return response;
    }
    final result = _networkClient.get(
      '/movie/$movieId',
      parser,
      {
        'api_key': Configuration.apiKey,
        'language': locale,
        'append_to_response': 'credits,videos'
      },
    );
    return result;
  }

   Future<bool> isFavorite(
    int movieId,
    String sessionId
  ) async {
    bool parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final result = jsonMap['favorite'] as bool;
      return result;
    }
    final result = _networkClient.get(
      '/movie/$movieId/account_states',
      parser,
      {
        'api_key': Configuration.apiKey,
        'session_id': sessionId
      },
    );
    return result;
  }
}