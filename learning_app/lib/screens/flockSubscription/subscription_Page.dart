import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// SubscriptionPackage class to handle data from Firestore
class SubscriptionPackage {
  final String name;
  final String price;
  final String? originalPrice;
  final String period;
  final String description;
  final List<String> features;
  final List<String> apps;
  final Color color;
  final bool isPopular;
  final IconData icon;

  SubscriptionPackage({
    required this.name,
    required this.price,
    this.originalPrice,
    required this.period,
    required this.description,
    required this.features,
    required this.apps,
    required this.color,
    required this.isPopular,
    required this.icon,
  });

  // Convert from Firestore document
  factory SubscriptionPackage.fromFirestore(Map<String, dynamic> data) {
    return SubscriptionPackage(
      name: data['name'] ?? '',
      price: data['price'] ?? '',
      originalPrice: data['originalPrice'],
      period: data['period'] ?? '',
      description: data['description'] ?? '',
      features: List<String>.from(data['features'] ?? []),
      apps: List<String>.from(data['apps'] ?? []),
      color: Color(data['color'] ?? 0xFF667eea),
      isPopular: data['isPopular'] ?? false,
      icon: _getIconFromString(data['icon'] ?? 'business_center_outlined'),
    );
  }

  // Convert to Map for consistency
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'originalPrice': originalPrice,
      'period': period,
      'description': description,
      'features': features,
      'apps': apps,
      'color': color.value,
      'isPopular': isPopular,
      'icon': icon.toString(),
    };
  }

  static IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'business_center_outlined':
        return Icons.business_center_outlined;
      case 'trending_up':
        return Icons.trending_up;
      case 'apartment':
        return Icons.apartment;
      default:
        return Icons.business_center_outlined;
    }
  }
}

class SubscriptionPage extends StatefulWidget {
  final Function onNavigate;
  final List<dynamic>? externalPackages; // Can be SubscriptionPackage or Map

  const SubscriptionPage({
    super.key,
    required this.onNavigate,
    this.externalPackages,
  });

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final user = FirebaseAuth.instance.currentUser;
  String? selectedPackage;
  List<String> subscribedModules = [];
  bool isLoading = true;
  bool _isDisposed = false;
  bool isAdmin = false;
  bool isCheckingAdmin = true;
  List<Map<String, dynamic>> packages = [];

  final List<Map<String, dynamic>> defaultPackages = [
    {
      'name': 'Basic Suite',
      'price': 'Free',
      'originalPrice': null,
      'period': '',
      'description': 'Perfect for small teams getting started',
      'features': [
        'Up to 5 team members',
        'Basic employee management',
        'Core HR functions',
        'Email support',
        '5GB storage'
      ],
      'apps': ["Employee", "Human Resources"],
      'color': const Color(0xFF667eea),
      'isPopular': false,
      'icon': Icons.business_center_outlined,
    },
    {
      'name': 'Business Core',
      'price': '\$29.99',
      'originalPrice': '\$49.99',
      'period': '/month',
      'description': 'Ideal for growing businesses',
      'features': [
        'Up to 50 team members',
        'Advanced payroll system',
        'Full accounting suite',
        'Sales management',
        'Inventory tracking',
        'Priority support',
        '100GB storage'
      ],
      'apps': [
        "Payroll",
        "Accounting",
        "Sales Hub",
        "Inventory Management",
        "Employee",
        "Human Resources"
      ],
      'color': const Color(0xFF11998e),
      'isPopular': true,
      'icon': Icons.trending_up,
    },
    {
      'name': 'Enterprise Suite',
      'price': '\$59.99',
      'originalPrice': '\$99.99',
      'period': '/month',
      'description': 'Complete solution for large organizations',
      'features': [
        'Unlimited team members',
        'All ERP modules included',
        'Advanced analytics',
        'Custom integrations',
        'Dedicated account manager',
        '24/7 phone support',
        'Unlimited storage',
        'Custom branding'
      ],
      'apps': [
        "Human Resources",
        "Employee",
        "Payroll",
        "Accounting",
        "Outreach",
        "Project Planning",
        "Business Operations",
        "Manufacturing",
        "Sales Hub",
        "Inventory Management"
      ],
      'color': const Color(0xFF8360c3),
      'isPopular': false,
      'icon': Icons.apartment,
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
    _checkAndHandleSubscriptionExpiry();
  }

  @override
  void didUpdateWidget(SubscriptionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.externalPackages != oldWidget.externalPackages) {
      updatePackagesFromExternal(widget.externalPackages);
    }
  }

  // Check if current user is Firebase Auth admin
  Future<void> _checkAdminAccess() async {
    try {
      if (user == null) {
        setState(() {
          isAdmin = false;
          isCheckingAdmin = false;
        });
        return;
      }

      if (user!.providerData.isEmpty) {
        setState(() {
          isAdmin = false;
          isCheckingAdmin = false;
        });
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        final role = userData?['role'] ?? '';
        final isFirebaseUser = userData?['authProvider'] == 'firebase' ||
            userData?['authProvider'] == null;

        setState(() {
          isAdmin = (role == 'Admin' || role == 'superadmin') && isFirebaseUser;
          isCheckingAdmin = false;
        });
      } else {
        setState(() {
          isAdmin = false;
          isCheckingAdmin = false;
        });
      }

      if (isAdmin) {
        _initializePackages();
        if (widget.externalPackages != null) {
          updatePackagesFromExternal(widget.externalPackages);
        }
        _loadUserSubscription();
      }
    } catch (e) {
      debugPrint('Error checking admin access: $e');
      setState(() {
        isAdmin = false;
        isCheckingAdmin = false;
      });
    }
  }

  void _initializePackages() {
    packages = List.from(defaultPackages);
  }

  void updatePackagesFromExternal(dynamic externalPackages) {
    if (externalPackages == null) return;

    List<Map<String, dynamic>> convertedPackages = [];

    if (externalPackages is List<SubscriptionPackage>) {
      convertedPackages = externalPackages.map((pkg) => pkg.toMap()).toList();
    } else if (externalPackages is List<Map<String, dynamic>>) {
      convertedPackages = List<Map<String, dynamic>>.from(externalPackages);
    } else if (externalPackages is List) {
      for (var item in externalPackages) {
        if (item is SubscriptionPackage) {
          convertedPackages.add(item.toMap());
        } else if (item is Map<String, dynamic>) {
          convertedPackages.add(item);
        } else if (item is Map) {
          convertedPackages.add(Map<String, dynamic>.from(item));
        }
      }
    }

    if (convertedPackages.isNotEmpty) {
      setState(() {
        packages = convertedPackages;
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  T? _getPackageProperty<T>(Map<String, dynamic> package, String key,
      [T? defaultValue]) {
    try {
      final value = package[key];
      if (value is T) {
        return value;
      }
      return defaultValue;
    } catch (e) {
      debugPrint('Error accessing package property $key: $e');
      return defaultValue;
    }
  }

  Color _getPackageColor(Map<String, dynamic> package) {
    final colorValue = package['color'];
    if (colorValue is Color) {
      return colorValue;
    } else if (colorValue is int) {
      return Color(colorValue);
    }
    return const Color(0xFF667eea);
  }

  IconData _getPackageIcon(Map<String, dynamic> package) {
    final iconValue = package['icon'];
    if (iconValue is IconData) {
      return iconValue;
    }
    return Icons.business_center_outlined;
  }

  Future<void> _loadUserSubscription() async {
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final docRef =
          FirebaseFirestore.instance.collection('users').doc(user!.uid);
      final subDoc =
          await docRef.collection('subscription').doc('active').get();

      if (!_isDisposed && mounted && subDoc.exists) {
        final data = subDoc.data();
        if (data != null) {
          final expiryDateStr = data['expiryDate'] as String?;
          if (expiryDateStr != null) {
            final expiryDate = DateTime.parse(expiryDateStr);
            if (DateTime.now().isAfter(expiryDate)) {
              await _handleSubscriptionExpiry(user!.uid, data);
              return;
            }
          }
          setState(() {
            selectedPackage = data['package'] as String?;
            subscribedModules = List<String>.from(data['modules'] ?? []);
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading subscription: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleSubscriptionExpiry(
      String userId, Map<String, dynamic> data) async {
    try {
      // Move to history collection in Firebase
      final historyRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('historySubscription')
          .doc('expired_${DateTime.now().millisecondsSinceEpoch}');
      await historyRef.set(data);

      // Delete from subscription collection in Firebase
      final subRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('subscription')
          .doc('active');
      await subRef.delete();

      // Delete from Supabase subscriptions table (assuming table name 'subscriptions')
      final supabase = Supabase.instance.client;
      await supabase.from('subscriptions').delete().eq('user_id', userId);

      if (!_isDisposed && mounted) {
        setState(() {
          selectedPackage = null;
          subscribedModules = [];
        });
        _showSnackBar('Subscription has expired and been archived.');
      }
    } catch (e) {
      debugPrint('Error handling subscription expiry: $e');
      if (!_isDisposed && mounted) {
        _showSnackBar('Error processing expired subscription: $e',
            isError: true);
      }
    }
  }

  Future<void> _subscribeToPackage(Map<String, dynamic> package) async {
    if (!mounted) return;

    final confirm = await _showConfirmationDialog(package);
    if (confirm != true || user == null || !mounted) return;

    try {
      final now = DateTime.now();
      final expiry = now.add(const Duration(days: 30));

      final subRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('subscription')
          .doc('active');

      await subRef.set({
        'package': package['name'],
        'modules': package['apps'],
        'subscriptionDate': now.toIso8601String(),
        'expiryDate': expiry.toIso8601String(),
      });

      if (!mounted) return;

      await _showSuccessDialog(package);

      if (!mounted) return;

      setState(() {
        selectedPackage = package['name']?.toString();
        subscribedModules = List<String>.from(package['apps'] ?? []);
      });
    } catch (e) {
      debugPrint('Error subscribing: $e');
      if (mounted) {
        _showErrorDialog();
      }
    }
  }

  Future<bool?> _showConfirmationDialog(Map<String, dynamic> package) {
    if (!mounted) return Future.value(false);

    final packageColor = _getPackageColor(package);
    final packageIcon = _getPackageIcon(package);
    final packageName =
        _getPackageProperty<String>(package, 'name', 'Unknown Package');
    final packageDescription =
        _getPackageProperty<String>(package, 'description', '');
    final packagePrice = _getPackageProperty<String>(package, 'price', 'Free');
    final packagePeriod = _getPackageProperty<String>(package, 'period', '');

    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: packageColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                packageIcon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Confirm Subscription'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subscribe to $packageName?'),
            const SizedBox(height: 8),
            Text(
              packageDescription!,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            if (packagePrice != 'Free') ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Price:'),
                    Text(
                      '$packagePrice$packagePeriod',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: packageColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: packageColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSuccessDialog(Map<String, dynamic> package) {
    if (!mounted) return Future.value();

    final packageColor = _getPackageColor(package);
    final packageName =
        _getPackageProperty<String>(package, 'name', 'Unknown Package');

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie/success.json',
                width: 100,
                height: 100,
                repeat: false,
                onLoaded: (composition) {
                  Future.delayed(composition.duration, () {
                    if (Navigator.of(dialogContext).mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome aboard!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: packageColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Successfully subscribed to $packageName',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Error'),
        content: const Text('Failed to subscribe. Please try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
            isError ? const Color(0xFFE74C3C) : const Color(0xFF00B894),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildAccessDeniedScreen() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 64,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'This page is restricted to Admin users only.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please contact your system Administrator for access.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => widget.onNavigate(0),
                icon: const Icon(Icons.arrow_back, size: 20),
                label: const Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Verifying Access...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF667eea),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we check your permissions',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isCheckingAdmin) {
      return _buildLoadingScreen();
    }

    if (!isAdmin) {
      return _buildAccessDeniedScreen();
    }

    if (isLoading) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                color: Color(0xFF667eea),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Subscription Manager'),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Text(
                    'Unlock Your Business Potential',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Choose the perfect plan for your team',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ...packages.map((package) => _buildSubscriptionCard(package)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
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
                children: [
                  const Icon(
                    Icons.security,
                    size: 40,
                    color: Color(0xFF11998e),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '30-Day Money Back Guarantee',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try risk-free for 30 days. Cancel anytime.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(Map<String, dynamic> package) {
    final isSelected = selectedPackage == package['name'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: package['color'], width: 2)
                  : Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? package['color'].withOpacity(0.2)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: isSelected ? 15 : 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: package['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        package['icon'],
                        color: package['color'],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package['name'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            package['description'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      package['price'],
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: package['color'],
                      ),
                    ),
                    if (package['period'] != null &&
                        package['period'].isNotEmpty)
                      Text(
                        package['period'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    const SizedBox(width: 8),
                    if (package['originalPrice'] != null)
                      Text(
                        package['originalPrice'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                ...package['features'].map<Widget>((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: package['color'],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: package['apps']
                      .map<Widget>((app) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: package['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              app,
                              style: TextStyle(
                                fontSize: 12,
                                color: package['color'],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSelected ? Colors.grey[300] : package['color'],
                      foregroundColor:
                          isSelected ? Colors.grey[600] : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: isSelected ? 0 : 2,
                    ),
                    onPressed:
                        isSelected ? null : () => _subscribeToPackage(package),
                    child: Text(
                      isSelected ? 'Current Plan' : 'Get Started',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (package['isPopular'])
            Positioned(
              top: -5,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.black87),
                    SizedBox(width: 4),
                    Text(
                      'POPULAR',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (isSelected)
            Positioned(
              top: -5,
              left: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: package['color'],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 16, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'ACTIVE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

  Future<void> _checkAndHandleSubscriptionExpiry() async {
    if (user == null) return;

    try {
      final docRef =
          FirebaseFirestore.instance.collection('users').doc(user!.uid);
      final subDoc =
          await docRef.collection('subscription').doc('active').get();

      if (subDoc.exists) {
        final data = subDoc.data();
        if (data != null) {
          final expiryDateStr = data['expiryDate'] as String?;
          if (expiryDateStr != null) {
            final expiryDate = DateTime.parse(expiryDateStr);
            if (DateTime.now().isAfter(expiryDate)) {
              await _handleSubscriptionExpiry(user!.uid, data);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking subscription expiry: $e');
    }
  }
}
