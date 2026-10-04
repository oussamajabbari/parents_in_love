// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custodies.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecurrentCustody _$RecurrentCustodyFromJson(Map<String, dynamic> json) =>
    RecurrentCustody(
        startDate: DateTime.parse(json['startDate'] as String),
        repeatEvery: (json['repeatEvery'] as num).toInt(),
        repeatBase: $enumDecode(_$RepeatBaseEnumMap, json['repeatBase']),
      )
      ..endDateExcluded = json['endDateExcluded'] == null
          ? null
          : DateTime.parse(json['endDateExcluded'] as String);

Map<String, dynamic> _$RecurrentCustodyToJson(RecurrentCustody instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'repeatEvery': instance.repeatEvery,
      'repeatBase': _$RepeatBaseEnumMap[instance.repeatBase]!,
      'endDateExcluded': instance.endDateExcluded?.toIso8601String(),
    };

const _$RepeatBaseEnumMap = {RepeatBase.day: 'day', RepeatBase.week: 'week'};

Custodies _$CustodiesFromJson(Map<String, dynamic> json) => Custodies(
  reccurentCustodies: (json['reccurentCustodies'] as List<dynamic>)
      .map((e) => RecurrentCustody.fromJson(e as Map<String, dynamic>))
      .toList(),
  exceptionalCustodies: (json['exceptionalCustodies'] as List<dynamic>)
      .map((e) => DateTime.parse(e as String))
      .toList(),
  exceptionalNoCustodies: (json['exceptionalNoCustodies'] as List<dynamic>)
      .map((e) => DateTime.parse(e as String))
      .toList(),
);

Map<String, dynamic> _$CustodiesToJson(Custodies instance) => <String, dynamic>{
  'reccurentCustodies': instance.reccurentCustodies
      .map((e) => e.toJson())
      .toList(),
  'exceptionalCustodies': instance.exceptionalCustodies
      .map((e) => e.toIso8601String())
      .toList(),
  'exceptionalNoCustodies': instance.exceptionalNoCustodies
      .map((e) => e.toIso8601String())
      .toList(),
};
