import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_list/ui/Theme/button_style.dart';
import 'package:movie_list/ui/Theme/app_colors.dart';
import 'package:movie_list/ui/navigation/main_navigation.dart';
import 'package:movie_list/ui/widgets/auth/auth_view_cubit.dart';
import 'package:provider/provider.dart';

class _AuthDataStorage {
  String login = '';
  String password = '';
}

class AuthWidget extends StatelessWidget {
  const AuthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthViewCubit, AuthViewCubitState>(
      listener: _onAuthViewCubitStateChange,
      child: Provider(
        create: (_) => _AuthDataStorage(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Залогіньтеся',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  fontFamily: 'Source Sans Pro'),
            ),
          ),
          body: ListView(
            children: const <Widget>[
              _HeaderWidget(),
            ],
          ),
        ),
      ),
    );
  }

  void _onAuthViewCubitStateChange(
      BuildContext context, AuthViewCubitState state) {
    if (state is AuthViewCubitSuccessAuthState) {
      MainNavigation.resetNavigation(context);
    }
  }
}

class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
        fontSize: 16, color: Colors.black, fontFamily: 'Source Sans Pro');
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _FormWidget(),
          const SizedBox(height: 25),
          const Text(
            'In order to use the editing and rating capabilities of TMDB, as well as get personal recommendations you will need to login to your account. If you do not have an account, registering for an account is free and simple. Click hete to get started',
            style: style,
          ),
          const SizedBox(height: 5),
          ElevatedButton(
            style: AppButtonStyle.linkButton,
            onPressed: () {},
            child: const Text(
              'Реєстрація',
              style: AppButtonStyle.linkButtonText,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Якщо ви зареєструвалися, але не отримали електронний лист із підтвердженням, натисніть тут, щоб відправити його заново.',
            style: style,
          ),
          const SizedBox(height: 5),
          ElevatedButton(
            style: AppButtonStyle.linkButton,
            onPressed: () {},
            child: const Text(
              'Підтвердіть email',
              style: AppButtonStyle.linkButtonText,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormWidget extends StatelessWidget {
  const _FormWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final model = context.read<AuthViewModel>();
    final authDataStorage = context.read<_AuthDataStorage>();

    const textStyle = TextStyle(
        fontSize: 16,
        color: Color.fromRGBO(33, 37, 41, 1),
        fontFamily: 'Source Sans Pro');

    const inputTextStyle = TextStyle(
        fontSize: 16,
        color: Color.fromRGBO(73, 80, 87, 1),
        fontFamily: 'Source Sans Pro');

    const textFieldDecoration = InputDecoration(
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Color.fromRGBO(206, 212, 218, 1), width: 0.8)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        isCollapsed: true,
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.mainDartBlue)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ErrorMessaggeWidget(),
        const Text("Ім'я користувача", style: textStyle),
        const SizedBox(height: 4),
        TextField(
          onChanged: (text) => authDataStorage.login = text,
          //controller: model.loginTextController,
          style: inputTextStyle,
          decoration: textFieldDecoration,
        ),
        const SizedBox(height: 16),
        const Text("Пароль", style: textStyle),
        const SizedBox(height: 4),
        TextField(
          onChanged: (text) => authDataStorage.password = text,
            //controller: model.passwordTextController,
            obscureText: true,
            decoration: textFieldDecoration),
        const SizedBox(height: 30),
        Row(
          children: [
            const _AuthButtonWidget(),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Скинути пароль',
                style: TextStyle(
                    color: AppColors.mainDartBlue,
                    fontFamily: 'Source Sans Pro',
                    fontSize: 16),
              ),
            )
          ],
        )
      ],
    );
  }
}

class _AuthButtonWidget extends StatelessWidget {
  const _AuthButtonWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final model = context.watch<AuthViewModel>();
    //final onPressed = model.canStartAuth ? () => model.auth(context) : null;
    //final child = cubit.isAuthInProgress
    final cubit = context.watch<AuthViewCubit>();
    final authDataStorage = context.read<_AuthDataStorage>(); 
    final canStartAuth = cubit.state is AuthViewCubitFormFillInProgressState || cubit.state is AuthViewCubitErrorState;
    final onPressed = canStartAuth ? () => cubit.auth(authDataStorage.login, authDataStorage.password) : null;
    final child = cubit.state is AuthViewCubitAuthProgressState
        ? const SizedBox(
            height: 20, width: 20, child: CircularProgressIndicator())
        : const Text('Увійти', style: AppButtonStyle.linkButtonText);
    return ElevatedButton(
      style: AppButtonStyle.linkButton,
      onPressed: onPressed,
      child: child,
    );
  }
}

class _ErrorMessaggeWidget extends StatelessWidget {
  const _ErrorMessaggeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final errorMessage =
    //     context.select((AuthViewModel value) => value.errorMessage);
    final errorMessage =
        context.select((AuthViewCubit c) {
          final state = c.state;
          return state is AuthViewCubitErrorState ? state.errorMessage : null;
        });
    if (errorMessage == null) {
      return const SizedBox.shrink();
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Text(
          errorMessage,
          style: const TextStyle(
              color: Colors.red, fontSize: 16, fontFamily: 'Sence Sans Pro'),
        ),
      );
    }
  }
}
