import 'dart:io';

import 'package:voola/core/settings/UserSettings.dart';
import 'package:voola/shared.dart';
import 'package:voola/ui/views/settings/SettingsMain.dart';
import 'package:voola/ui/views/settings/SettingsMainModel.dart';
import 'package:voola/ui/views/settings/security/Biometrics.dart';
import 'package:voola/ui/views/settings/security/PrivateKeys.dart';
import 'package:voola/ui/views/settings/security/smartCard/SmartCardAttach1.dart';
import 'package:voola/ui/views/start/SetPassword.dart';

import '../../../../core/authentication/AuthService.dart';
import '../../../../locator.dart';

class SecurityMainScreen extends StatefulWidget {
  const SecurityMainScreen({Key? key}) : super(key: key);

  @override
  _SecurityMainScreenState createState() => _SecurityMainScreenState();
}

class _SecurityMainScreenState extends State<SecurityMainScreen> {
  bool fingerprint = true;

  @override
  Widget build(BuildContext context) {
    return BaseView<SettingsMainModel>(
      onModelReady: (model) {},
      builder: (context, model, child) {
        return Scaffold(
          appBar: CAppBar(
            elevation: 0,
            title: Text(S.of(context).securityCenter),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SettingsTile(
                    index: 2,
                    icon: gradientIcon(AppIcons.password(24)),
                    value: S.of(context).changePassword,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => SetPasswordScreen(
                              S.of(context).changePassword,
                              () => Navigator.of(context).pop(),
                              changePassword: true,
                            )))),
                SettingsTile(
                    index: 2,
                    icon: gradientIcon(AppIcons.fingerprint_scan(24)),
                    value: S.of(context).biometrics,
                    onTap: () {
                      /*
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => BiometricsScreen())),*/

                    }),
                SettingsTile(
                    index: 2,
                    icon: gradientIcon(
                        Icon(Icons.vpn_key_outlined, color: Colors.white)),
                    value: S.of(context).privateKeys,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => PrivateKeysScreen()));
                    }),
                if (!Platform.isIOS) ...[
                  SettingsTile(
                    icon: AppIcons.credit_card(24),
                    //value: I18n.of(context).smartCard,
                    value: 'Smart Card',
                    onTap: () {
                      if (locator<AuthService>()
                          .accManager
                          .allAccounts
                          .any((element) => element.cardAttached!)) {
                        Flushbar.error(
                          title: S.of(context).cardAttachedYet,
                        ).show(Duration(seconds: 4));

                        return;
                      }
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => SmartCardAttach1()));
                    },
                    index: 2,
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}
