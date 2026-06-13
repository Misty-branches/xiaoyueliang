import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Providers
import 'providers/theme_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/diary_provider.dart';
import 'providers/todo_provider.dart';
import 'providers/bookshelf_provider.dart';
import 'providers/echo_provider.dart';
import 'providers/message_board_provider.dart';
import 'providers/letter_provider.dart';
import 'providers/note_provider.dart';
import 'providers/collection_provider.dart';
import 'providers/project_provider.dart';
import 'providers/daily_message_provider.dart';
import 'providers/observation_provider.dart';
import 'providers/shared_goals_provider.dart';
import 'providers/recent_activity_provider.dart';
import 'providers/provider_config_provider.dart';
import 'providers/memory_provider.dart';

// Theme
import 'widgets/theme_colors.dart';

// Pages
import 'pages/shell_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        // 主题
        ChangeNotifierProvider(create: (_) => ThemeProvider()..initTheme()),
        // 数据层
        ChangeNotifierProvider(create: (_) => ChatProvider()..load()),
        ChangeNotifierProvider(create: (_) => DiaryProvider()..loadEntries()),
        ChangeNotifierProvider(create: (_) => TodoProvider()..loadTodos()),
        ChangeNotifierProvider(create: (_) => BookshelfProvider()..loadBooks()),
        ChangeNotifierProvider(create: (_) => EchoProvider()..loadEntries()),
        ChangeNotifierProvider(create: (_) => MessageBoardProvider()..loadPosts()),
        ChangeNotifierProvider(create: (_) => LetterProvider()..loadLetters()),
        ChangeNotifierProvider(create: (_) => NoteProvider()..loadNotes()),
        ChangeNotifierProvider(create: (_) => CollectionProvider()..loadItems()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()..loadProjects()),
        // 观察层
        ChangeNotifierProvider(create: (_) => ObservationProvider()..loadCached()),
        ChangeNotifierProvider(create: (_) => DailyMessageProvider()..loadMessage()),
        ChangeNotifierProvider(create: (_) => SharedGoalsProvider()..loadGoals()),
        ChangeNotifierProvider(create: (_) => RecentActivityProvider()..loadActivities()),
        // 配置层
        ChangeNotifierProvider(create: (_) => ProviderConfigProvider()..loadProviders()),
        // 记忆层
        ChangeNotifierProvider(create: (_) => MemoryProvider()..loadMemories()),
      ],
      child: const MoonlitWindowApp(),
    ),
  );
}

class MoonlitWindowApp extends StatelessWidget {
  const MoonlitWindowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;

    final baseTheme = themeProvider.isDark ? ThemeData.dark() : ThemeData.light();

    final theme = baseTheme.copyWith(
      scaffoldBackgroundColor: colors.background,
      extensions: <ThemeExtension<AppColors>>[colors],
      textTheme: GoogleFonts.notoSansScTextTheme(baseTheme.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.cardSurface,
        foregroundColor: colors.mainText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'NotoSerifSC',
          fontWeight: FontWeight.w700,
          fontSize: 17,
          letterSpacing: 1,
          color: colors.mainText,
        ),
      ),
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: colors.accent,
        secondary: colors.accentWarm,
        surface: colors.cardSurface,
        onSurface: colors.mainText,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.accent,
        contentTextStyle: const TextStyle(
          fontFamily: 'NotoSansSC',
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );

    return MaterialApp(
      title: '月下窗',
      theme: theme,
      darkTheme: theme,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      home: const ShellPage(),
    );
  }
}
