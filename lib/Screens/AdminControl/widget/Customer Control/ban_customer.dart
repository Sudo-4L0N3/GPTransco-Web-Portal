// ban_feature.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gptransco/const/colors/colors.dart';

void showBanDialog(BuildContext context, DocumentSnapshot customer) {
  String? selectedReason;
  String? selectedDuration;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.blueGrey,
            title: Text('Ban Customer: ${customer['name']}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 350,
                  child: DropdownButton<String>(
                    value: selectedReason,
                    hint: const Text('Select reason'),
                    isExpanded: true,
                    items: <String>[
                      'Violation of terms',
                      'Suspicious activity',
                      'Inappropriate behavior',
                      'Spamming'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedReason = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  children: <Widget>[
                    RadioListTile<String>(
                      title: const Text('Three Days',
                          style: TextStyle(color: Colors.white)),
                      value: 'Three Days',
                      groupValue: selectedDuration,
                      onChanged: (String? value) {
                        setState(() {
                          selectedDuration = value;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('One Week',
                          style: TextStyle(color: Colors.white)),
                      value: 'One Week',
                      groupValue: selectedDuration,
                      onChanged: (String? value) {
                        setState(() {
                          selectedDuration = value;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('One Month',
                          style: TextStyle(color: Colors.white)),
                      value: 'One Month',
                      groupValue: selectedDuration,
                      onChanged: (String? value) {
                        setState(() {
                          selectedDuration = value;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('One Year',
                          style: TextStyle(color: Colors.white)),
                      value: 'One Year',
                      groupValue: selectedDuration,
                      onChanged: (String? value) {
                        setState(() {
                          selectedDuration = value;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Ten Years',
                          style: TextStyle(color: Colors.white)),
                      value: 'Ten Years',
                      groupValue: selectedDuration,
                      onChanged: (String? value) {
                        setState(() {
                          selectedDuration = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: selectedReason != null && selectedDuration != null
                    ? () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Ban'),
                              content: const Text(
                                  'Are you sure you want to ban this customer?'),
                              actions: [
                                TextButton(
                                  child: const Text('Yes'),
                                  onPressed: () {
                                    Duration duration;
                                    switch (selectedDuration) {
                                      case 'Three Days':
                                        duration = const Duration(days: 3);
                                        break;
                                      case 'One Week':
                                        duration = const Duration(days: 7);
                                        break;
                                      case 'One Month':
                                        duration = const Duration(days: 30);
                                        break;
                                      case 'One Year':
                                        duration = const Duration(days: 365);
                                        break;
                                      case 'Ten Years':
                                        duration = const Duration(days: 3650);
                                        break;
                                      default:
                                        duration = const Duration(days: 0);
                                    }
                                    banCustomer(context, customer, duration,
                                        selectedReason ?? 'No reason provided');
                                  },
                                ),
                                TextButton(
                                  child: const Text('No', style: TextStyle(color: white),),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    : null,
                child: const Text('Ban', style: TextStyle(color: red),),
              ),
              TextButton(
                child: const Text('Cancel', style: TextStyle(color: white),),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    },
  );
}

void banCustomer(BuildContext context, DocumentSnapshot customer,
    Duration duration, String reason) {
  final currentDate = DateTime.now();
  final banEndDate = currentDate.add(duration);

  FirebaseFirestore.instance.collection('Banned').doc(customer.id).set({
    'UID': customer.id,
    'email': customer['email'],
    'name': customer['name'],
    'banReason': reason,
    'banEndDate': banEndDate,
  }).then((_) {
    // Close the dialog after saving
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${customer['name']} has been banned.',style: const TextStyle(color: white),),backgroundColor: coral,),
    );
  }).catchError((error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to ban customer: $error', style: const TextStyle(color: white),), backgroundColor: orange,),
    );
  });
}