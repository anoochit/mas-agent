import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/chat_provider.dart';

class SettingsDialog extends ConsumerStatefulWidget {
  const SettingsDialog({super.key});

  @override
  ConsumerState<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<SettingsDialog> {
  late TextEditingController _serverUrlController;
  late TextEditingController _appNameController;
  late TextEditingController _userIdController;
  late TextEditingController _sessionIdController;

  @override
  void initState() {
    super.initState();
    final chatState = ref.read(chatProvider);
    _serverUrlController = TextEditingController(text: chatState.serverUrl);
    _appNameController = TextEditingController(text: chatState.appName);
    _userIdController = TextEditingController(text: chatState.userId);
    _sessionIdController = TextEditingController(text: chatState.sessionId);
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _appNameController.dispose();
    _userIdController.dispose();
    _sessionIdController.dispose();
    super.dispose();
  }

  void _save() {
    ref
        .read(chatProvider.notifier)
        .updateSettings(
          serverUrl: _serverUrlController.text.trim(),
          appName: _appNameController.text.trim(),
          userId: _userIdController.text.trim(),
          sessionId: _sessionIdController.text.trim(),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.settings_outlined),
          SizedBox(width: 8),
          Text('ADK API Settings'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _serverUrlController,
              decoration: const InputDecoration(
                labelText: 'Server SSE URL',
                hintText: 'http://127.0.0.1:8000/run_sse',
                helperText:
                    'Use http://10.0.2.2:8000/run_sse for Android emulator',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _appNameController,
              decoration: const InputDecoration(
                labelText: 'App Name',
                hintText: 'multi_agent_workflow',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
                hintText: 'u_123',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _sessionIdController,
              decoration: const InputDecoration(
                labelText: 'Session ID',
                hintText: 's_123',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
