import 'dart:convert';

import 'package:http/http.dart' as http;

/// Interface penyimpanan kunci API untuk memisahkan dependensi platform.
abstract interface class SecureKeyStorage {
  Future<String?> readKey(String key);
  Future<void> writeKey(String key, String value);
}

/// Implementasi in-memory fallback untuk testing atau perangkat tanpa secure enclave.
class InMemoryKeyStorage implements SecureKeyStorage {
  final Map<String, String> _data = {};

  @override
  Future<String?> readKey(String key) async => _data[key];

  @override
  Future<void> writeKey(String key, String value) async => _data[key] = value;
}

/// Layanan integrasi AI LLM (Google Gemini) untuk meringkas dan menganalisis catatan.
class AiService {
  AiService({http.Client? client, SecureKeyStorage? storage, String? baseUrl})
    : _client = client ?? http.Client(),
      _storage = storage ?? InMemoryKeyStorage(),
      _apiUrl =
          baseUrl ??
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  final http.Client _client;
  final SecureKeyStorage _storage;
  final String _apiUrl;

  static const String _keyStorageId = 'ai_api_key';

  /// Menyimpan API key ke secure storage.
  Future<void> saveApiKey(String apiKey) async {
    await _storage.writeKey(_keyStorageId, apiKey.trim());
  }

  /// Memeriksa ketersediaan API key.
  Future<bool> hasApiKey() async {
    final key = await _storage.readKey(_keyStorageId);
    return key != null && key.isNotEmpty;
  }

  /// Meringkas teks catatan dengan batasan token dan persona ramah privasi.
  Future<String> summarizeNote({
    required String title,
    required String body,
  }) async {
    final prompt =
        'Ringkas catatan berikut dalam 1-2 kalimat padat dan jelas:\n'
        'Judul: $title\n'
        'Isi: $body';

    return askAi(prompt);
  }

  /// Mengirim pertanyaan / prompt ke LLM API dengan mekanisme fallback.
  Future<String> askAi(String prompt) async {
    final apiKey = await _storage.readKey(_keyStorageId);
    if (apiKey == null || apiKey.isEmpty) {
      // Fallback ramah jika pengguna belum memasukkan API key
      return 'API Key belum diatur. Silakan simpan API Key Anda di menu Pengaturan AI.';
    }

    try {
      final response = await _client.post(
        Uri.parse('$_apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'system_instruction': {
            'parts': [
              {
                'text':
                    'Kamu adalah asisten pintar untuk aplikasi catatan mobile. '
                    'Jawab ringkas dalam Bahasa Indonesia maksimal 3 kalimat. '
                    'Dilarang meminta atau membocorkan data pribadi pengguna.',
              },
            ],
          },
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {'maxOutputTokens': 150, 'temperature': 0.4},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates.first['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            return parts.first['text'] as String;
          }
        }
        return 'Tidak ada respons yang dihasilkan oleh model AI.';
      } else if (response.statusCode == 429) {
        return 'Batas kuota request tercapai. Silakan coba beberapa saat lagi.';
      } else {
        return 'Layanan AI mengalami kendala (HTTP ${response.statusCode}). Beralih ke ringkasan lokal.';
      }
    } catch (e) {
      // Fallback offline jika tidak ada koneksi internet
      return 'Koneksi internet bermasalah. Layanan AI tidak dapat diakses saat ini.';
    }
  }
}
