import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:psa_academy/core/errors/failures.dart';
import 'package:psa_academy/core/usecases/usecase.dart';
import 'package:psa_academy/domain/entities/expense_entity.dart';
import 'package:psa_academy/domain/repositories/expense_repository.dart';

class GetExpensesByDateRangeUseCase
    implements UseCase<List<ExpenseEntity>, GetExpensesByDateRangeParams> {
  final ExpenseRepository repository;

  GetExpensesByDateRangeUseCase(this.repository);

  @override
  Future<Either<Failure, List<ExpenseEntity>>> call(
    GetExpensesByDateRangeParams params,
  ) async {
    return await repository.getExpensesByDateRange(
      params.startDate,
      params.endDate,
    );
  }
}

class GetExpensesByDateRangeParams extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const GetExpensesByDateRangeParams({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
}
