import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_app/Constants/app_theme.dart';
import 'package:learning_app/CustomWidget/custom_bottom_navigation_bar.dart';
import 'package:learning_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:learning_app/Constants/route_generator.dart';
import 'package:learning_app/blocs/switch_bloc/switch_bloc.dart';
import 'package:learning_app/screens/login/get_started_screen.dart';
import 'package:learning_app/screens/login/login_screen.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SwitchBloc, SwitchState>(
      builder: (context, state) {
        return MaterialApp(
          theme: state.switchValue
              ? AppThemes.appThemeData[AppTheme.darkTheme]
              : AppThemes.appThemeData[AppTheme.lightTheme],
          debugShowCheckedModeBanner: false,
          title: 'RedQuack🌹',
          onGenerateRoute: RouterGenerator.generateRoute,
          home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: ((context, state) {
              if (state.status == AuthenticationStatus.authenticated) {
                return const CustomBottomNavigationBar();
              } else if (state.status == AuthenticationStatus.unauthenticated) {
                return const LoginScreen();
              } else {
                return const GetStartedScreen();
              }
            }),
          ),
        );
      },
    );
  }
}
