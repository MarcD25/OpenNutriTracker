import 'package:flutter/material.dart';
import 'package:opennutritracker/generated/l10n.dart';

class ApiKeyDialog extends StatefulWidget {
  final Function(String) onSave;

  const ApiKeyDialog({
    super.key,
    required this.onSave,
  });

  @override
  State<ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<ApiKeyDialog> {
  final TextEditingController _apiKeyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).chatApiKeyTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              S.of(context).chatApiKeySubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _apiKeyController,
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: S.of(context).chatApiKeyHint,
                border: const OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return S.of(context).chatApiKeyError;
                }
                if (!value.startsWith('sk-or-v1-')) {
                  return S.of(context).chatApiKeyError;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(S.of(context).dialogCancelLabel),
        ),
        ElevatedButton(
          onPressed: _saveApiKey,
          child: Text(S.of(context).chatApiKeySave),
        ),
      ],
    );
  }

  void _saveApiKey() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(_apiKeyController.text.trim());
      Navigator.of(context).pop();
    }
  }
} 