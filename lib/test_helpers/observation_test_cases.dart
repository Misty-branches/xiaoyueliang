/// 观察层测试用例
///
/// 提供 10 条真实对话场景的测试数据，可手动导入验证
/// ObservationProvider 的提取器输出是否正确。
///
/// ── 手动测试方法 ──
/// 1. 在任意页面（如 main.dart 的 initState 或调试面板）中
///    import 'test_helpers/observation_test_cases.dart';
/// 2. 选择一个场景（如 kTestCases[0]）
/// 3. 将 chatMessages 转为 List<ChatMessage> 后传给
///    ObservationProvider.extractInterests() / extractMood()
/// 4. 打印结果并与 expectedOutput 对比
///
/// 示例：
/// ```dart
/// final testCase = kTestCases[0];
/// final messages = testCase.chatMessages.asMap().entries.map((e) =>
///   ChatMessage(
///     id: 'test_$e',
///     role: 'user',
///     content: e.value,
///     timestamp: DateTime.now().subtract(Duration(hours: e.key)),
///   ),
/// ).toList();
/// final provider = context.read<ObservationProvider>();
/// final interests = provider.extractInterests(messages, []);
/// print('兴趣话题: ${interests.map((i) => '${i.topic}(${i.score.toStringAsFixed(2)})')}');
/// // 对比 expectedOutput['interests']
/// ```

class ObservationTestCase {
  /// 场景名称
  final String name;

  /// 场景描述
  final String scenario;

  /// 输入对话（每条字符串代表一条聊天消息）
  final List<String> chatMessages;

  /// 预期观察结果（简化版）
  ///
  /// 字段说明：
  /// - interests: List<String> — 预期提取出的兴趣话题列表（按权重排序）
  /// - mood: String — 预期情绪 ('happy' | 'sad' | 'neutral')
  /// - hasProjects: bool — 是否有活跃项目
  /// - hasReading: bool — 是否有阅读进度
  final Map<String, dynamic> expectedOutput;

  const ObservationTestCase({
    required this.name,
    required this.scenario,
    required this.chatMessages,
    required this.expectedOutput,
  });
}

/// 10 条测试用例
///
/// 覆盖正常交流、随口抱怨、多种话题、纯情绪、长时间沉默、
/// 学习模式、项目讨论、纯闲聊、情绪波动、空数据等边缘情况。
const List<ObservationTestCase> kTestCases = [
  // ─── 1. 正常开发 ───
  ObservationTestCase(
    name: '正常开发',
    scenario: '用户连续讨论 Flutter 开发，多个相关技术词反复出现',
    chatMessages: [
      'Flutter 的 Widget 系统真是太好用了，我今天用 Flutter 重构了首页。',
      'Flutter 的 StatefulWidget 和 StatelessWidget 的区别要搞清楚。',
      '刚跑通了 Flutter 的测试，CI 也过了，Flutter 开发体验越来越好了。',
      '明天继续优化 Flutter 的性能，特别是 ListView 的复用。',
    ],
    expectedOutput: {
      'interests': ['Flutter'],
      'mood': 'happy',
      'hasProjects': false,
      'hasReading': false,
    },
  ),

  // ─── 2. 随口抱怨 ───
  ObservationTestCase(
    name: '随口抱怨',
    scenario: '用户说"烦死了"，但实际是随口吐槽，后续内容偏中性',
    chatMessages: [
      '今天天气真热，烦死了。',
      '点了杯冰咖啡，总算舒服了点。',
      '下午要不要一起去看电影？',
    ],
    expectedOutput: {
      'interests': ['天气', '冰咖啡', '电影'],
      'mood': 'neutral',
      'hasProjects': false,
      'hasReading': false,
    },
  ),

  // ─── 3. 多种话题 ───
  ObservationTestCase(
    name: '多种话题',
    scenario: '用户同时聊 Flutter、小说、音乐三个不同领域的话题',
    chatMessages: [
      '刚看到 Flutter 3.0 发布了新特性，Flutter 的 Impeller 引擎性能提升很大。',
      '最近在看《三体》，这本书的科幻设定太震撼了。',
      '周杰伦的新歌你听了吗？这旋律真好听，我已经循环播放了。',
    ],
    expectedOutput: {
      'interests': ['Flutter', '三体', '周杰伦'],
      'mood': 'happy',
      'hasProjects': false,
      'hasReading': true,
    },
  ),

  // ─── 4. 纯情绪无主题 ───
  ObservationTestCase(
    name: '纯情绪无主题',
    scenario: '用户只说心情没有具体话题，消息中只有语气词和情绪词',
    chatMessages: [
      '好开心！今天心情真好！太棒了！',
      '开心！开心！开心！',
      '笑死我了哈哈哈',
    ],
    expectedOutput: {
      'interests': <String>[], // 没有实质性话题
      'mood': 'happy',
      'hasProjects': false,
      'hasReading': false,
    },
  ),

  // ─── 5. 长时间沉默 ───
  ObservationTestCase(
    name: '长时间沉默',
    scenario: '只有1条消息，其余是沉默（用空字符串模拟无数据）',
    chatMessages: [
      '今天好累，先睡了。',
    ],
    expectedOutput: {
      'interests': <String>[], // 只有1条消息，词频不足以提炼话题
      'mood': 'sad',
      'hasProjects': false,
      'hasReading': false,
    },
  ),

  // ─── 6. 学习模式 ───
  ObservationTestCase(
    name: '学习模式',
    scenario: '用户讨论学习内容（读书、看教程），有明确的学习话题',
    chatMessages: [
      '看了 Flutter 官方文档的 Layout 部分，讲得真好。',
      '《设计模式》这本书看了三章，工厂模式很实用。',
      '今天学了 Vue 3 的 Composition API，和 Flutter 的 hooks 有点像。',
      '又买了本《深入理解计算机系统》，慢慢啃。',
    ],
    expectedOutput: {
      'interests': ['Flutter', '设计模式', '深入理解计算机系统', 'Vue'],
      'mood': 'happy',
      'hasProjects': false,
      'hasReading': true,
    },
  ),

  // ─── 7. 项目讨论 ───
  ObservationTestCase(
    name: '项目讨论',
    scenario: '用户讨论具体项目进度和计划',
    chatMessages: [
      '小月亮项目的首页重构快完成了，还剩几个 bug 要修。',
      '明天要把小月亮的推送通知加一下，用户等很久了。',
      '小月亮的数据迁移脚本写好了，测试通过就上线。',
      '下周计划搞小月亮的暗黑模式适配。',
    ],
    expectedOutput: {
      'interests': ['小月亮', '推送通知', '数据迁移', '暗黑模式'],
      'mood': 'neutral',
      'hasProjects': true,
      'hasReading': false,
    },
  ),

  // ─── 8. 纯闲聊 ───
  ObservationTestCase(
    name: '纯闲聊',
    scenario: '天气、美食、日常，没有技术或工作相关内容',
    chatMessages: [
      '今天天气真好，适合出去玩。',
      '中午吃了碗牛肉面，味道不错。',
      '晚上想去散步，顺便买个西瓜。',
      '准备做红烧肉，网上找的菜谱看起来很简单。',
    ],
    expectedOutput: {
      'interests': ['天气', '牛肉面', '西瓜', '红烧肉', '菜谱'],
      'mood': 'happy',
      'hasProjects': false,
      'hasReading': false,
    },
  ),

  // ─── 9. 情绪波动 ───
  ObservationTestCase(
    name: '情绪波动',
    scenario: '同一对话中先开心后低落，情绪提取应取整体趋势',
    chatMessages: [
      '今天项目上线成功了！太开心了！好棒！',
      '大家都很满意，这次迭代做得很棒。',
      '下午发现了个严重的 bug，烦死了，又要加班。',
      '好累，已经连续加班三天了，郁闷。',
    ],
    expectedOutput: {
      'interests': ['项目', '迭代', 'bug'],
      'mood': 'sad', // 后期负面情绪累积超过正面
      'hasProjects': true,
      'hasReading': false,
    },
  ),

  // ─── 10. 空数据 ───
  ObservationTestCase(
    name: '空数据',
    scenario: '没有任何聊天记录',
    chatMessages: <String>[],
    expectedOutput: {
      'interests': <String>[],
      'mood': 'neutral',
      'hasProjects': false,
      'hasReading': false,
    },
  ),
];
