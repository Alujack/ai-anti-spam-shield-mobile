import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/history_provider.dart';
import '../../utils/colors.dart';
import '../../models/scan_history.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String? _filterType;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(historyProvider.notifier).loadHistory());
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Scan History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onSelected: (value) {
              setState(() {
                _filterType = value == 'all' ? null : value;
              });
              ref.read(historyProvider.notifier).loadHistory(
                isSpam: _filterType == 'spam' ? true : (_filterType == 'safe' ? false : null),
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'spam', child: Text('Spam Only')),
              const PopupMenuItem(value: 'safe', child: Text('Safe Only')),
            ],
          ),
        ],
      ),
      body: historyState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : historyState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
                      const SizedBox(height: 16),
                      Text(
                        historyState.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(historyProvider.notifier).loadHistory();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : historyState.histories.isEmpty
                  ? Center(
                      child: FadeIn(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 80,
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No scan history yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.textSecondary.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Scan messages to see them here',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(historyProvider.notifier).loadHistory();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: historyState.histories.length,
                        itemBuilder: (context, index) {
                          final history = historyState.histories[index];
                          return FadeInUp(
                            duration: Duration(milliseconds: 300 + (index * 100)),
                            child: _buildHistoryCard(history),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildHistoryCard(ScanHistory history) {
    final isSpam = history.isSpam;
    final confidence = (history.confidence * 100).toStringAsFixed(1);

    return Dismissible(
      key: Key(history.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete History'),
            content: const Text('Are you sure you want to delete this scan history?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        try {
          await ref.read(historyProvider.notifier).deleteHistory(history.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('History deleted'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $e'),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              _showHistoryDetails(history);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isSpam ? AppColors.danger : AppColors.success).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isSpam ? Icons.warning_rounded : Icons.check_circle_rounded,
                          color: isSpam ? AppColors.danger : AppColors.success,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSpam ? 'SPAM' : 'SAFE',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSpam ? AppColors.danger : AppColors.success,
                              ),
                            ),
                            Text(
                              'Confidence: $confidence%',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatDate(history.scannedAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Message Preview
                  Text(
                    history.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showHistoryDetails(ScanHistory history) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            history.isSpam ? Icons.warning_rounded : Icons.check_circle_rounded,
                            size: 64,
                            color: history.isSpam ? AppColors.danger : AppColors.success,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            history.isSpam ? 'SPAM' : 'SAFE',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: history.isSpam ? AppColors.danger : AppColors.success,
                            ),
                          ),
                          Text(
                            'Confidence: ${(history.confidence * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Message
                    const Text(
                      'Message',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        history.message,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Date
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          'Scanned on ${_formatDateFull(history.scannedAt)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDateFull(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

