import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:voola/App.dart';
import 'package:voola/core/authentication/AuthService.dart';
import 'package:voola/core/settings/UserSettings.dart';
import 'package:voola/global_env.dart';
import 'package:voola/locator.dart';
import 'package:voola/shared.dart';

class SettingsMainModel extends BaseViewModel {
  final settings = locator<UserSettings>();

  List<List> localesList = [
    ["English", Locale("en")],
    ["Русский", Locale("ru")],
    ["中文", Locale("zh")],
  ];

  Future<void> changeLocale(Locale loc) async {
    setState(ViewState.Busy);
    try {
      await S.delegate.load(loc);
      locator<AppMainModel>().setState();
      locator<UserSettings>()
        ..language = loc
        ..save();
    } catch (e, st) {
      print('$e: $st');
    }
    setState(ViewState.Idle);
  }

  Future<void> logout(BuildContext context) async {
    var confirmed = (await showConfirmationDialog(
            S.of(context).logOutAllQuestion,
            S.of(context).checkSavedMnemonicAll))
        .confirmed;

    if (confirmed) {
      locator<AuthService>().logoutAll(context);
    }
  }

  void currencyChanged(String symbol) {
    FIAT_CURRENCY_SYMBOL = symbol;
    var lit = getFiatLiteral(symbol);
    FIAT_CURRENCY_LITERAL = lit.length == 3 ? '$lit ' : lit;
    settings
      ..currencySymbol = FIAT_CURRENCY_SYMBOL
      ..save();
    setState();
  }

  void changeTheme(context, bool switchVal) {
    var currThemeBrightness = ThemeProvider.of(context)!.brightness;
    var newTheme;
    if (currThemeBrightness == Brightness.light) {
      newTheme = DARK_THEME;
      AppColors = DarkColors;
      settings.themeMode = ThemeMode.dark;
    } else {
      newTheme = LIGHT_THEME;
      AppColors = LightColors;
      settings.themeMode = ThemeMode.light;
    }
    ThemeSwitcher.of(context)!.changeTheme(
      theme: newTheme,
      reverseAnimation: false,
    );
    settings.save();
  }

  Future<void> switchBiometrics(BuildContext context) async {
    var _settings = locator<UserSettings>();
    var _auth = locator<AuthService>();

    if (await _auth.biometricAuth(S.of(context).confirm)) {
      _settings.biometricsEnabled = !_settings.biometricsEnabled;
      _settings.save();
      setState();
    }
  }
}
