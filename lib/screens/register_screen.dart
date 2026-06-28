import 'package:flutter/material.dart';

import '../app_locale.dart';
import '../services/api_exception.dart';
import '../services/auth_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/language_toggle.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authService = AuthApiService();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى الموافقة على الشروط والأحكام')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmController.text,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on ApiException catch (exception) {
      if (mounted) _showError(exception.displayMessage);
    } catch (_) {
      if (mounted) _showError('حدث خطأ غير متوقع أثناء إنشاء الحساب.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _continueAsPreview() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final en = AppLocale.isEnglish(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFEFEF), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Text(
                      en ? 'Sirati' : 'سيرتي',
                      style: const TextStyle(
                        fontSize: 28,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    const LanguageToggle(),
                    const SizedBox(width: 10),
                    _RoundIconButton(
                      icon: Icons.help_outline_rounded,
                      onTap: _continueAsPreview,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _RegisterHero(english: en),
                        const SizedBox(height: 30),
                        _SignupField(
                          label: en ? 'Username' : 'الاسم الكامل',
                          icon: Icons.person_outline_rounded,
                          child: TextFormField(
                            controller: _nameController,
                            textDirection:
                                en ? TextDirection.ltr : TextDirection.rtl,
                            textAlign: en ? TextAlign.left : TextAlign.right,
                            decoration: _fieldDecoration(
                                en ? 'johndoe' : 'مثال: سالم السيار'),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? (en
                                        ? 'Please enter your username'
                                        : 'يرجى إدخال اسمك الكامل')
                                    : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SignupField(
                          label: en ? 'Email Address' : 'البريد الإلكتروني',
                          icon: Icons.mail_outline_rounded,
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.left,
                            decoration: _fieldDecoration('name@example.com'),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return en
                                    ? 'Please enter your email'
                                    : 'يرجى إدخال البريد الإلكتروني';
                              }

                              if (!value.contains('@')) {
                                return en
                                    ? 'Email address is invalid'
                                    : 'البريد الإلكتروني غير صحيح';
                              }

                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SignupField(
                          label: en ? 'Password' : 'كلمة المرور',
                          icon: Icons.lock_outline_rounded,
                          trailing: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.textHint,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textDirection:
                                en ? TextDirection.ltr : TextDirection.rtl,
                            textAlign: en ? TextAlign.left : TextAlign.right,
                            decoration: _fieldDecoration(
                                en ? '••••••••' : 'ثمانية أحرف على الأقل'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return en
                                    ? 'Please enter your password'
                                    : 'يرجى إدخال كلمة المرور';
                              }

                              if (value.length < 8) {
                                return en
                                    ? 'Password must be at least 8 characters'
                                    : 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';
                              }

                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SignupField(
                          label: en ? 'Confirm Password' : 'تأكيد كلمة المرور',
                          icon: Icons.lock_reset_rounded,
                          trailing: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.textHint,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                          child: TextFormField(
                            controller: _confirmController,
                            obscureText: _obscureConfirm,
                            textDirection:
                                en ? TextDirection.ltr : TextDirection.rtl,
                            textAlign: en ? TextAlign.left : TextAlign.right,
                            decoration: _fieldDecoration(en
                                ? 'Repeat your password'
                                : 'أعد كتابة كلمة المرور'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return en
                                    ? 'Please confirm your password'
                                    : 'يرجى تأكيد كلمة المرور';
                              }

                              if (value != _passwordController.text) {
                                return en
                                    ? 'Passwords do not match'
                                    : 'كلمتا المرور غير متطابقتين';
                              }

                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: _agreedToTerms,
                              activeColor: AppColors.primaryContainer,
                              onChanged: (value) => setState(
                                () => _agreedToTerms = value ?? false,
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => _agreedToTerms = !_agreedToTerms,
                                ),
                                child: RichText(
                                  textDirection: en
                                      ? TextDirection.ltr
                                      : TextDirection.rtl,
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 13,
                                      height: 1.5,
                                      color: AppColors.textSecondary,
                                    ),
                                    children: [
                                      TextSpan(
                                          text: en
                                              ? 'I agree to the '
                                              : 'أوافق على '),
                                      TextSpan(
                                        text: en
                                            ? 'Terms & Conditions'
                                            : 'الشروط والأحكام',
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _register,
                          icon: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.4,
                                  ),
                                )
                              : const Icon(Icons.arrow_back_rounded, size: 20),
                          label: Text(
                            _isLoading
                                ? (en
                                    ? 'Creating account...'
                                    : 'جارٍ إنشاء الحساب...')
                                : (en ? 'Create Account' : 'إنشاء الحساب'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _continueAsPreview,
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          label: Text(en
                              ? 'Continue as Preview'
                              : 'الدخول للتجربة بدون حساب'),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(en ? 'Sign In' : 'تسجيل الدخول'),
                            ),
                            Text(
                              en ? 'Have an account?' : 'لديك حساب بالفعل؟',
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _SocialDivider(english: en),
                        const SizedBox(height: 18),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SocialCircle(icon: Icons.business_center_outlined),
                            SizedBox(width: 16),
                            _SocialCircle(icon: Icons.apple),
                            SizedBox(width: 16),
                            _SocialCircle(icon: Icons.g_mobiledata_rounded),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _fieldDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    isDense: true,
    filled: false,
    contentPadding: EdgeInsets.zero,
  );
}

class _RegisterHero extends StatelessWidget {
  final bool english;

  const _RegisterHero({required this.english});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          english ? 'Join Us Today' : 'انضم إلينا اليوم',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            height: 1.3,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            english
                ? 'Create your account to unlock professional opportunities.'
                : 'أنشئ حسابك للوصول إلى فرص مهنية وأدوات تحسين السيرة الذاتية.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.55,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceHigh,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
      ),
    );
  }
}

class _SignupField extends StatelessWidget {
  final String label;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _SignupField({
    required this.label,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            label,
            textDirection: Directionality.of(context),
            textAlign: Directionality.of(context) == TextDirection.ltr
                ? TextAlign.left
                : TextAlign.right,
            style: const TextStyle(
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Row(
            textDirection: Directionality.of(context),
            children: [
              Icon(icon, color: AppColors.textHint, size: 22),
              const SizedBox(width: 12),
              Expanded(child: child),
              if (trailing != null) ...[
                const SizedBox(width: 6),
                trailing!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SocialDivider extends StatelessWidget {
  final bool english;

  const _SocialDivider({required this.english});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            english ? 'OR REGISTER WITH' : 'أو سجّل عبر',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textHint,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}

class _SocialCircle extends StatelessWidget {
  final IconData icon;

  const _SocialCircle({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border.withValues(alpha: .7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.textSecondary, size: 26),
    );
  }
}
