import 'package:flutter/material.dart';
import 'booking_screen.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final String serviceName;
  final IconData serviceIcon;
  final Color serviceColor;

  const ServiceDetailsScreen({
    super.key,
    required this.serviceName,
    required this.serviceIcon,
    required this.serviceColor,
  });

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = false;

  // Sample data - replace with actual API calls
  final List<Map<String, dynamic>> serviceProviders = [
    {
      'name': 'John Smith',
      'rating': 4.8,
      'reviews': 124,
      'price': 'Starting from ₹299',
      'experience': '5+ years',
      'verified': true,
      'location': 'Koramangala, Bangalore',
      'image': 'https://via.placeholder.com/60',
      'specialties': ['Quick Service', 'Quality Work', 'Affordable']
    },
    {
      'name': 'Sarah Johnson',
      'rating': 4.9,
      'reviews': 89,
      'price': 'Starting from ₹399',
      'experience': '3+ years',
      'verified': true,
      'location': 'Indiranagar, Bangalore',
      'image': 'https://via.placeholder.com/60',
      'specialties': ['Expert Service', 'Same Day', 'Professional']
    },
    {
      'name': 'Mike Wilson',
      'rating': 4.7,
      'reviews': 156,
      'price': 'Starting from ₹249',
      'experience': '7+ years',
      'verified': true,
      'location': 'Whitefield, Bangalore',
      'image': 'https://via.placeholder.com/60',
      'specialties': ['Experienced', 'Reliable', 'Budget Friendly']
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            _buildHeader(isSmallScreen),
            _buildTabBar(isSmallScreen),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildProvidersTab(isSmallScreen),
                        _buildReviewsTab(isSmallScreen),
                        _buildAboutTab(isSmallScreen),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [widget.serviceColor.withOpacity(0.8), widget.serviceColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // AppBar
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
                Expanded(
                  child: Text(
                    widget.serviceName,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 20 : 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // Service Info
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 20,
              vertical: isSmallScreen ? 16 : 20,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: isSmallScreen ? 30 : 40,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Icon(
                    widget.serviceIcon,
                    color: Colors.white,
                    size: isSmallScreen ? 30 : 40,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.serviceName,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 22 : 26,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${serviceProviders.length} providers available',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Starting ₹249',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 12 : 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Same Day',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 12 : 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isSmallScreen) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: widget.serviceColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: widget.serviceColor,
        tabs: const [
          Tab(text: 'Providers'),
          Tab(text: 'Reviews'),
          Tab(text: 'About'),
        ],
      ),
    );
  }

  Widget _buildProvidersTab(bool isSmallScreen) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Filter Bar
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search providers...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    // Show filter dialog
                  },
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.serviceColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          // Providers List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: serviceProviders.length,
            itemBuilder: (context, index) {
              final provider = serviceProviders[index];
              return _buildProviderCard(provider, isSmallScreen);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(Map<String, dynamic> provider, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 20,
        vertical: 8,
      ),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: isSmallScreen ? 25 : 30,
                    backgroundImage: NetworkImage(provider['image']),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              provider['name'],
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (provider['verified']) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.verified,
                                color: Colors.green,
                                size: isSmallScreen ? 16 : 18,
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
                              '${provider['rating']} (${provider['reviews']} reviews)',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          provider['location'],
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        provider['price'],
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: widget.serviceColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider['experience'],
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: provider['specialties'].map<Widget>((specialty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.serviceColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      specialty,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 11 : 12,
                        color: widget.serviceColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // View profile
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: widget.serviceColor),
                        foregroundColor: widget.serviceColor,
                      ),
                      child: const Text('View Profile'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to booking screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingScreen(
                              serviceName: widget.serviceName,
                              providerName: provider['name'],
                              providerImage: provider['image'],
                              rating: provider['rating'],
                              price: provider['price'],
                              serviceColor: widget.serviceColor,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.serviceColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Book Now'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsTab(bool isSmallScreen) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Reviews Coming Soon',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Customer reviews and ratings will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab(bool isSmallScreen) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About ${widget.serviceName}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Professional service providers offering high-quality solutions for all your needs. Our verified professionals are experienced, reliable, and committed to customer satisfaction.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'What\'s Included',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...[
              'Professional assessment',
              'Quality materials and tools',
              'Experienced technicians',
              'Post-service cleanup',
              '30-day service guarantee',
            ].map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: widget.serviceColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(item),
                ],
              ),
            )),
            const SizedBox(height: 24),
            const Text(
              'How it Works',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...[
              {'step': '1', 'title': 'Book Service', 'desc': 'Choose your preferred provider and time slot'},
              {'step': '2', 'title': 'Confirmation', 'desc': 'Receive booking confirmation and provider details'},
              {'step': '3', 'title': 'Service Delivery', 'desc': 'Professional arrives at scheduled time'},
              {'step': '4', 'title': 'Payment & Review', 'desc': 'Pay securely and rate your experience'},
            ].map((step) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: widget.serviceColor,
                    child: Text(
                      step['step']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step['desc']!,
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
            )),
          ],
        ),
      ),
    );
  }
}