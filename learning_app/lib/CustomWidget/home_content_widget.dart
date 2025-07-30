import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class MaleniaHomeScreen extends StatefulWidget {
  final Map<String, String> userProfile;
  final Function onNavigate;

  const MaleniaHomeScreen({
    super.key,
    required this.userProfile,
    required this.onNavigate,
  });

  @override
  State<MaleniaHomeScreen> createState() => _MaleniaHomeScreenState();
}

class _MaleniaHomeScreenState extends State<MaleniaHomeScreen>
    with TickerProviderStateMixin {
  late Map<String, String> _profile;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _profile = Map.from(widget.userProfile);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _refreshUserProfile() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final data = snapshot.data();
    if (data != null) {
      setState(() {
        _profile = {
          ..._profile,
          "profileImage": data.containsKey('profileImage')
              ? data['profileImage'] ?? ""
              : "",
          "travelPreference": data.containsKey('travelPreference')
              ? data['travelPreference'] ?? "Adventure"
              : "Adventure",
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    final travelModules = [
      _TravelModule(
        title: 'Buddy Matcher',
        subtitle: 'Find travel companions',
        lottie: 'buddy_matcher.json',
        icon: Icons.people_outline,
        primaryColor: const Color(0xFF6366f1),
        secondaryColor: const Color(0xFF8b5cf6),
        screenBuilder: (context) => Container(),
      ),
      _TravelModule(
        title: 'Destinations',
        subtitle: 'Explore amazing places',
        lottie: 'destinations.json',
        icon: Icons.location_on_outlined,
        primaryColor: const Color(0xFF10b981),
        secondaryColor: const Color(0xFF059669),
        screenBuilder: (context) => Container(),
      ),
      _TravelModule(
        title: 'Trip Planner',
        subtitle: 'Plan your journey',
        lottie: 'trip_planner.json',
        icon: Icons.map_outlined,
        primaryColor: const Color(0xFFf59e0b),
        secondaryColor: const Color(0xFFef4444),
        screenBuilder: (context) => Container(),
      ),
      _TravelModule(
        title: 'Chat & Connect',
        subtitle: 'Message travel buddies',
        lottie: 'chat.json',
        icon: Icons.chat_bubble_outline,
        primaryColor: const Color(0xFFec4899),
        secondaryColor: const Color(0xFFf97316),
        screenBuilder: (context) => Container(),
      ),
      _TravelModule(
        title: 'Travel Groups',
        subtitle: 'Join group adventures',
        lottie: 'groups.json',
        icon: Icons.groups_outlined,
        primaryColor: const Color(0xFF06b6d4),
        secondaryColor: const Color(0xFF3b82f6),
        screenBuilder: (context) => Container(),
      ),
      _TravelModule(
        title: 'Local Guides',
        subtitle: 'Meet local experts',
        lottie: 'guides.json',
        icon: Icons.tour_outlined,
        primaryColor: const Color(0xFF8b5cf6),
        secondaryColor: const Color(0xFF6366f1),
        screenBuilder: (context) => Container(),
      ),
      _TravelModule(
        title: 'Travel Stories',
        subtitle: 'Share your adventures',
        lottie: 'stories.json',
        icon: Icons.auto_stories_outlined,
        primaryColor: const Color(0xFF0ea5e9),
        secondaryColor: const Color(0xFF06b6d4),
        screenBuilder: (context) => Container(),
      ),
      _TravelModule(
        title: 'Safety Hub',
        subtitle: 'Travel safely together',
        lottie: 'safety.json',
        icon: Icons.security_outlined,
        primaryColor: const Color(0xFF7c3aed),
        secondaryColor: const Color(0xFF6366f1),
        screenBuilder: (context) => Container(),
      ),
    ];

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0a0a0a) : const Color(0xFFf8fafc),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Section
                      _buildHeroSection(isDark),

                      // Quick Actions
                      _buildQuickActions(isDark),

                      // Travel Stats
                      _buildTravelStats(isDark),

                      // Travel Modules
                      _buildTravelModules(travelModules, isDark),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isDark) {
    final hour = DateTime.now().hour;
    String greeting = hour < 12
        ? "Good Morning"
        : hour < 17
            ? "Good Afternoon"
            : "Good Evening";

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1f1f1f), const Color(0xFF2a2a2a)]
              : [const Color(0xFF6366f1), const Color(0xFF8b5cf6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, ${_profile["firstName"] ?? "Traveler"}!',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ready for your next adventure?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Find your perfect travel buddy on Malenia',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.flight_takeoff_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    final quickActions = [
      {
        'icon': Icons.search_outlined,
        'title': 'Find Buddies',
        'color': const Color(0xFF10b981)
      },
      {
        'icon': Icons.add_location_outlined,
        'title': 'Add Trip',
        'color': const Color(0xFF6366f1)
      },
      {
        'icon': Icons.message_outlined,
        'title': 'Messages',
        'color': const Color(0xFFf59e0b)
      },
      {
        'icon': Icons.person_outline,
        'title': 'Profile',
        'color': const Color(0xFFec4899)
      },
    ];

    return Container(
      height: 105,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: quickActions.length,
        itemBuilder: (context, index) {
          final action = quickActions[index];
          return Container(
            width: 80,
            margin: EdgeInsets.only(
                right: index < quickActions.length - 1 ? 16 : 0),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1f1f1f) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    action['icon'] as IconData,
                    color: action['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  action['title'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : const Color(0xFF6b7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTravelStats(bool isDark) {
    final travelStats = [
      {
        'title': 'Trips Planned',
        'value': '12',
        'change': '+3 this month',
        'positive': true
      },
      {
        'title': 'Buddies Met',
        'value': '28',
        'change': '+5 new matches',
        'positive': true
      },
      {
        'title': 'Countries',
        'value': '7',
        'change': '+2 planned',
        'positive': true
      },
    ];

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Travel Journey',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1f2937),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: travelStats.map((item) {
              final index = travelStats.indexOf(item);
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                      right: index < travelStats.length - 1 ? 12 : 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1f1f1f) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isDark ? Colors.white60 : const Color(0xFF6b7280),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['value'] as String,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? Colors.white : const Color(0xFF1f2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            size: 12,
                            color: const Color(0xFF10b981),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item['change'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF10b981),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelModules(List<_TravelModule> modules, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore Malenia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1f2937),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final module = modules[index];
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 200 + (index * 50)),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1f1f1f) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    module.screenBuilder(context),
                                transitionsBuilder: (_, animation, __, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.1),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icon with gradient background
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        module.primaryColor.withOpacity(0.1),
                                        module.secondaryColor.withOpacity(0.1),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: module.lottie.isNotEmpty
                                      ? Lottie.asset(
                                          'assets/lottie/${module.lottie}',
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              Icon(module.icon,
                                                  color: module.primaryColor,
                                                  size: 28),
                                        )
                                      : Icon(module.icon,
                                          color: module.primaryColor, size: 28),
                                ),
                                const SizedBox(height: 16),

                                // Title
                                Text(
                                  module.title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1f2937),
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Subtitle
                                Text(
                                  module.subtitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white60
                                        : const Color(0xFF6b7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TravelModule {
  final String title;
  final String subtitle;
  final String lottie;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final Widget Function(BuildContext context) screenBuilder;

  _TravelModule({
    required this.title,
    required this.subtitle,
    required this.lottie,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.screenBuilder,
  });
}
