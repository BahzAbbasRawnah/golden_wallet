import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';


class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {

    


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('checkout.title'.tr()),
      ),
      body: Center(

      )
    );
  }
  }
