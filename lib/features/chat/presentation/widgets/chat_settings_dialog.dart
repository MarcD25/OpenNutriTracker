import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opennutritracker/features/chat/domain/entity/custom_model_entity.dart';
import 'package:opennutritracker/features/chat/domain/usecase/chat_usecase.dart';
import 'package:opennutritracker/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/generated/l10n.dart';

class ChatSettingsDialog extends StatefulWidget {
  const ChatSettingsDialog({super.key});

  @override
  State<ChatSettingsDialog> createState() => _ChatSettingsDialogState();
}

class _ChatSettingsDialogState extends State<ChatSettingsDialog> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _modelIdentifierController = TextEditingController();
  final TextEditingController _modelDisplayNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late ChatUsecase _chatUsecase;
  late ChatBloc _chatBloc;
  String? _currentApiKey;
  bool _isLoading = true;
  bool _showApiKey = false;
  List<CustomModelEntity> _customModels = [];

  @override
  void initState() {
    super.initState();
    _chatUsecase = locator<ChatUsecase>();
    _chatBloc = locator<ChatBloc>();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final apiKey = await _chatUsecase.getApiKey();
      final customModels = await _chatUsecase.getCustomModels();
      
      setState(() {
        _currentApiKey = apiKey;
        _customModels = customModels;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _modelIdentifierController.dispose();
    _modelDisplayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      bloc: _chatBloc,
      listener: (context, state) {
        if (state is ChatApiKeySaved || state is ChatApiKeyChanged) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).chatApiKeySuccess)),
          );
          Navigator.of(context).pop();
        } else if (state is ChatApiKeyRemoved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).chatApiKeyRemoved)),
          );
          Navigator.of(context).pop();
        } else if (state is ChatCustomModelAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).chatCustomModelAdded)),
          );
          _loadSettings();
        } else if (state is ChatCustomModelRemoved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).chatCustomModelRemoved)),
          );
          _loadSettings();
        } else if (state is ChatActiveModelSet) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Model set as active')),
          );
          _loadSettings();
        } else if (state is ChatError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: AlertDialog(
        title: Text(S.of(context).chatSettingsLabel),
        content: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // API Key Section
                      _buildApiKeySection(),
                      const SizedBox(height: 24),
                      
                      // Custom Models Section
                      _buildCustomModelsSection(),
                    ],
                  ),
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(S.of(context).dialogCancelLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeySection() {
    final hasApiKey = _currentApiKey != null && _currentApiKey!.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).chatApiKeyStatus,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        
        // API Key Status Display
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                hasApiKey ? Icons.check_circle : Icons.error,
                color: hasApiKey ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasApiKey ? 'API Key Set' : 'No API Key',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (hasApiKey)
                      Text(
                        _showApiKey ? _currentApiKey! : _chatUsecase.maskApiKey(_currentApiKey!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // API Key Actions
        Row(
          children: [
            if (hasApiKey) ...[
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: _showApiKey ? null : _viewApiKey,
                    icon: Icon(
                      _showApiKey ? Icons.visibility_off : Icons.visibility,
                      size: 16,
                    ),
                    label: Text(
                      _showApiKey ? 'Hide' : 'View',
                      style: const TextStyle(fontSize: 10),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: _changeApiKey,
                    icon: const Icon(Icons.edit, size: 16),
                    label: Text(
                      'Change',
                      style: const TextStyle(fontSize: 10),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: _removeApiKey,
                    icon: const Icon(Icons.delete, size: 16),
                    label: Text(
                      'Remove',
                      style: const TextStyle(fontSize: 10),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: _addApiKey,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text(
                      'Add Key',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildCustomModelsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).chatCustomModelLabel,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        
        // Add Model Input
        TextFormField(
          controller: _modelIdentifierController,
          decoration: InputDecoration(
            labelText: S.of(context).chatCustomModelInputLabel,
            hintText: S.of(context).chatCustomModelIdentifierHint,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              onPressed: _addCustomModel,
              icon: const Icon(Icons.add),
            ),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!_chatUsecase.isValidModelIdentifier(value)) {
                return S.of(context).chatCustomModelInvalid;
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Custom Models List
        Text(
          S.of(context).chatCustomModelListLabel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        
        if (_customModels.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                S.of(context).chatCustomModelNoModels,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          )
        else
          ...(_customModels.map((model) => _buildModelCard(model))),
      ],
    );
  }

  Widget _buildModelCard(CustomModelEntity model) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(model.fullDisplayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              model.identifier,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
            if (model.isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  S.of(context).chatCustomModelActive,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!model.isActive)
              SizedBox(
                height: 32,
                child: TextButton(
                  onPressed: () => _setActiveModel(model.identifier),
                  child: Text(
                    'Active',
                    style: const TextStyle(fontSize: 11),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
            IconButton(
              onPressed: () => _removeCustomModel(model.identifier),
              icon: const Icon(Icons.delete, size: 18),
              color: Colors.red,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewApiKey() {
    setState(() {
      _showApiKey = !_showApiKey;
    });
  }

  void _addApiKey() {
    _showApiKeyDialog();
  }

  void _changeApiKey() {
    _showApiKeyDialog(currentKey: _currentApiKey);
  }

  void _removeApiKey() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).chatApiKeyRemoveConfirm),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(S.of(context).dialogCancelLabel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _chatBloc.add(RemoveApiKeyEvent());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(S.of(context).chatApiKeyRemove),
          ),
        ],
      ),
    );
  }

  void _showApiKeyDialog({String? currentKey}) {
    final controller = TextEditingController(text: currentKey ?? '');
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(currentKey != null ? S.of(context).chatApiKeyChange : 'Add API Key'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'API Key',
              hintText: S.of(context).chatApiKeyHint,
              border: const OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'API key is required';
              }
              if (!value.startsWith('sk-or-v1-')) {
                return S.of(context).chatApiKeyError;
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(S.of(context).dialogCancelLabel),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                if (currentKey != null) {
                  _chatBloc.add(ChangeApiKeyEvent(controller.text.trim()));
                } else {
                  _chatBloc.add(SaveApiKeyEvent(controller.text.trim()));
                }
              }
            },
            child: Text(S.of(context).dialogOKLabel),
          ),
        ],
      ),
    );
  }

  void _addCustomModel() {
    final identifier = _modelIdentifierController.text.trim();
    if (identifier.isEmpty) return;
    
    if (!_chatUsecase.isValidModelIdentifier(identifier)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).chatCustomModelInvalid)),
      );
      return;
    }
    
    final displayName = _modelDisplayNameController.text.trim();
    _chatBloc.add(AddCustomModelEvent(identifier, displayName));
    _modelIdentifierController.clear();
    _modelDisplayNameController.clear();
  }

  void _removeCustomModel(String identifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).chatCustomModelRemoveConfirm),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(S.of(context).dialogCancelLabel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _chatBloc.add(RemoveCustomModelEvent(identifier));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(S.of(context).chatCustomModelRemove),
          ),
        ],
      ),
    );
  }

  void _setActiveModel(String identifier) {
    _chatBloc.add(SetActiveModelEvent(identifier));
  }
} 