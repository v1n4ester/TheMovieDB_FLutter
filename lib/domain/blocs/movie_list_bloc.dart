// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:movie_list/configuration/configuration.dart';
import 'package:movie_list/domain/api_client/movie_api_client.dart';
import 'package:movie_list/domain/entity/movie.dart';
import 'package:movie_list/domain/entity/popular_movie_response.dart';
import 'package:movie_list/ui/widgets/movie_list/movie_list_cubit.dart';

abstract class MovieListEvent {}

class MovieListEventLoadNextPage extends MovieListEvent {
  final String locale;

  MovieListEventLoadNextPage(this.locale);
}

class MovieListEventReset extends MovieListEvent {}

class MovieListEventLoadSearchMovie extends MovieListEvent {
  final String query;

  MovieListEventLoadSearchMovie(this.query);
}

class MovieListContainer {
  final List<Movie> movies;
  final int currentPage;
  final int totalPage;

  bool get isComplete => currentPage >= totalPage;

  const MovieListContainer.initial()
      : movies = const <Movie>[],
        currentPage = 0,
        totalPage = 1; // пустий начальний стейт контейнера

  MovieListContainer({
    required this.movies,
    required this.currentPage,
    required this.totalPage,
  });

  MovieListContainer copyWith({
    List<Movie>? movies,
    int? currentPage,
    int? totalPage,
  }) {
    return MovieListContainer(
      movies: movies ?? this.movies,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage ?? this.totalPage,
    );
  }

  @override
  bool operator ==(covariant MovieListContainer other) {
    if (identical(this, other)) return true;

    return listEquals(other.movies, movies) &&
        other.currentPage == currentPage &&
        other.totalPage == totalPage;
  }

  @override
  int get hashCode =>
      movies.hashCode ^ currentPage.hashCode ^ totalPage.hashCode;
}

class MovieListState {
  final MovieListContainer popularMovieContainer;
  final MovieListContainer searchMovieContainer;
  final String searchQuery;

  bool get isSearchMode => searchQuery.isNotEmpty;
  List<Movie> get movies => isSearchMode ? searchMovieContainer.movies : popularMovieContainer.movies;

  const MovieListState.initial()
      : popularMovieContainer = const MovieListContainer.initial(),
        searchMovieContainer = const MovieListContainer.initial(),
        searchQuery = '';
      
  MovieListState({
    required this.popularMovieContainer,
    required this.searchMovieContainer,
    required this.searchQuery,
  });
  
  MovieListState copyWith({
    MovieListContainer? popularMovieContainer,
    MovieListContainer? searchMovieContainer,
    String? searchQuery,
  }) {
    return MovieListState(
      popularMovieContainer:
          popularMovieContainer ?? this.popularMovieContainer,
      searchMovieContainer: searchMovieContainer ?? this.searchMovieContainer,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  bool operator ==(covariant MovieListState other) {
    if (identical(this, other)) return true;

    return other.popularMovieContainer == popularMovieContainer &&
        other.searchMovieContainer == searchMovieContainer &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode =>
      popularMovieContainer.hashCode ^
      searchMovieContainer.hashCode ^
      searchQuery.hashCode;
}

class MovieListBloc extends Bloc<MovieListEvent, MovieListState> {
  final _movieApiClient = MovieApiClient();

  MovieListBloc(super.initialState) {
    on<MovieListEvent>((event, emit) async {
      if (event is MovieListEventLoadNextPage) {
        await onMovieListEventLoadNextPage(event, emit);
      } else if (event is MovieListEventReset) {
        await onMovieListEventReset(event, emit);
      } else if (event is MovieListEventLoadSearchMovie) {
        await onMovieListEventLoadSearchMovie(event, emit);
      }
    });
  }

  Future<void> onMovieListEventLoadNextPage(
      MovieListEventLoadNextPage event, Emitter<MovieListState> emit) async {
    if (state.isSearchMode) {
      final container = await _loadNextPage(
          state.searchMovieContainer,
          (page) => _movieApiClient.searchMovie(
              page, event.locale, state.searchQuery, Configuration.apiKey));
      if (container != null) {
        final newState = state.copyWith(searchMovieContainer: container);
        emit(newState);
      }
    } else {
      final container = await _loadNextPage(
          state.popularMovieContainer,
          (page) => _movieApiClient.popularMovie(
              page, event.locale, Configuration.apiKey));
      if (container != null) {
        final newState = state.copyWith(popularMovieContainer: container);
        emit(newState);
      }
    }
  }

  Future<MovieListContainer?> _loadNextPage(
    MovieListContainer container,
    Future<PopularMovieResponse> Function(int) loader,
  ) async {
    if (container.isComplete) return null;
    final nextPage = container.currentPage + 1;
    final result = await loader(nextPage);

    final movies = [...container.movies, ...result.movies];

    final newContainer = container.copyWith(
      movies: movies,
      currentPage: result.page,
      totalPage: result.totalPages,
    );
    return newContainer;
  }

  Future<void> onMovieListEventReset(
      MovieListEventReset event, Emitter<MovieListState> emit) async {
    emit(const MovieListState.initial());
  }

  Future<void> onMovieListEventLoadSearchMovie(
      MovieListEventLoadSearchMovie event, Emitter<MovieListState> emit) async {
    if (state.searchQuery == event.query) return;
    final newState = state.copyWith(
      searchQuery: event.query,
      searchMovieContainer: const MovieListState.initial().searchMovieContainer,
    );
    emit(newState);
  }
}
