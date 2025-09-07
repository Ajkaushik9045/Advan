// lib/core/widgets/status_chip.dart
import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;
  final bool isItemStatus;
  final double fontSize;

  const StatusChip({
    Key? key,
    required this.status,
    this.isItemStatus = false,
    this.fontSize = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    if (isItemStatus) {
      switch (status.toLowerCase()) {
        case 'pending':
          color = Colors.orange;
          label = 'Pending';
          break;
        case 'confirmed':
          color = Colors.green;
          label = 'Confirmed';
          break;
        case 'not_available':
          color = Colors.red;
          label = 'Not Available';
          break;
        case 'reassigned':
          color = Colors.blue;
          label = 'Reassigned';
          break;
        default:
          color = Colors.grey;
          label = status;
      }
    } else {
      switch (status.toLowerCase()) {
        case 'pending':
          color = Colors.orange;
          label = 'Pending';
          break;
        case 'confirmed':
          color = Colors.green;
          label = 'Confirmed';
          break;
        case 'partially_fulfilled':
          color = Colors.blue;
          label = 'Partially Fulfilled';
          break;
        default:
          color = Colors.grey;
          label = status;
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isItemStatus ? 8 : 12,
        vertical: isItemStatus ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isItemStatus ? 12 : 16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
