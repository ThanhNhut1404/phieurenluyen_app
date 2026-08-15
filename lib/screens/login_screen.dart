// Quân sửa: Tích hợp ClipRRect để bo góc và giữ các hạt nhiễu, đường vẽ không bị tràn ra ngoài ô Captcha
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phieurenluyen_app/screens/activation_screen.dart';
import 'package:phieurenluyen_app/screens/forgot_password_screen.dart';
import 'package:phieurenluyen_app/screens/home_screen.dart';
import 'package:phieurenluyen_app/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _captchaController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  String _captchaCode = '';
  List<double> _captchaRotations = [];
  List<double> _captchaOffsets = [];
  List<double> _captchaFontSizes = [];
  String? _feedbackMessage;
  bool _isFeedbackError = true;

  @override
  void initState() {
    super.initState();
    _generateNewCaptcha();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  void _generateNewCaptcha() {
    const chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKMNPQRSTUVWXYZ23456789';
    final random = Random();
    setState(() {
      _captchaCode = List.generate(5, (index) => chars[random.nextInt(chars.length)]).join();
      _captchaRotations = List.generate(5, (index) => (random.nextDouble() * 0.4) - 0.2);
      _captchaOffsets = List.generate(5, (index) => (random.nextDouble() * 8) - 4);
      _captchaFontSizes = List.generate(5, (index) => 18.0 + random.nextDouble() * 6);
      _captchaController.clear();
      _feedbackMessage = null;
    });
  }

  void _handleLogin() async {
    setState(() {
      _feedbackMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      if (_captchaController.text.trim().toLowerCase() != _captchaCode.toLowerCase()) {
        setState(() {
          _feedbackMessage = 'Mã xác thực không chính xác. Vui lòng thử lại!';
          _isFeedbackError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mã xác thực không chính xác. Vui lòng thử lại!'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _generateNewCaptcha();
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final response = await ApiService.login(email, password);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (response['status'] == 'success') {
        // Hiển thị SnackBar chúc mừng
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Đăng nhập thành công!'),
            backgroundColor: const Color(0xFF0F763E),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Chuyển thẳng sang HomeScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        final errorMsg = response['message'] ?? 'Đăng nhập thất bại. Vui lòng thử lại.';
        setState(() {
          _feedbackMessage = errorMsg;
          _isFeedbackError = true;
        });
        
        // Hiển thị thông báo dạng Popup
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Lỗi đăng nhập', style: TextStyle(color: Colors.red)),
            content: Text(errorMsg),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
        
        // Có thể sinh mã captcha mới khi sai
        _generateNewCaptcha();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/img/logo.png',
                        height: 90,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2B6CB0).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.school, size: 40, color: Color(0xFF2B6CB0)),
                                const SizedBox(width: 12),
                                Text(
                                  'UniDRL',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2B6CB0),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'ĐĂNG NHẬP HỆ THỐNG',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2B6CB0),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Container(
                        width: 70,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3182CE),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text(
                      'Email',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.plusJakartaSans(color: Colors.black87),
                      decoration: _buildInputDecoration(
                        hintText: 'Nhập email của bạn',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập Email';
                        }
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Email không đúng định dạng';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 6),

                    Text(
                      'Mật khẩu',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: GoogleFonts.plusJakartaSans(color: Colors.black87),
                      decoration: _buildInputDecoration(
                        hintText: 'Nhập mật khẩu của bạn',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.black38,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 2),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: const Color(0xFF2B6CB0),
                                side: const BorderSide(
                                  color: Colors.black38,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ghi nhớ đăng nhập',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: const Color(0xFF4A5568),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Quên mật khẩu?',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF3182CE),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    Text(
                      'Nhập mã xác thực',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: TextFormField(
                            controller: _captchaController,
                            style: GoogleFonts.plusJakartaSans(color: Colors.black87),
                            decoration: _buildInputDecoration(
                              hintText: 'Nhập mã',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nhập mã Captcha';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, color: Color(0xFF2B6CB0), size: 28),
                          onPressed: _generateNewCaptcha,
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(10),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CustomPaint(
                              painter: CaptchaBgPainter(),
                              foregroundPainter: const CaptchaFgPainter(),
                              child: Container(
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFBFDBFE),
                                    width: 1.5,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(_captchaCode.length, (index) {
                                    return Transform.translate(
                                      offset: Offset(0, _captchaOffsets[index]),
                                      child: Transform.rotate(
                                        angle: _captchaRotations[index],
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: Text(
                                            _captchaCode[index],
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: _captchaFontSizes[index],
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF1E40AF),
                                              letterSpacing: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    if (_feedbackMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0, top: 12.0),
                        child: Text(
                          _feedbackMessage!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: _isFeedbackError ? Colors.redAccent : const Color(0xFF0F763E),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),

                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFF0F763E),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F763E).withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'Đăng nhập',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Chưa có tài khoản? ',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: const Color(0xFF718096),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const ActivationScreen()),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Kích hoạt tài khoản',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF3182CE),
                            ),
                          ),
                        ),
                      ],
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

  InputDecoration _buildInputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.plusJakartaSans(
        color: Colors.black26,
        fontSize: 14,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF3182CE),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
      errorStyle: GoogleFonts.plusJakartaSans(
        color: Colors.redAccent,
        fontSize: 12,
      ),
    );
  }
}

class CaptchaBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDBEAFE).withOpacity(0.7)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final random = Random(12345);

    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        paint,
      );
    }

    for (int i = 0; i < 30; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        1.2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CaptchaFgPainter extends CustomPainter {
  const CaptchaFgPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E40AF).withOpacity(0.35)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final random = Random(54321);

    // 1. Vẽ 4 đường gạch ngang đè lên chữ
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(0, random.nextDouble() * size.height),
        Offset(size.width, random.nextDouble() * size.height),
        paint,
      );
    }

    // 2. Vẽ thêm 25 dấu chấm tròn nhỏ đè lên chữ
    final dotPaint = Paint()
      ..color = const Color(0xFF1E40AF).withOpacity(0.4)
      ..strokeWidth = 1.0;

    for (int i = 0; i < 25; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        random.nextDouble() * 1.5 + 0.8,
        dotPaint,
      );
    }

    // 3. Vẽ thêm 8 chữ X nhiễu đè lên chữ
    final crossPaint = Paint()
      ..color = const Color(0xFF1E40AF).withOpacity(0.3)
      ..strokeWidth = 1.2;

    for (int i = 0; i < 8; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      const sizeOffset = 4.0;
      canvas.drawLine(Offset(x - sizeOffset, y - sizeOffset), Offset(x + sizeOffset, y + sizeOffset), crossPaint);
      canvas.drawLine(Offset(x + sizeOffset, y - sizeOffset), Offset(x - sizeOffset, y + sizeOffset), crossPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
