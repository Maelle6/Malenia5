import 'package:deadline_repository/deadline_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_app/app_view.dart';
import 'package:learning_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:learning_app/blocs/chatbot_bloc/chatbot_bloc.dart';
import 'package:learning_app/blocs/deadline_bloc/deadlines_bloc.dart';
import 'package:learning_app/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:learning_app/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:learning_app/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:learning_app/blocs/switch_bloc/switch_bloc.dart';
import 'package:learning_app/blocs/task_CRUD_operation_bloc/task_crud_operation_bloc.dart';
import 'package:task_repository/task_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:subject_repository/subject_repository.dart';
import 'package:studyplan_repository/studyplan_repository.dart';
import 'package:learning_app/blocs/subject_CRUD_operation_bloc/subject_crud_operation_bloc.dart';
import 'package:learning_app/blocs/studyplan_CRUD_operation_bloc/studyplan_crud_operation_bloc.dart';

class MyApp extends StatelessWidget {
  final UserRepository userRepository;

  const MyApp(this.userRepository, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepository>(
          create: (context) => userRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(
              myUserRepository: context.read<UserRepository>(),
            ),
          ),

          BlocProvider<SignInBloc>(
              create: (context) => SignInBloc(
                  userRepository:
                      context.read<AuthenticationBloc>().userRepository)),

          BlocProvider<SignUpBloc>(
            create: (context) =>
                SignUpBloc(userRepository: context.read<UserRepository>()),
          ),

          BlocProvider<MyUserBloc>(
            create: (context) =>
                MyUserBloc(myUserRepository: context.read<UserRepository>()),
          ),
          BlocProvider<TaskCrudOperationBloc>(
            create: (context) => TaskCrudOperationBloc(
                taskRepository: context.read<TaskRepository>()),
          ),
          BlocProvider<DeadlineBloc>(
            create: (context) => DeadlineBloc(
                deadlineRepository: context.read<DeadlineRepository>()),
          ),
          BlocProvider<SubjectCrudOperationBloc>(
            create: (context) => SubjectCrudOperationBloc(
                subjectRepository: context.read<SubjectRepository>()),
          ),
          BlocProvider<StudyplanCrudOperationBloc>(
            create: (context) => StudyplanCrudOperationBloc(
                studyplanRepository: context.read<StudyplanRepository>()),
          ),
          BlocProvider<SwitchBloc>(
            create: (context) => SwitchBloc(),
          ),
          BlocProvider<ChatBloc>(
            create: (context) => ChatBloc(),
          ), // Add more BlocProviders if needed
        ],
        child: const MyAppView(),
      ),
    );
  }
}
