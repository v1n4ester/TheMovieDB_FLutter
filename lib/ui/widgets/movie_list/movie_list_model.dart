// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_list/domain/entity/movie.dart';
import 'package:movie_list/domain/services/movie_service.dart';
import 'package:movie_list/library/paginator.dart';
import 'package:movie_list/library/widgets/inherited/localized_model.dart';
import 'package:movie_list/ui/navigation/main_navigation.dart';

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

class MovieListViewModel extends ChangeNotifier {
  final _movieService = MovieService();
  late Paginator<Movie> _popularMoviePaginator;
  late Paginator<Movie> _searchMoviePaginator;
  Timer? searchDebounce;
  final LocalizedModelStorage _localeStorage = LocalizedModelStorage();

  var _movies = <MovieListRowData>[];
  late DateFormat _dateFormat;
  String? _searchQuery;

  bool get isSearchMode {
    final searchQuery = _searchQuery;
    return searchQuery != null && searchQuery.isNotEmpty;
  }

  List<MovieListRowData> get movies => List.unmodifiable(_movies);

  MovieListViewModel() {
    _popularMoviePaginator = Paginator<Movie>((page) async {
      final result = await _movieService.popularMovie(page, _localeStorage.localeTag);
      return PaginatorLoadResult(
        data: result.movies,
        currentPage: result.page,
        totalPages: result.totalPages,
      );
    });

    _searchMoviePaginator = Paginator<Movie>((page) async {
      final result = await _movieService.searchMovie(page, _localeStorage.localeTag, _searchQuery ?? '');
      return PaginatorLoadResult(
        data: result.movies,
        currentPage: result.page,
        totalPages: result.totalPages,
      );
    });
  }

  Future<void> setupLocale(Locale locale) async {
    if(!_localeStorage.updateLocale(locale)) return;
    _dateFormat = DateFormat.yMMMMd(_localeStorage.localeTag);
    await _resetList();
  }

  Future<void> _resetList() async {
    await _popularMoviePaginator.reset();
    await _searchMoviePaginator.reset();
    _movies.clear();
    await _loadNextPage();
  }

  Future<void> _loadNextPage() async {
    if(isSearchMode) {
      await _searchMoviePaginator.loadNextPage();
      _movies = _searchMoviePaginator.data.map((_makeRowData)).toList();
    } else {
      await _popularMoviePaginator.loadNextPage();
      _movies = _popularMoviePaginator.data.map((_makeRowData)).toList();
    }

    notifyListeners();
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

  void onMovieTap(int id, BuildContext context) {
    Navigator.of(context)
        .pushNamed(MainNavigationRoutesNames.movieDetails, arguments: id);
  }

  Future<void> searchMovie(String text) async {
    searchDebounce
        ?.cancel(); // відмінить таймер який вже існує, щоб не робити лишній запит
    searchDebounce = Timer(const Duration(milliseconds: 300), () async {
      final searchQuery = text.isNotEmpty ? text : null;
      if (_searchQuery == searchQuery) return;
      _searchQuery = searchQuery;

      _movies.clear();
      if(isSearchMode) {
        await _searchMoviePaginator.reset();
      }

      _loadNextPage();
    });
  }

  void showMovieAtIndex(int index) {
    if (index < movies.length - 1) return;
    _loadNextPage();
  }
}
