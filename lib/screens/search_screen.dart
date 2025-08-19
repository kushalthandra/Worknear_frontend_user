import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';

// --- FIX: Added missing import for navigation to work ---
import 'service_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  final TextEditingController _locationController = TextEditingController();
  final FocusNode _locationFocusNode = FocusNode();
  bool _isFetchingLocation = false;
  List<Map<String, String>> _locationSuggestions = [];
  bool _showSuggestions = false;
  Timer? _debounceTimer;
  final OverlayPortalController _overlayController = OverlayPortalController();
  final GlobalKey _locationFieldKey = GlobalKey();

  String selectedCategory = 'All';
  bool isLoading = false;

  final List<String> categories = [
    'All', 'Cleaning', 'Plumbing', 'Electrical', 'Beauty', 'Automotive', 'Home Repair', 'Catering',
  ];

  final List<Map<String, dynamic>> allServices = [
    {'name': 'Home Deep Cleaning', 'category': 'Cleaning', 'icon': FontAwesomeIcons.broom, 'color': Colors.teal, 'rating': 4.8, 'reviews': 124, 'price': 'From ₹2,499', 'providers': 45, 'popular': true,},
    {'name': 'Kitchen Pipe Repair', 'category': 'Plumbing', 'icon': FontAwesomeIcons.wrench, 'color': Colors.blue, 'rating': 4.7, 'reviews': 89, 'price': 'From ₹499', 'providers': 32, 'popular': false,},
    {'name': 'AC Service & Repair', 'category': 'Electrical', 'icon': FontAwesomeIcons.snowflake, 'color': Colors.cyan, 'rating': 4.9, 'reviews': 215, 'price': 'From ₹399', 'providers': 42, 'popular': true,},
    {'name': 'Facial & Spa Treatment', 'category': 'Beauty', 'icon': FontAwesomeIcons.spa, 'color': Colors.pink, 'rating': 4.6, 'reviews': 67, 'price': 'From ₹899', 'providers': 19, 'popular': false,},
    {'name': 'Car Washing & Detailing', 'category': 'Automotive', 'icon': FontAwesomeIcons.car, 'color': Colors.deepPurple, 'rating': 4.5, 'reviews': 203, 'price': 'From ₹549', 'providers': 54, 'popular': true,},
    {'name': 'Interior Wall Painting', 'category': 'Home Repair', 'icon': FontAwesomeIcons.paintRoller, 'color': Colors.orange, 'rating': 4.8, 'reviews': 91, 'price': 'From ₹20/sqft', 'providers': 37, 'popular': false,},
    {'name': 'General Pest Control', 'category': 'Home Repair', 'icon': FontAwesomeIcons.bug, 'color': Colors.red, 'rating': 4.7, 'reviews': 150, 'price': 'From ₹799', 'providers': 29, 'popular': true,},
    {'name': 'Event & Party Catering', 'category': 'Catering', 'icon': FontAwesomeIcons.utensils, 'color': Colors.green, 'rating': 4.9, 'reviews': 88, 'price': 'From ₹499/plate', 'providers': 22, 'popular': false,},
    {'name': 'Switch & Socket Repair', 'category': 'Electrical', 'icon': FontAwesomeIcons.bolt, 'color': Colors.amber, 'rating': 4.6, 'reviews': 180, 'price': 'From ₹149', 'providers': 61, 'popular': false,},
    {'name': 'AC Installation & Uninstall', 'category': 'Electrical', 'icon': FontAwesomeIcons.snowflake, 'color': Colors.cyan, 'rating': 4.8, 'reviews': 156, 'price': 'From ₹599', 'providers': 28, 'popular': false,},
  ];

  List<Map<String, dynamic>> filteredServices = [];
  List<String> recentSearches = ['AC Repair', 'House Cleaning', 'Plumber near me', 'Car service',];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    filteredServices = allServices;
    _locationController.text = 'Visakhapatnam, Andhra Pradesh';

    _locationFocusNode.addListener(() {
      if (!_locationFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            setState(() => _showSuggestions = false);
            _overlayController.hide();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _debounceTimer?.cancel();
    _locationController.dispose();
    _locationFocusNode.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _locationController.text = "Location permission denied";
          setState(() => _isFetchingLocation = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _locationController.text = "Location permission permanently denied";
        setState(() => _isFetchingLocation = false);
        return;
      }
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationController.text = "Location services disabled";
        setState(() => _isFetchingLocation = false);
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
    setState(() => _isFetchingLocation = false);
  }

  void _onLocationChanged(String query) {
    _debounceTimer?.cancel();
    if (query.length < 3) {
      setState(() => _showSuggestions = false);
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
      final response = await http.get(Uri.parse(url), headers: {'User-Agent': 'worknear-flutter-app/1.0'});
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final suggestions = data.map<Map<String, String>>((item) {
          final address = item['address'] ?? {};
          final city = address['city'] ?? address['town'] ?? address['village'] ?? '';
          final state = address['state'] ?? '';
          String displayName = item['display_name'] ?? '';
          String shortName = (city.isNotEmpty && state.isNotEmpty) ? '$city, $state' : displayName.split(',').take(2).join(',');
          return {'short': shortName, 'full': displayName,};
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
        if (mounted) _overlayController.hide();
      }
    } catch (e) {
      if (mounted) _overlayController.hide();
    }
  }

  // --- FIX: This widget has been corrected to properly position the overlay ---
  Widget _buildLocationSuggestionsOverlay() {
    final RenderBox? renderBox = _locationFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return const SizedBox.shrink();
    
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenHeight = MediaQuery.of(context).size.height;

    final dropdownTop = position.dy + size.height + 5; // Position below the text field
    final maxHeight = screenHeight - dropdownTop - 20; // Ensure it doesn't go off-screen

    return Positioned(
      top: dropdownTop,
      left: position.dx,
      width: size.width,
      child: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: BoxConstraints(maxHeight: maxHeight > 220 ? 220 : maxHeight),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: _locationSuggestions.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200,),
            itemBuilder: (context, index) {
              final suggestion = _locationSuggestions[index];
              return InkWell(
                onTap: () {
                  _locationController.text = suggestion['short']!;
                  setState(() => _showSuggestions = false);
                  _overlayController.hide();
                  _locationFocusNode.unfocus();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(suggestion['short']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      if (suggestion['full']!.isNotEmpty && suggestion['full'] != suggestion['short'])
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            suggestion['full']!,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600,),
                            maxLines: 1,
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

  void _filterServices(String query) {
    setState(() {
      if (query.isEmpty && selectedCategory == 'All') {
        filteredServices = allServices;
      } else {
        filteredServices = allServices.where((service) {
          final matchesQuery = query.isEmpty || service['name'].toString().toLowerCase().contains(query.toLowerCase());
          final matchesCategory = selectedCategory == 'All' || service['category'] == selectedCategory;
          return matchesQuery && matchesCategory;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(isSmallScreen),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSearchTab(isSmallScreen),
                  _buildCategoriesTab(isSmallScreen),
                  _buildFavoritesTab(isSmallScreen),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(bool isSmallScreen) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF00AF9A), Color(0xFF547DCD)], begin: Alignment.topLeft, end: Alignment.bottomRight,),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 20, vertical: isSmallScreen ? 8 : 12,),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).pop(),),
                const SizedBox(width: 8),
                const Expanded(child: Text('Search Services', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),),
                IconButton(icon: const Icon(Icons.filter_list, color: Colors.white), onPressed: _showFilterDialog,),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(isSmallScreen ? 16 : 20, 0, isSmallScreen ? 16 : 20, isSmallScreen ? 16 : 20),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _filterServices,
                  decoration: InputDecoration(
                    hintText: 'Search for services...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                      _searchController.clear();
                      _filterServices('');
                    },) : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none,),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                const SizedBox(height: 12),
                
                OverlayPortal(
                  controller: _overlayController,
                  overlayChildBuilder: (context) => _buildLocationSuggestionsOverlay(),
                  child: TextField(
                    key: _locationFieldKey, // Key is now on the TextField itself
                    controller: _locationController,
                    focusNode: _locationFocusNode,
                    onChanged: _onLocationChanged,
                    onTap: () {
                      if (_locationSuggestions.isNotEmpty) {
                        setState(() => _showSuggestions = true);
                        _overlayController.show();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Location',
                      prefixIcon: const Icon(Icons.location_on),
                      suffixIcon: _isFetchingLocation 
                        ? const Padding(padding: EdgeInsets.all(12.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF547DCD),)),)
                        : IconButton(icon: const Icon(Icons.my_location), onPressed: _detectLocation,),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none,),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF547DCD),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFF547DCD),
        tabs: const [
          Tab(icon: Icon(Icons.search), text: 'Search'),
          Tab(icon: Icon(Icons.category), text: 'Categories'),
          Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
        ],
      ),
    );
  }

  Widget _buildSearchTab(bool isSmallScreen) {
    if (_searchController.text.isEmpty && selectedCategory == 'All') {
      return _buildSearchSuggestions(isSmallScreen);
    }
    return _buildSearchResults(isSmallScreen);
  }

  Widget _buildSearchSuggestions(bool isSmallScreen) {
    final popularServices = allServices.where((s) => s['popular'] == true).toList();
    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recentSearches.isNotEmpty) ...[
            const Text('Recent Searches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: recentSearches.map((search) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = search;
                    _filterServices(search);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8,),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.history, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(search),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
          const Text('Popular Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: popularServices.length,
            itemBuilder: (context, index) {
              return _buildServiceListItem(popularServices[index], isSmallScreen);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(bool isSmallScreen) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (filteredServices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400],),
            const SizedBox(height: 16),
            Text('No services found', style: TextStyle(fontSize: 18, color: Colors.grey[600],),),
            const SizedBox(height: 8),
            Text('Try a different keyword or category', style: TextStyle(fontSize: 14, color: Colors.grey[500],),),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      itemCount: filteredServices.length,
      itemBuilder: (context, index) {
        return _buildServiceListItem(filteredServices[index], isSmallScreen);
      },
    );
  }

  Widget _buildServiceListItem(Map<String, dynamic> service, bool isSmallScreen) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ServiceDetailsScreen(
                serviceName: service['name'],
                serviceColor: service['color'],
                serviceIcon: service['icon'],
                userLocation: _locationController.text,
              ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: service['color'].withOpacity(0.1), borderRadius: BorderRadius.circular(10),),
                child: Icon(service['icon'], color: service['color'], size: isSmallScreen ? 24 : 28,),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service['name'], style: TextStyle(fontSize: isSmallScreen ? 14 : 16, fontWeight: FontWeight.bold,),),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: isSmallScreen ? 14 : 16,),
                        const SizedBox(width: 4),
                        Text('${service['rating']} (${service['reviews']} reviews)', style: TextStyle(fontSize: isSmallScreen ? 12 : 14, color: Colors.grey[600],),),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(service['price'], style: TextStyle(fontSize: isSmallScreen ? 14 : 16, fontWeight: FontWeight.bold, color: service['color'],),),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesTab(bool isSmallScreen) {
    return GridView.builder(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: isSmallScreen ? 2 : 3, childAspectRatio: 1.2, crossAxisSpacing: 12, mainAxisSpacing: 12,),
      itemCount: categories.length - 1,
      itemBuilder: (context, index) {
        final category = categories[index + 1];
        final categoryServices = allServices.where((s) => s['category'] == category).length;
        return Card(
          elevation: 2,
          shadowColor: Colors.grey.withOpacity(0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                selectedCategory = category;
                _tabController.animateTo(0);
                _searchController.clear();
              });
              _filterServices('');
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_getCategoryIcon(category), size: isSmallScreen ? 32 : 40, color: _getCategoryColor(category),),
                  const SizedBox(height: 8),
                  Text(category, style: TextStyle(fontSize: isSmallScreen ? 14 : 16, fontWeight: FontWeight.w600,), textAlign: TextAlign.center,),
                  const SizedBox(height: 4),
                  Text('$categoryServices services', style: TextStyle(fontSize: isSmallScreen ? 11 : 12, color: Colors.grey[600],),),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoritesTab(bool isSmallScreen) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64, color: Colors.grey,),
          SizedBox(height: 16),
          Text('No favorites yet', style: TextStyle(fontSize: 18, color: Colors.grey,),),
          SizedBox(height: 8),
          Text('Mark services as favorite to see them here', style: TextStyle(fontSize: 14, color: Colors.grey,),),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20)),),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
            const SizedBox(height: 16),
            const Text('Category'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: categories.map((category) {
                final isSelected = selectedCategory == category;
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() { selectedCategory = category; });
                    _filterServices(_searchController.text);
                    Navigator.pop(context);
                  },
                  selectedColor: const Color(0xFF547DCD).withOpacity(0.2),
                  checkmarkColor: const Color(0xFF547DCD),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // --- FIX: Added a default case to prevent crashes ---
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Cleaning': return FontAwesomeIcons.broom;
      case 'Plumbing': return FontAwesomeIcons.wrench;
      case 'Electrical': return FontAwesomeIcons.bolt;
      case 'Beauty': return FontAwesomeIcons.spa;
      case 'Automotive': return FontAwesomeIcons.car;
      case 'Home Repair': return FontAwesomeIcons.paintRoller;
      case 'Catering': return FontAwesomeIcons.utensils;
      default: return Icons.category;
    }
  }

  // --- FIX: Added a default case to prevent crashes ---
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Cleaning': return Colors.teal;
      case 'Plumbing': return Colors.blue;
      case 'Electrical': return Colors.amber;
      case 'Beauty': return Colors.pink;
      case 'Automotive': return Colors.deepPurple;
      case 'Home Repair': return Colors.orange;
      case 'Catering': return Colors.green;
      default: return Colors.grey;
    }
  }
}