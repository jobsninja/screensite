import 'package:common/common.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:providers/generic.dart';
import 'package:sandbox/sandbox_launcher2.dart';
import 'package:screensite/router.dart';
import 'package:screensite/sandbox_app.dart';
import 'package:screensite/search/search_page.dart';
import 'package:screensite/theme.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:theme/theme_mode.dart';
import 'firebase_options.dart';

void main() async {
  Chain.capture(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (kReleaseMode) {
      await dotenv.load(fileName: ".env.production");
    } else {
      await dotenv.load(fileName: ".env.development");
    }

    runApp(SandboxLauncher2(
      enabled: const String.fromEnvironment('SANDBOX') == 'true',
      app: ProviderScope(child: MainApp()),
      sandbox: SandboxApp(),
      getInitialState: () =>
          kDB.doc('sandbox/serge').get().then((doc) => doc.data()!['sandbox']),
      saveState: (state) => {
        kDB.doc('sandbox/serge').set({'sandbox': state})
      },
    ));
  }, onError: (error, Chain chain) {
    // print('Caught error $error\nStack trace: ${Trace.format(new Chain.forTrace(chain))}');
    print('ERROR: $error\n${chain.foldFrames((Frame p0) {
      // print(
      //     'fold uri:${p0.uri}, lib:${p0.library}, core:${p0.isCore}, location:${p0.location}, package:${p0.package}, member:${p0.member}');
      return p0.location.contains('framework.dart') ||
          p0.location.contains('dart-sdk') ||
          p0.location.contains('_engine') ||
          p0.location.contains('_internal') ||
          p0.location.contains('flutter') ||
          p0.location.contains('stack_trace') ||
          p0.location.contains('.js') ||
          (p0.member != null && p0.member == 'throw_');
    }, terse: true)}');
  });
}

class MainApp extends ConsumerWidget {
  const MainApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    bool isDarkTheme = ref.watch(themeModeSNP);
    return
        // DefaultTabController(
        //     initialIndex: 0,
        //     length: 3,
        //     child:
        // MaterialApp(
        //   title: 'Sanctions Screener',
        //   themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
        //   theme: lightTheme,
        //   darkTheme: ThemeData.dark().copyWith(
        //       // highlightColor: Colors.orange,
        //       // colorScheme:
        //       //     ColorScheme.dark().copyWith(secondary: Colors.orange)
        //       ),

        //   initialRoute: '/',
        //   onGenerateRoute: generateRoutes({
        //     '/': (context, settings) => LandingPage(),
        //     // '/': (context, settings) => SearchPage(),
        //     '/login': (context, settings) => LoginPage(),
        //     '/search': (context, settings) => SearchPage(),
        //     '/cases': (context, settings) => CasesPage(),
        //     '/lists': (context, settings) => ListsPage(),
        //   })),
        DefaultTabController(
            initialIndex: 0,
            length: 3,
            child: MaterialApp.router(
              title: 'Sanctions Screener',
              routeInformationParser: router.routeInformationParser,
              routerDelegate: router.routerDelegate,
              routeInformationProvider: router.routeInformationProvider,
              themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
              theme: lightTheme,
              darkTheme: ThemeData.dark().copyWith(
                  // highlightColor: Colors.orange,
                  // colorScheme:
                  //     ColorScheme.dark().copyWith(secondary: Colors.orange)
                  ),
            ));
  }
}

final isLoggedIn = StateNotifierProvider<GenericStateNotifier<bool>, bool>(
    (ref) => GenericStateNotifier<bool>(false));

final isLoading = StateNotifierProvider<GenericStateNotifier<bool>, bool>(
    (ref) => GenericStateNotifier<bool>(false));
