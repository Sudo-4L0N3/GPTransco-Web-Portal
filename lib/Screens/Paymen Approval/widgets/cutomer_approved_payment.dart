import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gptransco/const/colors/colors.dart';
import 'package:intl/intl.dart';

class CustomerApprovedPayment extends StatelessWidget {
  const CustomerApprovedPayment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Dark background color
      body: ApprovedPaymentListContainer(),
    );
  }
}

class ApprovedPaymentListContainer extends StatefulWidget {
  const ApprovedPaymentListContainer({super.key});

  @override
  _ApprovedPaymentListContainerState createState() => _ApprovedPaymentListContainerState();
}

class _ApprovedPaymentListContainerState extends State<ApprovedPaymentListContainer> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  List<Map<String, dynamic>> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final QuerySnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      List<Map<String, dynamic>> payments = [];
      for (var userDoc in userSnapshot.docs) {
        final userTickets = await userDoc.reference.collection('my_ticket').get();

        for (var ticketDoc in userTickets.docs) {
          // Only add payments with the status "Approved" or "Declined"
          if (ticketDoc['status'] == 'Approved' || ticketDoc['status'] == 'Declined') {
            payments.add({
              'customerName': userDoc['name'] ?? 'Unknown',
              'status': ticketDoc['status'] ?? 'Unknown',
              'expirationDate': ticketDoc['expirationDate'] ?? 'Unknown',
              'ticketID': ticketDoc['ticketID'] ?? 'Unknown',
              'driverName': ticketDoc['driverName'] ?? 'Unknown',
              'scheduledDate': ticketDoc['scheduledDate'] ?? 'Unknown',
              'plateNumber': ticketDoc['plateNumber'] ?? 'Unknown',
              'currentLocation': ticketDoc['currentLocation'] ?? 'Unknown',
              'destination': ticketDoc['destination'] ?? 'Unknown',
              'receipt': (ticketDoc['Receipt'] ?? ticketDoc['Receipt'] ?? '').toString(),
              'userUID': userDoc.id, // Add user UID
              'documentID': ticketDoc.id, // Add document ID
            });
          }
        }
      }

      setState(() {
        _payments = payments;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching payments: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading payments: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String formatTimestamp(dynamic timestamp) {
    if (timestamp == null || timestamp == 'Unknown') {
      return 'Unknown';
    }

    // If the timestamp is a Firestore Timestamp, convert it to DateTime
    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dateTime = timestamp;
    } else {
      return 'Invalid Date';
    }

    // Format the DateTime object
    return DateFormat('yyyy-MM-dd – hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    // Filter payments based on search text
    final filteredPayments = _payments
        .where((payment) =>
            (payment['customerName'].toString().toLowerCase().contains(_searchText) ||
                payment['driverName'].toString().toLowerCase().contains(_searchText) ||
                payment['plateNumber'].toString().toLowerCase().contains(_searchText) ||
                payment['scheduledDate'].toString().toLowerCase().contains(_searchText) ||
                payment['ticketID'].toString().toLowerCase().contains(_searchText)))
        .toList();

    return Container(
      height: double.infinity,
      width: double.infinity,
      color: secondaryColor, // Secondary dark color
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchText = value.trim().toLowerCase();
                });
              },
              style: const TextStyle(fontSize: 14, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search payments...',
                hintStyle: const TextStyle(color: Colors.white70, fontSize: 14),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 18),
              ),
            ),
          ),
          // Title
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Payment List (Approved & Declined)',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12.0),
          // Loading or Payment List
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: filteredPayments.isEmpty
                        ? Center(
                            child: Text(
                              'No payments found',
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredPayments.length,
                            itemBuilder: (context, index) {
                              final payment = filteredPayments[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4.0),
                                padding: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: CircleAvatar(
                                      radius: 12.0,
                                      backgroundColor: payment['status'] == 'Approved'
                                          ? Colors.green.withOpacity(0.5) // Green for approved
                                          : Colors.red.withOpacity(0.5), // Red for declined
                                      child: Icon(
                                        payment['status'] == 'Approved' ? Icons.check_circle : Icons.cancel,
                                        color: Colors.white,
                                        size: 14.0,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    payment['customerName'],
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                  ),
                                  subtitle: Text(
                                    'Status: ${payment['status']} | Expiration: ${formatTimestamp(payment['expirationDate'])}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, color: Colors.white, size: 16.0),
                                    onSelected: (String value) {
                                      switch (value) {
                                        case 'View':
                                          _showPaymentDetails(context, payment);
                                          break;
                                        case 'Delete':
                                          _showDeleteConfirmationDialog(context, payment);
                                          break;
                                      }
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return [
                                        const PopupMenuItem<String>(
                                          value: 'View',
                                          child: Text('View Details'),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'Delete',
                                          child: Text('Delete Payment'),
                                        ),
                                      ];
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
        ],
      ),
    );
  }

  // Show Payment Details Dialog
  void _showPaymentDetails(BuildContext context, Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: Text(
            'Payment Details',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Zoomable Receipt Image or Placeholder
                SizedBox(
                  height: 500, // Fixed height
                  width: double.infinity, // Match parent width
                  child: InteractiveViewer(
                    boundaryMargin: EdgeInsets.all(20.0),
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: payment['receipt'].isNotEmpty
                        ? Image.network(
                            payment['receipt'], // Load receipt image if available
                            fit: BoxFit.cover,
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[700],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Center(
                              child: Text(
                                'No Receipt Available',
                                style: TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12.0),
                Text('Ticket ID: ${payment['ticketID']}', style: TextStyle(color: Colors.white)),
                Text('Customer: ${payment['customerName']}', style: TextStyle(color: Colors.white)),
                Text('Driver Name: ${payment['driverName']}', style: TextStyle(color: Colors.white)),
                Text('Scheduled Date: ${formatTimestamp(payment['scheduledDate'])}', style: TextStyle(color: Colors.white)),
                Text('Plate Number: ${payment['plateNumber']}', style: TextStyle(color: Colors.white)),
                Text('Current Location: ${payment['currentLocation']}', style: TextStyle(color: Colors.white)),
                Text('Destination: ${payment['destination']}', style: TextStyle(color: Colors.white)),
                Text('Expiration Date: ${formatTimestamp(payment['expirationDate'])}', style: TextStyle(color: Colors.white)),
                Text('Status: ${payment['status']}', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Show Delete Confirmation Dialog
  void _showDeleteConfirmationDialog(BuildContext context, Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Are you sure you want to delete this payment?',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _deletePayment(payment);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('No', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Delete Payment from Firestore
  void _deletePayment(Map<String, dynamic> payment) async {
    try {
      final userUID = payment['userUID']; // Get the user UID
      final documentID = payment['documentID']; // Get the document ID

      // Delete the document from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userUID)
          .collection('my_ticket')
          .doc(documentID)
          .delete();

      // Update the local state
      setState(() {
        _payments.removeWhere((item) => item['documentID'] == payment['documentID']);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${payment['customerName']}\'s payment has been deleted.', style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('Error deleting payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete payment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}