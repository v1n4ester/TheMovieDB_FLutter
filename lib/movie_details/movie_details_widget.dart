import 'package:flutter/material.dart';
import 'package:movie_list/movie_details/movie_details_main_info_widget.dart';
import 'package:movie_list/movie_details/movie_details_model.dart';
import 'package:movie_list/movie_details/movie_details_scren_cast_widget.dart';
import 'package:provider/provider.dart';

class MovieDetailsWidget extends StatefulWidget {
  const MovieDetailsWidget({Key? key}) : super(key: key);

  @override
  State<MovieDetailsWidget> createState() => _MovieDetailsWidgetState();
}

class _MovieDetailsWidgetState extends State<MovieDetailsWidget> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final locale = Localizations.localeOf(context);
    Future.microtask(() => context.read<MovieDetailsModel>().setupLocale(context, locale)); // почекає поки добуудується дерево і тоді викличить метод
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const _TitleWidget(),
          centerTitle: true,
        ),
        body: const ColoredBox(
          color: Color.fromRGBO(22, 21, 24, 1),
          child: _BodyWidget()
        ));
  }
}


class _TitleWidget extends StatelessWidget {
  const _TitleWidget({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = context.select((MovieDetailsModel model) => model.data.title);
    return Text(title);
  }
}

class _BodyWidget extends StatelessWidget {
  const _BodyWidget({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select((MovieDetailsModel model) => model.data.isLoading);
    if(isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
            children: const [
              MovieDetailsMainInfoWidget(),
              MovieDetailsMainScreenCastWidget()
            ],
          );
  }
}