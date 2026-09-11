import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/order_model.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/order_tile.dart';
import 'orders_provider.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Orders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primaryAccent,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'Open Orders'),
              Tab(text: 'Order History'),
              Tab(text: 'Trade History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOpenOrdersTab(ref),
            _buildOrderHistoryTab(ref),
            _buildTradeHistoryTab(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenOrdersTab(WidgetRef ref) {
    final openOrdersAsync = ref.watch(openOrdersProvider);

    return openOrdersAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return const Center(
            child: Text('No open orders', style: TextStyle(color: AppColors.textSecondary)),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(openOrdersProvider),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderTile(
                order: order,
                onCancel: () async {
                  await ref.read(orderRepositoryProvider).cancelOrder(order.id);
                  ref.invalidate(openOrdersProvider);
                  ref.invalidate(orderHistoryProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Order ${order.id} canceled')),
                    );
                  }
                },
              );
            },
          ),
        );
      },
      loading: () => const LoadingWidget(),
      error: (err, stack) => CustomErrorWidget(
        message: 'Failed to load open orders',
        onRetry: () => ref.refresh(openOrdersProvider),
      ),
    );
  }

  Widget _buildOrderHistoryTab(WidgetRef ref) {
    final historyAsync = ref.watch(orderHistoryProvider);

    return historyAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return const Center(
            child: Text('No order history', style: TextStyle(color: AppColors.textSecondary)),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(orderHistoryProvider),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return OrderTile(order: orders[index]);
            },
          ),
        );
      },
      loading: () => const LoadingWidget(),
      error: (_, __) => CustomErrorWidget(
        message: 'Failed to load order history',
        onRetry: () => ref.refresh(orderHistoryProvider),
      ),
    );
  }

  Widget _buildTradeHistoryTab(WidgetRef ref) {
    final tradeAsync = ref.watch(tradeHistoryProvider);

    return tradeAsync.when(
      data: (trades) {
        if (trades.isEmpty) {
          return const Center(
            child: Text('No executed trades', style: TextStyle(color: AppColors.textSecondary)),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(tradeHistoryProvider),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: trades.length,
            itemBuilder: (context, index) {
              return OrderTile(order: trades[index]);
            },
          ),
        );
      },
      loading: () => const LoadingWidget(),
      error: (_, __) => CustomErrorWidget(
        message: 'Failed to load trade history',
        onRetry: () => ref.refresh(tradeHistoryProvider),
      ),
    );
  }
}
