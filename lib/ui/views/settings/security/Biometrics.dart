import 'package:tbccwallet/core/settings/UserSettings.dart';
import 'package:tbccwallet/locator.dart';
import 'package:tbccwallet/shared.dart';
import 'package:tbccwallet/ui/views/settings/SettingsMainModel.dart';

class BiometricsScreen extends StatelessWidget {
  const BiometricsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<SettingsMainModel>(
      onModelReady: (model) {},
      builder: (context, model, child) {
        return Scaffold(
          appBar: CAppBar(
            elevation: 0,
            title: Text(S.of(context).biometrics),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: locator<UserSettings>().canCheckBiometrics
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            S.of(context).biometricsText,
                            style: Theme.of(context).textTheme.subtitle1,
                            textAlign: TextAlign.center,
                          ),
                          Icon(
                            Icons.fingerprint,
                            size: MediaQuery.of(context).size.height * 0.2,
                            color: locator<UserSettings>().biometricsEnabled ? AppColors.active : AppColors.inactiveText,
                          ),
                          Button(
                            value: locator<UserSettings>().biometricsEnabled ? S.of(context).disable : S.of(context).enable,
                            onTap: () async {
                              await model.switchBiometrics(context);
                            },
                          )
                        ],
                      )
                    : Center(
                        child: Text(
                          S.of(context).biometricsUnavailable,
                          style: Theme.of(context).textTheme.subtitle1,
                          textAlign: TextAlign.center,
                        ),
                      )),
          ),
        );
      },
    );
  }
}
