import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  late TabController _tabController;
  
  String selectedCategory = 'All';
  bool isLoading = false;
  
  final List<String> categories = [
    'All',
    'Cleaning',
    'Plumbing',
    'Electrical',
    'Beauty',
    'Automotive',
    'Home Repair',
    'Catering',
  ];

  final List<Map<String, dynamic>> allServices = [
    {
      'name': 'Home Deep Cleaning',
      'category': 'Cleaning',
      'icon': FontAwesomeIcons.broom,
      'color': Colors.teal,
      'rating': 4.8,
      'reviews': 124,
      'price': 'From ₹299',
      'providers': 45,
      'popular': true,
    },
    {
      'name': 'Kitchen Pipe Repair',
      'category': 'Plumbing',
      'icon': FontAwesomeIcons.wrench,
      'color': Colors.blue,
      'rating': 4.7,
      'reviews': 89,
      'price': 'From ₹199',
      'providers': 32,
      'popular': false,
    },
    {
      'name': 'AC Installation',
      'category': 'Electrical',
      'icon': FontAwesomeIcons.snowflake,
      'color': Colors.cyan,
      'rating': 4.9,
      'reviews': 156,
      'price': 'From ₹599',
      'providers': 28,
      'popular': true,
    },
    {
      'name': 'Facial Treatment',
      'category': 'Beauty',
      'icon': FontAwesomeIcons.spa,
      'color': Colors.pink,
      'rating': 4.6,
      'reviews': 67,
      'price': 'From ₹399',
      'providers': 19,
      'popular': false,
    },
    {
      'name': 'Car Washing',
      'category': 'Automotive',
      'icon': FontAwesomeIcons.car,
      'color': Colors.deepPurple,
      'rating': 4.5,
      'reviews': 203,
      'price': 'From ₹149',
      'providers': 54,
      'popular': true,
    },
    {
      'name': 'Wall Painting',
      'category': 'Home Repair',
      'icon': FontAwesomeIcons.paintRoller,
      'color': Colors.orange,
      'rating': 4.8,
      'reviews': 91,
      'price': 'From ₹99/sqft',
      'providers': 37,
      'popular': false,
    },
  ];

  List<Map<String, dynamic>> filteredServices = [];
  List<String> recentSearches = [
    'AC Repair',
    'House Cleaning',
    'Plumber near me',
    'Car service',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    filteredServices = allServices;
    _locationController.text = 'Bengaluru, Karnataka';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _filterServices(String query) {
    setState(() {
      if (query.isEmpty && selectedCategory == 'All') {
        filteredServices = allServices;
      } else {
        filteredServices = allServices.where((service) {
          final matchesQuery = query.isEmpty || 
              service['name'].toString().toLowerCase().contains(query.toLowerCase());
          final matchesCategory = selectedCategory == 'All' || 
              service['category'] == selectedCategory;
          
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
        gradient: LinearGradient(
          colors: [Color(0xFF00AF9A), Color(0xFF547DCD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // App Bar
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 20,
              vertical: isSmallScreen ? 12 : 16,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Search Services',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  onPressed: _showFilterDialog,
                ),
              ],
            ),
          ),
          // Search Fields
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 20,
              vertical: isSmallScreen ? 12 : 16,
            ),
            child: Column(
              children: [
                // Service Search
                TextField(
                  controller: _searchController,
                  onChanged: _filterServices,
                  decoration: InputDecoration(
                    hintText: 'Search for services...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterServices('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                const SizedBox(height: 12),
                // Location Search
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: 'Location',
                    prefixIcon: const Icon(Icons.location_on),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: () {
                        // Get current location
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
    if (_searchController.text.isEmpty) {
      return _buildSearchSuggestions(isSmallScreen);
    }
    
    return _buildSearchResults(isSmallScreen);
  }

  Widget _buildSearchSuggestions(bool isSmallScreen) {
    final popularServices = allServices.where((s) => s['popular'] == true).toList();
    
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recent Searches
            if (recentSearches.isNotEmpty) ...[
              const Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: recentSearches.map((search) {
                  return GestureDetector(
                    onTap: () {
                      _searchController.text = search;
                      _filterServices(search);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.history, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(search),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
            // Popular Services
            const Text(
              'Popular Services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
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
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No services found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Results count
            Text(
              '${filteredServices.length} services found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            // Services list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredServices.length,
              itemBuilder: (context, index) {
                return _buildServiceListItem(filteredServices[index], isSmallScreen);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceListItem(Map<String, dynamic> service, bool isSmallScreen) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to service details
        },
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Row(
            children: [
              // Service Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: service['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  service['icon'],
                  color: service['color'],
                  size: isSmallScreen ? 24 : 28,
                ),
              ),
              const SizedBox(width: 12),
              // Service Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            service['name'],
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (service['popular']) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Popular',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 10 : 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: isSmallScreen ? 14 : 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${service['rating']} (${service['reviews']})',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.people,
                          color: Colors.grey[600],
                          size: isSmallScreen ? 14 : 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${service['providers']} providers',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      service['price'],
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: service['color'],
                      ),
                    ),
                  ],
                ),
              ),
              // Action Button
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  // Navigate to service details
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesTab(bool isSmallScreen) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Browse by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isSmallScreen ? 2 : 3,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: categories.length - 1, // Exclude 'All'
              itemBuilder: (context, index) {
                final category = categories[index + 1];
                final categoryServices = allServices
                    .where((s) => s['category'] == category)
                    .length;
                
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                        _tabController.animateTo(0);
                      });
                      _filterServices(_searchController.text);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getCategoryIcon(category),
                            size: isSmallScreen ? 32 : 40,
                            color: _getCategoryColor(category),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$categoryServices services',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 11 : 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesTab(bool isSmallScreen) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Mark services as favorite to see them here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                    setState(() {
                      selectedCategory = category;
                    });
                    _filterServices(_searchController.text);
                    Navigator.pop(context);
                  },
                  selectedColor: const Color(0xFF547DCD).withOpacity(0.2),
                  checkmarkColor: const Color(0xFF547DCD),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedCategory = 'All';
                  });
                  _filterServices(_searchController.text);
                  Navigator.pop(context);
                },
                child: const Text('Clear Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Cleaning':
        return FontAwesomeIcons.broom;
      case 'Plumbing':
        return FontAwesomeIcons.wrench;
      case 'Electrical':
        return FontAwesomeIcons.bolt;
      case 'Beauty':
        return FontAwesomeIcons.spa;
      case 'Automotive':
        return FontAwesomeIcons.car;
      case 'Home Repair':
        return FontAwesomeIcons.paintRoller;
      case 'Catering':
        return FontAwesomeIcons.utensils;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Cleaning':
        return Colors.teal;
      case 'Plumbing':
        return Colors.blue;
      case 'Electrical':
        return Colors.amber;
      case 'Beauty':
        return Colors.pink;
      case 'Automotive':
        return Colors.deepPurple;
      case 'Home Repair':
        return Colors.orange;
      case 'Catering':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}