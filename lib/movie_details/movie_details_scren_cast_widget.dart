import 'package:flutter/material.dart';
import 'package:movie_list/movie_details/movie_details_model.dart';
import 'package:provider/provider.dart';

class MovieDetailsMainScreenCastWidget extends StatelessWidget {
  const MovieDetailsMainScreenCastWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'В головних ролях',
              style: TextStyle(
                  fontFamily: 'Source Sans Pro',
                  fontSize: 19,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(
            height: 240,
            child: Scrollbar(
              child: _ActorListWidget(),
            ),
          ),
          TextButton(
              onPressed: () {},
              child: const Text('Уся знімальна група й актори'))
        ],
      ),
    );
  }
}

class _ActorListWidget extends StatelessWidget {
  const _ActorListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 7,
      itemExtent: 125,
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int index) {
        return _ActorListItemWidget(actorIndex: index);
      },
    );
  }
}

class _ActorListItemWidget extends StatelessWidget {
  final int actorIndex;
  const _ActorListItemWidget({Key? key, required this.actorIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.read<MovieDetailsModel>();
    final actors = model.data.actorsData;
    if(actors.isEmpty) return const SizedBox.shrink();
    final actor = actors[actorIndex];
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  width: 0.8, color: const Color.fromRGBO(227, 227, 227, 1)),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ]),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            clipBehavior: Clip.hardEdge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                actor.image,
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        actor.originalName,
                        maxLines: 2,
                        style: const TextStyle(
                            fontFamily: 'Source Sans Pro',
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        actor.character,
                        maxLines: 2,
                        style: const TextStyle(
                              fontFamily: 'Source Sans Pro', fontSize: 14.4))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
