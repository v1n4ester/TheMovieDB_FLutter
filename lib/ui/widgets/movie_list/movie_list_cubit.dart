// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:movie_list/domain/blocs/movie_list_bloc.dart';
import 'package:movie_list/domain/entity/movie.dart';

class MovieListRowData {
  final int id;
  final String title;
  final String releaseDate;
  final String overview;
  final String? posterPath;

  MovieListRowData({
    required this.id,
    required this.title,
    required this.releaseDate,
    required this.overview,
    required this.posterPath,
  });
}

class MovieListCubitState {
  final List<MovieListRowData> movies;
  final String localeTag;

  MovieListCubitState({
    required this.movies,
    required this.localeTag,
  });

  @override
  bool operator ==(covariant MovieListCubitState other) {
    if (identical(this, other)) return true;

    return listEquals(other.movies, movies) && other.localeTag == localeTag;
  }

  @override
  int get hashCode => movies.hashCode ^ localeTag.hashCode;

  MovieListCubitState copyWith({
    List<MovieListRowData>? movies,
    String? localeTag,
  }) {
    return MovieListCubitState(
      movies: movies ?? this.movies,
      localeTag: localeTag ?? this.localeTag,
    );
  }
}

class MovieListCubit extends Cubit<MovieListCubitState> {
  final MovieListBloc movieListBloc;
  late final StreamSubscription<MovieListState> movieBlocSubscription;
  late DateFormat _dateFormat;
  Timer? searchDebounce;

  MovieListCubit(this.movieListBloc)
      : super(MovieListCubitState(
          movies: const <MovieListRowData>[],
          localeTag: '',
        )) {
    Future.microtask(() {
      _onState(movieListBloc.state);
      movieBlocSubscription = movieListBloc.stream.listen(_onState);
    });
  }

  void _onState(MovieListState state) {
    final movies = state.movies.map(_makeRowData).toList();
    final newState = this.state.copyWith(movies: movies);
    emit(newState);
  }

  Future<void> setupLocale(String localeTag) async {
    if (state.localeTag == localeTag) return;
    final newState = state.copyWith(localeTag: localeTag);
    emit(newState);
    _dateFormat = DateFormat.yMMMMd(localeTag);
    movieListBloc.add(MovieListEventReset());
    movieListBloc.add(MovieListEventLoadNextPage(localeTag));
  }

  MovieListRowData _makeRowData(Movie movie) {
    final releaseDate = movie.releaseDate;
    final releaseDateTitle =
        releaseDate != null ? _dateFormat.format(releaseDate) : '';
    return MovieListRowData(
        id: movie.id,
        title: movie.title,
        releaseDate: releaseDateTitle,
        overview: movie.overview,
        posterPath: movie.posterPath);
  }

  void showMovieAtIndex(int index) {
    if (index < state.movies.length - 1) return;
    movieListBloc.add(MovieListEventLoadNextPage(state.localeTag));
  }

  void searchMovie(String text) {
    searchDebounce
        ?.cancel(); // відмінить таймер який вже існує, щоб не робити лишній запит
    searchDebounce = Timer(const Duration(milliseconds: 300), () async {
      movieListBloc.add(MovieListEventLoadSearchMovie(text));
      movieListBloc.add(MovieListEventLoadNextPage(state.localeTag));
    });
  }

  @override
  Future<void> close() {
    movieBlocSubscription.cancel();
    return super.close();
  }
}
