import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/order_book_model.dart';
import '../../../shared/models/order_model.dart';
import '../../../shared/widgets/buy_sell_toggle.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/order_book_widget.dart';
import '../../../shared/widgets/percentage_shortcuts.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/trading_input.dart';
import '../../home/presentation/home_provider.dart';
import '../../orders/presentation/orders_provider.dart';
import 'order_book_provider.dart';
import 'trading_provider.dart';

class TradingScreen extends ConsumerStatefulWidget {
  final String? initialPair;

  const TradingScreen({super.key, this.initialPair});

  @override
  ConsumerState<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends ConsumerState<TradingScreen> {
  late TextEditingController _priceController;
  late TextEditingController _stopPriceController;
  late TextEditingController _amountController;
  late TextEditingController _totalController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController();
    _stopPriceController = TextEditingController();
    _amountController = TextEditingController();
    _totalController = TextEditingController();

    if (widget.initialPair != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedTradingPairProvider.notifier).state = widget.initialPair!;
      });
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _stopPriceController.dispose();
    _amountController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  void _syncInputsWithState(TradingFormState form) {
    if (_priceController.text.isEmpty && form.price > 0) {
      _priceController.text = form.price.toStringAsFixed(2);
    }
    if (_amountController.text.isEmpty && form.amount > 0) {
      _amountController.text = form.amount.toStringAsFixed(4);
    }
  }

  void _showPairSelectorDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Trading Pair', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: AppConstants.popularSymbols.length,
                  itemBuilder: (context, index) {
                    final symbol = '${AppConstants.popularSymbols[index]}/USDT';
                    return ListTile(
                      title: Text(symbol, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () {
                        ref.read(selectedTradingPairProvider.notifier).state = symbol;
                        _priceController.clear();
                        _amountController.clear();
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOrderConfirmation(OrderModel order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.profitGreen, size: 48),
              const SizedBox(height: 12),
              const Text('Order Placed Successfully!', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildConfirmRow('Pair', order.pair),
              _buildConfirmRow('Type', order.type.name.toUpperCase()),
              _buildConfirmRow('Side', order.side.name.toUpperCase()),
              _buildConfirmRow('Price', Formatters.currency(order.price)),
              _buildConfirmRow('Amount', '${order.amount}'),
              _buildConfirmRow('Total', Formatters.currency(order.total)),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Done',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pair = ref.watch(selectedTradingPairProvider);
    final orderBookAsync = ref.watch(orderBookProvider);
    final formState = ref.watch(tradingNotifierProvider);
    final formNotifier = ref.read(tradingNotifierProvider.notifier);
    final walletAsync = ref.watch(walletOverviewProvider);

    final availableUsdt = walletAsync.asData?.value.fiatBalance ?? 10000.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => _showPairSelectorDialog(context),
          child: Row(
            children: [
              Text(pair, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primaryAccent),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Trading Form Controls
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Buy / Sell Toggle
                  BuySellToggle(
                    isBuySelected: formState.orderSide == OrderSide.buy,
                    onChanged: (isBuy) {
                      formNotifier.setOrderSide(isBuy ? OrderSide.buy : OrderSide.sell);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Order Type Selector
                  DropdownButtonFormField<OrderType>(
                    value: formState.orderType,
                    dropdownColor: AppColors.surfaceLight,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: OrderType.limit, child: Text('Limit Order')),
                      DropdownMenuItem(value: OrderType.market, child: Text('Market Order')),
                      DropdownMenuItem(value: OrderType.stopLimit, child: Text('Stop-Limit Order')),
                    ],
                    onChanged: (val) {
                      if (val != null) formNotifier.setOrderType(val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Available Balance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Avail', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                      Text(
                        Formatters.currency(availableUsdt),
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Stop Price Input (if Stop-Limit)
                  if (formState.orderType == OrderType.stopLimit) ...[
                    TradingInput(
                      label: 'Stop',
                      suffix: 'USDT',
                      controller: _stopPriceController,
                      onChanged: (val) {
                        final parsed = double.tryParse(val) ?? 0;
                        formNotifier.updateStopPrice(parsed);
                      },
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Price Input
                  TradingInput(
                    label: 'Price',
                    suffix: 'USDT',
                    readOnly: formState.orderType == OrderType.market,
                    controller: _priceController,
                    onChanged: (val) {
                      final parsed = double.tryParse(val) ?? 0;
                      formNotifier.updatePrice(parsed);
                      _totalController.text = formState.total.toStringAsFixed(2);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Amount Input
                  TradingInput(
                    label: 'Amount',
                    suffix: pair.split('/')[0],
                    controller: _amountController,
                    onChanged: (val) {
                      final parsed = double.tryParse(val) ?? 0;
                      formNotifier.updateAmount(parsed);
                      _totalController.text = formState.total.toStringAsFixed(2);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Percentage Shortcuts
                  PercentageShortcuts(
                    onSelected: (percent) {
                      formNotifier.setPercentageOfBalance(percent, availableUsdt);
                      _amountController.text = formNotifier.state.amount.toStringAsFixed(4);
                      _totalController.text = formNotifier.state.total.toStringAsFixed(2);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Total Input
                  TradingInput(
                    label: 'Total',
                    suffix: 'USDT',
                    readOnly: true,
                    controller: TextEditingController(text: formState.total.toStringAsFixed(2)),
                  ),
                  const SizedBox(height: 20),

                  if (formState.errorMessage != null) ...[
                    Text(
                      formState.errorMessage!,
                      style: const TextStyle(color: AppColors.lossRed, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Action Submit Button
                  PrimaryButton(
                    text: '${formState.orderSide == OrderSide.buy ? 'Buy' : 'Sell'} ${pair.split('/')[0]}',
                    color: formState.orderSide == OrderSide.buy ? AppColors.profitGreen : AppColors.lossRed,
                    isLoading: formState.isLoading,
                    onPressed: () async {
                      final order = await formNotifier.submitOrder(
                        pair: pair,
                        availableBalance: availableUsdt,
                      );
                      if (order != null) {
                        await ref.read(orderRepositoryProvider).addOrder(order);
                        ref.invalidate(openOrdersProvider);
                        ref.invalidate(orderHistoryProvider);
                        _showOrderConfirmation(order);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Right Column: Order Book
            Expanded(
              flex: 5,
              child: orderBookAsync.when(
                data: (book) {
                  _syncInputsWithState(formState.price > 0 ? formState : formState.copyWith(price: book.currentPrice));
                  return OrderBookWidget(
                    orderBook: book,
                    onPriceSelect: (selectedPrice) {
                      _priceController.text = selectedPrice.toStringAsFixed(2);
                      formNotifier.updatePrice(selectedPrice);
                    },
                  );
                },
                loading: () => const SizedBox(height: 300, child: LoadingWidget()),
                error: (err, stack) => const CustomErrorWidget(message: 'WebSocket stream offline'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
