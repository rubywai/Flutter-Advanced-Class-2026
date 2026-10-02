import 'dart:async';

import 'package:flutter/material.dart';

import 'providers/products_providers.dart';
import 'widgets/product_results_view.dart';

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  bool _isDebouncing = false;

  void _onChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();

    setState(() {
      _query = '';
      _isDebouncing = query.isNotEmpty;
    });

    if (query.isEmpty) return;

    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        _query = query;
        _isDebouncing = false;
      });
    });
  }

  void _onSubmitted(String value) {
    _debounce?.cancel();
    setState(() {
      _query = value.trim();
      _isDebouncing = false;
    });
  }

  void _clear() {
    _controller.clear();
    _onChanged('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: _onChanged,
          onSubmitted: _onSubmitted,
          decoration: const InputDecoration(
            hintText: 'Search products',
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              tooltip: 'Clear search',
              onPressed: _clear,
              icon: const Icon(Icons.clear),
            ),
        ],
      ),
      body: _isDebouncing
          ? const Center(child: CircularProgressIndicator())
          : _query.isEmpty
          ? const SizedBox.expand()
          : ProductResultsView(
              key: ValueKey(_query),
              query: ProductQuery(search: _query, perPage: 20),
              emptyMessage: 'No matching products.',
            ),
    );
  }
}
