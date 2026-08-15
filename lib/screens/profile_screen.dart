import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phieurenluyen_app/services/api_service.dart';
import 'package:phieurenluyen_app/screens/login_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // Thêm controller
  bool _isLoading = false;
  String _userName = 'Sinh viên';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Sinh viên';
    });
  }

  // Hàm kiểm tra định dạng mật khẩu
  bool _isValidPassword(String password) {
    // Ít nhất 9 ký tự, có chữ, có số, có ký tự đặc biệt
    final regex = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#\$&*~]).{9,}$');
    return regex.hasMatch(password);
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await ApiService.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Đổi mật khẩu', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _oldPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Mật khẩu cũ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Mật khẩu mới',
                        border: OutlineInputBorder(),
                        helperText: 'Tối thiểu 9 ký tự, có chữ, số & ký tự đặc biệt.',
                        helperMaxLines: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Xác nhận mật khẩu mới',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          final oldPass = _oldPasswordController.text;
                          final newPass = _newPasswordController.text;
                          final confirmPass = _confirmPasswordController.text;

                          if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin!')),
                            );
                            return;
                          }
                          
                          if (newPass != confirmPass) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Mật khẩu xác nhận không khớp!')),
                            );
                            return;
                          }

                          if (!_isValidPassword(newPass)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Mật khẩu phải có ít nhất 9 ký tự, bao gồm chữ cái, số và ký tự đặc biệt (!@#\$&*~).')),
                            );
                            return;
                          }
                          
                          setStateDialog(() {
                            _isLoading = true;
                          });

                          final result = await ApiService.changePassword(oldPass, newPass);

                          setStateDialog(() {
                            _isLoading = false;
                          });

                          if (result['status'] == 'success') {
                            if (mounted) {
                              Navigator.pop(context); // Close dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đổi mật khẩu thành công! Vui lòng đăng nhập lại.'), backgroundColor: Colors.green),
                              );
                              
                              // Đăng xuất và quay về LoginScreen
                              await ApiService.logout();
                              if (mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                  (route) => false,
                                );
                              }
                            }
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result['message'] ?? 'Có lỗi xảy ra'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF157F1F)),
                  child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Xác nhận', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Profile
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                ),
                const SizedBox(height: 16),
                Text(
                  _userName,
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sinh viên',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Menu Options
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _buildMenuTile(
                  icon: Icons.person_outline,
                  title: 'Thông tin cá nhân',
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                _buildMenuTile(
                  icon: Icons.lock_outline,
                  title: 'Đổi mật khẩu',
                  onTap: _showChangePasswordDialog,
                ),
                const Divider(height: 1, indent: 56),
                _buildMenuTile(
                  icon: Icons.settings_outlined,
                  title: 'Cài đặt',
                  onTap: () {},
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Logout Section
          Container(
            color: Colors.white,
            child: _buildMenuTile(
              icon: Icons.logout,
              title: 'Đăng xuất',
              color: Colors.red,
              onTap: _handleLogout,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({required IconData icon, required String title, required VoidCallback onTap, Color? color}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? const Color(0xFF157F1F)).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color ?? const Color(0xFF157F1F)),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: color ?? Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
