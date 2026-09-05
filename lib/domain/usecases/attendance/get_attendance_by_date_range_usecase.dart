import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:psa_academy/core/errors/failures.dart';
import 'package:psa_academy/core/usecases/usecase.dart';
import 'package:psa_academy/domain/entities/attendance_entity.dart';
import 'package:psa_academy/domain/repositories/attendance_repository.dart';

class GetAttendanceByDateRangeUseCase
    implements UseCase<List<AttendanceEntity>, GetAttendanceByDateRangeParams> {
  final AttendanceRepository repository;

  GetAttendanceByDateRangeUseCase(this.repository);

  @override
  Future<Either<Failure, List<AttendanceEntity>>> call(
    GetAttendanceByDateRangeParams params,
  ) async {
    return await repository.getAttendanceByDateRange(
      params.startDate,
      params.endDate,
    );
  }
}

class GetAttendanceByDateRangeParams extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const GetAttendanceByDateRangeParams({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
}
