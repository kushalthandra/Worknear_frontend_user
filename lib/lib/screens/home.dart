import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      {
        'icon': FontAwesomeIcons.broom,
        'title': 'Home Cleaning',
        'count': '1256',
        'color': Colors.teal,
      },
      {
        'icon': FontAwesomeIcons.wrench,
        'title': 'Plumbing',
        'count': '989',
        'color': Colors.blue,
      },
      {
        'icon': FontAwesomeIcons.bolt,
        'title': 'Electrical',
        'count': '867',
        'color': Colors.amber,
      },
      {
        'icon': FontAwesomeIcons.snowflake,
        'title': 'AC Repair',
        'count': '1134',
        'color': Colors.cyan,
      },
      {
        'icon': FontAwesomeIcons.spa,
        'title': 'Beauty & Spa',
        'count': '1503',
        'color': Colors.pink,
      },
      {
        'icon': FontAwesomeIcons.userNurse,
        'title': 'Massage Therapy',
        'count': '778',
        'color': Colors.deepPurple,
      },
      {
        'icon': FontAwesomeIcons.paintRoller,
        'title': 'Painting',
        'count': '645',
        'color': Colors.orange,
      },
      {
        'icon': FontAwesomeIcons.bug,
        'title': 'Pest Control',
        'count': '456',
        'color': Colors.red,
      },
      {
        'icon': FontAwesomeIcons.tools,
        'title': 'Appliance Repair',
        'count': '898',
        'color': Colors.green,
      },
      {
        'icon': FontAwesomeIcons.hammer,
        'title': 'Carpentry',
        'count': '534',
        'color': Colors.brown,
      },
      {
        'icon': FontAwesomeIcons.seedling,
        'title': 'Gardening',
        'count': '422',
        'color': Colors.lightGreen,
      },
      {
        'icon': FontAwesomeIcons.chalkboardTeacher,
        'title': 'Home Tutoring',
        'count': '1289',
        'color': Colors.indigo,
      },
      {
        'icon': FontAwesomeIcons.dumbbell,
        'title': 'Personal Training',
        'count': '987',
        'color': Colors.deepOrange,
      },
      {
        'icon': FontAwesomeIcons.utensils,
        'title': 'Catering',
        'count': '743',
        'color': Colors.lime,
      },
      {
        'icon': FontAwesomeIcons.camera,
        'title': 'Photography',
        'count': '611',
        'color': Colors.purple,
      },
      {
        'icon': FontAwesomeIcons.tshirt,
        'title': 'Laundry & Dry Cleaning',
        'count': '1002',
        'color': Colors.blueGrey,
      },
      {
        'icon': FontAwesomeIcons.shieldAlt,
        'title': 'Security Services',
        'count': '345',
        'color': Colors.black,
      },
      {
        'icon': FontAwesomeIcons.truckMoving,
        'title': 'Moving & Packing',
        'count': '567',
        'color': Colors.teal,
      },
      {
        'icon': FontAwesomeIcons.car,
        'title': 'Automotive',
        'count': '789',
        'color': Colors.blue,
      },
      {
        'icon': FontAwesomeIcons.dog,
        'title': 'Pet Care',
        'count': '234',
        'color': Colors.deepOrange,
      },
    ];

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
                    // AppBar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      child: Row(
                        children: [
                          const Text(
                            "Work Near",
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Responsive search bar
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: TextField(
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                  hintText: 'Search services...',
                                  hintStyle: const TextStyle(color: Colors.white70),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.15),
                                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, color: Color(0xFF547DCD)),
                          ),
                        ],
                      ),
                    ),
                    // Hero Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),
                          const Text(
                            'Find Your Perfect',
                            style: TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            'Service Provider',
                            style: TextStyle(
                              fontSize: 40,
                              color: Colors.orange,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Book trusted professionals for all your service needs.\nQuality service, guaranteed satisfaction, available across India.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Search fields
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 40),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        decoration: InputDecoration(
                                          hintText: 'What service do you need?',
                                          prefixIcon: const Icon(Icons.search),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        decoration: InputDecoration(
                                          hintText: 'Location',
                                          prefixIcon: const Icon(Icons.location_on),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Search Services',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Services Grid Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40),
                child: Column(
                  children: [
                    const Text(
                      'Popular Services in India',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Find trusted professionals for all your service needs across major Indian cities.\nOnly online providers are shown for instant booking.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                    const SizedBox(height: 30),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        double spacing = 24;
                        int crossAxisCount = MediaQuery.of(context).size.width > 900
                            ? 4
                            : MediaQuery.of(context).size.width > 600
                                ? 3
                                : 2;
                        double totalSpacing = spacing * (crossAxisCount - 1);
                        double itemWidth = (constraints.maxWidth - totalSpacing) / crossAxisCount;
                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: services.map((service) {
                            return SizedBox(
                              width: itemWidth,
                              child: _buildServiceCard(
                                icon: service['icon'] as IconData,
                                color: service['color'] as Color,
                                title: service['title'] as String,
                                subtitle: '${service['count']} services',
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 5,
      margin: const EdgeInsets.all(4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.12),
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
              radius: 32,
              backgroundColor: color.withOpacity(0.18),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(height: 7),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
