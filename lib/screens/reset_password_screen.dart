import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phieurenluyen_app/services/api_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _feedbackMessage;
  bool _isFeedbackError = true;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleResetPassword() async {
    setState(() {
      _feedbackMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final otpCode = _otpController.text.trim();
      final newPassword = _passwordController.text.trim();

      final response = await ApiService.resetPassword(widget.email, otpCode, newPassword);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Đổi mật khẩu thành công!'),
            backgroundColor: const Color(0xFF0F763E),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Quay về màn hình Login
        Navigator.of(context).pop();
      } else {
        setState(() {
          _feedbackMessage = response['message'] ?? 'Lỗi khi đặt lại mật khẩu.';
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
                      Icons.lock_reset,
                      size: 64,
                      color: const Color(0xFF2B6CB0),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Khôi Phục Mật Khẩu',
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
                      'Vui lòng nhập mã OTP đã được gửi đến:\n${widget.email}',
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

                    // Nhập OTP
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        letterSpacing: 4,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF334155),
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: 'Mã OTP (6 chữ số)',
                        labelStyle: GoogleFonts.inter(color: const Color(0xFF64748B), letterSpacing: 0, fontWeight: FontWeight.normal),
                        hintText: '000000',
                        hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), letterSpacing: 4),
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
                        counterText: "",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mã OTP';
                        }
                        if (value.length != 6) {
                          return 'Mã OTP phải gồm 6 chữ số';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Nhập mật khẩu mới
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: const Color(0xFF334155),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu mới',
                        labelStyle: GoogleFonts.inter(color: const Color(0xFF64748B)),
                        hintText: 'Nhập mật khẩu mới',
                        hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF64748B)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: const Color(0xFF64748B),
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
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
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu mới';
                        }
                        if (value.length < 6) {
                          return 'Mật khẩu phải có ít nhất 6 ký tự';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Xác nhận mật khẩu mới
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: const Color(0xFF334155),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Xác nhận mật khẩu',
                        labelStyle: GoogleFonts.inter(color: const Color(0xFF64748B)),
                        hintText: 'Nhập lại mật khẩu mới',
                        hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF64748B)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: const Color(0xFF64748B),
                          ),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
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
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng xác nhận mật khẩu';
                        }
                        if (value != _passwordController.text) {
                          return 'Mật khẩu xác nhận không khớp';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleResetPassword,
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
                              'Đổi mật khẩu',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
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
