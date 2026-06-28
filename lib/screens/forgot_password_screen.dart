import 'package:flutter/material.dart';

import '../app_locale.dart';
import '../services/api_exception.dart';
import '../services/auth_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/language_toggle.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _authService = AuthApiService();
  bool _isLoading = false;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final english = AppLocale.isEnglish(context);
    final email = _emailController.text.trim();
    if (!email.contains('@')) {
      _message(english
          ? 'Enter a valid email address.'
          : 'أدخل بريداً إلكترونياً صحيحاً.');
      return;
    }

    setState(() {
      _isLoading = true;
      _successMessage = null;
    });

    try {
      final message = await _authService.forgotPassword(email: email);
      if (!mounted) return;
      setState(() => _successMessage = message);
    } on ApiException catch (exception) {
      if (mounted) _message(exception.displayMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final english = AppLocale.isEnglish(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(english ? 'Reset Password' : 'استعادة كلمة المرور'),
        actions: const [
          Padding(
            padding: EdgeInsetsDirectional.only(end: 12),
            child: LanguageToggle(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
        children: [
          Text(
            english
                ? 'Enter your email and we will send a password reset link.'
                : 'أدخل بريدك الإلكتروني وسنرسل لك رابط استعادة كلمة المرور.',
            textAlign: english ? TextAlign.left : TextAlign.right,
            style: const TextStyle(
              fontSize: 18,
              height: 1.55,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 22),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            textAlign: english ? TextAlign.left : TextAlign.right,
            decoration: InputDecoration(
              labelText: english ? 'Email Address' : 'البريد الإلكتروني',
              floatingLabelAlignment: english
                  ? FloatingLabelAlignment.start
                  : FloatingLabelAlignment.start,
              labelStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _submit,
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.2),
                  )
                : const Icon(Icons.send_outlined),
            label: Text(english ? 'Send Reset Link' : 'إرسال الرابط'),
          ),
          if (_successMessage != null) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.tealLight,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.teal.withValues(alpha: .35)),
              ),
              child: Text(
                _successMessage!,
                textAlign: english ? TextAlign.left : TextAlign.right,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.tealDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
