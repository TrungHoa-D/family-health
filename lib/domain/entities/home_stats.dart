import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_stats.freezed.dart';

@freezed
class HomeStats with _$HomeStats {
  const factory HomeStats({
    @Default(0) int totalDoses,
    @Default(0) int takenDoses,
    @Default(0) int missedDoses,
    @Default(0.0) double completionPercentage,
  }) = _HomeStats;
}
