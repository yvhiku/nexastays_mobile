import 'package:equatable/equatable.dart';

class FeeBreakdown extends Equatable {
  final double basePrice;
  final double serviceFee;
  final double taxes;
  final double total;

  const FeeBreakdown({
    required this.basePrice,
    required this.serviceFee,
    required this.taxes,
    required this.total,
  });

  @override
  List<Object?> get props => [
        basePrice,
        serviceFee,
        taxes,
        total,
      ];
}
