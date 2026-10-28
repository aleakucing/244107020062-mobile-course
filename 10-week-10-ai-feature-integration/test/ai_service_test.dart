import 'dart:convert';

import 'package:ai_feature_integration/ai_assistant_dialog.dart';
import 'package:ai_feature_integration/ai_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('AiService', () {
    test('mengembalikan pesan jika API key belum dikonfigurasi', () async {
      final service = AiService();
      final result = await service.askAi('Halo AI');
      expect(result, contains('API Key belum diatur'));
    });

    test('mengirim prompt dengan format system instruction dan menerima respons sukses', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.queryParameters['key'], 'dummy-api-key');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body.containsKey('system_instruction'), isTrue);

        final responseJson = {
          'candidates': [
            {
              'content': {
                'parts': [
                  {
                    'text': 'Catatan ini berisi daftar rencana belanja mingguan bahan pokok.',
                  },
                ],
              },
            },
          ],
        };

        return http.Response(
          jsonEncode(responseJson),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final storage = InMemoryKeyStorage();
      await storage.writeKey('ai_api_key', 'dummy-api-key');

      final service = AiService(client: mockClient, storage: storage);
      final result = await service.summarizeNote(
        title: 'Belanja',
        body: 'Susu, telur, beras',
      );

      expect(result, contains('daftar rencana belanja mingguan'));
    });

    test('fallback ramah saat API mengembalikan error kuota (429)', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Rate limit exceeded', 429);
      });

      final storage = InMemoryKeyStorage();
      await storage.writeKey('ai_api_key', 'valid-key');

      final service = AiService(client: mockClient, storage: storage);
      final result = await service.askAi('Pertanyaan saya');

      expect(result, contains('Batas kuota request tercapai'));
    });

    test('fallback ramah saat terjadi error koneksi jaringan', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Connection closed');
      });

      final storage = InMemoryKeyStorage();
      await storage.writeKey('ai_api_key', 'valid-key');

      final service = AiService(client: mockClient, storage: storage);
      final result = await service.askAi('Pertanyaan saya');

      expect(result, contains('Koneksi internet bermasalah'));
    });
  });

  group('AiAssistantDialog UI Test', () {
    testWidgets('menampilkan dialog dan hasil ringkasan asisten AI', (
      tester,
    ) async {
      final mockClient = MockClient((request) async {
        final responseJson = {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Ringkasan sukses dari Gemini AI.'},
                ],
              },
            },
          ],
        };
        return http.Response(jsonEncode(responseJson), 200);
      });

      final storage = InMemoryKeyStorage();
      await storage.writeKey('ai_api_key', 'valid-key');
      final service = AiService(client: mockClient, storage: storage);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => AiAssistantDialog.show(
                  context,
                  aiService: service,
                  initialTitle: 'Kuliah Pemrograman Mobile',
                  initialBody: 'Mempelajari integrasi AI pada Flutter',
                ),
                child: const Text('Buka Asisten AI'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka Asisten AI'));
      await tester.pumpAndSettle();

      expect(find.text('Asisten AI Catatan'), findsOneWidget);
      expect(find.text('Catatan: Kuliah Pemrograman Mobile'), findsOneWidget);
      expect(find.text('Ringkasan sukses dari Gemini AI.'), findsOneWidget);
    });
  });
}
