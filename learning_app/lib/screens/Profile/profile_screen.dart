import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:learning_app/screens/Profile/EditProfileScreen.dart'; // Add this import
import 'package:learning_app/screens/Profile/Employee_edit_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  final Function onNavigate;
  const ProfileScreen({super.key, required this.onNavigate});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? userData;
  Map<String, dynamic>? subscriptionData;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final SupabaseClient _supabase = Supabase.instance.client;

  final List<String> workConditions = [
    'Work from home',
    'Office site',
    'On leave',
  ];

  String? selectedCondition;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutBack));

    _fetchUserData();
    fetchCurrentCondition();
  }

  Future<void> fetchCurrentCondition() async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId != null) {
      final response = await _supabase
          .from('employees')
          .select('workcondition')
          .eq('supabase_user_id', userId)
          .single();

      if (response != null && response['workcondition'] != null) {
        setState(() {
          selectedCondition = response['workcondition'];
        });
      }
    }
  }

  Future<void> updateWorkCondition(String newCondition) async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId != null) {
      try {
        await _supabase.from('employees').update(
            {'workcondition': newCondition}).eq('supabase_user_id', userId);

        setState(() {
          selectedCondition = newCondition;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Work condition updated.')),
        );
      } catch (e) {
        debugPrint('❌ Failed to update work condition: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ Error updating work condition.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      final supabaseUser = Supabase.instance.client.auth.currentUser;

      if (supabaseUser != null) {
        // --- EMPLOYEE PATH (Supabase) ---
        print('Supabase user found. Fetching employee data...');
        final response = await Supabase.instance.client
            .from('employees')
            .select()
            .eq('email', supabaseUser.email!)
            .limit(1)
            .maybeSingle();

        if (response == null) {
          throw Exception("Employee record not found.");
        }

        if (!mounted) return;
        setState(() {
          userData = {
            ...response,
            'name': response['full_name'],
            'role': response['role'] ?? 'Employee',
          };
          subscriptionData = null;
        });
      } else {
        final firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          // --- EMPLOYER PATH (Firebase) ---
          print('Firebase user found. Fetching employer data...');
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .get();

          if (!userDoc.exists)
            throw Exception("User record not found in Firestore.");

          final subscriptionQuery = await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .collection('subscription')
              .limit(1)
              .get();

          if (!mounted) return;
          setState(() {
            userData = userDoc.data();
            subscriptionData = subscriptionQuery.docs.isNotEmpty
                ? subscriptionQuery.docs.first.data()
                : null;
          });
        } else {
          throw Exception("User not authenticated");
        }
      }

      // Start animations after data is loaded
      _animationController.forward();
    } catch (e) {
      print('Error in _fetchUserData: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _uploadProfilePicture() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (picked == null || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Uploading image...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );

    try {
      const imgbbApiKey = '96ad28737529b7b0a7e18d56d31d8e25';
      final uri = Uri.parse("https://api.imgbb.com/1/upload?key=$imgbbApiKey");
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('image', picked.path));
      final response = await request.send();

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to upload image. Status code: ${response.statusCode}');
      }

      final body = await response.stream.bytesToString();
      final url = json.decode(body)['data']['url'];
      final role = userData?['role'];

      if (role == 'Admin' || role == 'HR Manager') {
        // --- Employer Logic: Update Firestore ---
        final userId = fb_auth.FirebaseAuth.instance.currentUser?.uid;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'companyLogo': url});
      } else {
        // --- Employee Logic: Update Supabase ---
        final userEmail = Supabase.instance.client.auth.currentUser?.email;
        await Supabase.instance.client
            .from('employees')
            .update({'profile_image_url': url}).eq('email', userEmail!);
      }

      if (mounted) Navigator.of(context).pop();
      await _fetchUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Profile picture updated successfully!'),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      print('Error uploading image: $e');
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error uploading image: $e')),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _navigateToEditScreen() {
    if (userData == null) return;

    // Check authentication source to determine navigation
    final supabaseUser = Supabase.instance.client.auth.currentUser;
    final firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;

    if (firebaseUser != null && supabaseUser == null) {
      // Firebase user (Admin/Employer) - navigate to EditProfileScreen
      Navigator.of(context)
          .push(PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                Editprofilescreen(userData: userData!, isEmployee: false),
            transitionsBuilder: (_, anim, __, child) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
              child: child,
            ),
          ))
          .then((_) => _fetchUserData());
    } else if (supabaseUser != null) {
      // Supabase user (Employee) - navigate to EmployeeEditProfileScreen
      Navigator.of(context)
          .push(PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                EmployeeEditProfileScreen(employeeData: userData!),
            transitionsBuilder: (_, anim, __, child) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
              child: child,
            ),
          ))
          .then((_) => _fetchUserData());
    }
  }

  Color _getSubscriptionColor() {
    if (subscriptionData == null) return Colors.grey;

    final expiry = DateTime.tryParse(subscriptionData!['expiryDate'] ?? '');
    if (expiry == null || expiry.isBefore(DateTime.now())) return Colors.grey;

    final package = subscriptionData!['package']?.toString().toLowerCase();
    switch (package) {
      case 'premium':
        return Colors.amber;
      case 'pro':
        return Colors.purple;
      case 'enterprise':
        return Colors.indigo;
      case 'business core':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  String _getSubscriptionStatus() {
    if (subscriptionData == null) return 'No Subscription';

    final expiryDateStr = subscriptionData!['expiryDate'];
    if (expiryDateStr != null) {
      final expiry = DateTime.tryParse(expiryDateStr);
      if (expiry != null && expiry.isBefore(DateTime.now())) {
        return 'Expired';
      }
    }

    return subscriptionData!['package'] ?? 'Basic';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;

    if (isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [Colors.grey[900]!, Colors.grey[800]!]
                  : [Colors.blue[50]!, Colors.white],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading profile...', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      );
    }

    if (userData == null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [Colors.grey[900]!, Colors.grey[800]!]
                  : [Colors.red[50]!, Colors.white],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  "Could not load user data.",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final String role = userData!['role'] ?? 'Employee';
    final bool isEmployer = (role == 'Admin' || role == 'HR Manager');
    final String? displayImageUrl =
        isEmployer ? userData!['companyLogo'] : userData!['profile_image_url'];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Colors.grey[900]!, Colors.grey[800]!]
                : [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 320,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              Colors.deepPurple[800]!,
                              Colors.deepPurple[600]!,
                              Colors.purple[400]!,
                            ]
                          : [
                              Colors.blue[400]!,
                              Colors.blue[600]!,
                              Colors.indigo[600]!,
                            ],
                    ),
                  ),
                  child: AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) => FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 50),
                            GestureDetector(
                              onTap: _uploadProfilePicture,
                              child: Hero(
                                tag: 'profile_image',
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.3),
                                        Colors.white.withOpacity(0.1),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 65,
                                    backgroundColor:
                                        Colors.white.withOpacity(0.2),
                                    backgroundImage: displayImageUrl != null
                                        ? NetworkImage(displayImageUrl)
                                        : null,
                                    child: displayImageUrl == null
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_a_photo,
                                                size: 35,
                                                color: Colors.white
                                                    .withOpacity(0.8),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Add Photo',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                            ),
                                            child: Icon(
                                              Icons.camera_alt,
                                              size: 30,
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              userData!['name'] ?? 'User Name',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                    color: Colors.black26,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.2),
                                    Colors.white.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isEmployer
                                        ? Icons.business_center
                                        : Icons.person,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    role,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) => FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        if (isEmployer) ...[
                          _buildSubscriptionCard(isDark),
                          const SizedBox(height: 24),
                          _buildInfoCard(
                            isDark,
                            'Company Information',
                            Icons.business,
                            Colors.teal,
                            [
                              _buildInfoRow(Icons.business_center, 'Company',
                                  userData!['companyName']),
                              _buildInfoRow(Icons.category, 'Industry',
                                  userData!['companyIndustry']),
                              _buildInfoRow(Icons.location_city, 'Address',
                                  userData!['companyAddress']),
                              _buildInfoRow(Icons.web, 'Website',
                                  userData!['companyWebsite']),
                              _buildInfoRow(Icons.people, 'Company Size',
                                  userData!['companySize']),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                        _buildInfoCard(
                          isDark,
                          'Personal Information',
                          Icons.person,
                          Colors.blue,
                          [
                            _buildInfoRow(
                                Icons.email, 'Email', userData!['email']),
                            _buildInfoRow(
                                Icons.phone, 'Phone', userData!['phone']),
                            _buildInfoRow(Icons.cake, 'Date of Birth',
                                userData!['date_of_birth']),
                            _buildInfoRow(Icons.location_on, 'Address',
                                userData!['address']),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildInfoCard(
                          isDark,
                          'Professional Information',
                          Icons.work,
                          Colors.deepPurple,
                          [
                            _buildInfoRow(Icons.work_outline, 'Department',
                                userData!['department']),
                            _buildInfoRow(Icons.school, 'Education',
                                userData!['education']),
                            _buildInfoRow(Icons.timeline, 'Experience',
                                userData!['experience']),
                            _buildInfoRow(
                                Icons.star, 'Skills', userData!['skills']),
                            _buildWorkConditionRow(isDark),
                          ],
                        ),
                        const SizedBox(height: 40),
                        // Enhanced Edit Profile Button
                        Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [
                                      Colors.deepPurple[600]!,
                                      Colors.deepPurple[800]!,
                                      Colors.purple[900]!,
                                    ]
                                  : [
                                      Colors.blue[400]!,
                                      Colors.blue[600]!,
                                      Colors.indigo[600]!,
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (isDark ? Colors.deepPurple : Colors.blue)
                                        .withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _navigateToEditScreen,
                            icon: const Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            label: const Text(
                              'Edit Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkConditionRow(bool isDark) {
    // Check if user is authenticated
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return const SizedBox
          .shrink(); // Don't show anything if not authenticated
    }

    final List<String> workConditions = [
      'Work from home',
      'Office site',
      'On leave',
    ];

    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchUserWorkCondition(user.id),
      builder: (context, snapshot) {
        // Show loading indicator while fetching
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Icon(Icons.home_work_outlined,
                    color: isDark ? Colors.deepPurpleAccent : Colors.deepPurple,
                    size: 22),
                const SizedBox(width: 12),
                const Expanded(
                  child: Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Handle error case
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Icon(Icons.home_work_outlined,
                    color: isDark ? Colors.deepPurpleAccent : Colors.deepPurple,
                    size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error loading work condition',
                    style: TextStyle(
                      color: isDark ? Colors.red[300] : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Get the current work condition from fetched data
        final userData = snapshot.data;
        String? selectedCondition = userData?['workcondition'];

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Icon(Icons.home_work_outlined,
                      color:
                          isDark ? Colors.deepPurpleAccent : Colors.deepPurple,
                      size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedCondition,
                      decoration: InputDecoration(
                        labelText: 'Work Condition',
                        labelStyle: TextStyle(
                          color: isDark
                              ? Colors.deepPurpleAccent
                              : Colors.deepPurple,
                          fontWeight: FontWeight.w600,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                      ),
                      items: workConditions.map((condition) {
                        return DropdownMenuItem(
                          value: condition,
                          child: Text(condition),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        if (value == null) return;

                        // Update locally
                        setState(() {
                          selectedCondition = value;
                        });

                        // Update in Supabase DB
                        try {
                          await Supabase.instance.client
                              .from('employees')
                              .update({'workcondition': value}).eq(
                                  'supabase_user_id', user.id);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Work condition updated to "$value"'),
                              ),
                            );
                          }
                        } catch (e) {
                          debugPrint('Error updating workcondition: $e');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Failed to update work condition'),
                              ),
                            );
                          }
                          // Revert the local state on error
                          setState(() {
                            selectedCondition = userData?['workcondition'];
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper method to fetch user's work condition from Supabase
  Future<Map<String, dynamic>?> _fetchUserWorkCondition(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('employees')
          .select('workcondition')
          .eq('supabase_user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Error fetching work condition: $e');
      rethrow;
    }
  }

  Widget _buildSubscriptionCard(bool isDark) {
    final subscriptionColor = _getSubscriptionColor();
    final expiryDateStr = subscriptionData?['expiryDate'];
    final expiryDate =
        expiryDateStr != null ? DateTime.tryParse(expiryDateStr) : null;
    final isActive = expiryDate != null && expiryDate.isAfter(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            subscriptionColor.withOpacity(0.1),
            subscriptionColor.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: subscriptionColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: subscriptionColor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  subscriptionColor.withOpacity(0.3),
                  subscriptionColor.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isActive ? Icons.verified : Icons.info_outline,
              color: subscriptionColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subscription Status',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _getSubscriptionStatus(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: subscriptionColor,
                  ),
                ),
                if (subscriptionData?['expiryDate'] != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Expires: ${subscriptionData!['expiryDate']}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isActive
                    ? [Colors.green[400]!, Colors.green[600]!]
                    : [Colors.grey[400]!, Colors.grey[600]!],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              isActive ? 'ACTIVE' : 'INACTIVE',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(bool isDark, String title, IconData icon,
      Color accentColor, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accentColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withOpacity(0.1),
                  accentColor.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accentColor.withOpacity(0.2),
                        accentColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            "$label:",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value != null && value.isNotEmpty ? value : "Not specified",
              style: TextStyle(
                fontSize: 16,
                color: (value != null && value.isNotEmpty)
                    ? null
                    : Colors.grey[500],
                fontStyle: (value != null && value.isNotEmpty)
                    ? FontStyle.normal
                    : FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
