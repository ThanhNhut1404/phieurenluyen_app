// Quân sửa: Thu nhỏ khoảng cách giữa các phần trong màn hình Kích hoạt tài khoản
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phieurenluyen_app/screens/login_screen.dart';
import 'package:phieurenluyen_app/services/api_service.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Ghi nhận đã qua bước đầu tiên (không còn là lần đầu mở app nữa)
  Future<void> _setNotFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
  }

  void _handleActivation() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _successMessage = null;
      });

      final response = await ApiService.yeuCauKichHoat(_emailController.text);
      await _setNotFirstTime();

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (response['status'] == 'success') {
            _successMessage = response['message'];
          } else {
            // Hiển thị lỗi từ API
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Có lỗi xảy ra'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      }
    }
  }

  void _navigateToLogin() async {
    await _setNotFirstTime();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
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
                    // Logo trường học
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

                    // Tiêu đề Kích hoạt tài khoản
                    Text(
                      'KÍCH HOẠT TÀI KHOẢN',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
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
                    const SizedBox(height: 24),

                    // Nếu gửi thành công, hiển thị giao diện thông báo thành công
                    if (_successMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4), // Xanh lá nhạt
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFBBF7D0), width: 1.5),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.mark_email_read_rounded, size: 48, color: Color(0xFF16A34A)),
                            const SizedBox(height: 12),
                            Text(
                              _successMessage!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF166534),
                                fontSize: 14,
                                height: 1.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Nút đi tới đăng nhập
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFF2B6CB0),
                        ),
                        child: ElevatedButton(
                          onPressed: _navigateToLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Đi tới Đăng nhập',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Mô tả luồng kích hoạt
                      Text(
                        'Nhập email sinh viên của bạn để hệ thống xác thực và gửi thông tin kích hoạt tài khoản.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: const Color(0xFF718096),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Ô nhập Email
                      Text(
                        'Email sinh viên',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.plusJakartaSans(color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Nhập email sinh viên của bạn',
                          hintStyle: GoogleFonts.plusJakartaSans(color: Colors.black26, fontSize: 14),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF3182CE), width: 1.5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                          ),
                          errorStyle: GoogleFonts.plusJakartaSans(color: Colors.redAccent, fontSize: 12),
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
                      const SizedBox(height: 14),

                      // Nút gửi yêu cầu kích hoạt
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFF0F763E), // Màu xanh lá logo
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F763E).withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleActivation,
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
                                  'Gửi yêu cầu',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),

                    // Chân trang: Quay về đăng nhập
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Tôi đã có tài khoản? ',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: const Color(0xFF718096),
                          ),
                        ),
                        TextButton(
                          onPressed: _navigateToLogin,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Đăng nhập',
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
}
