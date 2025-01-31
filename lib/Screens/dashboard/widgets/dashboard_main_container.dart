import 'package:flutter/material.dart';
import 'package:gptransco/const/colors/colors.dart';

class DashboardMainContainer  extends StatelessWidget {
  const DashboardMainContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Additional Information",
            style: TextStyle(
              fontSize: 18,
              //fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text("Informatons"),
        ],
      ),
    );
  }
}
