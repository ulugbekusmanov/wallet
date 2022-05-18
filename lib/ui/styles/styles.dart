import 'package:tbccwallet/shared.dart';

class ColorSet {
  late LinearGradient mainGradient;
  late LinearGradient altGradient;

  late Color primary;
  late Color active;
  late Color text;
  late Color inactiveText;
  late Color green;
  late Color red;
  late Color yellowOpac;
  late Color yellow;
  late Color primaryBg;
  late Color secondaryBG;
  late Color secondaryBG_gray;
  late Color shadowColor;
  late Color highlightedText;
  late Color generalShapesBg;
  late Color generalBorder;
  late Color tokenCardPriceUp;
  late Color tokenCardPriceDown;
}

class LightThemeColors extends ColorSet {
  LightThemeColors() {
    mainGradient = LinearGradient(
      colors: [Color(0xFF589BFF), Color(0xFF4E5FFF)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
    primary = Color(0xff4E94D7);
    active = Color(0xFF438AF9);
    altGradient = LinearGradient(
        colors: [Color(0xFFF5F5FA), Color(0xFFFEFEFF)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter);
    text = Color(0xFF2F385E);
    yellowOpac = Color(0xFFFCC419).withOpacity(0.08);
    yellow = Color(0xFFFCC419);
    inactiveText = Color(0xFFADB5BD);
    green = Color(0xFF38D9A9);
    red = Color(0xFFFD736A);
    primaryBg = Color(0xFFF5F5FA);
    secondaryBG = Color(0xFFFFFFFF);
    secondaryBG_gray = Color(0xFFEDEFF6);
    shadowColor = Colors.black.withOpacity(0.03);
    highlightedText = Color(0xFF589BFF);
    generalShapesBg = Color(0xFFFFFFFF);
    generalBorder = Color(0xFFE9ECF5);
    tokenCardPriceUp = Color(0x1438D9A9);
    tokenCardPriceDown = Color(0xFFFFF0F6);
  }
}

class DarkThemeColors extends ColorSet {
  DarkThemeColors() {
    mainGradient = LinearGradient(
      colors: [Color(0xFF589BFF), Color(0xFF4E5FFF)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
    altGradient = LinearGradient(
        colors: [Color(0xFF111316), Color(0xFF1E2125)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter);
    primary = Color(0xff4E94D7);
    active = Color(0xFF438AF9);
    text = Color(0xFFFFFFFF);
    inactiveText = Color(0xFF62686D);
    yellowOpac = Color(0xFFFCC419).withOpacity(0.08);
    yellow = Color(0xFFFCC419);
    green = Color(0xFF38D9A9);
    red = Color(0xFFFD736A);
    primaryBg = Color(0xFF111316);
    secondaryBG = Color(0xFF1B1E24);
    secondaryBG_gray = Color(0xFF1E2126);
    shadowColor = Colors.transparent;
    highlightedText = Color(0xFF589BFF);
    generalShapesBg = Color(0xFF1B1E24);
    generalBorder = Color(0xFF404854);
    tokenCardPriceUp = Color(0x1438D9A9);
    tokenCardPriceDown = Color(0x1FFF6B6B);
  }
}

final LightColors = LightThemeColors();
final DarkColors = DarkThemeColors();
//ColorSet AppColors = DarkColors;
late ColorSet AppColors;

final LIGHT_THEME = ThemeData(
  primaryColor: LightColors.primary,
  brightness: Brightness.light,
  appBarTheme: AppBarTheme(
      titleTextStyle: TextStyle(
        color: LightColors.text,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      toolbarTextStyle: TextStyle(
        color: LightColors.text,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      foregroundColor: LightColors.text,
      iconTheme: IconThemeData(size: 24, color: LightColors.text),
      color: Colors.transparent,
      textTheme: TextTheme(
          bodyText2: TextStyle(
              color: LightColors.text,
              fontSize: 20,
              fontWeight: FontWeight.w500))),
  fontFamily: 'Jost',
  scaffoldBackgroundColor: LightColors.primaryBg,
  textTheme: TextTheme(
    bodyText1: TextStyle(
        color: LightColors.text,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.2),
    bodyText2: TextStyle(
        color: LightColors.text,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.2),
    subtitle1: TextStyle(
        color: LightColors.text,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.2),
    subtitle2: TextStyle(
        color: LightColors.inactiveText,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.2),
    caption: TextStyle(
        color: LightColors.inactiveText,
        fontSize: 12,
        fontWeight: FontWeight.normal,
        height: 1.2),
    headline6: TextStyle(
        color: LightColors.text,
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 1.2),
    headline5: TextStyle(
        color: LightColors.text,
        fontSize: 36,
        fontWeight: FontWeight.w500,
        height: 1.2),
    headline4: TextStyle(
        color: LightColors.text,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 1.2),
  ),
);

final DARK_THEME = ThemeData(
  primaryColor: DarkColors.primary,
  brightness: Brightness.dark,
  appBarTheme: AppBarTheme(
    brightness: Brightness.dark,
    titleTextStyle: TextStyle(
        color: DarkColors.text, fontSize: 20, fontWeight: FontWeight.w500),
    toolbarTextStyle: TextStyle(
        color: DarkColors.text, fontSize: 20, fontWeight: FontWeight.w500),
    iconTheme: IconThemeData(size: 24, color: DarkColors.text),
    color: Colors.transparent,
    foregroundColor: DarkColors.text,
    textTheme: TextTheme(
        bodyText2: TextStyle(
            color: DarkColors.text, fontSize: 20, fontWeight: FontWeight.w500)),
  ),
  fontFamily: 'Jost',
  scaffoldBackgroundColor: DarkColors.primaryBg,
  textTheme: TextTheme(
    bodyText1: TextStyle(
        color: DarkColors.text,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.2),
    bodyText2: TextStyle(
        color: DarkColors.text,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.2),
    subtitle1: TextStyle(
        color: DarkColors.text,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.2),
    subtitle2: TextStyle(
        color: DarkColors.inactiveText,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.2),
    caption: TextStyle(
        color: DarkColors.inactiveText,
        fontSize: 12,
        fontWeight: FontWeight.normal,
        height: 1.2),
    headline6: TextStyle(
        color: DarkColors.text,
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 1.2),
    headline5: TextStyle(
        color: DarkColors.text,
        fontSize: 36,
        fontWeight: FontWeight.w500,
        height: 1.2),
    headline4: TextStyle(
        color: DarkColors.text,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 1.2),
  ),
);
