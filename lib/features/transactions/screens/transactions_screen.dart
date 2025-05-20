import 'package:flutter/material.dart';
import 'package:golden_wallet/features/transactions/widgets/transaction_list_item.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:golden_wallet/config/routes.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/transactions/models/transaction_model.dart';
import 'package:golden_wallet/features/transactions/providers/transaction_provider.dart';
import 'package:golden_wallet/features/transactions/utils/pdf_export_util.dart';
import 'package:golden_wallet/shared/widgets/custom_button.dart';
import 'package:golden_wallet/shared/widgets/custom_card.dart';
import 'package:golden_wallet/shared/widgets/custom_text_field.dart';

/// Transactions Screen
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isFilterExpanded = false;
  bool _isExporting = false;

  // Function to update search query
  void _updateSearchQuery() {
    if (mounted) {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      provider.setSearchQuery(_searchController.text);
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchController.addListener(_updateSearchQuery);
    });
  }

  @override
  void dispose() {
    // Remove listener before disposing the controller
    _searchController.removeListener(_updateSearchQuery);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'allTransactions'.tr(),
          style: TextStyle(
            color: AppTheme.goldDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppTheme.goldDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.sort,
              color: AppTheme.goldDark,
            ),
            onPressed: () {
              provider.toggleSortOrder();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    provider.sortAscending
                        ? 'sorted_oldest_first'.tr()
                        : 'sorted_newest_first'.tr(),
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: AppTheme.goldDark,
            ),
            onPressed: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: CustomTextField(
              controller: _searchController,
              hint: 'searchTransactions'.tr(),
              prefixIcon: Icons.search,
              borderRadius: 30, // More rounded corners
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[200],
              borderColor: Colors.transparent,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              suffix: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon:
                          const Icon(Icons.clear, size: 18, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
            ),
          ),

          // Filter section
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isFilterExpanded ? 240 : 0,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildFilterSection(context, provider),
                ],
              ),
            ),
          ),

          // Export button and transaction count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Transaction count with gold accent
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'transactionsFound'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      TextSpan(
                        text: ' ${provider.filteredTransactions.length}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.goldDark,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                // Export PDF button
                _isExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppTheme.goldColor),
                        ),
                      )
                    : InkWell(
                        onTap: provider.filteredTransactions.isEmpty
                            ? null
                            : () => _exportToPdf(context, provider),
                        child: Row(
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              color: provider.filteredTransactions.isEmpty
                                  ? Colors.grey
                                  : AppTheme.goldDark,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'exportPdf'.tr(),
                              style: TextStyle(
                                color: provider.filteredTransactions.isEmpty
                                    ? Colors.grey
                                    : AppTheme.goldDark,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),

          // Transaction list
          Expanded(
            child: provider.filteredTransactions.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = provider.filteredTransactions[index];
                      return TransactionListItem(
                        transaction: transaction,
                        onTap: () =>
                            _navigateToTransactionDetails(context, transaction),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Build filter section
  Widget _buildFilterSection(
      BuildContext context, TransactionProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CustomCard(
        borderRadius: 16,
        elevation: 1,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter header with right-aligned "filter" text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(), // Empty widget for spacing
                Text(
                  'filter'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Transaction type filter
            Text(
              'transactionType'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTypeFilterChip(
                    context,
                    null,
                    'all'.tr(),
                    provider,
                  ),
                  ...TransactionType.values.map((type) {
                    return _buildTypeFilterChip(
                      context,
                      type,
                      type.translationKey.tr(),
                      provider,
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Transaction status filter
            Text(
              'transactionStatus'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusFilterChip(
                    context,
                    null,
                    'all'.tr(),
                    provider,
                  ),
                  ...TransactionStatus.values.map((status) {
                    return _buildStatusFilterChip(
                      context,
                      status,
                      status.translationKey.tr(),
                      provider,
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Reset filters button
            Center(
              child: TextButton(
                onPressed: () {
                  provider.resetFilters();
                  _searchController.clear();
                },
                child: Text(
                  'resetFilters'.tr(),
                  style: TextStyle(
                    color: AppTheme.goldDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build type filter chip
  Widget _buildTypeFilterChip(
    BuildContext context,
    TransactionType? type,
    String label,
    TransactionProvider provider,
  ) {
    final isSelected = provider.selectedType == type;
    final Color chipColor = type?.color ?? AppTheme.goldColor;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          provider.setTypeFilter(selected ? type : null);
        },
        backgroundColor: Colors.grey[200],
        selectedColor: isSelected
            ? (type == null ? AppTheme.goldColor : chipColor)
            : Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isSelected
              ? BorderSide.none
              : BorderSide(color: Colors.grey[300]!),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        avatar: isSelected
            ? Icon(
                Icons.check,
                size: 14,
                color: Colors.white,
              )
            : null,
      ),
    );
  }

  /// Build status filter chip
  Widget _buildStatusFilterChip(
    BuildContext context,
    TransactionStatus? status,
    String label,
    TransactionProvider provider,
  ) {
    final isSelected = provider.selectedStatus == status;
    final Color chipColor = status?.color ?? AppTheme.goldColor;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          provider.setStatusFilter(selected ? status : null);
        },
        backgroundColor: Colors.grey[200],
        selectedColor: isSelected
            ? (status == null ? AppTheme.goldColor : chipColor)
            : Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isSelected
              ? BorderSide.none
              : BorderSide(color: Colors.grey[300]!),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        avatar: isSelected
            ? Icon(
                Icons.check,
                size: 14,
                color: Colors.white,
              )
            : null,
      ),
    );
  }

  /// Export transactions to PDF
  Future<void> _exportToPdf(
      BuildContext context, TransactionProvider provider) async {
    // Store context values before async operations

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    setState(() {
      _isExporting = true;
    });

    try {
      final filePath = await PdfExportUtil.exportTransactions(
        provider.filteredTransactions,
        'transactionReport'.tr(),
        'USD',
      );

      // Open the PDF file
      await PdfExportUtil.openPdf(filePath);

      // Check if the widget is still mounted before showing the snackbar
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('exportSuccess'.tr()),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      // Check if the widget is still mounted before showing the snackbar
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('exportFailed'.tr()),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      // Check if the widget is still mounted before updating state
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  /// Navigate to transaction details
  void _navigateToTransactionDetails(
      BuildContext context, Transaction transaction) {
    Navigator.pushNamed(
      context,
      AppRoutes.transactionDetail,
      arguments: transaction.id,
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'noTransactionsFound'.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'tryDifferentFilters'.tr(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'reset_filters'.tr(),
            onPressed: () {
              Provider.of<TransactionProvider>(context, listen: false)
                  .resetFilters();
              _searchController.clear();
              setState(() {
                _isFilterExpanded = false;
              });
            },
            type: ButtonType.secondary,
            textColor: AppTheme.goldDark,
          ),
        ],
      ),
    );
  }
}
