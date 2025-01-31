// customer_list_container.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gptransco/const/colors/colors.dart';
import 'Customer Control/ban_customer.dart';

class CustomerListContainer extends StatefulWidget {
  const CustomerListContainer({super.key});

  @override
  _CustomerListContainerState createState() => _CustomerListContainerState();
}

class _CustomerListContainerState extends State<CustomerListContainer> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: secondaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                hintText: 'Search customer...',
                hintStyle: const TextStyle(color: Colors.white70, fontSize: 14),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon:
                    const Icon(Icons.search, color: Colors.white70, size: 18),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Customer List',
              style: TextStyle(
                  fontSize: 16, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12.0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Banned').snapshots(),
                builder: (context, bannedSnapshot) {
                  if (bannedSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!bannedSnapshot.hasData) {
                    return const Center(
                      child: Text(
                        'No verified customers found',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    );
                  }

                  final bannedUsers = bannedSnapshot.data!.docs.where((doc) {
                    final banEndDate =
                        (doc['banEndDate'] as Timestamp).toDate();
                    return banEndDate.isAfter(DateTime.now());
                  }).map((doc) => doc['UID']).toList();

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('isEmailVerified', isEqualTo: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'No verified customers found',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        );
                      }

                      final customers = snapshot.data!.docs.where((doc) {
                        final name =
                            (doc['name'] ?? '').toString().toLowerCase();
                        return name.contains(_searchText) &&
                            !bannedUsers.contains(doc.id);
                      }).toList();

                      if (customers.isEmpty) {
                        return const Center(
                          child: Text(
                            'No customers match your search',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          final customer = customers[index];
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
                                  backgroundColor: Colors.grey.withOpacity(0.5),
                                  backgroundImage: customer['profileImageUrl'] !=
                                          null
                                      ? NetworkImage(customer['profileImageUrl'])
                                      : null,
                                  child: customer['profileImageUrl'] == null
                                      ? const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 14.0,
                                        )
                                      : null,
                                ),
                              ),
                              title: Text(
                                customer['name'] ?? 'No Name',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert,
                                    color: Colors.white, size: 16.0),
                                onSelected: (String value) {
                                  switch (value) {
                                    case 'Ban':
                                      showBanDialog(context, customer);
                                      break;
                                    case 'Delete':
                                      _showDeleteConfirmationDialog(context, customer);
                                      break;
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  return [
                                    const PopupMenuItem<String>(
                                      value: 'Ban',
                                      child: Text('Ban'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'Delete',
                                      child: Text('Delete'),
                                    ),
                                  ];
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, DocumentSnapshot customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: navy,
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this customer?'),
          actions: [
            TextButton(
              child: const Text('Yes', style: TextStyle(color:white ),),
              onPressed: () {
                _deleteCustomer(customer);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('No', style: TextStyle(color: red),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteCustomer(DocumentSnapshot customer) {
    FirebaseFirestore.instance.collection('users').doc(customer.id).delete().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(content: Text('${customer['name']} has been deleted.',style: const TextStyle(color: white),), backgroundColor: coral,),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete customer: $error'), backgroundColor: orange,),
      );
    });
  }
}
