import 'dart:io';

import 'package:stacked_services/stacked_services.dart';
import 'package:tbccwallet/core/settings/UserSettings.dart';
import 'package:tbccwallet/main.dart';
import 'package:tbccwallet/shared.dart';

import 'package:tbccwallet/ui/styles/styles.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:tbccwallet/ui/update/ForceUpdateScreen.dart';

import 'locator.dart';
import 'ui/views/start/LoginScreen.dart';
import 'ui/views/start/StartScreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:overlay_support/overlay_support.dart';

class WalletApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseView<AppMainModel>(onModelReady: (model) {
      model.setupTheme();
      model.getLocale();
      model.initStartScreen();
    }, builder: (context, model, child) {
      return ThemeProvider(
        initTheme: model.theme,
        builder: (context, currTheme) => OverlaySupport.global(
          child: MaterialApp(
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                S.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              title: 'TBCC Wallet',
              themeMode: ThemeMode.system,
              // theme: LIGHT_THEME,
              //darkTheme: DARK_THEME,
              theme: currTheme,
              locale: model.getLocale(),
              navigatorKey: StackedService.navigatorKey,
              //home: MainAppScreen(),
              home:
                  model.state == ViewState.Busy ? LoaderScreen() : model.home),
        ),
      );
    });
  }
}

class AppMainModel extends BaseViewModel {
  final settings = locator<UserSettings>();

  late ThemeData theme;
  late Widget home;
  setupTheme() {
    switch (settings.themeMode) {
      case ThemeMode.dark:
        AppColors = DarkColors;
        theme = DARK_THEME;
        break;
      case ThemeMode.light:
        AppColors = LightColors;
        theme = LIGHT_THEME;
        break;
      case ThemeMode.system:
        var platformBrightness =
            WidgetsBinding.instance?.window.platformBrightness;

        switch (platformBrightness) {
          case Brightness.dark:
            AppColors = DarkColors;
            theme = DARK_THEME;
            break;
          case Brightness.light:
            AppColors = LightColors;
            theme = LIGHT_THEME;
            break;
          case null:
            AppColors = DarkColors;
            theme = DARK_THEME;
        }
    }
  }

  getLocale() {
    var settingsLocale = settings.language;
    if (settingsLocale == null) {
      Locale locale;
      var platformLocale = Platform.localeName.split('_').first;
      if (['ru', 'en', 'zh'].contains(platformLocale)) {
        locale = Locale(platformLocale);
      } else {
        locale = Locale('en');
      }
      settings
        ..language = locale
        ..save();
      return locale;
    } else {
      return settingsLocale;
    }
  }

  initStartScreen() async {
    setState(ViewState.Busy);
    //var loaderScreen = LoaderScreen();
//
    //home = NoConnectionScreen(() {
    //  initStartScreen();
    //});
    //home = loaderScreen;
    if (settings.initNetworkFailed) {
      home = NoConnectionScreen(() async {
        setState(ViewState.Busy);
        await init(retryInternet: true);
        initStartScreen();
        setState(ViewState.Idle);
      });
    } else if (Platform.isAndroid &&
        settings.update.actualVersion! > int.parse(settings.versionCode)) {
      home = ForceUpdateScreen();
    } else if (settings.loggedIn) {
      home = LoginScreen();
    } else {
      home = StartScreen();
    }

    // home = HomeWrapper(setupTheme, home);
    setState(ViewState.Idle);
  }
}

class NoConnectionScreen extends StatelessWidget {
  void Function() onTapRetry;
  NoConnectionScreen(this.onTapRetry, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.of(context).checkInternet,
                style: Theme.of(context).textTheme.bodyText1,
              ),
              GestureDetector(
                onTap: onTapRetry,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Icon(
                    Icons.refresh,
                    size: 44,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class LoaderScreen extends StatelessWidget {
  LoaderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CScaffold(
      body: TBCCLoader(),
    );
  }
}