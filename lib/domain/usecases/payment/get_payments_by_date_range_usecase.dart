import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:psa_academy/core/errors/failures.dart';
import 'package:psa_academy/core/usecases/usecase.dart';
import 'package:psa_academy/domain/entities/payment_entity.dart';
import 'package:psa_academy/domain/repositories/payment_repository.dart';

class GetPaymentsByDateRangeUseCase
    implements UseCase<List<PaymentEntity>, GetPaymentsByDateRangeParams> {
  final PaymentRepository repository;

  GetPaymentsByDateRangeUseCase(this.repository);

  @override
  Future<Either<Failure, List<PaymentEntity>>> call(
    GetPaymentsByDateRangeParams params,
  ) async {
    return await repository.getPaymentsByDateRange(
      params.startDate,
      params.endDate,
    );
  }
}

class GetPaymentsByDateRangeParams extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const GetPaymentsByDateRangeParams({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
}
