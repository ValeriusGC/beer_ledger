// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'axis_contribution.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AxisContribution {

 LedgerAxisKind get kind; double get signedBaseDelta; String get enteredInId;
/// Create a copy of AxisContribution
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AxisContributionCopyWith<AxisContribution> get copyWith => _$AxisContributionCopyWithImpl<AxisContribution>(this as AxisContribution, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AxisContribution&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.signedBaseDelta, signedBaseDelta) || other.signedBaseDelta == signedBaseDelta)&&(identical(other.enteredInId, enteredInId) || other.enteredInId == enteredInId));
}


@override
int get hashCode => Object.hash(runtimeType,kind,signedBaseDelta,enteredInId);

@override
String toString() {
  return 'AxisContribution(kind: $kind, signedBaseDelta: $signedBaseDelta, enteredInId: $enteredInId)';
}


}

/// @nodoc
abstract mixin class $AxisContributionCopyWith<$Res>  {
  factory $AxisContributionCopyWith(AxisContribution value, $Res Function(AxisContribution) _then) = _$AxisContributionCopyWithImpl;
@useResult
$Res call({
 LedgerAxisKind kind, double signedBaseDelta, String enteredInId
});




}
/// @nodoc
class _$AxisContributionCopyWithImpl<$Res>
    implements $AxisContributionCopyWith<$Res> {
  _$AxisContributionCopyWithImpl(this._self, this._then);

  final AxisContribution _self;
  final $Res Function(AxisContribution) _then;

/// Create a copy of AxisContribution
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? signedBaseDelta = null,Object? enteredInId = null,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as LedgerAxisKind,signedBaseDelta: null == signedBaseDelta ? _self.signedBaseDelta : signedBaseDelta // ignore: cast_nullable_to_non_nullable
as double,enteredInId: null == enteredInId ? _self.enteredInId : enteredInId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AxisContribution].
extension AxisContributionPatterns on AxisContribution {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AxisContribution value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AxisContribution() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AxisContribution value)  $default,){
final _that = this;
switch (_that) {
case _AxisContribution():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AxisContribution value)?  $default,){
final _that = this;
switch (_that) {
case _AxisContribution() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LedgerAxisKind kind,  double signedBaseDelta,  String enteredInId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AxisContribution() when $default != null:
return $default(_that.kind,_that.signedBaseDelta,_that.enteredInId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LedgerAxisKind kind,  double signedBaseDelta,  String enteredInId)  $default,) {final _that = this;
switch (_that) {
case _AxisContribution():
return $default(_that.kind,_that.signedBaseDelta,_that.enteredInId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LedgerAxisKind kind,  double signedBaseDelta,  String enteredInId)?  $default,) {final _that = this;
switch (_that) {
case _AxisContribution() when $default != null:
return $default(_that.kind,_that.signedBaseDelta,_that.enteredInId);case _:
  return null;

}
}

}

/// @nodoc


class _AxisContribution implements AxisContribution {
  const _AxisContribution({required this.kind, required this.signedBaseDelta, required this.enteredInId});
  

@override final  LedgerAxisKind kind;
@override final  double signedBaseDelta;
@override final  String enteredInId;

/// Create a copy of AxisContribution
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AxisContributionCopyWith<_AxisContribution> get copyWith => __$AxisContributionCopyWithImpl<_AxisContribution>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AxisContribution&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.signedBaseDelta, signedBaseDelta) || other.signedBaseDelta == signedBaseDelta)&&(identical(other.enteredInId, enteredInId) || other.enteredInId == enteredInId));
}


@override
int get hashCode => Object.hash(runtimeType,kind,signedBaseDelta,enteredInId);

@override
String toString() {
  return 'AxisContribution(kind: $kind, signedBaseDelta: $signedBaseDelta, enteredInId: $enteredInId)';
}


}

/// @nodoc
abstract mixin class _$AxisContributionCopyWith<$Res> implements $AxisContributionCopyWith<$Res> {
  factory _$AxisContributionCopyWith(_AxisContribution value, $Res Function(_AxisContribution) _then) = __$AxisContributionCopyWithImpl;
@override @useResult
$Res call({
 LedgerAxisKind kind, double signedBaseDelta, String enteredInId
});




}
/// @nodoc
class __$AxisContributionCopyWithImpl<$Res>
    implements _$AxisContributionCopyWith<$Res> {
  __$AxisContributionCopyWithImpl(this._self, this._then);

  final _AxisContribution _self;
  final $Res Function(_AxisContribution) _then;

/// Create a copy of AxisContribution
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? signedBaseDelta = null,Object? enteredInId = null,}) {
  return _then(_AxisContribution(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as LedgerAxisKind,signedBaseDelta: null == signedBaseDelta ? _self.signedBaseDelta : signedBaseDelta // ignore: cast_nullable_to_non_nullable
as double,enteredInId: null == enteredInId ? _self.enteredInId : enteredInId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
