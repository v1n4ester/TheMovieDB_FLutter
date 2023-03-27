import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_list/domain/blocs/auth_bloc.dart';
import 'package:movie_list/movie_details/movie_details_model.dart';
import 'package:movie_list/movie_details/movie_details_widget.dart';
import 'package:movie_list/ui/widgets/auth/auth_widget.dart';
import 'package:movie_list/ui/widgets/auth/auth_view_cubit.dart';
import 'package:movie_list/ui/widgets/movie_list/movie_list_cubit.dart';
import 'package:movie_list/ui/widgets/loader_widget/loader_view_cubit.dart';
import 'package:movie_list/ui/widgets/loader_widget/loader_widget.dart';
import 'package:movie_list/ui/widgets/main_screen/main_screen_widget.dart';
import 'package:movie_list/ui/widgets/movie_list/movie_list_widget.dart';
import 'package:movie_list/ui/widgets/movie_trailer/movie_trailer_widget.dart';
import 'package:provider/provider.dart';

import '../blocs/movie_list_bloc.dart';

class ScreenFactory {
  AuthBloc? _authBloc;

  Widget makeLoader() {
    final authBloc = _authBloc ?? AuthBloc(AuthCheckStatusInProgressState());
    _authBloc = authBloc;
    return BlocProvider<LoaderViewCubit>(
        create: (_) => LoaderViewCubit( LoaderViewCubitState.unknown, authBloc),
        child: const LoaderWidget());
  }

  // Widget makeAuth() {
  //   return ChangeNotifierProvider(
  //       create: (_) => AuthViewModel(), child: const AuthWidget());
  // }

  Widget makeAuth() {
    final authBloc = _authBloc ?? AuthBloc(AuthCheckStatusInProgressState());
    _authBloc = authBloc;

    return BlocProvider<AuthViewCubit>(
      create: (_) => AuthViewCubit(AuthViewCubitFormFillInProgressState(), authBloc),
      child: const AuthWidget(),
      );
  }

  Widget makeMainScreen() {
    _authBloc?.close();
    _authBloc = null;
    return  const MainScreenWidget();
  }

  Widget makeMovieDetails(int movieId) {
    return ChangeNotifierProvider(
        create: (_) => MovieDetailsModel(movieId: movieId),
        child: const MovieDetailsWidget(),
      );
  }

  Widget makeMovietrailler(String youtubeKey) {
    return  MovieTrailerWidget(youtubeKey: youtubeKey);
  }

  Widget makeMovieList() {
    return BlocProvider<MovieListCubit>(
        create: (_) => MovieListCubit(MovieListBloc(const MovieListState.initial())),
        child: const MovieListWidget());
  }
}
