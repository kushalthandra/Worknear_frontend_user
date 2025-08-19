import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

class ServiceDetailsScreen extends StatefulWidget {
  final String serviceName;
  final IconData serviceIcon;
  final Color serviceColor;
  // --- NEW: Added userLocation to the constructor ---
  final String userLocation;

  const ServiceDetailsScreen({
    super.key,
    required this.serviceName,
    required this.serviceIcon,
    required this.serviceColor,
    required this.userLocation, // It is now required
  });

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

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
    // --- NEW: Fetching the current Supabase user ---
    final user = Supabase.instance.client.auth.currentUser;
    // Extract user details with fallbacks
    final userName = user?.userMetadata?['full_name'] ?? user?.email ?? 'Your Profile Name';
    final avatarUrl = user?.userMetadata?['avatar_url'];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Create Request'),
        icon: const Icon(Icons.add),
        backgroundColor: widget.serviceColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            // --- MODIFIED: Passing dynamic data to the profile header ---
            _buildProfileHeader(
              userName: userName,
              avatarUrl: avatarUrl,
              location: widget.userLocation,
            ),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRequestListPlaceholder('Incoming Requests', Icons.inbox_outlined),
                  _buildRequestListPlaceholder('Outgoing Requests', Icons.outbox_outlined),
                  _buildRequestListPlaceholder('Pending Requests', Icons.pending_outlined),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.serviceColor,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Hero(
            tag: 'service-icon-${widget.serviceName}',
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Icon(
                widget.serviceIcon,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.serviceName,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // --- MODIFIED: This widget now accepts and displays dynamic data ---
  Widget _buildProfileHeader({
    required String userName,
    String? avatarUrl,
    required String location,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      color: Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade200,
            // Display network image if URL exists, otherwise show a fallback icon
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null
                ? const Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.grey,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName, // Display dynamic user name
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  location, // Display dynamic location
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
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
        labelColor: widget.serviceColor,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: widget.serviceColor,
        indicatorWeight: 3.0,
        tabs: const [
          Tab(text: 'Incoming'),
          Tab(text: 'Outgoing'),
          Tab(text: 'Pending'),
        ],
      ),
    );
  }

  Widget _buildRequestListPlaceholder(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No $message',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your requests will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}