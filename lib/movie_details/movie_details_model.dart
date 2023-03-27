// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_list/domain/api_client/api_client_exception.dart';
import 'package:movie_list/domain/api_client/image_downloader.dart';
import 'package:movie_list/domain/entity/movie_details.dart';
import 'package:movie_list/domain/entity/movie_details_credits.dart';
import 'package:movie_list/domain/services/auth_service.dart';
import 'package:movie_list/domain/services/movie_service.dart';
import 'package:movie_list/library/widgets/inherited/localized_model.dart';
import 'package:movie_list/resources/resources.dart';
import 'package:movie_list/ui/navigation/main_navigation.dart';

class MovieDetailsPosterData {
  final String? backdropPath;
  final String? posterPath;
  final bool isFavorite;
  IconData get favoriteIcon => isFavorite ? Icons.favorite : Icons.favorite_outline;

  MovieDetailsPosterData({
    this.isFavorite = false,
    this.backdropPath,
    this.posterPath,
  });

  MovieDetailsPosterData copyWith({
    String? backdropPath,
    String? posterPath,
    bool? isFavorite,
  }) {
    return MovieDetailsPosterData(
      backdropPath: backdropPath ?? this.backdropPath,
      posterPath: posterPath ?? this.posterPath,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class MovieDetailsMovieNameData {
  final String name;
  final String year;

  MovieDetailsMovieNameData({
    required this.name,
    required this.year,
  });
}

class MovieDetailsMovieScoreData {
  final double voteAverage;
  final String? trailerKey;

  MovieDetailsMovieScoreData({
    required this.voteAverage,
    this.trailerKey,
  });
}

class MovieDetailsMovieSummaryData {
  final String texts;
  final String genres;

  MovieDetailsMovieSummaryData({
    required this.texts,
    required this.genres,
  });
}

class MovieDetailsPeopleData {
  final String name;
  final String job;

  MovieDetailsPeopleData({
    required this.name,
    required this.job,
  });
}

class MovieDetailsActorData {
  Image image;
  String originalName;
  String character;

  MovieDetailsActorData({
    required this.image,
    required this.originalName,
    required this.character,
  });
}

class MovieDetailsData {
  String title = 'Loading...';
  bool isLoading = true;
  String overview = '';
  MovieDetailsPosterData posterData = MovieDetailsPosterData(isFavorite: false);
  MovieDetailsMovieNameData nameData =
      MovieDetailsMovieNameData(name: '', year: '');
  MovieDetailsMovieScoreData scoreData =
      MovieDetailsMovieScoreData(voteAverage: 0);
  MovieDetailsMovieSummaryData summaryData =
      MovieDetailsMovieSummaryData(texts: '', genres: '');
  List<List<MovieDetailsPeopleData>> peopleData =
      <List<MovieDetailsPeopleData>>[];
  List<MovieDetailsActorData> actorsData = <MovieDetailsActorData>[];
}

class MovieDetailsModel extends ChangeNotifier {
  final _authService = AuthService();
  final _movieService = MovieService();

  final int movieId;
  final data = MovieDetailsData();
  final LocalizedModelStorage _localeStorage = LocalizedModelStorage();
  late DateFormat _dateFormat;

  MovieDetailsModel({required this.movieId});

  Future<void> setupLocale(BuildContext context, Locale locale) async {
    if(!_localeStorage.updateLocale(locale)) return;

    _dateFormat = DateFormat.yMMMMd(_localeStorage.localeTag);
    updateData(null, false);
    await loadDetails(context);
  }

  void updateData(MovieDetails? details, bool isFavorite) {
    data.title = details?.title ?? 'Loading...';
    data.isLoading = details == null;
    if (details == null) {
      notifyListeners();
      return;
    }

    data.overview = details.overview ?? '';

    data.posterData = MovieDetailsPosterData(
      isFavorite: isFavorite,
      backdropPath: details.backdropPath,
      posterPath: details.posterPath,
    );
    var year = details.releaseDate?.year.toString();
    year = year != null ? '($year)' : '';
    data.nameData = MovieDetailsMovieNameData(name: details.title, year: year);

    final videos = details.videos.results
        .where((video) => video.type == 'Trailer' && video.site == 'YouTube');
    final trailerKey = videos.isNotEmpty ? videos.first.key : null;
    data.scoreData = MovieDetailsMovieScoreData(
        voteAverage: details.voteAverage * 10, trailerKey: trailerKey);
    data.summaryData = makeSummaryData(details);
    data.peopleData = makePeopleData(details);
    data.actorsData = makeActorData(details);

    notifyListeners();
  }

  MovieDetailsMovieSummaryData makeSummaryData(MovieDetails details) {
    var texts = <String>[];
    final releaseDate = details.releaseDate;
    if (releaseDate != null) {
      texts.add(_dateFormat.format(releaseDate));
    }
    if (details.productionCountries.isNotEmpty) {
      texts.add('(${details.productionCountries.first.iso})');
    }
    final runtime = details.runtime ?? 0;
    final duration = Duration(minutes: runtime);
    final hours = duration.inHours;
    final minutes =
        duration.inMinutes.remainder(60); // взяли залишовк від ділення на 60
    texts.add('${hours}h ${minutes}m');
    final genres = details.genres.isNotEmpty
        ? details.genres.map((e) => e.name).toList().join(', ')
        : '';
    return MovieDetailsMovieSummaryData(texts: texts.join(' '), genres: genres);
  }

  List<List<MovieDetailsPeopleData>> makePeopleData(MovieDetails details) {
    if (details.credits.crew.isEmpty) return [];

    var crew = <Employee>[];
    var crewMap = <String, Employee>{};
    for (var i = 0; i < details.credits.crew.length; i++) {
      var crewMember = details.credits.crew[i];
      if (!crewMap.containsKey(crewMember.name)) {
        crewMap[crewMember.name] = crewMember;
      } else {
        crewMap[crewMember.name] = crewMap[crewMember.name]!.copyWith(
            job: '${crewMap[crewMember.name]!.job}, ${crewMember.job}');
      }
    }
    crewMap.forEach((name, member) => crew.add(member));

    crew = crew.length > 4 ? crew.sublist(0, 4) : crew;

    final List<MovieDetailsPeopleData> finalCrew = crew
        .map((el) => MovieDetailsPeopleData(name: el.name, job: el.job))
        .toList();

    var crewChunks = <List<MovieDetailsPeopleData>>[];
    for (var i = 0; i < crew.length; i += 2) {
      crewChunks
          .add(finalCrew.sublist(i, i + 2 > crew.length ? crew.length : i + 2));
    }
    return crewChunks;
  }

  List<MovieDetailsActorData> makeActorData(MovieDetails details) {
    final actors = details.credits.cast
        .map((el) => MovieDetailsActorData(
              image: el.profilePath == null
                  ? const Image(image: AssetImage(AppImages.actor))
                  : Image.network(ImageDownloader.imageUrl(el.profilePath!),
                      width: 130, height: 120, fit: BoxFit.cover),
              originalName: el.originalName ?? '',
              character: el.character,
            ))
        .toList();
    return actors;
  }

  Future<void> loadDetails(BuildContext context) async {
    try {
      final details = await _movieService.loadDetails(movieId: movieId, locale: _localeStorage.localeTag);
      
      updateData(details.movieDetails, details.isFavorite);
    } on ApiClientException catch (e) {
      _handleApiClientException(e, context);
    }
  }

  Future<void> toggleFavorite(BuildContext context) async {

    final isFavorite = !data.posterData.isFavorite;
    data.posterData = data.posterData.copyWith(isFavorite: isFavorite);

    notifyListeners();

    try {
      await _movieService.updateFavorite(isFavorite: isFavorite, movieId: movieId);
    } on ApiClientException catch (e) {
      _handleApiClientException(e, context);
    }
  }

  void _handleApiClientException(
      ApiClientException exception, BuildContext context) {
    switch (exception.type) {
      case ApiClientExceptionType.sessionExpired:
        _authService.logout();
        MainNavigation.resetNavigation(context);
        break;
      default:
        print(exception);
    }
  }
}
