// lib/features/requests/pages/create_request_page.dart
import 'package:advan_app/features/auth/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../requests/provider/request_provider.dart';
import '../models/item_model.dart';

class CreateRequestPage extends StatefulWidget {
  const CreateRequestPage({Key? key}) : super(key: key);

  @override
  State<CreateRequestPage> createState() => _CreateRequestPageState();
}

class _CreateRequestPageState extends State<CreateRequestPage> {
  final List<SelectedItem> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RequestProvider>(
        context,
        listen: false,
      ).fetchAvailableItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Request'),
        actions: [
          TextButton(
            onPressed: _selectedItems.isNotEmpty ? _submitRequest : null,
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Consumer<RequestProvider>(
        builder: (context, requestProvider, child) {
          if (requestProvider.isLoading &&
              requestProvider.availableItems.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (requestProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${requestProvider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      requestProvider.clearError();
                      requestProvider.fetchAvailableItems();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              if (_selectedItems.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue[50],
                  child: Row(
                    children: [
                      Icon(Icons.shopping_cart, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedItems.length} items selected',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _clearSelection,
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _selectedItems.length,
                    itemBuilder: (context, index) {
                      final item = _selectedItems[index];
                      return SelectedItemCard(
                        item: item,
                        onQuantityChanged: (quantity) {
                          setState(() {
                            item.quantity = quantity;
                          });
                        },
                        onRemove: () {
                          setState(() {
                            _selectedItems.removeAt(index);
                          });
                        },
                      );
                    },
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: requestProvider.availableItems.length,
                    itemBuilder: (context, index) {
                      final item = requestProvider.availableItems[index];
                      return AvailableItemCard(
                        item: item,
                        onAdd: () {
                          setState(() {
                            _selectedItems.add(SelectedItem.fromItem(item));
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _clearSelection() {
    setState(() {
      _selectedItems.clear();
    });
  }

  Future<void> _submitRequest() async {
    if (_selectedItems.isEmpty) return;

    final requestProvider = Provider.of<RequestProvider>(
      context,
      listen: false,
    );

    try {
      await requestProvider.createRequest(
        items: _selectedItems
            .map((item) => {'itemId': item.id, 'quantity': item.quantity})
            .toList(),
        auth: Provider.of<AuthProvider>(context, listen: false),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class AvailableItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onAdd;

  const AvailableItemCard({Key? key, required this.item, required this.onAdd})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(item.name),
        subtitle: Text(item.description),
        trailing: ElevatedButton(onPressed: onAdd, child: const Text('Add')),
      ),
    );
  }
}

class SelectedItemCard extends StatelessWidget {
  final SelectedItem item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const SelectedItemCard({
    Key? key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: item.quantity > 1
                      ? () => onQuantityChanged(item.quantity - 1)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('${item.quantity}'),
                ),
                IconButton(
                  onPressed: () => onQuantityChanged(item.quantity + 1),
                  icon: const Icon(Icons.add),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SelectedItem {
  final String id;
  final String name;
  final String description;
  int quantity;

  SelectedItem({
    required this.id,
    required this.name,
    required this.description,
    this.quantity = 1,
  });

  factory SelectedItem.fromItem(Item item) {
    return SelectedItem(
      id: item.id,
      name: item.name,
      description: item.description,
      quantity: 1,
    );
  }
}
