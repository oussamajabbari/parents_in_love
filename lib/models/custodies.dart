import 'package:json_annotation/json_annotation.dart';

part 'custodies.g.dart';

enum RepeatBase {
  day(value: 'day'),
  week(value: 'week');

  const RepeatBase({required this.value});

  final String value;
}

enum CustodyStatus {
  noCustody,
  recurrentCustody,
  exceptionalCustody,
  exceptionalNoCustody,
}

@JsonSerializable()
class RecurrentCustody {
  final DateTime startDate;
  int repeatEvery;
  RepeatBase repeatBase;
  DateTime? endDateExcluded;

  RecurrentCustody({
    required this.startDate,
    required this.repeatEvery,
    required this.repeatBase,
  });

  factory RecurrentCustody.fromJson(Map<String, dynamic> json) =>
      _$RecurrentCustodyFromJson(json);

  Map<String, dynamic> toJson() => _$RecurrentCustodyToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Custodies {
  List<RecurrentCustody> reccurentCustodies = [];
  List<DateTime> exceptionalCustodies = [];
  List<DateTime> exceptionalNoCustodies = [];

  Custodies({
    required this.reccurentCustodies,
    required this.exceptionalCustodies,
    required this.exceptionalNoCustodies,
  });

  factory Custodies.fromJson(Map<String, dynamic> json) =>
      _$CustodiesFromJson(json);

  Map<String, dynamic> toJson() => _$CustodiesToJson(this);

  bool _doesDayMatchRecurrentCustodyDefinition(
    DateTime date,
    RecurrentCustody reccurentCustody,
  ) {
    if (date.isBefore(reccurentCustody.startDate)) {
      return false;
    }

    if (reccurentCustody.endDateExcluded != null) {
      if (date.isAtSameMomentAs(reccurentCustody.endDateExcluded!) ||
          date.isAfter(reccurentCustody.endDateExcluded!)) {
        return false;
      }
    }

    var delta = date.difference(reccurentCustody.startDate);
    if (reccurentCustody.repeatBase == RepeatBase.day) {
      if (delta.inDays % reccurentCustody.repeatEvery == 0) {
        return true;
      }
    } else {
      final deltaWeeks = delta.inDays / 7;
      final deltaWeeksRemainder = delta.inDays % 7;
      if (deltaWeeksRemainder == 0 &&
          deltaWeeks % reccurentCustody.repeatEvery == 0) {
        return true;
      }
    }

    return false;
  }

  CustodyStatus getCustodyStatusForDate(DateTime date) {
    if (exceptionalCustodies.contains(date)) {
      return .exceptionalCustody;
    }
    if (exceptionalNoCustodies.contains(date)) {
      return .exceptionalNoCustody;
    }

    for (var reccurentCustody in reccurentCustodies) {
      if (_doesDayMatchRecurrentCustodyDefinition(date, reccurentCustody)) {
        return .recurrentCustody;
      } else {
        continue;
      }
    }

    return .noCustody;
  }

  Iterable<RecurrentCustody> getMatchingReccurentCustodiesForDate(
    DateTime date,
  ) {
    return reccurentCustodies.where(
      (reccurentCustody) =>
          _doesDayMatchRecurrentCustodyDefinition(date, reccurentCustody),
    );
  }

  bool isEmpty() {
    return reccurentCustodies.isEmpty &&
        exceptionalCustodies.isEmpty &&
        exceptionalNoCustodies.isEmpty;
  }
}
