import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class Malenia extends StatefulWidget {
  final Function(int) onNavigate;
  const Malenia({super.key, required this.onNavigate});

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<Malenia> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final SupabaseClient _supabase = Supabase.instance.client;
  String? _userId;
  String _currentQuestionId = 'welcome';
  Map<String, dynamic> _userResponses = {};
  bool _isTyping = false;
  late AnimationController _typingAnimationController;

  // Define questions with conditional flow
  final Map<String, Map<String, dynamic>> _questions = {
    'welcome': {
      'question':
          "Hey there! 👋 I'm Malenia, your AI travel companion. I'm excited to help you connect with amazing fellow travelers! What should I call you?",
      'field': 'nickname',
      'type': 'text',
      'next': 'pronouns',
    },
    'pronouns': {
      'question':
          "Nice to meet you, {nickname}! What pronouns do you use? (e.g., she/her, he/him, they/them)",
      'field': 'pronouns',
      'type': 'text',
      'next': 'languages',
    },
    'languages': {
      'question':
          "What languages do you speak? This helps me find travelers you can communicate with easily! 🗣️",
      'field': 'languages',
      'type': 'text_list',
      'next': 'origin',
    },
    'origin': {
      'question': "Where do you call home? 🏠",
      'field': 'country_birth',
      'type': 'text',
      'next': 'travel_status',
    },
    'travel_status': {
      'question':
          "Are you currently traveling somewhere exciting? If yes, where are you right now? ✈️",
      'field': 'currently_travelling',
      'type': 'text_bool',
      'follow_up_field': 'current_residence',
      'next_if_yes': 'stay_duration',
      'next_if_no': 'travel_style',
    },
    'stay_duration': {
      'question':
          "How long are you planning to stay in {current_location}? This helps me match you with people on similar timelines! ⏰",
      'field': 'stay_duration',
      'type': 'text',
      'next': 'travel_style',
    },
    'travel_style': {
      'question':
          "What's your travel vibe? Pick what resonates with you! 🎒\n\n• Backpacking & Budget\n• Luxury & Comfort\n• Cultural Immersion\n• Nature & Adventure\n• Digital Nomad\n• Wellness & Mindful\n• Photography & Art",
      'field': 'travel_style',
      'type': 'multiple_choice',
      'options': [
        'Backpacking & Budget',
        'Luxury & Comfort',
        'Cultural Immersion',
        'Nature & Adventure',
        'Digital Nomad',
        'Wellness & Mindful',
        'Photography & Art'
      ],
      'next': 'social_type',
    },
    'social_type': {
      'question': "How would you describe your social energy? 🔋",
      'field': 'social_type',
      'type': 'choice',
      'options': [
        'Introvert - I recharge with alone time',
        'Ambivert - I\'m somewhere in between',
        'Extrovert - I gain energy from being around people'
      ],
      'next': 'social_vibe',
    },
    'social_vibe': {
      'question':
          "What kind of connections do you enjoy most? 💫\n\n• Deep, meaningful conversations\n• Fun & spontaneous adventures\n• Chill, relaxed hangouts\n• Goal-oriented activities\n• Creative collaborations",
      'field': 'social_vibe',
      'type': 'multiple_choice',
      'options': [
        'Deep conversations',
        'Fun & spontaneous',
        'Chill & relaxed',
        'Goal-oriented',
        'Creative collaborations'
      ],
      'next': 'personality_words',
    },
    'personality_words': {
      'question':
          "Pick 3 words that best capture your personality! This helps me find your perfect travel matches 🎯\n\n• Curious • Calm • Playful • Responsible • Bold • Empathetic • Creative • Organized • Spontaneous • Thoughtful",
      'field': 'personality_words',
      'type': 'text_list',
      'max_length': 3,
      'next': 'meet_preferences',
    },
    'meet_preferences': {
      'question': "How do you prefer to meet new people while traveling? 👥",
      'field': 'preferred_meet_type',
      'type': 'choice',
      'options': [
        'One-on-one connections',
        'Small groups (2-4 people)',
        'I\'m open to both'
      ],
      'next': 'gender_preference',
    },
    'gender_preference': {
      'question': "Any preferences for who you'd like to meet?",
      'field': 'preferred_gender',
      'type': 'choice',
      'options': [
        'Open to meeting anyone',
        'Prefer same gender',
        'I\'d rather not specify'
      ],
      'next': 'activities',
    },
    'activities': {
      'question':
          "What activities make your travel heart sing? Select all that excite you! ❤️\n\n• Hiking & Nature\n• Museums & Culture\n• Street Food Adventures\n• Water Sports\n• Yoga & Wellness\n• Photography\n• Festivals & Events\n• Volunteering\n• Nightlife & Parties\n• Local Markets\n• Art & Crafts",
      'field': 'travel_activities',
      'type': 'multiple_choice',
      'options': [
        'Hiking & Nature',
        'Museums & Culture',
        'Street Food Adventures',
        'Water Sports',
        'Yoga & Wellness',
        'Photography',
        'Festivals & Events',
        'Volunteering',
        'Nightlife & Parties',
        'Local Markets',
        'Art & Crafts'
      ],
      'next': 'nightlife_check',
    },
    'nightlife_check': {
      'condition': 'nightlife_selected',
      'question':
          "I noticed you're into nightlife! How do you feel about alcohol and party scenes? 🍻",
      'field': 'alcohol_smoking_view',
      'type': 'text',
      'next': 'explore_style',
      'fallback_next': 'explore_style',
    },
    'explore_style': {
      'question': "How do you like to explore new places? 🗺️",
      'field': 'explore_style',
      'type': 'multiple_choice',
      'options': [
        'Chat with locals',
        'Solo wandering',
        'Guided tours',
        'Hidden gems hunting',
        'Following recommendations'
      ],
      'next': 'time_preference',
    },
    'time_preference': {
      'question': "What's your ideal adventure timing? 🌅",
      'field': 'time_preference',
      'type': 'choice',
      'options': [
        'Early bird - sunrise hikes and morning markets',
        'Night owl - late dinners and city walks',
        'I adapt to whatever sounds fun'
      ],
      'next': 'looking_for',
    },
    'looking_for': {
      'question':
          "What are you hoping to find in your travel connections? 🌟\n\n• Just friends\n• Travel buddies for activities\n• Cultural exchange\n• Language practice\n• Adventure partners\n• Local insights\n• Open to whatever develops naturally",
      'field': 'looking_for',
      'type': 'multiple_choice',
      'options': [
        'Just friends',
        'Travel buddies',
        'Cultural exchange',
        'Language practice',
        'Adventure partners',
        'Local insights',
        'Open to whatever develops'
      ],
      'next': 'dealbreakers',
    },
    'dealbreakers': {
      'question':
          "What would make you uncomfortable when meeting someone new? This helps me make better matches! 🚫",
      'field': 'social_dealbreakers',
      'type': 'text',
      'next': 'availability',
    },
    'availability': {
      'question': "When are you usually free for meetups? ⏰",
      'field': 'meetup_availability',
      'type': 'multiple_choice',
      'options': [
        'Mornings',
        'Afternoons',
        'Evenings',
        'Weekends only',
        'Very flexible'
      ],
      'next': 'match_frequency',
    },
    'match_frequency': {
      'question': "How often would you like to discover new travel buddies? 🔄",
      'field': 'match_frequency',
      'type': 'choice',
      'options': [
        'Daily - I love meeting new people!',
        'Every few days - moderate pace',
        'Weekly - I prefer fewer, quality connections',
        'Only when I choose - I\'ll browse when ready'
      ],
      'next': 'spontaneous_plans',
    },
    'spontaneous_plans': {
      'question':
          "Would you be up for spontaneous group activities that I might suggest? 🎲",
      'field': 'open_to_spontaneous_plans',
      'type': 'boolean',
      'next': 'privacy_settings',
    },
    'privacy_settings': {
      'question': "Who should be able to see your profile? 👀",
      'field': 'profile_visibility',
      'type': 'choice',
      'options': [
        'Everyone in my area',
        'Only people I match with',
        'Only after we both express interest'
      ],
      'next': 'location_sharing',
    },
    'location_sharing': {
      'question':
          "Can I share your general location (city only) to help find nearby travel buddies? 📍",
      'field': 'share_general_location',
      'type': 'boolean',
      'next': 'travel_archetype',
    },
    'travel_archetype': {
      'question': "Finally, which travel archetype speaks to your soul? ✨",
      'field': 'travel_archetype',
      'type': 'choice',
      'options': [
        'The Explorer - Always seeking new horizons',
        'The Foodie - Tasting the world one dish at a time',
        'The Philosopher - Finding meaning in every journey',
        'The Seeker - Searching for authentic experiences',
        'The Adventurer - Chasing thrills and adrenaline'
      ],
      'next': 'complete',
    },
  };

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _initializeUser();
    _startConversation();
  }

  @override
  void dispose() {
    _typingAnimationController.dispose();
    super.dispose();
  }

  void _initializeUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please log in to continue'),
          backgroundColor: Colors.red[400],
        ),
      );
    }
  }

  void _startConversation() async {
    await Future.delayed(Duration(milliseconds: 800));
    _addBotMessage(_questions['welcome']!['question']);
  }

  void _addBotMessage(String text) async {
    setState(() {
      _isTyping = true;
    });

    // Simulate typing delay
    await Future.delayed(Duration(milliseconds: 1000 + (text.length * 20)));

    setState(() {
      _isTyping = false;
      _messages.add({
        'sender': 'bot',
        'text': _personalizeMessage(text),
        'timestamp': DateTime.now(),
      });
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add({
        'sender': 'user',
        'text': text,
        'timestamp': DateTime.now(),
      });
    });
    _scrollToBottom();
  }

  String _personalizeMessage(String message) {
    String personalized = message;

    if (_userResponses.containsKey('nickname')) {
      personalized =
          personalized.replaceAll('{nickname}', _userResponses['nickname']);
    }

    if (_userResponses.containsKey('current_residence')) {
      personalized = personalized.replaceAll(
          '{current_location}', _userResponses['current_residence']);
    }

    return personalized;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String? _getNextQuestion() {
    final currentQuestion = _questions[_currentQuestionId];
    if (currentQuestion == null) return null;

    // Handle conditional logic
    if (currentQuestion.containsKey('condition')) {
      final condition = currentQuestion['condition'];
      if (condition == 'nightlife_selected') {
        final activities = _userResponses['travel_activities'] as List<String>?;
        if (activities?.contains('Nightlife & Parties') == true) {
          return currentQuestion['next'];
        } else {
          return currentQuestion['fallback_next'];
        }
      }
    }

    // Handle yes/no branching
    if (currentQuestion['type'] == 'text_bool') {
      final isTravelling =
          _userResponses['currently_travelling'] as bool? ?? false;
      if (isTravelling && currentQuestion.containsKey('next_if_yes')) {
        return currentQuestion['next_if_yes'];
      } else if (!isTravelling && currentQuestion.containsKey('next_if_no')) {
        return currentQuestion['next_if_no'];
      }
    }

    return currentQuestion['next'];
  }

  void _handleUserResponse(String response) async {
    if (response.trim().isEmpty) return;

    final currentQuestion = _questions[_currentQuestionId];
    if (currentQuestion == null) return;

    _addUserMessage(response);

    // Process response based on question type
    bool validResponse = true;

    switch (currentQuestion['type']) {
      case 'text':
        _userResponses[currentQuestion['field']] = response.trim();
        break;

      case 'text_list':
        final items = response
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (currentQuestion['max_length'] != null &&
            items.length > currentQuestion['max_length']) {
          _addBotMessage(
              'Please provide up to ${currentQuestion['max_length']} items, separated by commas.');
          validResponse = false;
        } else {
          _userResponses[currentQuestion['field']] = items;
        }
        break;

      case 'choice':
      case 'multiple_choice':
        final options = currentQuestion['options'] as List<String>;
        if (currentQuestion['type'] == 'choice') {
          final matchingOption = options.firstWhere(
            (option) =>
                option.toLowerCase().contains(response.toLowerCase()) ||
                response.toLowerCase().contains(option.toLowerCase()),
            orElse: () => '',
          );
          if (matchingOption.isNotEmpty) {
            _userResponses[currentQuestion['field']] = matchingOption;
          } else {
            _addBotMessage(
                'Please choose one of the options I provided, or type something similar to one of them.');
            validResponse = false;
          }
        } else {
          // Handle multiple choice by parsing comma-separated values
          final selectedItems =
              response.split(',').map((e) => e.trim()).toList();
          final validItems = <String>[];

          for (final item in selectedItems) {
            final matchingOption = options.firstWhere(
              (option) =>
                  option.toLowerCase().contains(item.toLowerCase()) ||
                  item.toLowerCase().contains(option.toLowerCase()),
              orElse: () => '',
            );
            if (matchingOption.isNotEmpty &&
                !validItems.contains(matchingOption)) {
              validItems.add(matchingOption);
            }
          }

          if (validItems.isNotEmpty) {
            _userResponses[currentQuestion['field']] = validItems;
          } else {
            _addBotMessage(
                'Please select from the options I provided. You can choose multiple items by separating them with commas.');
            validResponse = false;
          }
        }
        break;

      case 'boolean':
        final boolResponse = response.toLowerCase().contains('yes') ||
            response.toLowerCase().contains('sure') ||
            response.toLowerCase().contains('okay') ||
            response.toLowerCase().contains('true');
        _userResponses[currentQuestion['field']] = boolResponse;
        break;

      case 'text_bool':
        final isTravelling = response.toLowerCase().contains('yes') ||
            response.toLowerCase().contains('currently');
        _userResponses['currently_travelling'] = isTravelling;
        if (isTravelling) {
          // Extract location from response
          final words = response.split(' ');
          final locationIndex = words.indexWhere((word) =>
              word.toLowerCase() == 'in' || word.toLowerCase() == 'at');
          if (locationIndex != -1 && locationIndex < words.length - 1) {
            _userResponses['current_residence'] =
                words.sublist(locationIndex + 1).join(' ');
          } else {
            _userResponses['current_residence'] = response
                .replaceFirst(RegExp(r'^yes\s*,?\s*', caseSensitive: false), '')
                .trim();
          }
        }
        break;
    }

    if (!validResponse) {
      _controller.clear();
      return;
    }

    // Move to next question
    final nextQuestionId = _getNextQuestion();
    if (nextQuestionId == null || nextQuestionId == 'complete') {
      await _saveResponses();
      _addBotMessage(
          '🎉 Amazing! I feel like I really know you now, ${_userResponses['nickname']}! \n\nI\'m excited to help you discover incredible travel connections. Ready to start meeting some awesome people?');
    } else {
      _currentQuestionId = nextQuestionId;
      await Future.delayed(Duration(milliseconds: 500));
      _addBotMessage(_questions[nextQuestionId]!['question']);
    }

    _controller.clear();
  }

  Future<void> _saveResponses() async {
    if (_userId == null) return;

    try {
      await _supabase.from('userquestion').upsert({
        'userid': _userId,
        ..._userResponses,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Profile created successfully!'),
            ],
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Error saving profile: $e'),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _typingAnimationController,
                  builder: (context, child) {
                    return Row(
                      children: List.generate(3, (index) {
                        final delay = index * 0.2;
                        final animationValue =
                            (_typingAnimationController.value + delay) % 1.0;
                        final opacity = (animationValue < 0.5)
                            ? animationValue * 2
                            : (1 - animationValue) * 2;

                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 1),
                          child: Opacity(
                            opacity: opacity.clamp(0.3, 1.0),
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.grey[600],
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
                SizedBox(width: 8),
                Text(
                  'Malenia is typing...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple[400]!, Colors.pink[400]!],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.smart_toy, color: Colors.white, size: 18),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Malenia',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Your AI Travel Companion',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }

                final message = _messages[index];
                final isBot = message['sender'] == 'bot';

                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isBot) ...[
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.purple[400]!, Colors.pink[400]!],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.smart_toy,
                              color: Colors.white, size: 16),
                        ),
                        SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: isBot
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isBot ? Colors.white : Colors.blue[500],
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                  bottomLeft: Radius.circular(isBot ? 4 : 18),
                                  bottomRight: Radius.circular(isBot ? 18 : 4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                message['text'],
                                style: TextStyle(
                                  color:
                                      isBot ? Colors.grey[800] : Colors.white,
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isBot) ...[
                        SizedBox(width: 12),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.blue[500],
                            shape: BoxShape.circle,
                          ),
                          child:
                              Icon(Icons.person, color: Colors.white, size: 16),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Type your response...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        onSubmitted: (value) => _handleUserResponse(value),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[400]!, Colors.blue[600]!],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send_rounded, color: Colors.white),
                      onPressed: () => _handleUserResponse(_controller.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
