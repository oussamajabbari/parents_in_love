// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  name: json['name'] as String?,
  birthDate: json['birthDate'] == null
      ? null
      : DateTime.parse(json['birthDate'] as String),
  gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
  lookingForGender: $enumDecodeNullable(
    _$GenderEnumMap,
    json['lookingForGender'],
  ),
  custodies: json['custodies'] == null
      ? null
      : Custodies.fromJson(json['custodies'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'name': instance.name,
      'birthDate': instance.birthDate?.toIso8601String(),
      'gender': _$GenderEnumMap[instance.gender],
      'lookingForGender': _$GenderEnumMap[instance.lookingForGender],
      'custodies': instance.custodies?.toJson(),
    };

const _$GenderEnumMap = {
  Gender.woman: 'woman',
  Gender.man: 'man',
  Gender.whatever: 'whatever',
};
