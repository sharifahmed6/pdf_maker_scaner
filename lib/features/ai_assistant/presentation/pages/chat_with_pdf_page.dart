import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/components/tool_processing_view.dart';

class ChatWithPdfPage extends StatefulWidget {
  const ChatWithPdfPage({super.key});

  @override
  State<ChatWithPdfPage> createState() => _ChatWithPdfPageState();
}

enum ChatState { initial, processing, chatting }

class _ChatWithPdfPageState extends State<ChatWithPdfPage> {
  ChatState _state = ChatState.initial;
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];

  final List<String> _suggestions = [
    'Summarize this document',
    'What are the key points?',
    'Explain this in simple language',
    'What are the important dates?',
    'Find the main conclusions'
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _messageController.clear();
      // Simulate AI response
      _messages.add({'role': 'ai', 'content': 'Thinking...'});
    });
    
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.last['content'] = 'Based on the document, here is the answer to your question...';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chat with PDF'),
            if (_state == ChatState.chatting)
              Text('Report_2023.pdf', style: theme.textTheme.bodySmall),
          ],
        ),
        actions: _state == ChatState.chatting ? [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ] : null,
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    switch (_state) {
      case ChatState.initial:
        return Center(
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() => _state = ChatState.processing);
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  setState(() {
                    _state = ChatState.chatting;
                    _messages.add({'role': 'ai', 'content': 'Hello! I have read the document. What would you like to know?'});
                  });
                }
              });
            },
            icon: const Icon(Icons.upload_file),
            label: const Text('Select PDF to Chat'),
          ),
        );
      case ChatState.processing:
        return const ToolProcessingView(
          title: 'Processing Document...',
          subtitle: 'Preparing the AI to answer your questions.',
        );
      case ChatState.chatting:
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['role'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser ? theme.colorScheme.primary : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16).copyWith(
                          bottomRight: isUser ? const Radius.circular(0) : null,
                          bottomLeft: !isUser ? const Radius.circular(0) : null,
                        ),
                        border: !isUser ? Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)) : null,
                      ),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      child: Text(
                        msg['content']!,
                        style: TextStyle(color: isUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_messages.length == 1) // Only show suggestions at the start
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        label: Text(_suggestions[index]),
                        onPressed: () => _sendMessage(_suggestions[index]),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Ask anything about this PDF...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primary,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () => _sendMessage(_messageController.text),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
    }
  }
}
