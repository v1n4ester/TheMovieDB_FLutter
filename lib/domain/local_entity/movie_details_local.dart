// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:movie_list/domain/entity/movie_details.dart';

class MovieDetailsLocal {
  final MovieDetails movieDetails;
  final bool isFavorite;
  
  MovieDetailsLocal({
    required this.movieDetails,
    required this.isFavorite,
  });
}
