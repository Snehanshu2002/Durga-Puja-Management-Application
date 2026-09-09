import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:durgapuja_manager/core/services/biometric_service.dart';
import 'package:durgapuja_manager/core/theme/app_colors.dart';
import 'package:durgapuja_manager/core/utils/validators.dart';
import 'package:durgapuja_manager/core/widgets/app_button.dart';
import 'package:durgapuja_manager/core/widgets/app_logo.dart';
import 'package:durgapuja_manager/core/widgets/app_text_field.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:durgapuja_manager/core/utils/platform_reload.dart';
import 'package:durgapuja_manager/core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/session_manager_provider.dart';
import 'package:durgapuja_manager/features/users/presentation/providers/user_provider.dart';
import 'package:durgapuja_manager/features/puja_event/presentation/providers/puja_event_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _biometricService = BiometricService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _canUseBiometrics = false;
  bool _hasSavedCredentials = false;

  static const String _keyRememberMe = 'remember_me';
  static const String _keySavedEmail = 'saved_email';
  static const String _keySavedPassword = 'saved_password';

  @override
  void initState() {
    super.initState();
    _initLoginState();
  }

  Future<void> _initLoginState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remember = prefs.getBool(_keyRememberMe) ?? false;
      final savedEmail = prefs.getString(_keySavedEmail) ?? '';
      final savedPassword = prefs.getString(_keySavedPassword) ?? '';
      final canBio = await _biometricService.canAuthenticate();

      final hasSaved = savedEmail.isNotEmpty && savedPassword.isNotEmpty;

      if (mounted) {
        setState(() {
          _canUseBiometrics = canBio;
          _hasSavedCredentials = hasSaved;
          if (remember) {
            _rememberMe = true;
            _emailController.text = savedEmail;
            _passwordController.text = savedPassword;
          } else {
            _rememberMe = false;
            _emailController.clear();
            _passwordController.clear();
          }
        });
      }
    } catch (_) {}
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/app_logo.png'), context);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleBiometricLogin() async {
    final messenger = ScaffoldMessenger.of(context);
    final authenticated = await _biometricService.authenticate();

    if (authenticated) {
      final creds = await _biometricService.getSavedCredentials();
      if (creds != null) {
        _emailController.text = creds['email']!;
        _passwordController.text = creds['password']!;
        _handleLogin();
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('No saved credentials found. Please sign in with email & password once.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Fingerprint authentication canceled or failed.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setBool(_keyRememberMe, true);
        await prefs.setString(_keySavedEmail, _emailController.text.trim());
        await prefs.setString(_keySavedPassword, _passwordController.text);
        await _biometricService.setBiometricEnabled(true);
      } else {
        await prefs.setBool(_keyRememberMe, false);
        await prefs.remove(_keySavedEmail);
        await prefs.remove(_keySavedPassword);
        await _biometricService.setBiometricEnabled(false);
      }

      await ref.read(authControllerProvider).signIn(
            email: _emailController.text,
            password: _passwordController.text,
          );
      messenger.clearSnackBars();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(forcedLogoutMessageProvider, (previous, message) {
      if (message != null && message.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 5),
                behavior: SnackBarBehavior.floating,
              ),
            );
            ref.read(forcedLogoutMessageProvider.notifier).state = null;
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const AppLogo(size: 100),
                        const SizedBox(height: 16),
                        Text(
                          AppConstants.appName,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppConstants.appTagline,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Container(
                            width: 60,
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.accent.withValues(alpha: 0.0),
                                  AppColors.accent,
                                  AppColors.accent.withValues(alpha: 0.0),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        AppTextField(
                          controller: _emailController,
                          labelText: 'Email Address',
                          hintText: 'member@durgapuja.org',
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _passwordController,
                          labelText: 'Password',
                          hintText: '••••••••',
                          obscureText: _obscurePassword,
                          validator: Validators.validatePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textSecondaryLight,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _rememberMe = val ?? false;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _rememberMe = !_rememberMe;
                                });
                              },
                              child: const Text(
                                'Remember Me',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimaryLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                text: 'Sign In',
                                isLoading: _isLoading,
                                onPressed: _handleLogin,
                              ),
                            ),
                            if (_canUseBiometrics && _hasSavedCredentials) ...[
                              const SizedBox(width: 12),
                              Material(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: _isLoading ? null : _handleBiometricLogin,
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                    ),
                                    child: const Icon(
                                      Icons.fingerprint,
                                      color: AppColors.primary,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Text(
                            'v${AppConstants.appVersion} (Build ${AppConstants.buildNumber})',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 14,
              child: Material(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () async {
                    if (kIsWeb) {
                      reloadPage();
                    } else {
                      _formKey.currentState?.reset();
                      await _initLoginState();
                      ref.invalidate(authControllerProvider);
                      ref.invalidate(currentUserProvider);
                      ref.invalidate(activePujaEventProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('App reloaded completely fresh!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 5),
                        Text(
                          'Refresh',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
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
}
