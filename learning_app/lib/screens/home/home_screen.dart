import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_app/CustomWidget/home_content_widget.dart';
import 'package:learning_app/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learning_app/Constants/route_generator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigate;
  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<String, String> userDetails = {};

  @override
  void initState() {
    super.initState();
    debugPrint('[INIT] HomeScreen initialized.');
    _fetchUser();
    fetchUserDetails();
  }

  @override
  void dispose() {
    debugPrint('[DISPOSE] HomeScreen disposed.');
    super.dispose();
  }

  void _fetchUser() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    debugPrint('[FETCH_USER] Firebase UID: $userId');
  }

  Future<void> fetchUserDetails() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final supabaseUser = Supabase.instance.client.auth.currentUser;

    debugPrint('[DEBUG] Firebase user: $firebaseUser');
    debugPrint('[DEBUG] Supabase user: $supabaseUser');

    if (firebaseUser != null) {
      debugPrint('[INFO] Auth via Firebase. UID: ${firebaseUser.uid}');
      await _loadCompanyDetailsFromFirestore(firebaseUser.uid);
    } else if (supabaseUser != null) {
      debugPrint('[INFO] Auth via Supabase. UID: ${supabaseUser.id}');
      //await _loadCompanyDetailsFromSupabase(supabaseUser.id);
    } else {
      debugPrint('[ERROR] No user found in either Firebase or Supabase.');
    }
  }

  Future<void> _loadCompanyDetailsFromFirestore(String uid) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        debugPrint('[FIRESTORE] user data: $data');

        setState(() {
          userDetails = {
            'username': data['username'] ?? '',
            'first_name': data['first_name'] ?? '',
            'last_name': data['last_name'] ?? '',
            'email': data['email'] ?? '',
            'profileImage': data['profileImage'] ?? '',
            'displayName': data['username'] ?? 'User',
          };
        });
      } else {
        debugPrint('[FIRESTORE] Employer document not found.');
      }
    } catch (e, stack) {
      debugPrint('[ERROR] _loadCompanyDetailsFromFirestore: $e');
      debugPrint('[STACK] $stack');
    }
  }

  /*

  Future<void> _loadCompanyDetailsFromSupabase(String userId) async {
    try {
      final supabase = Supabase.instance.client;

      final employee = await supabase
          .from('employees')
          .select('full_name, email, company_id')
          .eq('supabase_user_id', userId)
          .maybeSingle();

      if (employee == null) {
        debugPrint(
            '[SUPABASE] No matching employee found for Supabase UID: $userId');
        return;
      }

      debugPrint('[SUPABASE] Employee data: $employee');

      final companyId = employee['company_id'];

      final companySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(companyId)
          .get();

      final companyData = companySnapshot.data();
      debugPrint('[FIRESTORE] Company document: $companyData');

      setState(() {
        userDetails = {
          'companyName': companyData?['companyName'] ?? '',
          'companyIndustry': companyData?['companyIndustry'] ?? '',
          'companyAddress': companyData?['companyAddress'] ?? '',
          'email': employee['email'] ?? '',
          'companyLogo': companyData?['companyLogo'] ?? '',
          'displayName': employee['full_name'] ?? 'User',
        };
      });
    } catch (e, stack) {
      debugPrint('[ERROR] _loadCompanyDetailsFromSupabase: $e');
      debugPrint('[STACK] $stack');
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    debugPrint(
        '[BUILD] HomeScreen build triggered. userDetails empty: ${userDetails.isEmpty}');

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Row(
          children: [
            const SizedBox(width: 8),
            BlocBuilder<MyUserBloc, MyUserState>(
              builder: (context, state) {
                String displayName = state.user?.username ?? "User";
                String initial =
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : "U";
                String userEmail = state.user?.email ?? "User@example.com";

                debugPrint(
                    '[BLOC] MyUserBloc: name=$displayName, email=$userEmail');

                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      routeSettingScreen,
                      arguments: {
                        "initial": initial,
                        "displayName": displayName,
                        "userEmail": userEmail,
                      },
                    );
                    debugPrint(
                        '[NAVIGATION] Navigating to Settings with: $initial, $displayName, $userEmail');
                  },
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            BlocBuilder<MyUserBloc, MyUserState>(
              builder: (context, state) {
                String displayName = userDetails['displayName'] ?? "User";

                return Expanded(
                  child: Text(
                    'Welcome, $displayName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.notifications),
              iconSize: 35,
              color: Theme.of(context).iconTheme.color,
              onPressed: () {
                debugPrint('[ACTION] Notifications icon tapped.');
              },
            ),
          ),
        ],
      ),
      body: userDetails.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : MaleniaHomeScreen(
              onNavigate: widget.onNavigate,
              userProfile: {},
            ),
    );
  }
}
