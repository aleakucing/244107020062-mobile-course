import 'package:flutter/material.dart';

import 'ai_service.dart';

/// Dialog antarmuka interaktif untuk meminta bantuan asisten AI.
class AiAssistantDialog extends StatefulWidget {
  const AiAssistantDialog({
    super.key,
    required this.aiService,
    this.initialTitle,
    this.initialBody,
  });

  final AiService aiService;
  final String? initialTitle;
  final String? initialBody;

  static Future<void> show(
    BuildContext context, {
    required AiService aiService,
    String? initialTitle,
    String? initialBody,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AiAssistantDialog(
        aiService: aiService,
        initialTitle: initialTitle,
        initialBody: initialBody,
      ),
    );
  }

  @override
  State<AiAssistantDialog> createState() => _AiAssistantDialogState();
}

class _AiAssistantDialogState extends State<AiAssistantDialog> {
  final _promptController = TextEditingController();
  bool _isLoading = false;
  String? _response;

  @override
  void initState() {
    super.initState();
    if (widget.initialTitle != null || widget.initialBody != null) {
      _triggerAutoSummary();
    }
  }

  Future<void> _triggerAutoSummary() async {
    setState(() => _isLoading = true);
    final result = await widget.aiService.summarizeNote(
      title: widget.initialTitle ?? 'Catatan',
      body: widget.initialBody ?? '',
    );
    if (mounted) {
      setState(() {
        _isLoading = false;
        _response = result;
      });
    }
  }

  Future<void> _handleSendPrompt() async {
    final text = _promptController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _response = null;
    });

    final answer = await widget.aiService.askAi(text);
    if (mounted) {
      setState(() {
        _isLoading = false;
        _response = answer;
      });
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.auto_awesome, color: Colors.amber),
          SizedBox(width: 8),
          Expanded(child: Text('Asisten AI Catatan')),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.initialTitle != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Catatan: ${widget.initialTitle}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                hintText: 'Tanyakan sesuatu atau minta saran...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('AI sedang berpikir...'),
                    ],
                  ),
                ),
              )
            else if (_response != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blueGrey.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jawaban Asisten:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(_response!),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.send, size: 16),
          label: const Text('Kirim'),
          onPressed: _isLoading ? null : _handleSendPrompt,
        ),
      ],
    );
  }
}
