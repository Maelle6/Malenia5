import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart'; // Import Lottie for animations
import 'package:learning_app/Constants/app_color.dart';
import 'package:learning_app/Constants/constant.dart';
import 'package:learning_app/Constants/route_generator.dart';

class CheckEmailScreen extends StatefulWidget {
  const CheckEmailScreen({super.key});

  @override
  State<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends State<CheckEmailScreen> {
  // Countdown duration
  static const int countdownDuration = 10; // 5 seconds
  int remainingTime = countdownDuration; // Initialize remaining time
  Timer? timer; // Timer variable

  @override
  void initState() {
    super.initState();
    // Start the countdown timer
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--; // Decrement remaining time
        });
      } else {
        timer.cancel(); // Stop the timer when it reaches zero
        Navigator.pushReplacementNamed(context, routeLoginScreen);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        body: Container(
          color: AppColors.whiteModeBgColor,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Illustration Image
                    Image.asset(
                      recoverAccountImg, // Replace with your image path
                      height: 320,
                    ),
                    const SizedBox(height: 30),

                    // Forgot Password Title
                    const Text(
                      'Password Reset Email sent',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Description Text
                    const Text(
                      "You're nearly there! We've sent you a secure link on your email to reset your password.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.greyText,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, routeLoginScreen);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      textAlign: TextAlign.center,
                      'Redirecting to login screen in $remainingTime seconds...',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
