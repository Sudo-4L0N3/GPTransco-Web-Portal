import 'package:flutter/material.dart';
import 'package:gptransco/const/colors/colors.dart';
import 'package:gptransco/const/responsive/responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ItemReturnedScreen extends StatefulWidget {
  const ItemReturnedScreen({super.key});

  @override
  _ItemReturnedScreenState createState() => _ItemReturnedScreenState();
}

class _ItemReturnedScreenState extends State<ItemReturnedScreen> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, bool> itemSelectedMap = {};
  bool selectAll = false;
  String _searchQuery = '';

  void _filterItems(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  Future<void> _confirmAndDeleteSelectedItems() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: navy,
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete the selected items?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      final collection = FirebaseFirestore.instance.collection('returnedItem');
      for (var entry in itemSelectedMap.entries) {
        if (entry.value) {
          await collection.doc(entry.key).delete();
        }
      }
      setState(() {
        itemSelectedMap.clear();
        selectAll = false;
      });
    }
  }

  bool _isAnyItemSelected() {
    return itemSelectedMap.containsValue(true);
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);

    final double fontSize = isMobile || isTablet ? 11 : 15;
    final double iconSize = isMobile || isTablet ? 18 : 24;
    final double padding = isMobile || isTablet ? 8.0 : 16.0;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(padding),
        color: secondaryColor,
        child: Column(
          children: [
            Text(
              "Returned Items",
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 17),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search Returned Items",
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
            SizedBox(height: padding),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Checkbox(
                    value: selectAll,
                    onChanged: (value) {
                      setState(() {
                        selectAll = value!;
                        itemSelectedMap.updateAll((key, _) => selectAll);
                      });
                    },
                  ),
                ),
                Text("All", style: TextStyle(fontSize: fontSize)),
                const Spacer(),
                IconButton(
                  onPressed: _isAnyItemSelected() ? _confirmAndDeleteSelectedItems : null,
                  icon: Icon(Icons.delete, color: Colors.red, size: iconSize),
                  tooltip: "Delete Selected",
                ),
              ],
            ),
            SizedBox(height: padding / 2),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('returnedItem').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No returned items found.",
                        style: TextStyle(fontSize: fontSize, color: Colors.white70),
                      ),
                    );
                  }

                  var items = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final itemName = data['itemName']?.toString().toLowerCase() ?? '';
                    final driverName = data['driverName']?.toString().toLowerCase() ?? '';
                    final plateNumber = data['plateNumber']?.toString().toLowerCase() ?? '';
                    final returnedDateTime = DateFormat('dd-MMMM-yyyy hh:mma').format((data['returnedDateTime'] as Timestamp).toDate()).toLowerCase();
                    return _searchQuery.isEmpty ||
                        itemName.contains(_searchQuery) ||
                        driverName.contains(_searchQuery) ||
                        plateNumber.contains(_searchQuery) ||
                        returnedDateTime.contains(_searchQuery);
                  }).toList();

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final doc = items[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final itemId = doc.id;
                      final itemName = data['itemName'] ?? "";
                      final returnedDateTime = (data['returnedDateTime'] as Timestamp).toDate();
                      final driverName = data['driverName'] ?? "";
                      final plateNumber = data['plateNumber'] ?? "";
                      final itemPicture = data['itemPicture'] ?? "";
                      final dateTimeFound = (data['dateTime'] as Timestamp).toDate();

                      if (!itemSelectedMap.containsKey(itemId)) {
                        itemSelectedMap[itemId] = false;
                      }

                      return Card(
                        color: Colors.white10,
                        child: ListTile(
                          leading: Checkbox(
                            value: itemSelectedMap[itemId],
                            onChanged: (value) {
                              setState(() {
                                itemSelectedMap[itemId] = value!;
                              });
                            },
                          ),
                          title: Text(
                            'Item: $itemName',
                            style: TextStyle(fontSize: fontSize),
                          ),
                          subtitle: Text(
                            'Date Returned: ${DateFormat('dd-MMMM-yyyy hh:mma').format(returnedDateTime)}\nDate Found: ${DateFormat('dd-MMMM-yyyy hh:mma').format(dateTimeFound)}',
                            style: TextStyle(fontSize: fontSize - 2),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: navy,
                                  title: Text(
                                    'Item Information',
                                    style: TextStyle(color: Colors.white, fontSize: fontSize),
                                  ),
                                  content: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Item Image:",
                                        style: TextStyle(color: Colors.white, fontSize: fontSize - 2),
                                      ),
                                      SizedBox(height: padding),
                                      Image.network(
                                        itemPicture,
                                        height: 100,
                                        width: 100,
                                      ),
                                      SizedBox(height: padding),
                                      Text(
                                        "Item: $itemName",
                                        style: TextStyle(color: Colors.white, fontSize: fontSize - 2),
                                      ),
                                      SizedBox(height: padding),
                                      Text(
                                        "Date and Time Found: ${DateFormat('dd-MMMM-yyyy hh:mma').format(dateTimeFound)}",
                                        style: TextStyle(color: Colors.white, fontSize: fontSize - 2),
                                      ),
                                      SizedBox(height: padding),
                                      Text(
                                        "Return Date: ${DateFormat('dd-MMMM-yyyy hh:mma').format(returnedDateTime)}",
                                        style: TextStyle(color: Colors.white, fontSize: fontSize - 2),
                                      ),
                                      SizedBox(height: padding),
                                      Text(
                                        "Driver Name: $driverName",
                                        style: TextStyle(color: Colors.white, fontSize: fontSize - 2),
                                      ),
                                      SizedBox(height: padding),
                                      Text(
                                        "Driver Plate Number: $plateNumber",
                                        style: TextStyle(color: Colors.white, fontSize: fontSize - 2),
                                      ),
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
