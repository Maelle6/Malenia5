import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Editprofilescreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const Editprofilescreen({
    super.key,
    required this.userData,
    required bool isEmployee,
  });

  @override
  State<Editprofilescreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<Editprofilescreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController companyNameController;
  late TextEditingController companyAddressController;
  late TextEditingController companyIndustryController;
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

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimations();
  }

  void _initializeControllers() {
    nameController = TextEditingController(text: widget.userData["name"] ?? "");
    companyNameController =
        TextEditingController(text: widget.userData["companyName"] ?? "");
    companyAddressController =
        TextEditingController(text: widget.userData["companyAddress"] ?? "");
    companyIndustryController =
        TextEditingController(text: widget.userData["companyIndustry"] ?? "");
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
    nameController.dispose();
    companyNameController.dispose();
    companyAddressController.dispose();
    companyIndustryController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfileChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw 'User not logged in';

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        "name": nameController.text.trim(),
        "companyName": companyNameController.text.trim(),
        "companyAddress": companyAddressController.text.trim(),
        "companyIndustry": companyIndustryController.text.trim(),
      });

      if (mounted) {
        _showSuccessSnackBar('Profile updated successfully! ✨');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to update profile: $e');
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() => isChangingPassword = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not logged in';

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPasswordController.text,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPasswordController.text);

      if (mounted) {
        _showSuccessSnackBar('Password changed successfully! 🔐');
        _clearPasswordFields();
        setState(() => _showPasswordSection = false);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to change password';
        if (e.toString().contains('wrong-password')) {
          errorMessage = 'Current password is incorrect';
        } else if (e.toString().contains('weak-password')) {
          errorMessage = 'New password is too weak';
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
          _buildProfileInfoCard(isDark, colorScheme),
          const SizedBox(height: 20),
          _buildPasswordCard(isDark, colorScheme),
          const SizedBox(height: 30),
          _buildSaveButton(isDark, colorScheme),
        ],
      ),
    );
  }

  Widget _buildProfileInfoCard(bool isDark, ColorScheme colorScheme) {
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
                  'Profile Information',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildAnimatedTextField(
              controller: nameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              isDark: isDark,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 16),
            _buildAnimatedTextField(
              controller: companyNameController,
              label: 'Company Name',
              icon: Icons.business_outlined,
              isDark: isDark,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 16),
            _buildAnimatedTextField(
              controller: companyAddressController,
              label: 'Company Address',
              icon: Icons.location_on_outlined,
              isDark: isDark,
              colorScheme: colorScheme,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            _buildAnimatedTextField(
              controller: companyIndustryController,
              label: 'Company Industry',
              icon: Icons.work_outline,
              isDark: isDark,
              colorScheme: colorScheme,
            ),
          ],
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
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (value) => value!.isEmpty ? '$label is required' : null,
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
