import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';

/// 统计页可切换的指标
enum _Metric {
  bloodPressure('血压'),
  bloodSugar('血糖'),
  weight('体重'),
  heartRate('心率'),
  temperature('体温');

  const _Metric(this.label);

  /// 指标的中文名称
  final String label;
}

/// 统计页可切换的时间范围
enum _Range {
  days7('近7天', 7),
  days30('近30天', 30),
  days90('近90天', 90),
  all('全部', null);

  const _Range(this.label, this.days);

  /// 范围的展示名称
  final String label;

  /// 天数；为 null 表示不限时间
  final int? days;
}

/// 图表中的一条折线
class _Series {
  _Series({required this.label, required this.color, required this.spots});

  /// 图例名称
  final String label;

  /// 线条颜色
  final Color color;

  /// 数据点
  final List<FlSpot> spots;
}

/// 数据统计页面
///
/// 以「概览卡片 + 趋势折线图」的形式展示健康指标，区别于单纯罗列记录的「记录」页。
class StatisticsPage extends StatefulWidget {
  /// 创建StatisticsPage实例
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  /// 已加载并按日期升序排列的健康记录
  final List<HealthRecord> _records = [];

  /// 是否仍在加载
  bool _loading = true;

  /// 当前时间范围
  _Range _range = _Range.days30;

  /// 当前展示的指标
  _Metric _metric = _Metric.bloodPressure;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// 加载健康记录
  Future<void> _loadData() async {
    List<HealthRecord> list;
    try {
      list = await loadHealthRecords();
    } catch (_) {
      list = [];
    }
    // 折线图按时间先后连线，先升序排序
    list.sort((a, b) => a.date.compareTo(b.date));
    if (!mounted) return;
    setState(() {
      _records
        ..clear()
        ..addAll(list);
      _loading = false;
    });
  }

  /// 按当前时间范围过滤记录
  List<HealthRecord> get _filtered {
    final days = _range.days;
    if (days == null) return _records;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _records.where((r) => !r.date.isBefore(cutoff)).toList();
  }

  /// 当前指标在 Y 轴上留出的上下余量
  ///
  /// 按各指标的常见波动幅度取值，避免曲线贴着图表边缘显得扁平。
  double get _yMargin => switch (_metric) {
        _Metric.bloodPressure => 10,
        _Metric.bloodSugar => 1,
        _Metric.weight => 2,
        _Metric.heartRate => 10,
        _Metric.temperature => 0.5,
      };

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final data = _filtered;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 时间范围切换
            Center(
              child: SegmentedButton<_Range>(
                segments: _Range.values
                    .map((r) => ButtonSegment<_Range>(
                          value: r,
                          label: Text(r.label),
                        ))
                    .toList(),
                selected: {_range},
                showSelectedIcon: false,
                onSelectionChanged: (selection) {
                  setState(() => _range = selection.first);
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '指标概览',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildOverview(context, data),
            const SizedBox(height: 20),
            const Text(
              '趋势图',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // 指标切换：用横向滚动的 Chip 而非分段按钮，避免 5 个指标在窄屏溢出
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _Metric.values.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final metric = _Metric.values[index];
                  return ChoiceChip(
                    label: Text(metric.label),
                    selected: _metric == metric,
                    onSelected: (_) => setState(() => _metric = metric),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildChartSection(context, data),
          ],
        ),
      ),
    );
  }

  /// 构建指标概览卡片区
  Widget _buildOverview(BuildContext context, List<HealthRecord> data) {
    // 取范围内「最新」一条记录，用药慢病场景更关心当前状态而非平均值
    HealthRecord? latestMatching(bool Function(HealthRecord) has) {
      for (var i = data.length - 1; i >= 0; i--) {
        if (has(data[i])) return data[i];
      }
      return null;
    }

    final bp = latestMatching(
        (r) => r.systolicPressure != null || r.diastolicPressure != null);
    final sugar = latestMatching((r) => r.bloodSugar != null);
    final weight = latestMatching((r) => r.weight != null);
    final heart = latestMatching((r) => r.heartRate != null);
    final temp = latestMatching((r) => r.temperature != null);

    final cards = <Widget>[
      _overviewCard(context, '记录条数', '${data.length}', '条', null),
      if (bp != null)
        _overviewCard(
          context,
          '血压',
          _formatBloodPressure(bp),
          'mmHg',
          bp.date,
        ),
      if (sugar != null)
        _overviewCard(context, '血糖', '${sugar.bloodSugar}', 'mmol/L', sugar.date),
      if (weight != null)
        _overviewCard(context, '体重', '${weight.weight}', 'kg', weight.date),
      if (heart != null)
        _overviewCard(context, '心率', '${heart.heartRate}', 'bpm', heart.date),
      if (temp != null)
        _overviewCard(context, '体温', '${temp.temperature}', '°C', temp.date),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: cards.map((card) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 44) / 2,
          child: card,
        );
      }).toList(),
    );
  }

  /// 构建单张概览卡片
  Widget _overviewCard(
    BuildContext context,
    String title,
    String value,
    String unit,
    DateTime? date,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
            if (date != null)
              Text(
                '${date.month}月${date.day}日',
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
              ),
          ],
        ),
      ),
    );
  }

  /// 拼接血压的展示文本
  String _formatBloodPressure(HealthRecord record) {
    final sys = record.systolicPressure;
    final dia = record.diastolicPressure;
    if (sys != null && dia != null) return '${sys.toInt()}/${dia.toInt()}';
    if (sys != null) return sys.toInt().toString();
    return dia!.toInt().toString();
  }

  /// 构建图表区域
  Widget _buildChartSection(BuildContext context, List<HealthRecord> data) {
    final cs = Theme.of(context).colorScheme;

    if (data.isEmpty) {
      return _emptyChart(
        cs,
        _records.isEmpty
            ? '暂无健康记录，请先到「记录」页添加'
            : '该时间范围内暂无记录',
      );
    }

    final series = _buildSeries(data, cs);
    if (!series.any((s) => s.spots.isNotEmpty)) {
      return _emptyChart(cs, '该时间范围内暂无${_metric.label}数据');
    }

    // 计算 Y 轴范围：取所有系列的最值，并按指标留出余量
    final values = series
        .expand((s) => s.spots.map((p) => p.y))
        .toList(growable: false);
    var minY = values.reduce(math.min) - _yMargin;
    var maxY = values.reduce(math.max) + _yMargin;
    // 单点或全等值时上下各留余量后仍然相等会画不出来，这里再兜底撑开
    if (maxY - minY < 1e-6) {
      minY -= _yMargin;
      maxY += _yMargin;
    }
    // 血压、血糖、体重等都不该为负，避免 Y 轴出现负数刻度
    if (minY < 0) minY = 0;

    final maxX = data.length <= 1 ? 1.0 : (data.length - 1).toDouble();
    // 数据点多时抽稀 X 轴标签，防止日期刻度糊成一片
    final xInterval = math.max(1, (data.length / 5).ceil()).toDouble();

    final labelStyle = TextStyle(fontSize: 11, color: cs.onSurfaceVariant);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
        child: Column(
          children: [
            // fl_chart 没有内置图例，用色块加文字自行绘制
            _buildLegend(cs, series),
            const SizedBox(height: 12),
            SizedBox(
              // 必须限定高度：折线图在可滚动容器中高度无界会直接报错
              height: 240,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: maxX,
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _gridInterval(minY, maxY),
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: cs.outlineVariant,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          meta.formattedValue,
                          style: labelStyle,
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval: xInterval,
                        getTitlesWidget: (value, meta) {
                          final index = value.round();
                          if (index < 0 || index >= data.length) {
                            return const SizedBox.shrink();
                          }
                          final date = data[index].date;
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${date.month}/${date.day}',
                              style: labelStyle,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => cs.inverseSurface,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.round();
                          final date = (index >= 0 && index < data.length)
                              ? data[index].date
                              : null;
                          final prefix =
                              date == null ? '' : '${date.month}/${date.day}  ';
                          return LineTooltipItem(
                            '$prefix${spot.y.toStringAsFixed(1)}',
                            TextStyle(
                              color: cs.onInverseSurface,
                              fontSize: 12,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: series
                      .map((s) => LineChartBarData(
                            spots: s.spots,
                            color: s.color,
                            barWidth: 2,
                            isStrokeCapRound: true,
                            // 只有 1~2 个点时开曲线会画得很难看，3 个点以上再开
                            isCurved: s.spots.length > 2,
                            dotData: FlDotData(
                              show: s.spots.length <= 30,
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: s.color.withValues(alpha: 0.10),
                            ),
                          ))
                      .toList(),
                ),
                duration: const Duration(milliseconds: 250),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建图例
  Widget _buildLegend(ColorScheme cs, List<_Series> series) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 4,
      children: series.map((s) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: s.color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              s.label,
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            ),
          ],
        );
      }).toList(),
    );
  }

  /// 按 Y 轴范围推算一个合适的横向网格间距
  double _gridInterval(double minY, double maxY) {
    final span = maxY - minY;
    if (span <= 0) return 1;
    // 目标：竖直方向约 5 条网格线
    final rough = span / 5;
    final magnitude = math.pow(10, (math.log(rough) / math.ln10).floor()).toDouble();
    return math.max(magnitude, 1e-3);
  }

  /// 构建空状态
  Widget _emptyChart(ColorScheme cs, String message) {
    return Card(
      margin: EdgeInsets.zero,
      child: SizedBox(
        height: 240,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart, size: 40, color: cs.outline),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 根据当前指标构造折线系列
  List<_Series> _buildSeries(List<HealthRecord> data, ColorScheme cs) {
    switch (_metric) {
      case _Metric.bloodPressure:
        // 收缩压/舒张压数值区间接近，共用一条 Y 轴最直观，不必上双轴
        return [
          _Series(
            label: '收缩压',
            color: cs.primary,
            spots: _spots(data, (r) => r.systolicPressure),
          ),
          _Series(
            label: '舒张压',
            color: cs.tertiary,
            spots: _spots(data, (r) => r.diastolicPressure),
          ),
        ];
      case _Metric.bloodSugar:
        return [
          _Series(
            label: '血糖',
            color: cs.primary,
            spots: _spots(data, (r) => r.bloodSugar),
          ),
        ];
      case _Metric.weight:
        return [
          _Series(
            label: '体重',
            color: cs.primary,
            spots: _spots(data, (r) => r.weight),
          ),
        ];
      case _Metric.heartRate:
        return [
          _Series(
            label: '心率',
            color: cs.primary,
            spots: _spots(data, (r) => r.heartRate?.toDouble()),
          ),
        ];
      case _Metric.temperature:
        return [
          _Series(
            label: '体温',
            color: cs.primary,
            spots: _spots(data, (r) => r.temperature),
          ),
        ];
    }
  }

  /// 从记录中提取某指标的折线点
  ///
  /// X 轴使用记录在列表中的序号而非时间戳：既保证点等距，
  /// 也避免引入 intl 之类的额外依赖来格式化刻度。
  List<FlSpot> _spots(
    List<HealthRecord> data,
    double? Function(HealthRecord) pick,
  ) {
    final spots = <FlSpot>[];
    for (var i = 0; i < data.length; i++) {
      final value = pick(data[i]);
      if (value != null) {
        spots.add(FlSpot(i.toDouble(), value));
      }
    }
    return spots;
  }
}
