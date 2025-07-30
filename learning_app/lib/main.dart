import 'package:deadline_repository/deadline_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:learning_app/app.dart';
import 'package:learning_app/firebase_options.dart';
import 'package:learning_app/services/notification_service.dart';
import 'package:learning_app/services/supabase_sync_service.dart';
import 'package:learning_app/simple_bloc_observer.dart';
import 'package:learning_app/supabase_config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:subject_repository/subject_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_repository/task_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:studyplan_repository/studyplan_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authFlowType: AuthFlowType.implicit,
  );

  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authFlowType: AuthFlowType.implicit,
    );

    /// Now listen to Firebase and sync JWT
    FirebaseAuth.instance.idTokenChanges().listen((user) async {
      if (user == null) {
        await Supabase.instance.client.auth.signOut();
      } else {
        final token = await user.getIdToken();
        await Supabase.instance.client.auth.setSession(token!);
        print("✅ Supabase Auth set from Firebase token.");
      }
    });

    await NotificationService().init();
    Bloc.observer = SimpleBlocObserver();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: await getApplicationDocumentsDirectory(),
    );

    final userRepository =
        FirebaseUserRepository(syncService: SupabaseSyncService());
    final taskRepository = FirebaseTaskRepository();
    final deadlineRepository = FirebaseDeadlineRepository();
    final subjectRepository = FirebaseSubjectRepository();
    final studyplanRepository = FirebaseStudyplanRepository();

    final userId = FirebaseAuth.instance.currentUser?.uid;

    runApp(MyApp(userRepository));
  }

  await NotificationService().init();
  Bloc.observer = SimpleBlocObserver();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  // Create instances of repositories
  final userRepository = FirebaseUserRepository(
    syncService: SupabaseSyncService(),
  );
  final taskRepository = FirebaseTaskRepository();
  final deadlineRepository = FirebaseDeadlineRepository();
  final subjectRepository = FirebaseSubjectRepository();
  final studyplanRepository = FirebaseStudyplanRepository();
  final userId = FirebaseAuth.instance.currentUser?.uid;
  //if (userId != null) {
  // await updateStudyStreak(userId);
  //StudyTimerService().start(); // Start once user is authenticated
  //}

  runApp(MyApp(
    userRepository,
  ));
}
