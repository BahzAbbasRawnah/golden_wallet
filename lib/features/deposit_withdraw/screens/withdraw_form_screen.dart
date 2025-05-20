import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/deposit_withdraw/models/deposit_withdraw_model.dart';
import 'package:golden_wallet/features/deposit_withdraw/providers/deposit_withdraw_provider.dart';
import 'package:golden_wallet/features/deposit_withdraw/screens/transaction_confirmation_screen.dart';
import 'package:golden_wallet/features/deposit_withdraw/utils/validation_utils.dart';
import 'package:golden_wallet/shared/widgets/custom_button.dart';
import 'package:golden_wallet/shared/widgets/custom_card.dart';
import 'package:golden_wallet/shared/widgets/custom_text_field.dart';

/// Screen for withdraw form
class WithdrawFormScreen extends StatefulWidget {
  const WithdrawFormScreen({Key? key}) : super(key: key);

  @override
  State<WithdrawFormScreen> createState() => _WithdrawFormScreenState();
}

class _WithdrawFormScreenState extends State<WithdrawFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DepositWithdrawMethod _selectedMethod = DepositWithdrawMethod.bankTransfer;

  // Bank transfer details
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountHolderNameController = TextEditingController();
  final _swiftCodeController = TextEditingController();
  final _ibanController = TextEditingController();

  // Card payment details
  final _cardNumberController = TextEditingController();
  final _cardHolderNameController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  // Reference number
  final _referenceController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderNameController.dispose();
    _swiftCodeController.dispose();
    _ibanController.dispose();
    _cardNumberController.dispose();
    _cardHolderNameController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final depositWithdrawProvider =
        Provider.of<DepositWithdrawProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('WithdrawFunds'.tr()),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Available balance
                  _buildAvailableBalance(context, depositWithdrawProvider),
                  const SizedBox(height: 24),

                  // Amount input
                  Text(
                    'amount'.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: Icons.attach_money,
                    hint: '0.00',
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      final error =
                          DepositWithdrawValidationUtils.validateAmount(
                        value,
                        depositWithdrawProvider.cashBalance,
                      );
                      if (error != null) {
                        return error.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Withdrawal method selection
                  Text(
                    'selectMethod'.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Method selection cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildMethodCard(
                          context: context,
                          method: DepositWithdrawMethod.bankTransfer,
                          isSelected: _selectedMethod ==
                              DepositWithdrawMethod.bankTransfer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMethodCard(
                          context: context,
                          method: DepositWithdrawMethod.cardPayment,
                          isSelected: _selectedMethod ==
                              DepositWithdrawMethod.cardPayment,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMethodCard(
                          context: context,
                          method: DepositWithdrawMethod.cash,
                          isSelected:
                              _selectedMethod == DepositWithdrawMethod.cash,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMethodCard(
                          context: context,
                          method: DepositWithdrawMethod.physicalGold,
                          isSelected: _selectedMethod ==
                              DepositWithdrawMethod.physicalGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Method specific details
                  _buildMethodDetails(),
                  const SizedBox(height: 24),

                  // Notes
                  Text(
                    'notes'.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _notesController,
                    maxLines: 3,
                    hint: 'notesOptional'.tr(),
                  ),
                  const SizedBox(height: 32),

                  // Continue button
                  CustomButton(
                    text: 'continue'.tr(),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _processWithdraw(depositWithdrawProvider);
                      }
                    },
                    type: ButtonType.primary,
                    icon: Icons.arrow_forward,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build available balance card
  Widget _buildAvailableBalance(
      BuildContext context, DepositWithdrawProvider provider) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.account_balance_wallet,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'availableBalance'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${provider.cashBalance.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build payment method card
  Widget _buildMethodCard({
    required BuildContext context,
    required DepositWithdrawMethod method,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? method.color.withAlpha(30) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? method.color : Colors.grey.withAlpha(100),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              method.icon,
              color: isSelected ? method.color : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              method.translationKey.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? method.color : null,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build method-specific details
  Widget _buildMethodDetails() {
    switch (_selectedMethod) {
      case DepositWithdrawMethod.bankTransfer:
        return _buildBankTransferDetails();
      case DepositWithdrawMethod.cardPayment:
        return _buildCardPaymentDetails();
      case DepositWithdrawMethod.cash:
        return _buildCashDetails();
      case DepositWithdrawMethod.physicalGold:
        return _buildPhysicalGoldDetails();
    }
  }

  /// Build bank transfer details
  Widget _buildBankTransferDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'bankDetails'.tr(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _bankNameController,
          label: 'bankName'.tr(),
          prefixIcon: Icons.account_balance,
          validator: (value) {
            final error =
                DepositWithdrawValidationUtils.validateBankName(value);
            if (error != null) {
              return error.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _accountNumberController,
          label: 'accountNumber'.tr(),
          prefixIcon: Icons.credit_card,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          validator: (value) {
            final error =
                DepositWithdrawValidationUtils.validateAccountNumber(value);
            if (error != null) {
              return error.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _accountHolderNameController,
          label: 'accountHolderName'.tr(),
          prefixIcon: Icons.person,
          validator: (value) {
            final error =
                DepositWithdrawValidationUtils.validateAccountHolderName(value);
            if (error != null) {
              return error.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _swiftCodeController,
          label: 'swiftCodeOptional'.tr(),
          prefixIcon: Icons.code,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _ibanController,
          label: 'ibanOptional'.tr(),
          prefixIcon: Icons.numbers,
        ),
      ],
    );
  }

  /// Build card payment details
  Widget _buildCardPaymentDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'cardDetails'.tr(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _cardNumberController,
          label: 'cardNumber'.tr(),
          prefixIcon: Icons.credit_card,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          validator: (value) {
            final error =
                DepositWithdrawValidationUtils.validateCardNumber(value);
            if (error != null) {
              return error.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _cardHolderNameController,
          label: 'cardHolderName'.tr(),
          prefixIcon: Icons.person,
          validator: (value) {
            final error =
                DepositWithdrawValidationUtils.validateCardHolderName(value);
            if (error != null) {
              return error.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _expiryDateController,
                label: 'expiryDate'.tr(),
                hint: 'MM/YY',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  _ExpiryDateInputFormatter(),
                ],
                validator: (value) {
                  final error =
                      DepositWithdrawValidationUtils.validateExpiryDate(value);
                  if (error != null) {
                    return error.tr();
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: _cvvController,
                label: 'cvv'.tr(),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (value) {
                  final error =
                      DepositWithdrawValidationUtils.validateCVV(value);
                  if (error != null) {
                    return error.tr();
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build cash details
  Widget _buildCashDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'cashWithdrawalInstructions'.tr(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        CustomCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'visitBranch'.tr(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text('cashWithdrawalStep1'.tr()),
              const SizedBox(height: 16),
              Text(
                'provideId'.tr(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text('cashWithdrawalStep2'.tr()),
              const SizedBox(height: 16),
              Text(
                'receiveCash'.tr(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text('cashWithdrawalStep3'.tr()),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _referenceController,
          label: 'transactionReferenceOptional'.tr(),
          prefixIcon: Icons.tag,
        ),
      ],
    );
  }

  /// Build physical gold details
  Widget _buildPhysicalGoldDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'physicalGoldWithdrawalInstructions'.tr(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        CustomCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'visitGoldCenter'.tr(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text('goldWithdrawalStep1'.tr()),
              const SizedBox(height: 16),
              Text(
                'verification'.tr(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text('goldWithdrawalStep2'.tr()),
              const SizedBox(height: 16),
              Text(
                'receiveGold'.tr(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text('goldWithdrawalStep3'.tr()),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _referenceController,
          label: 'transactionReference'.tr(),
          prefixIcon: Icons.tag,
        ),
      ],
    );
  }

  /// Process withdraw
  void _processWithdraw(DepositWithdrawProvider provider) {
    // Parse amount
    final amount = double.parse(_amountController.text);

    // Initialize withdraw transaction
    provider.initializeWithdraw(
      amount: amount,
      method: _selectedMethod,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    // Update method-specific details
    switch (_selectedMethod) {
      case DepositWithdrawMethod.bankTransfer:
        provider.updateBankDetails(
          bankName: _bankNameController.text,
          accountNumber: _accountNumberController.text,
          accountHolderName: _accountHolderNameController.text,
          swiftCode: _swiftCodeController.text.isNotEmpty
              ? _swiftCodeController.text
              : null,
          iban: _ibanController.text.isNotEmpty ? _ibanController.text : null,
        );
        break;
      case DepositWithdrawMethod.cardPayment:
        provider.updateCardDetails(
          cardNumber: _cardNumberController.text,
          cardHolderName: _cardHolderNameController.text,
          expiryDate: _expiryDateController.text,
          cvv: _cvvController.text,
        );
        break;
      default:
        break;
    }

    // Update reference if provided
    if (_referenceController.text.isNotEmpty) {
      provider.updateReference(_referenceController.text);
    }

    // Navigate to confirmation screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TransactionConfirmationScreen(),
      ),
    );
  }
}

/// Custom input formatter for expiry date (MM/YY)
class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    // Add slash after first two digits
    if (text.length == 2 && oldValue.text.length == 1) {
      return TextEditingValue(
        text: '$text/',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    }

    // Handle backspace at the slash position
    if (text.length == 2 && oldValue.text.length == 3) {
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }

    // Format as MM/YY
    if (text.length <= 2) {
      return newValue;
    } else if (text.length <= 5) {
      final month = text.substring(0, 2);
      final year = text.substring(2).replaceAll('/', '');

      return TextEditingValue(
        text: '$month/$year',
        selection: TextSelection.collapsed(offset: '$month/$year'.length),
      );
    }

    return oldValue;
  }
}
