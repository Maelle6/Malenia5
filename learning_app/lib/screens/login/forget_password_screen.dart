import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:learning_app/Constants/app_color.dart';
import 'package:learning_app/Constants/constant.dart';
import 'package:learning_app/Constants/route_generator.dart';
import 'package:learning_app/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:learning_app/components/string.dart';
import 'package:learning_app/utils/load_overlay.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      child: Theme(
        data: ThemeData.light(),
        child: Scaffold(
          backgroundColor: AppColors.whiteModeBgColor,
          appBar: AppBar(
            backgroundColor: AppColors.whiteModeBgColor,
            elevation: 0,
            surfaceTintColor: Colors.transparent, // Remove surface tint
            //shadowColor: Color.fromARGB(97, 0, 0, 0),
            leading: IconButton(
              icon: SvgPicture.asset(
                backArrowSvg, // Your custom icon path
                width: 20,
                height: 20,
              ),
              onPressed: () {
                Navigator.pop(
                    context); // Navigate back when the button is pressed
              },
            ),
          ),
          body: BlocListener<SignInBloc, SignInState>(
            listener: (context, state) {
              final loadingOverlay = LoadingOverlay.of(context);

              // Show loading overlay when the sign-in process starts
              if (state is ResetPasswordInProcess) {
                loadingOverlay.show();
              }

              if (state is ResetPasswordSuccess) {
                loadingOverlay.hide();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
                // move to an animated screen
                Navigator.pushReplacementNamed(
                    context, routeConfirmationEmailScreen);
              } else if (state is ResetPasswordFailure) {
                loadingOverlay.hide();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Illustration Image
                      Image.asset(
                        forgetPasswordImage, // Replace with your image path
                        height: 300,
                      ),
                      const SizedBox(height: 30),

                      // Forgot Password Title
                      const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Description Text
                      const Text(
                        "Don't worry, we got you covered! Enter the email address of the associated account and we will send you a link to reset your password on that email!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.greyText,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Email Address Input
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email address',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email address.';
                          } else if (!emailRexExp.hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<SignInBloc>().add(
                                  ResetPasswordRequired(
                                      _emailController.text.trim()));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text(
                            'Submit',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
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
    );
  }
}
