import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final Function onNavigate;
  const ChatListScreen({Key? key, required this.onNavigate}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  String? _currentUserId;
  String? _companyId;
  bool _isLoading = true;
  List<Map<String, dynamic>> _colleagues = [];
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _chats = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeUser() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      debugPrint('❌ No authenticated user found.');
      setState(() => _isLoading = false);
      return;
    }

    _currentUserId = user.id;
    debugPrint('[Supabase Auth] Employee UID: $_currentUserId');

    try {
      // Fetch company_id for the current user
      final res = await _supabase
          .from('employees')
          .select('company_id')
          .eq('supabase_user_id', _currentUserId!)
          .maybeSingle();

      if (res == null || res['company_id'] == null) {
        debugPrint('❌ No company_id found for user $_currentUserId');
        setState(() => _isLoading = false);
        return;
      }

      _companyId = res['company_id'];
      debugPrint('[Supabase] Employee Company ID: $_companyId');

      // Fetch colleagues and chats
      await Future.wait([
        _fetchColleagues(),
        _fetchChats(),
      ]);
    } catch (e) {
      debugPrint('❌ Error initializing user: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _fetchColleagues() async {
    if (_companyId == null) return;

    try {
      final res = await _supabase
          .from('employees')
          .select('supabase_user_id, full_name')
          .eq('company_id', _companyId!)
          .neq('supabase_user_id', _currentUserId!);

      setState(() {
        _colleagues = List<Map<String, dynamic>>.from(res);
        _searchResults = _colleagues;
      });
      debugPrint('✅ Fetched ${_colleagues.length} colleagues');
    } catch (e) {
      debugPrint('❌ Error fetching colleagues: $e');
    }
  }

  Future<void> _fetchChats() async {
    if (_currentUserId == null) return;

    try {
      final res = await _supabase
          .from('chat_participants')
          .select('chat_id, chats (id, name, last_message)')
          .eq('participant_id', _currentUserId!);

      setState(() {
        _chats = List<Map<String, dynamic>>.from(
          res.map((e) => {
                'id': e['chats']['id'],
                'name': e['chats']['name'],
                'last_message': e['chats']['last_message'],
              }),
        );
      });
      debugPrint('✅ Fetched ${_chats.length} chats');
    } catch (e) {
      debugPrint('❌ Error fetching chats: $e');
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = _colleagues);
      debugPrint('🔍 Empty query, showing all colleagues');
      return;
    }

    debugPrint('🔍 Searching "$query" in company $_companyId');

    try {
      final res = await _supabase
          .from('employees')
          .select('supabase_user_id, full_name')
          .eq('company_id', _companyId!)
          .neq('supabase_user_id', _currentUserId!)
          .ilike('full_name', '%$query%');

      setState(() {
        _searchResults = List<Map<String, dynamic>>.from(res);
      });
      debugPrint('✅ Search returned ${_searchResults.length} result(s)');
    } catch (e) {
      debugPrint('❌ Error during search: $e');
    }
  }

  Future<void> _createChat(String otherUserId, String otherUserName) async {
    if (_currentUserId == null) return;

    try {
      debugPrint(
          'Creating chat with: currentUserId=$_currentUserId, otherUserId=$otherUserId');
      debugPrint(
          'Calling find_existing_chat with user1=$_currentUserId, user2=$otherUserId');

      // Check for existing chat
      final check = await _supabase.rpc('find_existing_chat', params: {
        'user1': _currentUserId,
        'user2': otherUserId,
      });

      debugPrint('RPC response: $check');

      String chatId;

      if (check is List && check.isNotEmpty && check[0]['chat_id'] != null) {
        chatId = check[0]['chat_id'];
        debugPrint('➡️ Existing chat: $chatId');
      } else {
        // Create new chat
        debugPrint('Inserting new chat with created_by=$_currentUserId');
        final chatRes = await _supabase
            .from('chats')
            .insert({
              'name': 'Chat with $otherUserName',
              'created_by': _currentUserId,
              'is_group': false,
            })
            .select()
            .single();

        chatId = chatRes['id'];
        debugPrint('Chat created with id=$chatId');

        // Insert participants
        debugPrint('Inserting participants: $_currentUserId, $otherUserId');
        await _supabase.from('chat_participants').insert([
          {
            'chat_id': chatId,
            'participant_id': _currentUserId,
          },
          {
            'chat_id': chatId,
            'participant_id': otherUserId,
          },
        ]);

        debugPrint('✅ New chat created: $chatId');

        // Refresh chats
        await _fetchChats();
      }

      // Navigate to ChatScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(chatId: chatId),
        ),
      );
    } catch (e) {
      debugPrint('❌ Error creating chat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating chat: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_currentUserId == null || _companyId == null) {
      return const Scaffold(
        body: Center(
            child: Text(
                'Please log in and ensure you are assigned to a company.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quack Chat'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search colleagues...',
                fillColor: Colors.white,
                filled: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchUsers(_searchController.text.trim()),
                ),
              ),
              onChanged: (value) => _searchUsers(value.trim()),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (_chats.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _chats.length,
                itemBuilder: (context, index) {
                  final chat = _chats[index];
                  return ListTile(
                    title: Text(chat['name'] ?? 'Unnamed Chat'),
                    subtitle: Text(
                      chat['last_message'] ?? 'No messages yet',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(chatId: chat['id']),
                      ),
                    ),
                  );
                },
              ),
            ),
          if (_searchResults.isNotEmpty && _searchController.text.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final colleague = _searchResults[index];
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(colleague['full_name'] ?? 'Unknown'),
                    onTap: () => _createChat(
                      colleague['supabase_user_id'],
                      colleague['full_name'],
                    ),
                  );
                },
              ),
            ),
          if (_searchResults.isEmpty && _searchController.text.isNotEmpty)
            const Center(child: Text('No colleagues found.')),
          if (_chats.isEmpty && _searchController.text.isEmpty)
            const Center(
                child:
                    Text('No chats yet. Search for a colleague to start one.')),
        ],
      ),
    );
  }
}
