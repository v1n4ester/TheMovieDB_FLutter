import 'package:flutter/material.dart';
import 'package:movie_list/movie_details/movie_details_model.dart';
import 'package:movie_list/ui/navigation/main_navigation.dart';
import 'package:movie_list/ui/widgets/elements/radial_percent_widget.dart';
import 'package:provider/provider.dart';

import '../domain/api_client/image_downloader.dart';

class MovieDetailsMainInfoWidget extends StatelessWidget {
  const MovieDetailsMainInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _TopPosters(),
        _MovieNameWidget(),
        _ScoreWidget(),
        SizedBox(height: 16),
        _SummeryWidget(),
        _OverviewWidget(),
        SizedBox(
          height: 30,
        ),
        _PeopleWidget(),
      ],
    );
  }
}

class _PeopleWidget extends StatelessWidget {
  const _PeopleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var peopleData = context.select((MovieDetailsModel model) => model.data.peopleData);
    if(peopleData.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
          children: peopleData
              .map((chunk) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _PeopleWidgetsRow(emloyees: chunk),
                  ))
              .toList()),
    );
  }
}

class _PeopleWidgetsRow extends StatelessWidget {
  final List<MovieDetailsPeopleData> emloyees;

  const _PeopleWidgetsRow({
    Key? key,
    required this.emloyees,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: emloyees
            .map(
              (employee) =>
                  Expanded(child: _PeopleWidgetsRowItem(employee: employee)),
            )
            .toList());
  }
}

class _PeopleWidgetsRowItem extends StatelessWidget {
  final MovieDetailsPeopleData employee;
  const _PeopleWidgetsRowItem({Key? key, required this.employee})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const personsStyle = TextStyle(
        fontFamily: 'Source Sans Pro',
        fontSize: 16,
        color: Color.fromRGBO(255, 255, 255, 1),
        fontWeight: FontWeight.w700);

    const personsRoleStyle = TextStyle(
        fontFamily: 'Source Sans Pro',
        fontSize: 14,
        color: Color.fromRGBO(255, 255, 255, 1),
        fontWeight: FontWeight.w700);

    return Column(
      children: [
        Text(employee.name, style: personsStyle),
        Text(employee.job, style: personsRoleStyle, textAlign: TextAlign.center, maxLines: 2),
      ],
    );
  }
}

class _OverviewWidget extends StatelessWidget {
  const _OverviewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final overview = context.select((MovieDetailsModel model) => model.data.overview,);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Опис',
            style: TextStyle(
                fontFamily: 'Source Sans Pro',
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            overview,
            style: const TextStyle(
              fontFamily: 'Source Sans Pro',
              fontSize: 16,
              color: Color.fromRGBO(255, 255, 255, 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopPosters extends StatelessWidget {
  const _TopPosters({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.read<MovieDetailsModel>();
    final posterData = context.select((MovieDetailsModel model) => model.data.posterData);
    final backdropPath = posterData.backdropPath;
    final posterPath = posterData.posterPath;
    return AspectRatio(
      // робимо дефолтний розмір(точніше співвідношення), щоб не стрибало при появленні картинок
      aspectRatio: 411 / 186,
      child: Stack(
        children: [
          if(backdropPath != null) 
          Padding(
            padding: const EdgeInsets.only(left: 80.0),
            child: Image.network(
                    ImageDownloader.imageUrl(backdropPath),
                    width: double.infinity,
                  ),
          ),
          if(posterPath != null) 
          Positioned(
              top: 20,
              bottom: 20,
              left: 20,
              child: Image.network(ImageDownloader.imageUrl(posterPath))),
          Positioned(
              top: 5,
              right: 5,
              child: IconButton(
                onPressed: () => model.toggleFavorite(context),
                icon: Icon(posterData.favoriteIcon),
              ))
        ],
      ),
    );
  }
}

class _MovieNameWidget extends StatelessWidget {
  const _MovieNameWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = context.select((MovieDetailsModel model) => model.data.nameData);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: RichText(
          textAlign: TextAlign.center,
          maxLines: 3,
          text: TextSpan(children: [
            TextSpan(
                text: data.name,
                style: const TextStyle(
                    fontFamily: 'Source Sans Pro',
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600)),
            const WidgetSpan(child: SizedBox(width: 6)),
            TextSpan(
                text: data.year,
                style: const TextStyle(
                    fontFamily: 'Source Sans Pro',
                    fontSize: 17,
                    color: Color.fromRGBO(255, 255, 255, 0.8))),
          ])),
    );
  }
}

class _ScoreWidget extends StatelessWidget {
  const _ScoreWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final movieDetails =
        context.select((MovieDetailsModel model) => model.data.scoreData);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  height: 44,
                  width: 44,
                  child: RadiantPercentWidget(
                    percent: movieDetails.voteAverage,
                    fillColor: const Color.fromARGB(255, 10, 23, 25),
                    lineCoolor: const Color.fromARGB(255, 37, 203, 103),
                    freeColor: const Color.fromARGB(255, 25, 54, 31),
                    lineWidth: 3,
                    child: Text(
                      '${movieDetails.voteAverage.round()}%',
                      style: const TextStyle(
                        fontFamily: 'Source Sans Pro',
                        fontSize: 16,
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Оцінка користувача',
                        style: TextStyle(
                          fontFamily: 'Source Sans Pro',
                          fontSize: 16,
                          color: Color.fromRGBO(255, 255, 255, 1),
                        ),
                      )),
                ),
              ],
            ),
          ),
          if(movieDetails.trailerKey != null)
              Expanded(
                  child: Row(
                    children: [
                      Container(
                        height: 15,
                        width: 1,
                        color: Colors.grey,
                      ),
                      TextButton(
                          onPressed: () => Navigator.of(context).pushNamed(
                              MainNavigationRoutesNames.movieTrailerWidget,
                              arguments: movieDetails.trailerKey),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                              ),
                              Text(
                                'Відтворити трейлер',
                                style: TextStyle(
                                  fontFamily: 'Source Sans Pro',
                                  fontSize: 16,
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}

class _SummeryWidget extends StatelessWidget {
  const _SummeryWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final movieDetails = context.select((MovieDetailsModel model) => model.data.summaryData);
    return Container(
      color: const Color.fromRGBO(22, 21, 25, 1),
      width: double.infinity,
      child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                movieDetails.texts,
                maxLines: 3,
                style: const TextStyle(
                  fontFamily: 'Source Sans Pro',
                  fontSize: 16,
                  color: Color.fromRGBO(255, 255, 255, 1),
                ),
              ),
              Text(
                movieDetails.genres,
                maxLines: 3,
                style: const TextStyle(
                  fontFamily: 'Source Sans Pro',
                  fontSize: 16,
                  color: Color.fromRGBO(255, 255, 255, 1),
                ),
              ),
            ],
          )),
    );
  }
}

