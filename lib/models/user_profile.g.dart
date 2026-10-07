// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UserProfileCWProxy {
  UserProfile name(String? name);

  UserProfile birthDate(DateTime? birthDate);

  UserProfile gender(Gender? gender);

  UserProfile lookingForGender(Gender? lookingForGender);

  UserProfile custodies(Custodies? custodies);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `UserProfile(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// UserProfile(...).copyWith(id: 12, name: "My name")
  /// ```
  UserProfile call({
    String? name,
    DateTime? birthDate,
    Gender? gender,
    Gender? lookingForGender,
    Custodies? custodies,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfUserProfile.copyWith(...)` or call `instanceOfUserProfile.copyWith.fieldName(value)` for a single field.
class _$UserProfileCWProxyImpl implements _$UserProfileCWProxy {
  const _$UserProfileCWProxyImpl(this._value);

  final UserProfile _value;

  @override
  UserProfile name(String? name) => call(name: name);

  @override
  UserProfile birthDate(DateTime? birthDate) => call(birthDate: birthDate);

  @override
  UserProfile gender(Gender? gender) => call(gender: gender);

  @override
  UserProfile lookingForGender(Gender? lookingForGender) =>
      call(lookingForGender: lookingForGender);

  @override
  UserProfile custodies(Custodies? custodies) => call(custodies: custodies);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `UserProfile(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// UserProfile(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  UserProfile call({
    Object? name = const $CopyWithPlaceholder(),
    Object? birthDate = const $CopyWithPlaceholder(),
    Object? gender = const $CopyWithPlaceholder(),
    Object? lookingForGender = const $CopyWithPlaceholder(),
    Object? custodies = const $CopyWithPlaceholder(),
  }) {
    return UserProfile(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      birthDate: birthDate == const $CopyWithPlaceholder()
          ? _value.birthDate
          // ignore: cast_nullable_to_non_nullable
          : birthDate as DateTime?,
      gender: gender == const $CopyWithPlaceholder()
          ? _value.gender
          // ignore: cast_nullable_to_non_nullable
          : gender as Gender?,
      lookingForGender: lookingForGender == const $CopyWithPlaceholder()
          ? _value.lookingForGender
          // ignore: cast_nullable_to_non_nullable
          : lookingForGender as Gender?,
      custodies: custodies == const $CopyWithPlaceholder()
          ? _value.custodies
          // ignore: cast_nullable_to_non_nullable
          : custodies as Custodies?,
    );
  }
}

extension $UserProfileCopyWith on UserProfile {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfUserProfile.copyWith(...)` or `instanceOfUserProfile.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UserProfileCWProxy get copyWith => _$UserProfileCWProxyImpl(this);
}

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
