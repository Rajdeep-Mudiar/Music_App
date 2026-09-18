import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resonance/features/ai_assistant/ai_assistant_screen.dart';
import 'package:resonance/features/auth/login_screen.dart';
import 'package:resonance/features/community/community_screen.dart';
import 'package:resonance/features/home/home_screen.dart';
import 'package:resonance/features/library/library_screen.dart';
import 'package:resonance/features/player/full_player_screen.dart';
import 'package:resonance/features/search/search_screen.dart';
import 'package:resonance/features/study/study_screen.dart';
import 'package:resonance/providers/auth_provider.dart';
import 'package:resonance/providers/core_providers.dart';
import 'package:resonance/services/update_service.dart';
import 'package:resonance/widgets/mini_player.dart';
import 'package:resonance/widgets/update_dialog.dart';

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    StudyScreen(),
    CommunityScreen(),
    LibraryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVersionUpdate();
    });
  }

  Future<void> _checkVersionUpdate() async {
    final updateService = ref.read(updateServiceProvider);
    final result = await updateService.checkForUpdates();
    if (!mounted) return;

    if (result.status == UpdateStatus.updateAvailable ||
        result.status == UpdateStatus.forceUpdateRequired) {
      if (result.versionInfo != null) {
        showDialog(
          context: context,
          barrierDismissible: result.status != UpdateStatus.forceUpdateRequired,
          builder: (c) => UpdateDialog(
            versionInfo: result.versionInfo!,
            isForceUpdate: result.status == UpdateStatus.forceUpdateRequired,
            updateService: updateService,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MiniPlayer(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.search),
              activeIcon: Icon(Icons.search),
              label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.timer_outlined),
              activeIcon: Icon(Icons.timer),
              label: 'Study'),
          BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined),
              activeIcon: Icon(Icons.group),
              label: 'Community'),
          BottomNavigationBarItem(
              icon: Icon(Icons.library_music_outlined),
              activeIcon: Icon(Icons.library_music),
              label: 'Library'),
        ],
      ),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainShellScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/player',
        builder: (context, state) => const FullPlayerScreen(),
      ),
      GoRoute(
        path: '/ai-assistant',
        builder: (context, state) => const AIAssistantScreen(),
      ),
    ],
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';
      if (!authState.isAuthenticated && !authState.isLoading) {
        return '/login';
      }
      if (authState.isAuthenticated && isLoggingIn) {
        return '/';
      }
      return null;
    },
  );
});
