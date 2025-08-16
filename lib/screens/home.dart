import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_screen.dart';
import 'service_details_screen.dart';
import 'search_screen.dart';
import 'my_bookings_screen.dart';

// Dummy Profile Page (keeping for backward compatibility)
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Center(
        child: Text(
          user != null
              ? 'Hello, ${user.email ?? "User"}!'
              : 'No user info available.',
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> services = [
    {
      'icon': FontAwesomeIcons.broom,
      'title': 'Home Cleaning',
      'color': Colors.teal,
    },
    {
      'icon': FontAwesomeIcons.wrench,
      'title': 'Plumbing',
      'color': Colors.blue,
    },
    {
      'icon': FontAwesomeIcons.bolt,
      'title': 'Electrical',
      'color': Colors.amber,
    },
    {
      'icon': FontAwesomeIcons.snowflake,
      'title': 'AC Repair',
      'color': Colors.cyan,
    },
    {
      'icon': FontAwesomeIcons.spa,
      'title': 'Beauty & Spa',
      'color': Colors.pink,
    },
    {
      'icon': FontAwesomeIcons.paintRoller,
      'title': 'Painting',
      'color': Colors.orange,
    },
    {
      'icon': FontAwesomeIcons.bug,
      'title': 'Pest Control',
      'color': Colors.red,
    },
    {
      'icon': FontAwesomeIcons.car,
      'title': 'Automotive',
      'color': Colors.deepPurple,
    },
    {
      'icon': FontAwesomeIcons.utensils,
      'title': 'Catering',
      'color': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 900;
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // AppBar & Hero Section
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00AF9A), Color(0xFF547DCD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    // AppBar Row
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16 : 30,
                        vertical: isSmallScreen ? 12 : 20,
                      ),
                      child: isSmallScreen 
                        ? _buildMobileAppBar()
                        : _buildDesktopAppBar(),
                    ),
                    // Hero Section
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16 : 20,
                      ),
                      child: _buildHeroSection(screenWidth, isSmallScreen),
                    ),
                  ],
                ),
              ),
              // Popular Services Section
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 20,
                  vertical: isSmallScreen ? 24 : 40,
                ),
                child: _buildServicesSection(screenWidth, isSmallScreen, isMediumScreen),
              ),
            ],
          ),
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(isSmallScreen),
    );
  }

  Widget _buildMobileAppBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Text(
                "WorkNear",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                ),
                _buildProfileMenu(),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Search bar below on mobile - now navigates to search screen
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            );
          },
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                SizedBox(width: 12),
                Icon(Icons.search, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Search services...',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopAppBar() {
    return Row(
      children: [
        const Text(
          "WorkNear",
          style: TextStyle(
            fontSize: 28,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 16),
        // Responsive search bar - now navigates to search screen
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
              },
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 16),
                    Icon(Icons.search, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Search services...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildProfileMenu(),
      ],
    );
  }

  Widget _buildProfileMenu() {
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.userMetadata?['username'] ?? user?.userMetadata?['name'];
    
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 16,
              child: user?.userMetadata?['avatar_url'] != null
                  ? ClipOval(
                      child: Image.network(
                        user!.userMetadata!['avatar_url'],
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, color: Color(0xFF547DCD), size: 16),
                      ),
                    )
                  : const Icon(Icons.person, color: Color(0xFF547DCD), size: 16),
            ),
            if (userName != null) ...[
              const SizedBox(width: 8),
              Text(
                userName.length > 10 ? '${userName.substring(0, 10)}...' : userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
          ],
        ),
      ),
      onSelected: (value) async {
        if (value == 'profile') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        } else if (value == 'bookings') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
          );
        } else if (value == 'settings') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        } else if (value == 'logout') {
          await Supabase.instance.client.auth.signOut();
          if (context.mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'profile',
          child: ListTile(
            leading: Icon(Icons.person, color: Color(0xFF547DCD)),
            title: Text('My Profile'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'bookings',
          child: ListTile(
            leading: Icon(Icons.receipt_long, color: Color(0xFF547DCD)),
            title: Text('My Bookings'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'settings',
          child: ListTile(
            leading: Icon(Icons.settings, color: Color(0xFF547DCD)),
            title: Text('Settings'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Sign Out', style: TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(double screenWidth, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: isSmallScreen ? 20 : 30),
        Text(
          'Find Your Perfect',
          style: TextStyle(
            fontSize: isSmallScreen ? 28 : 40,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          'Service Provider',
          style: TextStyle(
            fontSize: isSmallScreen ? 28 : 40,
            color: Colors.orange,
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 0),
          child: Text(
            'Book trusted professionals for all your service needs.\nQuality service, guaranteed satisfaction, available across India.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.white70,
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 20 : 30),
        // Search fields - now navigates to search screen
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 8 : 40,
            ),
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                isSmallScreen 
                  ? _buildMobileSearchFields()
                  : _buildDesktopSearchFields(),
                SizedBox(height: isSmallScreen ? 12 : 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 20 : 40,
                        vertical: isSmallScreen ? 12 : 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Search Services',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 20 : 30),
      ],
    );
  }

  Widget _buildMobileSearchFields() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.search, size: 20),
                SizedBox(width: 8),
                Text('What service do you need?', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.location_on, size: 20),
                SizedBox(width: 8),
                Text('Vijayawada, Andhra Pradesh', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopSearchFields() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.search),
                  SizedBox(width: 8),
                  Text('What service do you need?'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.location_on),
                  SizedBox(width: 8),
                  Text('Bengaluru, Karnataka'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSection(double screenWidth, bool isSmallScreen, bool isMediumScreen) {
    // Responsive grid columns
    int crossAxisCount;
    if (isSmallScreen) {
      crossAxisCount = 2;
    } else if (isMediumScreen) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 4;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Services',
          style: TextStyle(
            fontSize: isSmallScreen ? 22 : 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        Text(
          'Book trusted professionals for all your needs.',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 15,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: isSmallScreen ? 20 : 30),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: services.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: isSmallScreen ? 16 : 24,
            crossAxisSpacing: isSmallScreen ? 16 : 24,
            childAspectRatio: isSmallScreen ? 0.85 : 0.95,
          ),
          itemBuilder: (context, index) {
            final service = services[index];
            return _buildServiceCard(
              icon: service['icon'],
              color: service['color'],
              title: service['title'],
              isSmallScreen: isSmallScreen,
            );
          },
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required Color color,
    required String title,
    required bool isSmallScreen,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          // Navigate to service details screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ServiceDetailsScreen(
                serviceName: title,
                serviceIcon: icon,
                serviceColor: color,
              ),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 16 : 24,
            horizontal: isSmallScreen ? 8 : 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.13),
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: isSmallScreen ? 22 : 28,
                backgroundColor: color.withOpacity(0.17),
                child: Icon(
                  icon,
                  color: color,
                  size: isSmallScreen ? 24 : 30,
                ),
              ),
              SizedBox(height: isSmallScreen ? 10 : 14),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 12 : 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(bool isSmallScreen) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF547DCD),
      unselectedItemColor: Colors.grey,
      currentIndex: 0, // Home is selected
      onTap: (index) {
        switch (index) {
          case 0:
            // Already on home
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}