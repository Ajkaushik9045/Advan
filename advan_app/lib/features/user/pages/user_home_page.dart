// lib/features/user/pages/user_home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/provider/auth_provider.dart';
import '../../requests/provider/request_provider.dart';
import '../../requests/pages/create_request_page.dart';
import '../../requests/pages/request_details_page.dart';
import '../../../core/utils/enums.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final requestProvider = Provider.of<RequestProvider>(
        context,
        listen: false,
      );
      requestProvider.fetchRequests(
        receiverId: 'user-${auth.role?.name ?? 'endUser'}',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final requestProvider = Provider.of<RequestProvider>(
                context,
                listen: false,
              );
              requestProvider.fetchRequests(
                receiverId: 'user-${auth.role?.name ?? 'endUser'}',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Consumer<RequestProvider>(
        builder: (context, requestProvider, child) {
          if (requestProvider.isLoading && requestProvider.requests.isEmpty) {
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
                      final auth = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      requestProvider.fetchRequests(
                        receiverId: 'user-${auth.role?.name ?? 'endUser'}',
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (requestProvider.requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No requests yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your first request to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              await requestProvider.fetchRequests(
                receiverId: 'user-${auth.role?.name ?? 'endUser'}',
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requestProvider.requests.length,
              itemBuilder: (context, index) {
                final request = requestProvider.requests[index];
                return RequestCard(
                  request: request,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RequestDetailsPage(request: request),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateRequestPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  final dynamic request;
  final VoidCallback onTap;

  const RequestCard({super.key, required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Request #${request.id.substring(0, 8)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(request.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${request.totalItemsCount} items',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Created: ${_formatDate(request.createdAt)}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              if (request.isPartiallyConfirmed) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: request.confirmedItemsCount / request.totalItemsCount,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    request.isFullyConfirmed ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${request.confirmedItemsCount}/${request.totalItemsCount} items confirmed',
                  style: const TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ],
            ],
          ),
        ),
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
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
