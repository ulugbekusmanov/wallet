import 'package:tbccwallet/shared.dart';
import 'package:tbccwallet/ui/views/settings/SettingsMain.dart';
import 'package:tbccwallet/ui/views/settings/SettingsMainModel.dart';
import 'package:tbccwallet/ui/views/settings/security/Biometrics.dart';
import 'package:tbccwallet/ui/views/settings/security/PrivateKeys.dart';
import 'package:tbccwallet/ui/views/start/SetPassword.dart';

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
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BiometricsScreen())),
                ),
                SettingsTile(
                    index: 2,
                    icon: gradientIcon(Icon(Icons.vpn_key_outlined, color: Colors.white)),
                    value: S.of(context).privateKeys,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => PrivateKeysScreen()));
                    }),
              ],
            ),
          ),
        );
      },
    );
  }
}
