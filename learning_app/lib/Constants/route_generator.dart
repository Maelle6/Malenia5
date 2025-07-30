import 'package:flutter/material.dart';
import 'package:learning_app/CustomWidget/custom_bottom_navigation_bar.dart';
import 'package:learning_app/screens/flockSubscription/subscription_Page.dart';

import 'package:learning_app/screens/login/confirmation_email_sent.dart';
import 'package:learning_app/screens/login/forget_password_screen.dart';
import 'package:learning_app/screens/login/login_screen.dart';
import 'package:learning_app/screens/home/setting_screen.dart';
import 'package:learning_app/screens/login/sign_up_screen.dart';
import 'package:learning_app/screens/login/get_started_screen.dart';

// import 'package:learning_app/screens/stats/stats_screen.dart';
// import 'package:learning_app/screens/mind/mind_screen.dart';
// import 'package:learning_app/screens/chatbot/chatbot_screen.dart';

// Define route constants outside the RouterGenerator class
// const String routeHomeScreen = 'homeScreen';
// const String routePlanScreen = 'planScreen';
// const String routeMindScreen = 'mindScreen';
// const String routeChatbotScreen = 'chatbotScreen';
// const String routeStatsScreen = 'statsScreen';
const String routeGetStartedScreen = 'getStartedScreen';
const String routeLoginScreen = 'loginScreen';
const String routeSignInScreen = 'signInScreen';
const String routeForgetPasswordScreen = 'forgetPasswordScreen';
const String routeConfirmationEmailScreen = 'checkEmailScreen';
const String routeSettingScreen = 'settingScreen';
const String routeAddDeadlineScreen = 'addDeadlineScreen';
const String routeAddTaskScreen = 'addTaskScreen';
const String routeListOfTaskScreen = 'listOfTaskScreen';
const String routeListOfDeadlineScreen = 'listOfDeadlineScreen';
const String routeSubjectManagerScreen = 'subjectPanel';
const String routeStudyPlanScreen = 'studyPlan';
//use this route if you want to Navigate to home
const String routeNavigationScreen = 'navigationScreen';
//const String routeSubscriptionPage = 'subscriptionPage';
const String routeAddEmployeePage = 'add-employee';
const String routeEmployeeDirectoryPage = 'employee-directory';
const String routeSubscriptionPage = 'subscription_Page';
const String routeEditBranchPage = 'edit_branch';

class RouterGenerator {
  static PageRouteBuilder generateRoute(RouteSettings routeSettings) {
    //custom fade and scale transition function
    PageRouteBuilder buildPageRoute(Widget page) {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const curve = Curves.easeInOut;

          // Define the fade animation
          var fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: curve),
          );

          // Define the scale animation
          var scaleAnimation = Tween(begin: 0.95, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: curve),
          );

          return FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      );
    }

    switch (routeSettings.name) {
      // case routePlanScreen:
      //   return buildPageRoute(PlanScreen());
      // case routeMindScreen:
      //   return buildPageRoute(const MindScreen());
      // case routeChatbotScreen:
      //   return buildPageRoute(const ChatbotScreen());
      // case routeStatsScreen:
      //   return buildPageRoute(const StatsScreen());
      case routeGetStartedScreen:
        return buildPageRoute(const GetStartedScreen());
      case routeLoginScreen:
        return buildPageRoute(const LoginScreen());
      case routeSignInScreen:
        return buildPageRoute(const SignUpScreen());
      case routeForgetPasswordScreen:
        return buildPageRoute(const ForgotPasswordScreen());
      case routeConfirmationEmailScreen:
        return buildPageRoute(const CheckEmailScreen());
      case routeSubscriptionPage:
        return buildPageRoute(SubscriptionPage(
          onNavigate: () {},
        ));
      case routeSettingScreen:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return buildPageRoute(SettingsScreen(
          initial: args['initial'],
          displayName: args['displayName'],
          userEmail: args['userEmail'],
        ));

      case routeNavigationScreen:
        return buildPageRoute(const CustomBottomNavigationBar());
      default:
        return buildPageRoute(const CustomBottomNavigationBar());
    }
  }
}
