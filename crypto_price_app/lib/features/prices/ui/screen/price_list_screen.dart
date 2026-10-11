import 'package:flutter/material.dart';

class PriceListScreen extends StatefulWidget {
  const PriceListScreen({super.key});

  @override
  State<PriceListScreen> createState() => _PriceListScreenState();
}

class _PriceListScreenState extends State<PriceListScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Price List screen"),
    );
  }
}
