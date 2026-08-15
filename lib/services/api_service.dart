import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.100/phieurenluyen-230907/api/';

  // Lấy header chuẩn, bao gồm cả Token nếu đã lưu
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Hàm đăng nhập
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url = Uri.parse('${baseUrl}login.php');
      final headers = await _getHeaders();
      final body = jsonEncode({
        'email': email,
        'password': password,
      });

      final response = await http.post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        
        // Kiểm tra status từ JSON trả về
        if (decoded['status'] == 'success') {
          // Lưu token nếu có trong data
          if (decoded['data'] != null && decoded['data']['token'] != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', decoded['data']['token']);
          }
        }
        
        return decoded; // Trả về toàn bộ decoded object (status, message, data...)
      } else {
        return {
          'status': 'error',
          'message': 'Lỗi server (Mã: ${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Lỗi kết nối: ${e.toString()}',
      };
    }
  }

  // Hàm lấy phiếu chấm điểm hiện tại
  static Future<Map<String, dynamic>> getPhieuChamDiem() async {
    try {
      final url = Uri.parse('${baseUrl}get_phieu_cham_diem.php');
      final headers = await _getHeaders();

      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Lỗi server (Mã: ${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Lỗi kết nối: ${e.toString()}',
      };
    }
  }

  // Hàm gửi kết quả chấm điểm và minh chứng
  static Future<Map<String, dynamic>> submitChamDiem(int idPhieu, List<String> kqSv, List<Map<String, dynamic>> minhChung) async {
    try {
      final url = Uri.parse('${baseUrl}cham_diem.php');
      final headers = await _getHeaders();
      final body = jsonEncode({
        'id_phieu': idPhieu,
        'kq_sv': kqSv,
        'minh_chung': minhChung,
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Lỗi server (Mã: ${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Lỗi kết nối: ${e.toString()}',
      };
    }
  }

  // Hàm yêu cầu kích hoạt tài khoản
  static Future<Map<String, dynamic>> yeuCauKichHoat(String email) async {
    try {
      final url = Uri.parse('${baseUrl}yeu_cau_kich_hoat.php');
      final headers = await _getHeaders();
      final body = jsonEncode({
        'email': email,
      });

      final response = await http.post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Lỗi server (Mã: ${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Lỗi kết nối: ${e.toString()}',
      };
    }
  }
}
