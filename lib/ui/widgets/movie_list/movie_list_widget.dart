import 'package:flutter/material.dart';
import 'package:movie_list/ui/widgets/movie_list/movie_list_cubit.dart';
import 'package:provider/provider.dart';
import 'package:movie_list/ui/navigation/main_navigation.dart';

import '../../../domain/api_client/image_downloader.dart';

class MovieListWidget extends StatefulWidget {
  const MovieListWidget({super.key});

  @override
  State<MovieListWidget> createState() => _MovieListWidgetState();
}

class _MovieListWidgetState extends State<MovieListWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final locale = Localizations.localeOf(context);
    context.read<MovieListCubit>().setupLocale(locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Stack(
        children: const [_MovieListWidget(), _SearchWidget()],
      ),
    );
  }
}

class _SearchWidget extends StatelessWidget {
  const _SearchWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MovieListCubit>();
    return TextField(
      onChanged: cubit.searchMovie,
      decoration: InputDecoration(
        labelText: 'Пошук',
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(6))),
        isDense: true,
        filled: true,
        fillColor: Colors.white.withAlpha(235),
      ),
      style: const TextStyle(
        fontFamily: 'Sence Sans Pro',
        fontSize: 16,
      ),
    );
  }
}

class _MovieListWidget extends StatelessWidget {
  const _MovieListWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<MovieListCubit>();
    return Padding(
      padding: const EdgeInsets.only(top: 70),
      child: ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior
            .onDrag, // вимикає клаву при скролі
        itemCount: cubit.state.movies.length,
        itemExtent: 152, // можемо крнтролювати розмір
        itemBuilder: (BuildContext context, int index) {
          cubit.showMovieAtIndex(index);
          return _MovieListRowWidget(index: index);
        },
      ),
    );
  }
}

class _MovieListRowWidget extends StatelessWidget {
  final int index;
  const _MovieListRowWidget({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MovieListCubit>();
    final movie = cubit.state.movies[index];
    final posterPath = movie.posterPath;
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                style: BorderStyle.solid,
                color: const Color.fromRGBO(227, 227, 227, 1),
              ),
              borderRadius: const BorderRadius.all(Radius.circular(6)),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  offset: Offset(0, 2),
                  blurRadius: 8,
                ),
              ]),
          clipBehavior:
              Clip.hardEdge, // добавляєм скруглення для внутрішніх об'єктів
          child: Row(
            children: [
              if(posterPath != null)
                  Image.network(ImageDownloader.imageUrl(posterPath),
                      width: 95),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontFamily: 'Source Sans Pro',
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            movie.releaseDate,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Color.fromRGBO(153, 153, 153, 1),
                                fontSize: 14.4,
                                fontFamily: 'Source Sans Pro'),
                          ),
                        ],
                      ),
                      Text(
                        movie.overview,
                        maxLines: 2,
                        overflow: TextOverflow
                            .ellipsis, // добавляєм в кінець 3 крапки
                        style: const TextStyle(
                          fontFamily: 'Source Sans Pro',
                          fontSize: 14.4,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            onTap: () => _onMovieTap(movie.id, context),
          ),
        )
      ],
    );
  }

  void _onMovieTap(int movieId, BuildContext context) {
    Navigator.of(context).pushNamed(MainNavigationRoutesNames.movieDetails, arguments: movieId);
  }
}
