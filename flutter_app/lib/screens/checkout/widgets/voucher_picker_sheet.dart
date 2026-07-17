import 'package:flutter/material.dart';
import 'package:flutter_app/core.dart';
import 'package:provider/provider.dart';

class VoucherPickerSheet extends StatefulWidget {
  final int subtotal;
  final String? currentVoucherId;
  final ValueChanged<Voucher?> onSelect;

  const VoucherPickerSheet({
    super.key,
    required this.subtotal,
    this.currentVoucherId,
    required this.onSelect,
  });

  @override
  State<VoucherPickerSheet> createState() => VoucherPickerSheetState();
}

class VoucherPickerSheetState extends State<VoucherPickerSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SportZoneState>().fetchMyVouchers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final state = context.watch<SportZoneState>();
    final vouchers = state.availableVouchers.where((v) => !v.isUsed).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Material(
          color: SportZoneTheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 14),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: SportZoneTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Chọn Voucher',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              if (vouchers.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'Bạn chưa có voucher nào.',
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: vouchers.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final voucher = vouchers[index];
                      final isSelected = voucher.id == widget.currentVoucherId;
                      final isEligible =
                          widget.subtotal >= voucher.minOrderValue;

                      return InkWell(
                        onTap: isEligible
                            ? () => widget.onSelect(voucher)
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFE8F5E9)
                                : SportZoneTheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF00C853)
                                  : (isEligible
                                        ? SportZoneTheme.primary.withValues(
                                            alpha: 0.1,
                                          )
                                        : SportZoneTheme.borderSubtle),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isEligible && !isSelected
                                ? const [
                                    BoxShadow(
                                      color: Color(0x0A000000),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Opacity(
                            opacity: isEligible ? 1.0 : 0.5,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        voucher.code,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                          color: SportZoneTheme.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        voucher.discountDisplay,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF00C853),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Đơn tối thiểu: ${formatVnd(voucher.minOrderValue)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: SportZoneTheme.secondary,
                                            ),
                                      ),
                                      if (!isEligible) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Chưa đạt giá trị đơn tối thiểu',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: SportZoneTheme.error,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF00C853),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (widget.currentVoucherId != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => widget.onSelect(null),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: SportZoneTheme.error,
                        side: const BorderSide(color: SportZoneTheme.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('BỎ CHỌN VOUCHER'),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
