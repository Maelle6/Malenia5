import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_app/Constants/app_color.dart';
import 'package:learning_app/Constants/route_generator.dart';
import 'package:learning_app/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:learning_app/components/string.dart';
import 'package:learning_app/utils/load_overlay.dart';
import 'package:user_repository/user_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _userFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  int _currentStep = 0;
  String? _profileImageUrl;
  bool _isUploadingImage = false;

  late AnimationController _animationController;
  late AnimationController _welcomeAnimationController;
  late AnimationController _floatingAnimationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _scaleAnimation;
  Animation<double>? _welcomeSlideAnimation;
  Animation<double>? _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _welcomeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _floatingAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));

    _welcomeSlideAnimation = Tween<double>(
      begin: -50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _welcomeAnimationController,
      curve: Curves.easeOutBack,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingAnimationController,
      curve: Curves.easeInOut,
    ));

    if (_animationController.isAnimating == false) {
      _animationController.forward();
    }
    if (_welcomeAnimationController.isAnimating == false) {
      _welcomeAnimationController.forward();
    }
    if (_floatingAnimationController.isAnimating == false) {
      _floatingAnimationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _welcomeAnimationController.dispose();
    _floatingAnimationController.dispose();
    _pageController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    ageController.dispose();
    genderController.dispose();
    super.dispose();
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

    setState(() => _isUploadingImage = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.purple),
            const SizedBox(height: 16),
            Text(
              'Uploading profile picture...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
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

      setState(() {
        _profileImageUrl = url;
        _isUploadingImage = false;
      });

      if (mounted) Navigator.of(context).pop();

      _showSuccessMessage('Profile picture uploaded successfully!');
    } catch (e) {
      setState(() => _isUploadingImage = false);
      if (mounted) {
        Navigator.of(context).pop();
        _showError('Error uploading image: $e');
      }
    }
  }

  void _nextStep() {
    bool isValid = false;
    switch (_currentStep) {
      case 0:
        isValid = _userFormKey.currentState?.validate() ?? false;
        break;
      case 1:
        isValid = _passwordFormKey.currentState?.validate() ?? false;
        break;
    }

    if (isValid) {
      if (_currentStep < 1) {
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
      } else {
        _signUp();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _signUp() async {
    if (_passwordFormKey.currentState!.validate()) {
      try {
        final myUser = MyUser.empty.copyWith(
          email: emailController.text.trim(),
          username: usernameController.text.trim(),
          first_name: firstNameController.text.trim(),
          last_name: lastNameController.text.trim(),
          age: int.tryParse(ageController.text.trim()) ?? 0,
          gender: genderController.text.trim(),
          profileImage: _profileImageUrl ?? '',
        );

        // Trigger the signup event
        context.read<SignUpBloc>().add(SignUpRequired(
              myUser,
              passwordController.text.trim(),
            ));
      } catch (e) {
        _showError('Error during signup: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(20),
        elevation: 8,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(20),
        elevation: 8,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: BlocListener<SignUpBloc, SignUpState>(
          listener: (context, state) {
            final loadingOverlay = LoadingOverlay.of(context);
            if (state is SignUpProcess) {
              loadingOverlay.show();
            } else if (state is SignUpSuccess) {
              loadingOverlay.hide();
              Navigator.pushReplacementNamed(context, routeLoginScreen);
            } else if (state is SignUpFailure) {
              loadingOverlay.hide();
              _showError(state.message);
            }
          },
          child: SafeArea(
            child: Column(
              children: [
                _buildProgressIndicator(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildUserInfoStep(),
                      _buildPasswordStep(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          if (_currentStep > 0)
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: IconButton(
                onPressed: _previousStep,
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                color: Colors.grey.shade600,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.1),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ),
          Expanded(
            child: Row(
              children: [
                _buildProgressStep(0),
                const SizedBox(width: 12),
                _buildProgressStep(1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int step) {
    final isActive = _currentStep >= step;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 6,
        decoration: BoxDecoration(
          color: isActive ? AppColors.purple : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(3),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.purple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  Widget _buildUserInfoStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _userFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeIllustration(),
              const SizedBox(height: 40),
              _buildWelcomeText(),
              const SizedBox(height: 50),
              _buildTextField(
                controller: usernameController,
                label: 'Username',
                icon: Icons.person_rounded,
                validatorMsg: 'Username is required',
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: firstNameController,
                label: 'First Name',
                icon: Icons.person_rounded,
                validatorMsg: 'First name is required',
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: lastNameController,
                label: 'Last Name',
                icon: Icons.person_rounded,
                validatorMsg: 'Last name is required',
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: emailController,
                label: 'Email Address',
                icon: Icons.email_rounded,
                validator: (val) => val == null || val.isEmpty
                    ? 'Email required'
                    : (!emailRexExp.hasMatch(val) ? 'Invalid email' : null),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: ageController,
                label: 'Age',
                icon: Icons.cake_rounded,
                keyboardType: TextInputType.number,
                validatorMsg: 'Age is required',
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: genderController,
                label: 'Gender',
                icon: Icons.people_rounded,
                validatorMsg: 'Gender is required',
              ),
              const SizedBox(height: 24),
              _buildProfileImageUploader(),
              const SizedBox(height: 40),
              _buildContinueButton(),
              const SizedBox(height: 24),
              _buildLoginLink(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageUploader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Picture',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isUploadingImage ? null : _uploadProfilePicture,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _profileImageUrl != null
                            ? Colors.transparent
                            : AppColors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: _profileImageUrl != null
                            ? Border.all(color: Colors.grey.shade300, width: 2)
                            : null,
                      ),
                      child: _profileImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                _profileImageUrl!,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.purple,
                                      strokeWidth: 2,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.error_outline,
                                    color: Colors.red.shade400,
                                    size: 24,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.camera_alt_rounded,
                              color: AppColors.purple,
                              size: 28,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _profileImageUrl != null
                                ? 'Profile picture uploaded'
                                : 'Upload Profile Picture',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _profileImageUrl != null
                                  ? Colors.green.shade700
                                  : Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _profileImageUrl != null
                                ? 'Tap to change picture'
                                : 'Tap to select from gallery',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isUploadingImage)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.purple,
                          strokeWidth: 2,
                        ),
                      )
                    else
                      Icon(
                        _profileImageUrl != null
                            ? Icons.check_circle_rounded
                            : Icons.add_photo_alternate_rounded,
                        color: _profileImageUrl != null
                            ? Colors.green.shade600
                            : Colors.grey.shade400,
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_profileImageUrl == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Optional - Add a profile picture to personalize your account',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _passwordFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildStepHeader('Set Password'),
              const SizedBox(height: 60),
              _buildPasswordField(
                controller: passwordController,
                label: 'Password',
                isVisible: _isPasswordVisible,
                toggleVisibility: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
                validator: (value) => value == null || value.length < 6
                    ? 'Password must be at least 6 characters'
                    : null,
              ),
              const SizedBox(height: 24),
              _buildPasswordField(
                controller: confirmPasswordController,
                label: 'Confirm Password',
                isVisible: _isConfirmPasswordVisible,
                toggleVisibility: () => setState(() =>
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                validator: (value) => value != passwordController.text
                    ? 'Passwords do not match'
                    : null,
              ),
              const SizedBox(height: 40),
              _buildSignUpButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeIllustration() {
    return AnimatedBuilder(
      animation: _floatingAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (_floatingAnimation?.value ?? 0) * 10 - 5),
          child: FadeTransition(
            opacity: _fadeAnimation ?? AlwaysStoppedAnimation(1.0),
            child: ScaleTransition(
              scale: _scaleAnimation ?? AlwaysStoppedAnimation(1.0),
              child: Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.purple.withOpacity(0.1),
                      Colors.blue.shade100.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 20,
                      right: 30,
                      child:
                          _buildFloatingShape(Colors.orange.shade300, 40, 0.8),
                    ),
                    Positioned(
                      bottom: 30,
                      left: 40,
                      child: _buildFloatingShape(Colors.pink.shade300, 30, 1.2),
                    ),
                    Positioned(
                      top: 50,
                      left: 20,
                      child: _buildFloatingShape(Colors.cyan.shade300, 25, 0.6),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.purple,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.purple.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_add_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Join Malenia - Your AI Travel Buddy 🌍✨',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingShape(Color color, double size, double speedMultiplier) {
    return AnimatedBuilder(
      animation: _floatingAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            (_floatingAnimation?.value ?? 0) * 5 * speedMultiplier,
            (_floatingAnimation?.value ?? 0) * 8 * speedMultiplier,
          ),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withOpacity(0.6),
              borderRadius: BorderRadius.circular(size / 2),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeText() {
    return AnimatedBuilder(
      animation: _welcomeAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_welcomeSlideAnimation?.value ?? 0, 0),
          child: FadeTransition(
            opacity: _fadeAnimation ?? AlwaysStoppedAnimation(1.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Create ',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                      height: 1.2,
                    ),
                    children: [
                      TextSpan(
                        text: 'Account',
                        style: TextStyle(
                          color: AppColors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find Your Perfect Travel Companion with Malenia',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.purple.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.purple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _currentStep == 0
                      ? 'Enter your details to join Malenia'
                      : 'Set a secure password for your account',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? validatorMsg,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType ?? TextInputType.text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'Enter your $label.toLowerCase()',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.normal,
              ),
              prefixIcon: Icon(
                icon,
                color: Colors.grey.shade500,
                size: 22,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.purple, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
            validator: validator ??
                (validatorMsg != null
                    ? (value) =>
                        value == null || value.isEmpty ? validatorMsg : null
                    : null),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback toggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: !isVisible,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'Enter your $label.toLowerCase()',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.normal,
              ),
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: Colors.grey.shade500,
                size: 22,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isVisible
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: Colors.grey.shade500,
                  size: 22,
                ),
                onPressed: toggleVisibility,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.purple, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.purple,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Continue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.purple,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.person_add_rounded, size: 20),
            SizedBox(width: 8),
            Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 15,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, routeLoginScreen),
          child: Text(
            'Login now',
            style: TextStyle(
              color: AppColors.purple,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
