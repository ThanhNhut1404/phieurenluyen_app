import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phieurenluyen_app/screens/reset_password_screen.dart';
import 'package:phieurenluyen_app/services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  bool _isLoading = false;
  String? _feedbackMessage;
  bool _isFeedbackError = true;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendOtp() async {
    setState(() {
      _feedbackMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text.trim();
      final response = await ApiService.forgotPassword(email);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Đã gửi mã OTP vào email.'),
            backgroundColor: const Color(0xFF0F763E),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Chuyển sang màn hình xác minh OTP
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(email: email),
          ),
        );
      } else {
        setState(() {
          _feedbackMessage = response['message'] ?? 'Lỗi khi gửi yêu cầu.';
          _isFeedbackError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
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
                    Icon(
                      Icons.mark_email_unread_outlined,
                      size: 64,
                      color: const Color(0xFF2B6CB0),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Quên Mật Khẩu',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nhập email của bạn để nhận mã khôi phục mật khẩu gồm 6 chữ số.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: const Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    if (_feedbackMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: _isFeedbackError
                              ? const Color(0xFFFEF2F2)
                              : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isFeedbackError
                                ? const Color(0xFFFCA5A5)
                                : const Color(0xFF86EFAC),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isFeedbackError ? Icons.error_outline : Icons.check_circle_outline,
                              color: _isFeedbackError ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _feedbackMessage!,
                                style: GoogleFonts.inter(
                                  color: _isFeedbackError ? const Color(0xFFB91C1C) : const Color(0xFF15803D),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: const Color(0xFF334155),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: GoogleFonts.inter(color: const Color(0xFF64748B)),
                        hintText: 'Nhập email của bạn',
                        hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF64748B)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2B6CB0), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                        if (!value.contains('@')) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B6CB0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: const Color(0xFF94A3B8),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Nhận mã OTP',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),
                    
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Quay lại Đăng nhập',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
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
    );
  }
}
