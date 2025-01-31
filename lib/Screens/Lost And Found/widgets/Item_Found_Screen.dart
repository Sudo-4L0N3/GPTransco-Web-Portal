import 'package:flutter/material.dart';
import 'package:gptransco/const/colors/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../const/responsive/responsive.dart';

class ItemFoundScreen extends StatefulWidget {
  const ItemFoundScreen({super.key});

  @override
  _ItemFoundScreenState createState() => _ItemFoundScreenState();
}

class _ItemFoundScreenState extends State<ItemFoundScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void _filterItems(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _claimItem(Map<String, dynamic> item) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      bool? confirmClaim = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: navy,
            title: const Text('Return Item'),
            content: const Text('Are you sure you want to return this item?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirm', style: TextStyle(color: Colors.green)),
              ),
            ],
          );
        },
      );

      if (confirmClaim == true) {
        // Update isReturned in LNF collection
        await firestore.collection('LNF').doc(item['id']).update({'isReturned': true});

        // Save item to returnedItem collection with returnedDateTime
        await firestore.collection('returnedItem').add({
          'itemName': item['itemName'],
          'itemPicture': item['itemPicture'],
          'dateTime': item['dateTime'],
          'driverName': item['driverName'],
          'plateNumber': item['plateNumber'],
          'itemInformation': item['itemInformation'],
          'isReturned': true,
          'returnedDateTime': Timestamp.now(),
        });

        // Delete the item from LNF collection
        await firestore.collection('LNF').doc(item['id']).delete();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error claiming item: $e');
    }
  }

  void _deleteItem(Map<String, dynamic> item) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      bool? confirmDelete = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: navy,
            title: const Text('Delete Item'),
            content: const Text('Are you sure you want to delete this item?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirm', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        await firestore.collection('LNF').doc(item['id']).delete();
        await firestore.collection('returnedItem').where('itemName', isEqualTo: item['itemName']).get().then((querySnapshot) {
          for (var doc in querySnapshot.docs) {
            doc.reference.delete();
          }
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting item: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);

    final double fontSize = isMobile || isTablet ? 11 : 15;
    final double iconSize = isMobile || isTablet ? 18 : 20;
    final double avatarRadius = isMobile || isTablet ? 24 : 32;
    final double padding = isMobile || isTablet ? 8.0 : 16.0;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(padding),
        color: secondaryColor,
        child: Column(
          children: [
            Text(
              "Item Found",
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: padding),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search Lost Items",
                hintStyle: const TextStyle(color: Colors.white70, fontSize: 14),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: Icon(Icons.search, size: iconSize),
              ),
              onChanged: _filterItems,
            ),
            SizedBox(height: padding * 1.5),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('LNF')
                    .where('isReturned', isEqualTo: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No items found', style: TextStyle(fontSize: fontSize)));
                  }

                  var items = snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    data['id'] = doc.id;
                    return data;
                  }).where((item) {
                    return _searchQuery.isEmpty ||
                        item['itemName'].toString().toLowerCase().contains(_searchQuery) ||
                        item['driverName'].toString().toLowerCase().contains(_searchQuery) ||
                        item['plateNumber'].toString().toLowerCase().contains(_searchQuery) ||
                        DateFormat('dd-MMMM-yyyy hh:mma').format((item['dateTime'] as Timestamp).toDate()).toLowerCase().contains(_searchQuery);
                  }).toList();

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      var item = items[index];
                      return Card(
                        color: Colors.white10,
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: avatarRadius,
                            backgroundColor: primaryColor,
                            backgroundImage: item['itemPicture'] != null
                                ? NetworkImage(item['itemPicture'])
                                : null,
                            child: item['itemPicture'] == null
                                ? Text(
                                    item['itemName'][0],
                                    style: TextStyle(color: Colors.white, fontSize: fontSize - 2),
                                  )
                                : null,
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'Delete') {
                                _deleteItem(item);
                              } else if (value == 'Claim') {
                                _claimItem(item);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'Delete',
                                child: Container(
                                  color: Colors.red,
                                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
                                  child: Center(child: Text('Delete', style: TextStyle(color: Colors.white, fontSize: fontSize - 2))),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'Claim',
                                child: Container(
                                  color: Colors.green,
                                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
                                  child: Center(child: Text('Claim', style: TextStyle(color: Colors.white, fontSize: fontSize - 2))),
                                ),
                              ),
                            ],
                            icon: Icon(Icons.more_horiz, size: iconSize),
                          ),
                          title: Text(
                            'Found Item: ${item['itemName']}',
                            style: TextStyle(fontSize: fontSize),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date: ${DateFormat('dd-MMMM-yyyy').format((item['dateTime'] as Timestamp).toDate())}',
                                style: TextStyle(fontSize: fontSize - 2),
                              ),
                              Text(
                                'Time: ${DateFormat('hh:mma').format((item['dateTime'] as Timestamp).toDate())}',
                                style: TextStyle(fontSize: fontSize - 2),
                              ),
                            ],
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: navy,
                                  title: Text('Item Information', style: TextStyle(fontSize: fontSize)),
                                  content: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("Item Image:", style: TextStyle(fontSize: fontSize - 2)),
                                      SizedBox(height: padding),
                                      Image.network(
                                        item['itemPicture'] ?? 'https://via.placeholder.com/150',
                                        height: 100,
                                        width: 100,
                                      ),
                                      SizedBox(height: padding),
                                      Text("Date: ${DateFormat('dd-MMMM-yyyy').format((item['dateTime'] as Timestamp).toDate())}", style: TextStyle(fontSize: fontSize - 2)),
                                      Text("Time: ${DateFormat('hh:mma').format((item['dateTime'] as Timestamp).toDate())}", style: TextStyle(fontSize: fontSize - 2)),
                                      SizedBox(height: padding),
                                      Text("Driver Name: ${item['driverName']}", style: TextStyle(fontSize: fontSize - 2)),
                                      SizedBox(height: padding),
                                      Text("Plate Number: ${item['plateNumber']}", style: TextStyle(fontSize: fontSize - 2)),
                                      SizedBox(height: padding),
                                      Text("Item Information: ${item['itemInformation']}", style: TextStyle(fontSize: fontSize - 2)),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Close", style: TextStyle(color: Colors.white, fontSize: fontSize - 2)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
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
