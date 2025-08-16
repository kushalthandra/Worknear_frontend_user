import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingScreen extends StatefulWidget {
  final String serviceName;
  final String providerName;
  final String providerImage;
  final double rating;
  final String price;
  final Color serviceColor;

  const BookingScreen({
    super.key,
    required this.serviceName,
    required this.providerName,
    required this.providerImage,
    required this.rating,
    required this.price,
    required this.serviceColor,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  int currentStep = 0;
  
  // Form controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Booking details
  DateTime? selectedDate;
  String selectedTimeSlot = '';
  List<String> selectedServices = [];
  
  // Available time slots
  final List<String> timeSlots = [
    '9:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '12:00 PM - 1:00 PM',
    '2:00 PM - 3:00 PM',
    '3:00 PM - 4:00 PM',
    '4:00 PM - 5:00 PM',
    '5:00 PM - 6:00 PM',
  ];
  
  // Service options
  final List<Map<String, dynamic>> serviceOptions = [
    {'name': 'Basic Service', 'price': 299, 'duration': '1 hour'},
    {'name': 'Premium Service', 'price': 499, 'duration': '2 hours'},
    {'name': 'Deep Service', 'price': 699, 'duration': '3 hours'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _nameController.text = user.userMetadata?['name'] ?? '';
      _phoneController.text = user.userMetadata?['phone'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Book Service'),
        backgroundColor: widget.serviceColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildProviderHeader(isSmallScreen),
          Expanded(
            child: _buildStepperContent(isSmallScreen),
          ),
          _buildBottomBar(isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildProviderHeader(bool isSmallScreen) {
    return Container(
      color: widget.serviceColor,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: isSmallScreen ? 25 : 30,
            backgroundImage: NetworkImage(widget.providerImage),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.providerName,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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
                      '${widget.rating}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      widget.serviceName,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.price,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperContent(bool isSmallScreen) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: widget.serviceColor,
        ),
      ),
      child: Stepper(
        currentStep: currentStep,
        onStepTapped: (step) {
          setState(() {
            currentStep = step;
          });
        },
        controlsBuilder: (context, details) {
          return Row(
            children: [
              if (details.onStepContinue != null)
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.serviceColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(currentStep == 2 ? 'Book Now' : 'Next'),
                ),
              const SizedBox(width: 8),
              if (details.onStepCancel != null)
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Back'),
                ),
            ],
          );
        },
        steps: [
          Step(
            title: const Text('Select Date & Time'),
            content: _buildDateTimeStep(isSmallScreen),
            isActive: currentStep >= 0,
          ),
          Step(
            title: const Text('Service Details'),
            content: _buildServiceDetailsStep(isSmallScreen),
            isActive: currentStep >= 1,
          ),
          Step(
            title: const Text('Contact Information'),
            content: _buildContactInfoStep(isSmallScreen),
            isActive: currentStep >= 2,
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeStep(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Date',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Card(
          child: CalendarDatePicker(
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 30)),
            onDateChanged: (date) {
              setState(() {
                selectedDate = date;
              });
            },
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Select Time Slot',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isSmallScreen ? 2 : 3,
            childAspectRatio: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: timeSlots.length,
          itemBuilder: (context, index) {
            final slot = timeSlots[index];
            final isSelected = selectedTimeSlot == slot;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedTimeSlot = slot;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? widget.serviceColor : Colors.white,
                  border: Border.all(
                    color: isSelected ? widget.serviceColor : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    slot,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildServiceDetailsStep(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Service Package',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...serviceOptions.map((option) {
          final isSelected = selectedServices.contains(option['name']);
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: CheckboxListTile(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedServices.add(option['name']);
                  } else {
                    selectedServices.remove(option['name']);
                  }
                });
              },
              title: Text(
                option['name'],
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('${option['duration']} - ₹${option['price']}'),
              activeColor: widget.serviceColor,
            ),
          );
        }),
        const SizedBox(height: 20),
        const Text(
          'Additional Notes',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Any specific requirements or notes...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoStep(bool isSmallScreen) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Service Address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
            maxLines: 2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the service address';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildBookingSummary(isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildBookingSummary(bool isSmallScreen) {
    final totalPrice = selectedServices.fold<int>(
      0,
      (sum, serviceName) {
        final service = serviceOptions.firstWhere((s) => s['name'] == serviceName);
        return sum + (service['price'] as int);
      },
    );

    return Card(
      color: widget.serviceColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Provider:'),
                Text(widget.providerName, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Date:'),
                Text(
                  selectedDate != null
                      ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                      : 'Not selected',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Time:'),
                Text(
                  selectedTimeSlot.isNotEmpty ? selectedTimeSlot : 'Not selected',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Services:'),
                Text(
                  selectedServices.isNotEmpty ? selectedServices.join(', ') : 'None selected',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  '₹$totalPrice',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.serviceColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '₹${_calculateTotal()}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: widget.serviceColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _canProceedToNext() ? _handleStepAction : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.serviceColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 24 : 32,
                  vertical: isSmallScreen ? 12 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                currentStep == 2 ? 'Confirm Booking' : 'Next Step',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateTotal() {
    return selectedServices.fold<int>(
      0,
      (sum, serviceName) {
        final service = serviceOptions.firstWhere((s) => s['name'] == serviceName);
        return sum + (service['price'] as int);
      },
    );
  }

  bool _canProceedToNext() {
    switch (currentStep) {
      case 0:
        return selectedDate != null && selectedTimeSlot.isNotEmpty;
      case 1:
        return selectedServices.isNotEmpty;
      case 2:
        return _formKey.currentState?.validate() ?? false;
      default:
        return false;
    }
  }

  void _handleStepAction() {
    if (currentStep < 2) {
      setState(() {
        currentStep++;
      });
    } else {
      _confirmBooking();
    }
  }

  Future<void> _confirmBooking() async {
    if (!_formKey.currentState!.validate()) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('Booking Confirmed!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your service has been booked successfully.'),
                const SizedBox(height: 12),
                Text(
                  'Booking ID: BK${DateTime.now().millisecondsSinceEpoch}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text('Provider: ${widget.providerName}'),
                Text('Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'),
                Text('Time: $selectedTimeSlot'),
                Text('Total: ₹${_calculateTotal()}'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.serviceColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      // Show error dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}