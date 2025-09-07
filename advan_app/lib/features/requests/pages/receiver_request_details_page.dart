// lib/features/requests/pages/receiver_request_details_page.dart
import 'package:advan_app/features/auth/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../requests/provider/request_provider.dart';
import '../../requests/models/item_model.dart';
import '../../../core/utils/enums.dart';

class ReceiverRequestDetailsPage extends StatefulWidget {
  final dynamic request;

  const ReceiverRequestDetailsPage({super.key, required this.request});

  @override
  State<ReceiverRequestDetailsPage> createState() =>
      _ReceiverRequestDetailsPageState();
}

class _ReceiverRequestDetailsPageState
    extends State<ReceiverRequestDetailsPage> {
  final Map<String, ItemStatus> _itemConfirmations = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize confirmations with current item statuses
    for (var item in widget.request.items) {
      _itemConfirmations[item.id] = _parseItemStatus(item.status);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request #${widget.request.id.substring(0, 8)}'),
        actions: [
          if (_hasChanges())
            TextButton(
              onPressed: _isSubmitting ? null : _submitConfirmations,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRequestInfo(),
            const SizedBox(height: 24),
            _buildStatusSection(),
            const SizedBox(height: 24),
            _buildItemsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Request Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Request ID', widget.request.id),
            _buildInfoRow('From', widget.request.userName),
            _buildInfoRow('Created', _formatDate(widget.request.createdAt)),
            if (widget.request.updatedAt != null)
              _buildInfoRow(
                'Last Updated',
                _formatDate(widget.request.updatedAt),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatusChip(widget.request.status),
                const Spacer(),
                Text(
                  '${widget.request.confirmedItemsCount}/${widget.request.totalItemsCount} items',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            if (widget.request.isPartiallyConfirmed ||
                widget.request.isFullyConfirmed) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value:
                    widget.request.confirmedItemsCount /
                    widget.request.totalItemsCount,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.request.isFullyConfirmed
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Items (${widget.request.items.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...widget.request.items.map<Widget>((item) => _buildItemCard(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(dynamic item) {
    final currentStatus = _itemConfirmations[item.id] ?? ItemStatus.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: _getItemStatusColor(currentStatus).withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quantity: ${item.quantity}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              _buildItemStatusChip(currentStatus),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatusButtons(item.id, currentStatus),
        ],
      ),
    );
  }

  Widget _buildStatusButtons(String itemId, ItemStatus currentStatus) {
    return Row(
      children: [
        Expanded(
          child: _buildStatusButton(
            itemId,
            'Available',
            ItemStatus.confirmed,
            currentStatus,
            Colors.green,
            Icons.check,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatusButton(
            itemId,
            'Not Available',
            ItemStatus.notAvailable,
            currentStatus,
            Colors.red,
            Icons.close,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusButton(
    String itemId,
    String label,
    ItemStatus status,
    ItemStatus currentStatus,
    Color color,
    IconData icon,
  ) {
    final isSelected = currentStatus == status;

    return OutlinedButton.icon(
      onPressed: () {
        setState(() {
          _itemConfirmations[itemId] = status;
        });
      },
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: isSelected ? Colors.white : color,
        backgroundColor: isSelected ? color : null,
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(RequestStatus status) {
    Color color;
    String label;

    switch (status) {
      case RequestStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        break;
      case RequestStatus.confirmed:
        color = Colors.green;
        label = 'Confirmed';
        break;
      case RequestStatus.partiallyFulfilled:
        color = Colors.blue;
        label = 'Partially Fulfilled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildItemStatusChip(ItemStatus status) {
    Color color;
    String label;

    switch (status) {
      case ItemStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        break;
      case ItemStatus.confirmed:
        color = Colors.green;
        label = 'Confirmed';
        break;
      case ItemStatus.notAvailable:
        color = Colors.red;
        label = 'Not Available';
        break;
      case ItemStatus.reassigned:
        color = Colors.blue;
        label = 'Reassigned';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getItemStatusColor(ItemStatus status) {
    switch (status) {
      case ItemStatus.pending:
        return Colors.orange;
      case ItemStatus.confirmed:
        return Colors.green;
      case ItemStatus.notAvailable:
        return Colors.red;
      case ItemStatus.reassigned:
        return Colors.blue;
    }
  }

  ItemStatus _parseItemStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ItemStatus.pending;
      case 'confirmed':
        return ItemStatus.confirmed;
      case 'not_available':
        return ItemStatus.notAvailable;
      case 'reassigned':
        return ItemStatus.reassigned;
      default:
        return ItemStatus.pending;
    }
  }

  bool _hasChanges() {
    for (var item in widget.request.items) {
      final currentStatus = _parseItemStatus(item.status);
      final newStatus = _itemConfirmations[item.id] ?? currentStatus;
      if (currentStatus != newStatus) {
        return true;
      }
    }
    return false;
  }

  Future<void> _submitConfirmations() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final requestProvider = Provider.of<RequestProvider>(
        context,
        listen: false,
      );

      final itemConfirmations = _itemConfirmations.entries
          .map(
            (entry) => {
              'itemId': entry.key,
              'available': entry.value == ItemStatus.confirmed,
            },
          )
          .toList();

      await requestProvider.confirmItems(
        requestId: widget.request.id,
        itemConfirmations: itemConfirmations,
        auth: Provider.of<AuthProvider>(context, listen: false),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item confirmations saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving confirmations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
