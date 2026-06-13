/// 时间窗口工具类
///
/// 提供统一的起始时间计算，用于观察层、Memory层等需要按时间范围筛选数据的场景。
class TimeWindow {
  /// 最近 24 小时
  static DateTime start24h() =>
      DateTime.now().subtract(const Duration(hours: 24));

  /// 最近 7 天
  static DateTime start7d() =>
      DateTime.now().subtract(const Duration(days: 7));

  /// 最近 14 天
  static DateTime start14d() =>
      DateTime.now().subtract(const Duration(days: 14));

  /// 最近 30 天
  static DateTime start30d() =>
      DateTime.now().subtract(const Duration(days: 30));
}
