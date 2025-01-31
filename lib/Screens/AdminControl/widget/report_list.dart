import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gptransco/const/colors/colors.dart';
import 'package:intl/intl.dart';

class ReportList extends StatefulWidget {
  const ReportList({super.key});

  @override
  _ReportListState createState() => _ReportListState();
}

class _ReportListState extends State<ReportList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                  hintText: 'Search banned user...',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 18),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Banned Users',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Banned').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final bannedUsers = snapshot.data!.docs.where((doc) {
                    final name = doc['name'] as String;
                    return _searchText.isEmpty || name.toLowerCase().contains(_searchText);
                  }).toList();

                  if (bannedUsers.isEmpty) {
                    return const Center(child: Text('No banned users found'));
                  }

                  return ListView.builder(
                    itemCount: bannedUsers.length,
                    itemBuilder: (context, index) {
                      final report = bannedUsers[index];
                      final banEndDate = (report['banEndDate'] as Timestamp).toDate();
                      final formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(banEndDate);

                      return Card(
                        color: Colors.white10,
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          title: Text(
                            report['name'],
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Violation: ${report['banReason']}',
                                style: const TextStyle(fontSize: 11, color: Colors.redAccent),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Date & Time: $formattedDate',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Email: ${report['email']}',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.lock_open, color: Colors.grey, size: 18),
                            tooltip: 'Unbanned User',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: navy,
                                    title: const Text('Confirm Unban'),
                                    content: const Text('Are you sure you want to unban this user?'),
                                    actions: [
                                      TextButton(
                                        child: const Text('Cancel', style: TextStyle(color: Colors.red),),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Unban', style: TextStyle(color: Colors.white),),
                                        onPressed: () {
                                          FirebaseFirestore.instance.collection('Banned').doc(report.id).delete();
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
