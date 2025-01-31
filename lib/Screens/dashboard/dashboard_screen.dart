import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../../const/responsive/responsive.dart';
import 'widgets/dashboard_box.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Responsive(
          mobile: _buildMobileLayout(),
          desktop: _buildDesktopLayout(),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Driver').snapshots(),
      builder: (context, driverSnapshot) {
        if (driverSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (driverSnapshot.hasError) {
          return const Center(child: Text('Error fetching data'));
        } else {
          int driverCount = driverSnapshot.data?.docs.where((doc) => doc['role'] == 'Driver').length ?? 0;
          int dispatcherCount = driverSnapshot.data?.docs.where((doc) => doc['role'] == 'Dispatcher').length ?? 0;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (userSnapshot.hasError) {
                return const Center(child: Text('Error fetching data'));
              } else {
                int customerCount = userSnapshot.data?.size ?? 0;

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('LNF').snapshots(),
                  builder: (context, lnfSnapshot) {
                    if (lnfSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (lnfSnapshot.hasError) {
                      return const Center(child: Text('Error fetching data'));
                    } else {
                      int lnfReportCount = lnfSnapshot.data?.size ?? 0;

                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0, bottom: 16.0),
                                  child: DashboardBox(
                                    title: "DRIVERS",
                                    value: driverCount.toString(), // Display dynamic driver count
                                    iconPath: "assets/icons/license.svg",
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
                                  child: DashboardBox(
                                    title: "CUSTOMERS",
                                    value: customerCount.toString(), // Display dynamic customer count
                                    iconPath: "assets/icons/person.svg",
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: DashboardBox(
                                    title: "DISPATCHERS",
                                    value: dispatcherCount.toString(), // Display dynamic dispatcher count
                                    iconPath: "assets/icons/dispatcher3.svg",
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: DashboardBox(
                                    title: "LNF REPORTS",
                                    value: lnfReportCount.toString(), // Display dynamic LNF report count
                                    iconPath: "assets/icons/box.svg",
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }
                  },
                );
              }
            },
          );
        }
      },
    );
  }

  Widget _buildDesktopLayout() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Driver').snapshots(),
      builder: (context, driverSnapshot) {
        if (driverSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (driverSnapshot.hasError) {
          return const Center(child: Text('Error fetching data'));
        } else {
          int driverCount = driverSnapshot.data?.docs.where((doc) => doc['role'] == 'Driver').length ?? 0;
          int dispatcherCount = driverSnapshot.data?.docs.where((doc) => doc['role'] == 'Dispatcher').length ?? 0;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (userSnapshot.hasError) {
                return const Center(child: Text('Error fetching data'));
              } else {
                int customerCount = userSnapshot.data?.size ?? 0;

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('LNF').snapshots(),
                  builder: (context, lnfSnapshot) {
                    if (lnfSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (lnfSnapshot.hasError) {
                      return const Center(child: Text('Error fetching data'));
                    } else {
                      int lnfReportCount = lnfSnapshot.data?.size ?? 0;

                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: DashboardBox(
                                    title: "DRIVERS",
                                    value: driverCount.toString(), // Display dynamic driver count
                                    iconPath: "assets/icons/license.svg",
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: DashboardBox(
                                    title: "CUSTOMERS",
                                    value: customerCount.toString(), // Display dynamic customer count
                                    iconPath: "assets/icons/person.svg",
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: DashboardBox(
                                    title: "DISPATCHERS",
                                    value: dispatcherCount.toString(), // Display dynamic dispatcher count
                                    iconPath: "assets/icons/dispatcher3.svg",
                                  ),
                                ),
                              ),
                              Expanded(
                                child: DashboardBox(
                                  title: "LNF REPORTS",
                                  value: lnfReportCount.toString(), // Display dynamic LNF report count
                                  iconPath: "assets/icons/box.svg",
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }
                  },
                );
              }
            },
          );
        }
      },
    );
  }
}
