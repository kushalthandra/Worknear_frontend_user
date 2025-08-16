import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = false;

  // Sample booking data - replace with actual API calls
  final List<Map<String, dynamic>> allBookings = [
    {
      'id': 'BK1704567890123',
      'serviceName': 'Home Deep Cleaning',
      'providerName': 'John Smith',
      'providerImage': 'https://via.placeholder.com/60',
      'providerRating': 4.8,
      'date': DateTime.now().add(const Duration(days: 2)),
      'timeSlot': '10:00 AM - 12:00 PM',
      'status': 'confirmed',
      'price': 599,
      'address': '123 MG Road, Bengaluru',
      'icon': FontAwesomeIcons.broom,
      'color': Colors.teal,
      'services': ['Deep Cleaning', 'Kitchen Cleaning'],
    },
    {
      'id': 'BK1704567890124',
      'serviceName': 'AC Repair',
      'providerName': 'Sarah Johnson',
      'providerImage': 'https://via.placeholder.com/60',
      'providerRating': 4.9,
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'timeSlot': '2:00 PM - 3:00 PM',
      'status': 'completed',
      'price': 450,
      'address': '456 Brigade Road, Bengaluru',
      'icon': FontAwesomeIcons.snowflake,
      'color': Colors.cyan,
      'services': ['AC Repair'],
    },
    {
      'id': 'BK1704567890125',
      'serviceName': 'Plumbing',
      'providerName': 'Mike Wilson',
      'providerImage': 'https://via.placeholder.com/60',
      'providerRating': 4.7,
      'date': DateTime.now().add(const Duration(days: 5)),
      'timeSlot': '9:00 AM - 10:00 AM',
      'status': 'confirmed',
      'price': 299,
      'address': '789 Koramangala, Bengaluru',
      'icon': FontAwesomeIcons.wrench,
      'color': Colors.blue,
      'services': ['Pipe Repair'],
    },
  ];

  List<Map<String, dynamic>> upcomingBookings = [];
  List<Map<String, dynamic>> pastBookings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadBookings() {
    setState(() {
      upcomingBookings = allBookings.where((booking) {
        return booking['status'] == 'confirmed' || booking['status'] == 'in_progress';
      }).toList();
      
      pastBookings = allBookings.where((booking) {
        return booking['status'] == 'completed' || booking['status'] == 'cancelled';
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: const Color(0xFF547DCD),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              Future.delayed(const Duration(seconds: 1), () {
                setState(() {
                  isLoading = false;
                });
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsHeader(isSmallScreen),
          _buildTabBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAllBookingsTab(isSmallScreen),
                      _buildUpcomingTab(isSmallScreen),
                      _buildPastTab(isSmallScreen),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/home');
        },
        backgroundColor: const Color(0xFF547DCD),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Book Service'),
      ),
    );
  }

  Widget _buildStatsHeader(bool isSmallScreen) {
    final totalBookings = allBookings.length;
    final completedBookings = allBookings.where((b) => b['status'] == 'completed').length;
    final upcomingCount = upcomingBookings.length;

    return Container(
      color: const Color(0xFF547DCD),
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total',
              totalBookings.toString(),
              Icons.receipt_long,
              isSmallScreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Upcoming',
              upcomingCount.toString(),
              Icons.upcoming,
              isSmallScreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Completed',
              completedBookings.toString(),
              Icons.check_circle,
              isSmallScreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: isSmallScreen ? 20 : 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: Colors.white70,
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
          Tab(text: 'All'),
          Tab(text: 'Upcoming'),
          Tab(text: 'Past'),
        ],
      ),
    );
  }

  Widget _buildAllBookingsTab(bool isSmallScreen) {
    if (allBookings.isEmpty) {
      return _buildEmptyState('No bookings yet', 'Book your first service to get started!');
    }

    return ListView.builder(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      itemCount: allBookings.length,
      itemBuilder: (context, index) {
        return _buildBookingCard(allBookings[index], isSmallScreen);
      },
    );
  }

  Widget _buildUpcomingTab(bool isSmallScreen) {
    if (upcomingBookings.isEmpty) {
      return _buildEmptyState('No upcoming bookings', 'All your future bookings will appear here.');
    }

    return ListView.builder(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      itemCount: upcomingBookings.length,
      itemBuilder: (context, index) {
        return _buildBookingCard(upcomingBookings[index], isSmallScreen);
      },
    );
  }

  Widget _buildPastTab(bool isSmallScreen) {
    if (pastBookings.isEmpty) {
      return _buildEmptyState('No past bookings', 'Your completed and cancelled bookings will appear here.');
    }

    return ListView.builder(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      itemCount: pastBookings.length,
      itemBuilder: (context, index) {
        return _buildBookingCard(pastBookings[index], isSmallScreen);
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, bool isSmallScreen) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showBookingDetails(booking),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Service Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: booking['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      booking['icon'],
                      color: booking['color'],
                      size: isSmallScreen ? 20 : 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Service Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking['serviceName'],
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Booking ID: ${booking['id']}',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  _buildStatusBadge(booking['status'], isSmallScreen),
                ],
              ),
              const SizedBox(height: 16),
              // Provider Info
              Row(
                children: [
                  CircleAvatar(
                    radius: isSmallScreen ? 20 : 25,
                    backgroundImage: NetworkImage(booking['providerImage']),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking['providerName'],
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: isSmallScreen ? 14 : 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${booking['providerRating']}',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${booking['price']}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: booking['color'],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Date, Time, Location
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: isSmallScreen ? 16 : 18,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(booking['date']),
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: isSmallScreen ? 16 : 18,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    booking['timeSlot'],
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: isSmallScreen ? 16 : 18,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      booking['address'],
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Action Buttons
              _buildActionButtons(booking, isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isSmallScreen) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status) {
      case 'confirmed':
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        displayText = 'Confirmed';
        break;
      case 'completed':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        displayText = 'Completed';
        break;
      case 'cancelled':
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        displayText = 'Cancelled';
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        displayText = 'Unknown';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 12,
        vertical: isSmallScreen ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: isSmallScreen ? 11 : 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> booking, bool isSmallScreen) {
    final status = booking['status'];
    
    if (status == 'confirmed') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _cancelBooking(booking),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                foregroundColor: Colors.red,
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _rescheduleBooking(booking),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF547DCD),
                foregroundColor: Colors.white,
              ),
              child: const Text('Reschedule'),
            ),
          ),
        ],
      );
    } else if (status == 'completed') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _bookAgain(booking),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF547DCD)),
                foregroundColor: const Color(0xFF547DCD),
              ),
              child: const Text('Book Again'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _rateService(booking),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF547DCD),
                foregroundColor: Colors.white,
              ),
              child: const Text('Rate Service'),
            ),
          ),
        ],
      );
    } else if (status == 'in_progress') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _trackService(booking),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.location_on),
          label: const Text('Track Service'),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final bookingDate = DateTime(date.year, date.month, date.day);

    if (bookingDate == today) {
      return 'Today';
    } else if (bookingDate == tomorrow) {
      return 'Tomorrow';
    } else if (bookingDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Booking details content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Booking Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildDetailRow('Service', booking['serviceName']),
                      _buildDetailRow('Provider', booking['providerName']),
                      _buildDetailRow('Date', _formatDate(booking['date'])),
                      _buildDetailRow('Time', booking['timeSlot']),
                      _buildDetailRow('Address', booking['address']),
                      _buildDetailRow('Total', '₹${booking['price']}'),
                      _buildDetailRow('Status', booking['status']),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _cancelBooking(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text('Are you sure you want to cancel your ${booking['serviceName']} booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking cancelled successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _rescheduleBooking(Map<String, dynamic> booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reschedule feature coming soon')),
    );
  }

  void _bookAgain(Map<String, dynamic> booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Redirecting to book again...')),
    );
  }

  void _rateService(Map<String, dynamic> booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rating feature coming soon')),
    );
  }

  void _trackService(Map<String, dynamic> booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tracking feature coming soon')),
    );
  }
}