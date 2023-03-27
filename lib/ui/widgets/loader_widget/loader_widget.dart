import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_list/ui/navigation/main_navigation.dart';
import 'package:movie_list/ui/widgets/loader_widget/loader_view_cubit.dart';

class LoaderWidget extends StatelessWidget {
  const LoaderWidget({super.key});

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();

  //   final cubit = context.read<LoaderViewCubit>();
  //   _onLoaderViewCubitStateChange(context, cubit.state);
  // }
  @override
  Widget build(BuildContext context) {
    return BlocListener<LoaderViewCubit, LoaderViewCubitState>(
      listenWhen: (previous, current) => current != LoaderViewCubitState.unknown,
      listener: _onLoaderViewCubitStateChange,
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  void _onLoaderViewCubitStateChange(BuildContext context, LoaderViewCubitState state) {
    final nextScreen = state == LoaderViewCubitState.authorized
            ? MainNavigationRoutesNames.mainScreen
            : MainNavigationRoutesNames.auth;
        Navigator.of(context).pushReplacementNamed(nextScreen);
  }
}
