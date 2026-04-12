import 'package:freezed_annotation/freezed_annotation.dart';

part 'member_stats.freezed.dart';

/// Thống kê tiến độ uống thuốc của một thành viên trong ngày
@freezed
class MemberStats with _$MemberStats {
  const factory MemberStats({
    required String userId,
    required String displayName,
    String? avatarUrl,
    @Default(0) int takenDoses,
    @Default(0) int totalDoses,
  }) = _MemberStats;
}
