import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  const ChatScreen({Key? key, required this.chatId}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _currentUserId;
  List<Map<String, dynamic>> _messages = [];
  RealtimeChannel? _subscription;

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _fetchMessages();
    _setupRealtime();
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeUser() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      _currentUserId = user.id;
      debugPrint('[Supabase Auth] User ID: $_currentUserId');
    } else {
      debugPrint('❌ No authenticated user found.');
    }
  }

  Future<void> _fetchMessages() async {
    try {
      final res = await _supabase
          .from('messages')
          .select()
          .eq('chat_id', widget.chatId)
          .order('timestamp', ascending: true);

      setState(() {
        _messages = List<Map<String, dynamic>>.from(res);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    } catch (e) {
      debugPrint('❌ Error fetching messages: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching messages: $e')),
      );
    }
  }

  void _setupRealtime() {
    _subscription = _supabase.channel('public:messages');
    _subscription!.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: 'INSERT',
        schema: 'public',
        table: 'messages',
        filter: 'chat_id=eq.${widget.chatId}',
      ),
      (payload, [ref]) {
        setState(() {
          _messages.add(payload['new']);
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      },
    ).subscribe();
  }

  Future<void> _sendMessage() async {
    if (_currentUserId == null || _messageController.text.trim().isEmpty)
      return;

    try {
      final message = _messageController.text.trim();
      await _supabase.from('messages').insert({
        'chat_id': widget.chatId,
        'sender_id': _currentUserId,
        'message': message,
      });

      await _supabase.from('chats').update({
        'last_message': message,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', widget.chatId);

      _messageController.clear();
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final isMe = message['sender_id'] == _currentUserId;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(message['message']),
            const SizedBox(height: 5),
            Text(
              _formatTimestamp(message['timestamp']),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp).toLocal();
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessage(_messages[index]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
