import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kls_project/model/ChangeThemeMode.dart';
import 'package:kls_project/model/VideoModel.dart';
import 'package:kls_project/screen/PlayListScreen.dart';
import 'package:kls_project/screen/SettingsScreen.dart';
import 'package:kls_project/screen/YoutubeSearchScreen.dart';
import 'package:kls_project/services/PlayListState.dart';
import 'package:kls_project/services/YoutubeSearchState.dart';
import 'package:kls_project/theme/theme.dart';
import 'package:kls_project/viewModel/theme_initialze.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(VideoModelAdapter());
  await Hive.openBox<VideoModel>('playlist');
  runApp(
    MultiProvider(
      providers: [
        // 확장을 위해 멀티 Provider 사용
        ChangeNotifierProvider(create: (_) => ChangeThemeMode()),
        ChangeNotifierProvider(create: (_) => Youtubesearchstate()),
        ChangeNotifierProvider(create: (_) => PlayListState()),
      ],
      child: ThemeInitialze(
        // ThemeInitialze 커스텀 위젯을 통해 Theme 테마 가져옵니다
        child: Consumer<ChangeThemeMode>(
          builder: (context, changeMode, child) => const NavigationBarApp(),
        ),
      ),
    ),
  );
}

class NavigationBarApp extends StatelessWidget {
  const NavigationBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: Provider.of<ChangeThemeMode>(context).themeData,
      home: const NavigationExample(),
    );
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;
  String titleName = "KLS MUSIC";

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: Text(titleName, style: Theme.of(context).textTheme.titleLarge),
      ),
      body: <Widget>[
        /// Home page
        SafeArea(
          child: Center(
            child: Text('홈',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
          ),
        ),

        // 음악재생 페이지
        PlayListScreen(),

        // 검색 페이지
        YoutubeSearchScreen(
          streamInjection:
              Provider.of<Youtubesearchstate>(context, listen: false)
                  .searchResult,
        ),

        // 검색 페이지
        SettingsScreen(),
      ][currentPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPageIndex,
        onTap: (index) {
          setState(() {
            currentPageIndex = index;
            if (currentPageIndex > 0) {
              // 0이 아닌 경우 ex ) KLS MUSIC
              switch (currentPageIndex) {
                case 1:
                  titleName = "플레이 리스트";
                  break;
                case 2:
                  titleName = "검색";
                  break;
                case 3:
                  titleName = "설정";
                  break;
              }
            } else {
              titleName = "KLS MUSIC";
            }
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor:
            Provider.of<ChangeThemeMode>(context).themeData == whiteMode()
                ? Colors.black
                : Colors.white,
        unselectedItemColor: const Color(0xFF838383),
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.double_music_note),
            label: '음악',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            label: '검색',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }
}
