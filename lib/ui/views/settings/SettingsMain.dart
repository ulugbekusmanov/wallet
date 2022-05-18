import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tbccwallet/global_env.dart';
import 'package:tbccwallet/shared.dart';
import 'package:tbccwallet/ui/views/settings/SettingsMainModel.dart';
import 'package:tbccwallet/ui/views/settings/address_book/AddressBook.dart';
import 'package:tbccwallet/ui/views/start/LoginScreen.dart';
import 'package:tbccwallet/ui/widgets/SharedWidgets.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';

import 'About.dart';
import 'currency/CurrencyScreen.dart';
import 'language/LanguageScreen.dart';
import 'security/SercurityMain.dart';

class SettingsMainScreen extends StatefulWidget {
  const SettingsMainScreen({Key? key}) : super(key: key);

  @override
  _SettingsMainScreenState createState() => _SettingsMainScreenState();
}

class _SettingsMainScreenState extends State<SettingsMainScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return BaseView<SettingsMainModel>(
      onModelReady: (model) {},
      builder: (context, model, child) {
        return CScaffold(
          appBar: CAppBar(
            elevation: 0,
            title: Text(S.of(context).settings),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              //SettingsTile(
              //  index: 0,
              //  icon: gradientIcon(AppIcons.walletconnect(24)),
              //  value: 'WalletConnect',
              //  onTap: () {},
              //),
              SettingsTile(
                  index: 2,
                  icon: gradientIcon(AppIcons.verified(24)),
                  value: S.of(context).securityCenter,
                  onTap: () async {
                    if ((await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => LoginScreen(confirmation: true)))) == true) {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => SecurityMainScreen()));
                    }
                  },
                  bottomSpace: true),

              SettingsTile(
                index: 1,
                icon: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 25,
                    height: 25,
                    child: SvgPicture.asset('assets/images/flags/${FIAT_CURRENCY_SYMBOL.toLowerCase()}.svg', fit: BoxFit.fill, clipBehavior: Clip.hardEdge),
                  ),
                ),
                value: S.of(context).currency,
                onTap: () => Navigator.of(context).push(PageTransition(type: PageTransitionType.rightToLeftWithFade, child: CurrencyScreen(model))),
                trailing: Text(
                  '$FIAT_CURRENCY_SYMBOL  ',
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(color: AppColors.inactiveText),
                ),
              ),
              SettingsTile(
                index: 2,
                icon: gradientIcon(AppIcons.globe(24)),
                value: S.of(context).language,
                onTap: () => Navigator.of(context).push(PageTransition(type: PageTransitionType.rightToLeftWithFade, child: LanguageScreen(model))),
              ),
              //SettingsTile(index: 3, icon: gradientIcon(AppIcons.crown(24)), value: 'Push Notifications', onTap: () {}),
              SettingsTile(
                index: 4,
                bottomSpace: true,
                icon: gradientIcon(AppIcons.book_open(24)),
                value: S.of(context).addressBook,
                onTap: () => Navigator.of(context).push(PageTransition(type: PageTransitionType.rightToLeftWithFade, child: AddressBookMain())),
              ),
              ThemeSwitcher(builder: (context) {
                return SwitchSettingsTile(
                  bottomSpace: true,
                  index: 3,
                  icon: gradientIcon(AppIcons.idea(24)),
                  value: S.of(context).darkMode,
                  onTap: () {},
                  isSwitched: ThemeProvider.of(context)!.brightness == Brightness.dark,
                  onSwitchChanged: (bool val) {
                    model.changeTheme(context, val);
                  },
                );
              }),
              //SettingsTile(index: 4, icon: gradientIcon(AppIcons.support(24)), value: S.of(context).supportCenter, onTap: () {}),
              SettingsTile(
                index: 4,
                icon: gradientIcon(AppIcons.person_add(24)),
                value: S.of(context).community,
                onTap: () {
                  launch('https://t.me/tbcc_china');
                },
                endIcon: false,
                trailing: Text(
                  'Telegram @tbcc_china',
                  style: Theme.of(context).textTheme.caption,
                ),
              ),

              SettingsTile(
                index: 5,
                icon: gradientIcon(AppIcons.info(24)),
                value: S.of(context).aboutTbcc,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AboutScreen())),
                bottomSpace: true,
              ),
              SettingsTile(
                index: 6,
                icon: Icon(Icons.logout_outlined, color: AppColors.red),
                value: S.of(context).logOut,
                onTap: () => model.logout(context),
                endIcon: false,
              ),
            ],
          ),
        );
      },
    );
  }
}

class SettingsTile extends StatelessWidget {
  final Widget icon;
  final void Function() onTap;
  final String value;
  final Widget? trailing;
  final bool bottomSpace;
  final int index;
  final bool endIcon;
  @override
  SettingsTile({required this.index, required this.icon, required this.value, required this.onTap, this.bottomSpace = false, this.trailing, this.endIcon = true});

  Widget build(BuildContext context) {
    return AnimatedOpacityWrapper(
      index: index,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.fromLTRB(0, 4, 0, bottomSpace ? 16 : 4),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: AppColors.generalShapesBg),
          child: Row(
            children: [
              Row(
                children: [
                  Padding(padding: const EdgeInsets.only(right: 14), child: icon),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 5.0), child: Text(value, style: Theme.of(context).textTheme.bodyText2)),
                ],
              ),
              Spacer(),
              if (trailing != null) trailing!,
              if (endIcon) Icon(Icons.chevron_right, color: AppColors.text),
            ],
          ),
        ),
      ),
    );
  }
}

class SwitchSettingsTile extends StatelessWidget {
  final int index;
  final Widget icon;
  final void Function() onTap;
  final String value;
  final bool bottomSpace;
  final bool isSwitched;
  final Function(bool) onSwitchChanged;
  @override
  SwitchSettingsTile({
    required this.index,
    required this.icon,
    required this.value,
    required this.onTap,
    this.isSwitched = false,
    this.bottomSpace = false,
    required this.onSwitchChanged,
  });

  Widget build(BuildContext context) {
    return AnimatedOpacityWrapper(
      index: index,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.fromLTRB(0, 4, 0, bottomSpace ? 16 : 4),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8.5),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: AppColors.generalShapesBg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: icon,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  )
                ],
              ),
              CupertinoSwitch(
                value: isSwitched,
                onChanged: onSwitchChanged,
                activeColor: AppColors.active,
              )
            ],
          ),
        ),
      ),
    );
  }
}
