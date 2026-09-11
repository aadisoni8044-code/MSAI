import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/asset_tile.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../home/presentation/home_provider.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  void _showDepositModal(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    String selectedCoin = 'USDT';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Deposit Funds', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCoin,
                dropdownColor: AppColors.surfaceLight,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Select Coin'),
                items: ['USDT', ...AppConstants.popularSymbols]
                    .map((sym) => DropdownMenuItem(value: sym, child: Text(sym)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) selectedCoin = val;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Deposit Amount',
                  hintText: 'Enter amount',
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: 'Confirm Deposit',
                onPressed: () async {
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (amount > 0) {
                    await ref.read(walletRepositoryProvider).deposit(selectedCoin, amount);
                    ref.invalidate(walletOverviewProvider);
                    ref.invalidate(recentTransactionsProvider);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Successfully deposited $amount $selectedCoin')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWithdrawModal(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final addressController = TextEditingController();
    String selectedCoin = 'USDT';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Withdraw Funds', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCoin,
                dropdownColor: AppColors.surfaceLight,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Select Coin'),
                items: ['USDT', ...AppConstants.popularSymbols]
                    .map((sym) => DropdownMenuItem(value: sym, child: Text(sym)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) selectedCoin = val;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Destination Wallet Address',
                  hintText: '0x...',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Withdraw Amount',
                  hintText: 'Enter amount',
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: 'Confirm Withdrawal',
                onPressed: () async {
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (amount > 0 && addressController.text.isNotEmpty) {
                    try {
                      await ref.read(walletRepositoryProvider).withdraw(
                            selectedCoin,
                            amount,
                            addressController.text.trim(),
                          );
                      ref.invalidate(walletOverviewProvider);
                      ref.invalidate(recentTransactionsProvider);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Successfully withdrew $amount $selectedCoin')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.lossRed),
                        );
                      }
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTransferModal(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Internal Transfer', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(8)),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('From', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                          SizedBox(height: 4),
                          Text('Spot Account', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.swap_horiz_rounded, color: AppColors.primaryAccent),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(8)),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('To', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                          SizedBox(height: 4),
                          Text('Futures Account', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Transfer Amount (USDT)',
                  hintText: 'Enter amount',
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: 'Confirm Transfer',
                onPressed: () async {
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (amount > 0) {
                    await ref.read(walletRepositoryProvider).transfer('Spot', 'Futures', amount);
                    ref.invalidate(walletOverviewProvider);
                    ref.invalidate(recentTransactionsProvider);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Transferred \$${amount.toStringAsFixed(2)} USDT to Futures')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletOverviewProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Wallet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: walletAsync.when(
        data: (wallet) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(walletOverviewProvider),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Wallet Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.surfaceLight, AppColors.surface],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Estimated Value', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        const SizedBox(height: 8),
                        Text(
                          Formatters.currency(wallet.totalPortfolioValue),
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'Fiat Balance: ${Formatters.currency(wallet.fiatBalance)}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: PrimaryButton(
                                text: 'Deposit',
                                height: 40,
                                onPressed: () => _showDepositModal(context, ref),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: PrimaryButton(
                                text: 'Withdraw',
                                height: 40,
                                color: AppColors.surfaceHighlight,
                                onPressed: () => _showWithdrawModal(context, ref),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: PrimaryButton(
                                text: 'Transfer',
                                height: 40,
                                color: AppColors.surfaceHighlight,
                                onPressed: () => _showTransferModal(context, ref),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Assets List
                  const Text('Crypto Holdings', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: wallet.cryptoAssets.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
                    itemBuilder: (context, index) {
                      return AssetTile(asset: wallet.cryptoAssets[index]);
                    },
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (err, stack) => CustomErrorWidget(
          message: 'Failed to load wallet assets',
          onRetry: () => ref.refresh(walletOverviewProvider),
        ),
      ),
    );
  }
}
