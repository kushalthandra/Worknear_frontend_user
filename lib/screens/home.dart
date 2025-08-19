import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_screen.dart';
import 'service_details_screen.dart';
import 'search_screen.dart';
import 'my_bookings_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Center(
        child: Text(
          user != null ? 'Hello, ${user.email ?? "User"}!' : 'No user info available.',
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
    {'icon': FontAwesomeIcons.broom, 'title': 'Home Cleaning', 'color': Colors.teal},
    {'icon': FontAwesomeIcons.wrench, 'title': 'Plumbing', 'color': Colors.blue},
    {'icon': FontAwesomeIcons.bolt, 'title': 'Electrical', 'color': Colors.amber},
    {'icon': FontAwesomeIcons.snowflake, 'title': 'AC Repair', 'color': Colors.cyan},
    {'icon': FontAwesomeIcons.spa, 'title': 'Beauty & Spa', 'color': Colors.pink},
    {'icon': FontAwesomeIcons.paintRoller, 'title': 'Painting', 'color': Colors.orange},
    {'icon': FontAwesomeIcons.bug, 'title': 'Pest Control', 'color': Colors.red},
    {'icon': FontAwesomeIcons.car, 'title': 'Automotive', 'color': Colors.deepPurple},
    {'icon': FontAwesomeIcons.utensils, 'title': 'Catering', 'color': Colors.green},
  ];

  final TextEditingController _locationController = TextEditingController();
  final FocusNode _locationFocusNode = FocusNode();
  bool _isFetching = false;
  List<Map<String, String>> _locationSuggestions = [];
  bool _showSuggestions = false;
  Timer? _debounceTimer;
  final OverlayPortalController _overlayController = OverlayPortalController();
  final GlobalKey _locationFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _locationFocusNode.addListener(() {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted && !_locationFocusNode.hasFocus) {
          setState(() => _showSuggestions = false);
          _overlayController.hide();
        }
      });
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _locationController.dispose();
    _locationFocusNode.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() => _isFetching = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _locationController.text = "Location permission denied";
          setState(() => _isFetching = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _locationController.text = "Location permission permanently denied";
        setState(() => _isFetching = false);
        return;
      }
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationController.text = "Location services disabled";
        setState(() => _isFetching = false);
        return;
      }
      Position position = await Geolocator.getCurrentPosition();

      if (!kIsWeb) {
        final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final city = place.locality ?? '';
          final state = place.administrativeArea ?? '';
          if (city.isNotEmpty || state.isNotEmpty) {
            _locationController.text = [city, state].where((e) => e.isNotEmpty).join(', ');
          } else {
            _locationController.text = '${position.latitude}, ${position.longitude}';
          }
        } else {
          _locationController.text = '${position.latitude}, ${position.longitude}';
        }
      } else {
        final url = 'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${position.latitude}&lon=${position.longitude}';
        final response = await http.get(Uri.parse(url), headers: {'User-Agent': 'worknear-flutter-app'});
        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          final city = json['address']?['city'] ?? json['address']?['town'] ?? json['address']?['village'] ?? '';
          final state = json['address']?['state'] ?? '';
          if (city.isNotEmpty || state.isNotEmpty) {
            _locationController.text = [city, state].where((e) => e.isNotEmpty).join(', ');
          } else {
            _locationController.text = '${position.latitude}, ${position.longitude}';
          }
        } else {
          _locationController.text = '${position.latitude}, ${position.longitude}';
        }
      }
    } catch (e) {
      _locationController.text = "Error fetching location";
    }
    setState(() => _isFetching = false);
  }

  void _onLocationChanged(String query) {
    _debounceTimer?.cancel();
    if (query.length < 3) {
      setState(() {
        _locationSuggestions = [];
        _showSuggestions = false;
      });
      _overlayController.hide();
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _fetchLocationSuggestions(query);
    });
  }

  Future<void> _fetchLocationSuggestions(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = 'https://nominatim.openstreetmap.org/search?format=jsonv2&q=$encodedQuery&addressdetails=1&limit=5&countrycodes=IN';
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'worknear-flutter-app/1.0'},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final suggestions = data.map<Map<String, String>>((item) {
          final address = item['address'] ?? {};
          final city = address['city'] ?? address['town'] ?? address['village'] ?? '';
          final state = address['state'] ?? '';
          String displayName = item['display_name'] ?? '';
          String shortName = '';
          if (city.isNotEmpty && state.isNotEmpty) {
            shortName = '$city, $state';
          } else if (city.isNotEmpty) {
            shortName = city;
          } else if (state.isNotEmpty) {
            shortName = state;
          } else {
            shortName = displayName.split(',').take(2).join(',');
          }
          return {'short': shortName, 'full': displayName};
        }).where((item) => item['short']!.isNotEmpty).toList();
        if (mounted) {
          setState(() {
            _locationSuggestions = suggestions;
            _showSuggestions = suggestions.isNotEmpty;
          });
          if (suggestions.isNotEmpty && _locationFocusNode.hasFocus) {
            _overlayController.show();
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _locationSuggestions = [];
            _showSuggestions = false;
          });
          _overlayController.hide();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationSuggestions = [];
          _showSuggestions = false;
        });
        _overlayController.hide();
      }
    }
  }

  Widget _buildLocationSuggestionsOverlay() {
    if (!_showSuggestions || _locationSuggestions.isEmpty) {
      return const SizedBox.shrink();
    }
    final RenderBox? renderBox = _locationFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return const SizedBox.shrink();
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenHeight = MediaQuery.of(context).size.height;
    final dropdownTop = position.dy + size.height + 4;
    final dropdownLeft = position.dx;
    final dropdownWidth = size.width;
    final maxHeight = screenHeight - dropdownTop - 50;
    final constrainedHeight = maxHeight > 200 ? 200.0 : maxHeight;
    return Positioned(
      top: dropdownTop,
      left: dropdownLeft,
      width: dropdownWidth,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        shadowColor: Colors.black26,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          constraints: BoxConstraints(maxHeight: constrainedHeight),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: _locationSuggestions.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
            itemBuilder: (context, index) {
              final suggestion = _locationSuggestions[index];
              return InkWell(
                onTap: () {
                  _locationController.text = suggestion['short']!;
                  setState(() => _showSuggestions = false);
                  _overlayController.hide();
                  _locationFocusNode.unfocus();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion['short']!,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      if (suggestion['full']!.isNotEmpty && suggestion['full'] != suggestion['short'])
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            suggestion['full']!,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

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
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 30, vertical: isSmallScreen ? 12 : 20),
                      child: isSmallScreen ? _buildMobileAppBar() : _buildDesktopAppBar(),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
                      child: _buildHeroSection(screenWidth, isSmallScreen, context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20, vertical: isSmallScreen ? 24 : 40),
                child: _buildServicesSection(screenWidth, isSmallScreen, isMediumScreen),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(isSmallScreen),
    );
  }

  // --- MODIFIED: Removed the fake search bar from the mobile app bar ---
  Widget _buildMobileAppBar() {
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.email ?? '';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(
          child: Text(
            "WorkNear",
            style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          children: [
            IconButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchScreen())),
                icon: const Icon(Icons.search, color: Colors.white)),
            _buildProfileMenu(userName, user),
          ],
        ),
      ],
    );
  }

  // --- MODIFIED: Removed the search bar from the desktop app bar ---
  Widget _buildDesktopAppBar() {
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.email ?? '';
    return Row(
      children: [
        const Text(
          "WorkNear",
          style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const Spacer(), // Use Spacer to push profile menu to the right
        _buildProfileMenu(userName, user),
      ],
    );
  }

  Widget _buildProfileMenu(String userName, dynamic user) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 16,
              child: user?.userMetadata?['avatar_url'] != null
                  ? ClipOval(
                      child: Image.network(
                        user!.userMetadata['avatar_url'],
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 16, color: Color(0xFF547DCD)),
                      ),
                    )
                  : const Icon(Icons.person, size: 16, color: Color(0xFF547DCD)),
            ),
            if (userName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(userName.length > 10 ? '${userName.substring(0, 10)}...' : userName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
          ],
        ),
      ),
      onSelected: (value) async {
        switch (value) {
          case 'profile':
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            break;
          case 'bookings':
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyBookingsScreen()));
            break;
          case 'settings':
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            break;
          case 'logout':
            await Supabase.instance.client.auth.signOut();
            if (mounted) Navigator.of(context).pushReplacementNamed('/login');
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
            value: 'profile',
            child: ListTile(leading: Icon(Icons.person, color: Color(0xFF547DCD)), title: Text('My Profile'), contentPadding: EdgeInsets.zero)),
        const PopupMenuItem(
            value: 'bookings',
            child:
                ListTile(leading: Icon(Icons.receipt_long, color: Color(0xFF547DCD)), title: Text('My Bookings'), contentPadding: EdgeInsets.zero)),
        const PopupMenuItem(
            value: 'settings',
            child: ListTile(leading: Icon(Icons.settings, color: Color(0xFF547DCD)), title: Text('Settings'), contentPadding: EdgeInsets.zero)),
        const PopupMenuDivider(),
        const PopupMenuItem(
            value: 'logout',
            child: ListTile(leading: Icon(Icons.logout, color: Colors.red), title: Text('Sign Out', style: TextStyle(color: Colors.red)), contentPadding: EdgeInsets.zero)),
      ],
    );
  }

  Widget _buildHeroSection(double screenWidth, bool isSmallScreen, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: isSmallScreen ? 20 : 30),
        const Text(
          'Find Your Perfect',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 28),
          textAlign: TextAlign.center,
        ),
        const Text(
          'Service Provider',
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 28),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        const Padding(
          padding: EdgeInsets.symmetric(),
          child: Text(
            'Book trusted professionals for all your service needs.\nQuality service, guaranteed satisfaction, available across India.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        ),
        SizedBox(height: isSmallScreen ? 20 : 30),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.white.withOpacity(0.12),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchScreen())),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Row(
                        children: [
                          Icon(Icons.search, size: 20),
                          SizedBox(width: 8),
                          Expanded(child: Text('What service do you need?', style: TextStyle(fontSize: 14))),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OverlayPortal(
                  controller: _overlayController,
                  overlayChildBuilder: (context) => _buildLocationSuggestionsOverlay(),
                  child: Container(
                    key: _locationFieldKey,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _locationController,
                              focusNode: _locationFocusNode,
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Enter your location",
                                isDense: true,
                              ),
                              onChanged: _onLocationChanged,
                              onTap: () {
                                if (_locationSuggestions.isNotEmpty) {
                                  setState(() => _showSuggestions = true);
                                  _overlayController.show();
                                }
                              },
                            ),
                          ),
                          _isFetching
                              ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : IconButton(
                                  icon: Icon(Icons.my_location, color: Colors.blue.shade700),
                                  onPressed: _detectLocation,
                                  tooltip: 'Use current location',
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchScreen())),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 40, vertical: isSmallScreen ? 12 : 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text("Search Services", style: TextStyle(color: Colors.white, fontSize: isSmallScreen ? 14 : 16)),
                  ),
                )
              ],
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 20 : 30),
      ],
    );
  }

  Widget _buildServicesSection(double screenWidth, bool isSmallScreen, bool isMediumScreen) {
    int crossAxisCount = 3;
    if (isMediumScreen) {
      crossAxisCount = 4;
    } else if (screenWidth > 900) {
      crossAxisCount = 5;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Popular Services", style: TextStyle(fontSize: isSmallScreen ? 22 : 26, fontWeight: FontWeight.bold)),
        SizedBox(height: isSmallScreen ? 8 : 12),
        Text("Book trusted professionals for all your needs.", style: TextStyle(fontSize: isSmallScreen ? 14 : 15, color: Colors.black54)),
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
            return _buildServiceCard(service['icon'], service['color'], service['title'], isSmallScreen);
          },
        ),
      ],
    );
  }

  // --- MODIFIED: This widget is completely redesigned for an outlined look with new icon styles ---
  Widget _buildServiceCard(IconData icon, Color color, String title, bool isSmallScreen) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ServiceDetailsScreen(serviceName: title, serviceColor: color, serviceIcon: icon,userLocation: _locationController.text,)
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 16 : 24, horizontal: isSmallScreen ? 8 : 10),
        decoration: BoxDecoration(
          color: Colors.white, // Clean white background
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200, width: 1.5), // Subtle outline
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // New icon style: Solid color background with white icon
          CircleAvatar(
            radius: isSmallScreen ? 22 : 28,
            backgroundColor: color, // Solid service color
            child: Icon(icon, size: isSmallScreen ? 22 : 28, color: Colors.white), // White icon
          ),
          SizedBox(height: isSmallScreen ? 10 : 14),
          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(fontSize: isSmallScreen ? 12 : 15, fontWeight: FontWeight.bold),
            ),
          )
        ]),
      ),
    );
  }

  Widget _buildBottomNavigationBar(bool isSmallScreen) {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            break;
          case 1:
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
            break;
          case 2:
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyBookingsScreen()));
            break;
          case 3:
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            break;
        }
      },
      selectedItemColor: const Color(0xFF547DCD),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Bookings"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}