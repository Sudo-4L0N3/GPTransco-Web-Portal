import 'package:flutter/material.dart';
import '../../const/responsive/responsive.dart';
import 'widgets/Item_Found_Screen.dart';
import 'widgets/Item_Returned_Screen.dart';
class LNFScreen extends StatelessWidget {
  const LNFScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Responsive(
          mobile: Column(
            children: [
              Expanded(child: ItemFoundScreen()),
              SizedBox(height: 16),
              Expanded(child: ItemReturnedScreen()),
            ],
          ),
          tablet: Column(
            children: [
              Expanded(child: ItemFoundScreen()),
              SizedBox(height: 16),
              Expanded(child: ItemReturnedScreen()),
            ],
          ),
          desktop: Row(
            children: [
              Expanded(child: ItemFoundScreen()),
              SizedBox(width: 16),
              Expanded(child: ItemReturnedScreen()),
            ],
          ),
        ),
      ),
    );
  }
}
