import 'package:flutter/material.dart';
import 'package:gptransco/Screens/Paymen%20Approval/widgets/customer_payment_screen.dart';
import 'package:gptransco/Screens/Paymen%20Approval/widgets/cutomer_approved_payment.dart';


class PaymentApprovalScreen extends StatelessWidget {
  const PaymentApprovalScreen({super.key});

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              // Mobile and tablet layout
              return const Column(
                children: [
                  Expanded(
                    child: CustomerPaymentScreen(),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: CustomerApprovedPayment(),
                  ),
                ],
              );
            } else {
              // Desktop layout
              return const Row(
                children: [
                  Expanded(
                    child: CustomerPaymentScreen(),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: CustomerApprovedPayment(),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}