import 'dart:io';

import 'package:voola/shared.dart';
import 'package:voola/ui/views/settings/SettingsMain.dart';
import 'package:voola/ui/views/settings/SettingsMainModel.dart';
import 'package:voola/ui/views/settings/security/Biometrics.dart';
import 'package:voola/ui/views/settings/security/PrivateKeys.dart';
import 'package:voola/ui/views/settings/security/smartCard/SmartCardAttach1.dart';
import 'package:voola/ui/views/start/SetPassword.dart';

import '../../../../core/authentication/AuthService.dart';
import '../../../../locator.dart';

class SecurityMainScreen extends StatelessWidget {
  const SecurityMainScreen({Key? key}) : super(key: key);

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
                  icon: AppIcons.verified(20, AppColors.primary),
                  index: 2,
                  value: 'Authentication mode',
                  onTap: () {},
                ),
                SettingsTile(
                  index: 2,
                  icon: AppIcons.password(20, AppColors.primary),
                  value: S.of(context).changePassword,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SetPasswordScreen(
                        S.of(context).changePassword,
                        () => Navigator.of(context).pop(),
                        changePassword: true,
                      ),
                    ),
                  ),
                ),
                SettingsTile(
                  index: 2,
                  icon: AppIcons.fingerprint_scan(20, AppColors.primary),
                  value: 'Fingerprint',
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => BiometricsScreen())),
                ),
                SettingsTile(
                  index: 2,
                  icon: AppIcons.face_detection(20, AppColors.primary),
                  value: 'Face Detection',
                  onTap: () {},
                ),
                if (!Platform.isIOS) ...[
                  SettingsTile(
                    icon: AppIcons.credit_card(20),
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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SmartCardAttach1(),
                        ),
                      );
                    },
                    index: 2,
                  ),
                ],
                SettingsTile(
                  index: 2,
                  icon: Icon(Icons.vpn_key_outlined, color: AppColors.primary),
                  value: S.of(context).privateKeys,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PrivateKeysScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
