import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class EmployeeEditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> employeeData;

  const EmployeeEditProfileScreen({
    super.key,
    required this.employeeData,
  });

  @override
  State<EmployeeEditProfileScreen> createState() =>
      _EmployeeEditProfileScreenState();
}

class _EmployeeEditProfileScreenState extends State<EmployeeEditProfileScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController nationalIdController;
  late TextEditingController dateOfBirthController;
  late TextEditingController currentPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool isSaving = false;
  bool isChangingPassword = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _showPasswordSection = false;

  DateTime? selectedDate;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimations();
  }

  void _initializeControllers() {
    fullNameController =
        TextEditingController(text: widget.employeeData["full_name"] ?? "");
    emailController =
        TextEditingController(text: widget.employeeData["email"] ?? "");
    phoneController =
        TextEditingController(text: widget.employeeData["phone"] ?? "");
    addressController =
        TextEditingController(text: widget.employeeData["address"] ?? "");
    nationalIdController =
        TextEditingController(text: widget.employeeData["national_id"] ?? "");

    // Handle date of birth
    if (widget.employeeData["date_of_birth"] != null) {
      selectedDate = DateTime.parse(widget.employeeData["date_of_birth"]);
      dateOfBirthController = TextEditingController(
          text: DateFormat('yyyy-MM-dd').format(selectedDate!));
    } else {
      dateOfBirthController = TextEditingController();
    }

    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    nationalIdController.dispose();
    dateOfBirthController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ??
          DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> updateUserEmailViaEdgeFunction({
    required String supabaseUserId,
    required String newEmail,
  }) async {
    final url = Uri.parse(
        'https://fgamjtbxrcepnrizlyjl.supabase.co/functions/v1/updateUserEmail');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'supabase_user_id': supabaseUserId,
        'email': newEmail,
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body)['error'] ?? 'Unknown error';
      throw Exception('Failed to update email: $error');
    }
  }

  Future<void> _saveProfileChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      final userId = supabase.auth.currentUser?.id;
      debugPrint('Current User ID: $userId');
      if (userId == null) throw 'User not logged in';

      // 1. Check if email has changed, if yes, update via Edge Function first
      if (emailController.text != widget.employeeData['email']) {
        final supabaseUserId = widget.employeeData['supabase_user_id'];
        if (supabaseUserId != null) {
          debugPrint('📧 Email changed, updating Supabase Auth email...');
          await updateUserEmailViaEdgeFunction(
            supabaseUserId: supabaseUserId,
            newEmail: emailController.text,
          );
          debugPrint('✅ Supabase Auth email updated');
        } else {
          debugPrint(
              '⚠️ No supabase_user_id found, skipping Auth email update');
        }
      }

      final updatedData = {
        'full_name': fullNameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'national_id': nationalIdController.text.trim(),
        'date_of_birth': selectedDate?.toIso8601String().split('T')[0],
      };

      debugPrint('Updating employee data: $updatedData');

      final updateResponse = await supabase
          .from('employees')
          .update(updatedData)
          .eq('supabase_user_id', userId);

      debugPrint('Supabase update response: ${updateResponse.toString()}');

      // Check if email has changed and update in Supabase Auth
      if (emailController.text.trim() != widget.employeeData["email"]) {
        debugPrint('Updating email in Supabase Auth...');
        final authResponse = await supabase.auth
            .updateUser(UserAttributes(email: emailController.text.trim()));
        debugPrint('Auth update response: ${authResponse.toString()}');
      }

      if (mounted) {
        _showSuccessSnackBar('Profile updated successfully! ✨');
      }
    } catch (e) {
      debugPrint('Error during profile update: $e');
      if (mounted) {
        _showErrorSnackBar('Failed to update profile: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() => isChangingPassword = true);

    try {
      // Verify current password by attempting to sign in
      final email = supabase.auth.currentUser?.email;
      if (email == null) throw 'User email not found';

      // Sign out and sign back in to verify current password
      await supabase.auth.signInWithPassword(
        email: email,
        password: currentPasswordController.text,
      );

      // Update password
      await supabase.auth
          .updateUser(UserAttributes(password: newPasswordController.text));

      if (mounted) {
        _showSuccessSnackBar('Password changed successfully! 🔐');
        _clearPasswordFields();
        setState(() => _showPasswordSection = false);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to change password';
        if (e.toString().contains('Invalid login credentials')) {
          errorMessage = 'Current password is incorrect';
        } else if (e
            .toString()
            .contains('Password should be at least 6 characters')) {
          errorMessage = 'New password must be at least 6 characters';
        }
        _showErrorSnackBar(errorMessage);
      }
    } finally {
      if (mounted) setState(() => isChangingPassword = false);
    }
  }

  void _clearPasswordFields() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.deepPurple.shade900,
                    Colors.indigo.shade900,
                    Colors.purple.shade800,
                  ]
                : [
                    Colors.blue.shade50,
                    Colors.indigo.shade100,
                    Colors.purple.shade50,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(context, isDark, colorScheme),
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildBody(context, isDark, colorScheme),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(
      BuildContext context, bool isDark, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(isDark ? 0.1 : 0.8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: isDark ? Colors.white : Colors.black87,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(isDark ? 0.1 : 0.8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.person_outline,
                color: isDark ? Colors.white : Colors.black87,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, bool isDark, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPersonalInfoCard(isDark, colorScheme),
          const SizedBox(height: 20),
          _buildPasswordCard(isDark, colorScheme),
          const SizedBox(height: 30),
          _buildSaveButton(isDark, colorScheme),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(bool isDark, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.secondary],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      const Icon(Icons.person, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildAnimatedTextField(
              controller: fullNameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              isDark: isDark,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 16),
            _buildAnimatedTextField(
              controller: emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              isDark: isDark,
              colorScheme: colorScheme,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value!.isEmpty) return 'Email is required';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildAnimatedTextField(
              controller: phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              isDark: isDark,
              colorScheme: colorScheme,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildAnimatedTextField(
              controller: addressController,
              label: 'Address',
              icon: Icons.location_on_outlined,
              isDark: isDark,
              colorScheme: colorScheme,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            _buildAnimatedTextField(
              controller: nationalIdController,
              label: 'National ID',
              icon: Icons.badge_outlined,
              isDark: isDark,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 16),
            _buildDateField(isDark, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(bool isDark, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: _selectDate,
      child: AbsorbPointer(
        child: TextFormField(
          controller: dateOfBirthController,
          validator: (value) =>
              value!.isEmpty ? 'Date of birth is required' : null,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            labelText: 'Date of Birth',
            prefixIcon:
                Icon(Icons.calendar_today_outlined, color: colorScheme.primary),
            suffixIcon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
            labelStyle: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            filled: true,
            fillColor:
                isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordCard(bool isDark, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange, Colors.red.shade400],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.lock_outline,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Security',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              Switch.adaptive(
                value: _showPasswordSection,
                onChanged: (value) {
                  setState(() {
                    _showPasswordSection = value;
                    if (!value) _clearPasswordFields();
                  });
                },
                activeColor: colorScheme.primary,
              ),
            ],
          ),
          if (_showPasswordSection) ...[
            const SizedBox(height: 24),
            Form(
              key: _passwordFormKey,
              child: Column(
                children: [
                  _buildPasswordField(
                    controller: currentPasswordController,
                    label: 'Current Password',
                    obscureText: _obscureCurrentPassword,
                    onToggleVisibility: () => setState(() =>
                        _obscureCurrentPassword = !_obscureCurrentPassword),
                    isDark: isDark,
                    colorScheme: colorScheme,
                    validator: (value) =>
                        value!.isEmpty ? 'Current password is required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    controller: newPasswordController,
                    label: 'New Password',
                    obscureText: _obscureNewPassword,
                    onToggleVisibility: () => setState(
                        () => _obscureNewPassword = !_obscureNewPassword),
                    isDark: isDark,
                    colorScheme: colorScheme,
                    validator: (value) {
                      if (value!.isEmpty) return 'New password is required';
                      if (value.length < 6)
                        return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    controller: confirmPasswordController,
                    label: 'Confirm New Password',
                    obscureText: _obscureConfirmPassword,
                    onToggleVisibility: () => setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword),
                    isDark: isDark,
                    colorScheme: colorScheme,
                    validator: (value) {
                      if (value!.isEmpty) return 'Please confirm your password';
                      if (value != newPasswordController.text)
                        return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildChangePasswordButton(isDark, colorScheme),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required ColorScheme colorScheme,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator:
          validator ?? (value) => value!.isEmpty ? '$label is required' : null,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
        ),
        filled: true,
        fillColor:
            isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color:
                isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required bool isDark,
    required ColorScheme colorScheme,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.lock_outline, color: colorScheme.primary),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
            color: colorScheme.primary,
          ),
          onPressed: onToggleVisibility,
        ),
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
        ),
        filled: true,
        fillColor:
            isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color:
                isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildChangePasswordButton(bool isDark, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange, Colors.red.shade400],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: isChangingPassword ? null : _changePassword,
        icon: isChangingPassword
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.security, color: Colors.white),
        label: Text(
          isChangingPassword ? 'Changing Password...' : 'Change Password',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isDark, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: isSaving ? null : _saveProfileChanges,
        icon: isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.save_rounded, color: Colors.white, size: 24),
        label: Text(
          isSaving ? 'Saving Changes...' : 'Save Profile',
          style: const TextStyle(
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
    );
  }
}
