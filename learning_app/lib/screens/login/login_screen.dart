import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_app/Constants/route_generator.dart';
import 'package:learning_app/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:learning_app/components/string.dart';
import 'package:learning_app/utils/load_overlay.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  int _currentStep = 0;

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
    // Main content animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Welcome section animations
    _welcomeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Floating elements animation
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

    // Start animations
    _animationController.forward();
    _welcomeAnimationController.forward();
    _floatingAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _welcomeAnimationController.dispose();
    _floatingAnimationController.dispose();
    _pageController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0 && _validateEmail()) {
      setState(() => _currentStep = 1);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousStep() {
    if (_currentStep == 1) {
      setState(() => _currentStep = 0);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  bool _validateEmail() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _showError('Please enter your email address');
      return false;
    }
    if (!emailRexExp.hasMatch(email)) {
      _showError('Please enter a valid email address');
      return false;
    }
    return true;
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

  void _signIn() {
    final password = passwordController.text.trim();
    if (password.isEmpty) {
      _showError('Please enter your password');
      return;
    }

    context.read<SignInBloc>().add(
          SignInRequired(
            emailController.text.trim(),
            passwordController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FFFE),
        body: BlocListener<SignInBloc, SignInState>(
          listener: _handleSignInState,
          child: SafeArea(
            child: Column(
              children: [
                _buildProgressIndicator(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildEmailStep(),
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

  void _handleSignInState(BuildContext context, SignInState state) {
    final loadingOverlay = LoadingOverlay.of(context);

    switch (state.runtimeType) {
      case SignInProcess:
        loadingOverlay.show();
        break;
      case SignInSuccess:
        loadingOverlay.hide();
        Navigator.pushReplacementNamed(context, routeNavigationScreen);
        break;
      case SignInFailure:
        loadingOverlay.hide();
        _showError((state as SignInFailure).message);
        break;
    }
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          if (_currentStep == 1)
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
          color: isActive ? const Color(0xFF2E8B89) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(3),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF2E8B89).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  Widget _buildEmailStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTravelIllustration(),
            const SizedBox(height: 40),
            _buildWelcomeText(),
            const SizedBox(height: 50),
            _buildEmailInput(),
            const SizedBox(height: 40),
            _buildContinueButton(),
            const SizedBox(height: 24),
            _buildSignUpLink(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelIllustration() {
    if (_floatingAnimation == null ||
        _fadeAnimation == null ||
        _scaleAnimation == null) {
      return const SizedBox(height: 260);
    }

    return AnimatedBuilder(
      animation: _floatingAnimation!,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation!.value * 8 - 4),
          child: FadeTransition(
            opacity: _fadeAnimation!,
            child: ScaleTransition(
              scale: _scaleAnimation!,
              child: Container(
                height: 260,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF2E8B89).withOpacity(0.08),
                      const Color(0xFF4A90E2).withOpacity(0.15),
                      const Color(0xFFE8F4F8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Stack(
                  children: [
                    // Background floating elements
                    Positioned(
                      top: 30,
                      right: 40,
                      child: _buildFloatingShape(
                        const Color(0xFFFF6B6B),
                        35,
                        0.7,
                        Icons.flight_takeoff,
                      ),
                    ),
                    Positioned(
                      bottom: 50,
                      left: 50,
                      child: _buildFloatingShape(
                        const Color(0xFF4ECDC4),
                        30,
                        1.1,
                        Icons.luggage,
                      ),
                    ),
                    Positioned(
                      top: 70,
                      left: 30,
                      child: _buildFloatingShape(
                        const Color(0xFFFFD93D),
                        28,
                        0.9,
                        Icons.explore,
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      right: 60,
                      child: _buildFloatingShape(
                        const Color(0xFF6BCF7F),
                        25,
                        0.8,
                        Icons.map,
                      ),
                    ),
                    // Main logo and content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // App Logo
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF2E8B89).withOpacity(0.3),
                                  blurRadius: 25,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Image.asset(
                                'assets/Images/malenia.png', // Your logo path
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback if logo not found
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          const Color(0xFF2E8B89),
                                          const Color(0xFF4A90E2),
                                        ],
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'M',
                                        style: TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Malenia',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E8B89),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your Perfect Travel Companion Awaits',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
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

  Widget _buildFloatingShape(
      Color color, double size, double speedMultiplier, IconData icon) {
    if (_floatingAnimation == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Icon(
          icon,
          color: color,
          size: size * 0.5,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _floatingAnimation!,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _floatingAnimation!.value * 4 * speedMultiplier,
            _floatingAnimation!.value * 6 * speedMultiplier,
          ),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(size / 2),
            ),
            child: Icon(
              icon,
              color: color,
              size: size * 0.5,
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeText() {
    if (_welcomeSlideAnimation == null || _fadeAnimation == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: 'Welcome ',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
                height: 1.2,
              ),
              children: [
                TextSpan(
                  text: 'Explorer!',
                  style: TextStyle(
                    color: const Color(0xFF2E8B89),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ready to find your next travel buddy?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      );
    }

    return AnimatedBuilder(
      animation: _welcomeSlideAnimation!,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_welcomeSlideAnimation!.value, 0),
          child: FadeTransition(
            opacity: _fadeAnimation!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Welcome ',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                      height: 1.2,
                    ),
                    children: [
                      TextSpan(
                        text: 'Explorer!',
                        style: TextStyle(
                          color: const Color(0xFF2E8B89),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ready to find your next travel buddy?',
                  style: TextStyle(
                    fontSize: 16,
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

  Widget _buildEmailInput() {
    if (_slideAnimation == null || _fadeAnimation == null) {
      return _buildEmailInputContent();
    }

    return SlideTransition(
      position: _slideAnimation!,
      child: FadeTransition(
        opacity: _fadeAnimation!,
        child: _buildEmailInputContent(),
      ),
    );
  }

  Widget _buildEmailInputContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
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
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'Enter your email address',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.normal,
              ),
              prefixIcon: Icon(
                Icons.email_outlined,
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
                borderSide:
                    BorderSide(color: const Color(0xFF2E8B89), width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    if (_slideAnimation == null || _fadeAnimation == null) {
      return _buildContinueButtonContent();
    }

    return SlideTransition(
      position: _slideAnimation!,
      child: FadeTransition(
        opacity: _fadeAnimation!,
        child: _buildContinueButtonContent(),
      ),
    );
  }

  Widget _buildContinueButtonContent() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E8B89).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E8B89),
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
              'Continue Journey',
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

  Widget _buildSignUpLink() {
    if (_fadeAnimation == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'New to Malenia? ',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 15,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, routeSignInScreen),
            child: Text(
              'Create Account',
              style: TextStyle(
                color: const Color(0xFF2E8B89),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation!,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'New to Malenia? ',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 15,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, routeSignInScreen),
            child: Text(
              'Create Account',
              style: TextStyle(
                color: const Color(0xFF2E8B89),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildPasswordHeader(),
            const SizedBox(height: 60),
            _buildPasswordInput(),
            const SizedBox(height: 20),
            _buildForgotPasswordLink(),
            const SizedBox(height: 60),
            _buildSignInButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Secure Access',
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
            color: const Color(0xFF2E8B89).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF2E8B89).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                color: const Color(0xFF2E8B89),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: 'Welcome back, ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    children: [
                      TextSpan(
                        text: emailController.text,
                        style: TextStyle(
                          color: const Color(0xFF2E8B89),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
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
            controller: passwordController,
            obscureText: !_isPasswordVisible,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'Enter your password',
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
                  _isPasswordVisible
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: Colors.grey.shade500,
                  size: 22,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
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
                borderSide:
                    BorderSide(color: const Color(0xFF2E8B89), width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, routeForgetPasswordScreen),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            'Forgot Password?',
            style: TextStyle(
              color: const Color(0xFF2E8B89),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E8B89).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _signIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E8B89),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.flight_takeoff_rounded, size: 20),
            SizedBox(width: 8),
            Text(
              'Start Journey',
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
}
