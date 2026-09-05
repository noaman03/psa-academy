import 'package:equatable/equatable.dart';

class CoachWorkSessionEntity extends Equatable {
  final String id;
  final String coachId;
  final String? coachName;
  final DateTime checkIn;
  final DateTime? checkOut;
  final double hoursWorked;
  final double calculatedSalary;
  final DateTime date;

  const CoachWorkSessionEntity({
    required this.id,
    required this.coachId,
    this.coachName,
    required this.checkIn,
    this.checkOut,
    this.hoursWorked = 0.0,
    this.calculatedSalary = 0.0,
    required this.date,
  });

  bool get isActiveSession => checkOut == null;

  @override
  List<Object?> get props => [
        id,
        coachId,
        coachName,
        checkIn,
        checkOut,
        hoursWorked,
        calculatedSalary,
        date,
      ];
}
