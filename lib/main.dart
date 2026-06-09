import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/theme_provider.dart';
import 'providers/chat_provider.dart';
import 'widgets/theme_colors.dart';
import 'pages/windowsill_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const XiaoYueLiangApp(),
    ),
  );
}

class XiaoYueLiangApp extends StatelessWidget {
  const XiaoYueLiangApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;
    final colors = themeProvider.colors;

    final baseTheme = isDark ? ThemeData.dark() : ThemeData.light();

    final theme = baseTheme.copyWith(
      scaffoldBackgroundColor: colors.background,
      extensions: <ThemeExtension<AppColors>>[colors],
      textTheme: GoogleFonts.notoSansSCTextTheme(baseTheme.textTheme),
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
      dialogTheme: DialogTheme(
        backgroundColor: colors.cardSurface,
        titleTextStyle: TextStyle(
          fontFamily: 'NotoSerifSC',
          fontWeight: FontWeight.w700,
          fontSize: 17,
          color: colors.mainText,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.accent,
        contentTextStyle: TextStyle(
          fontFamily: 'NotoSansSC',
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );

    return MaterialApp(
      title: '小月亮',
      theme: theme,
      darkTheme: theme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const WindowsillPage(),
    );
  }
}
