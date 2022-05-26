import 'package:voola/core/authentication/AuthService.dart';
import 'package:voola/core/settings/UserSettings.dart';
import 'package:voola/locator.dart';
import 'package:voola/shared.dart';
import 'package:voola/ui/views/settings/SettingsMainModel.dart' as m;

class SetPasswordModel extends BaseViewModel {
  final _authService = locator<AuthService>();
  final _settings = locator<UserSettings>();
  bool? changePassword;
  Function? onDone;

  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();
  bool obscure = true;

  Future<void> setPassword(BuildContext context) async {
    setState(ViewState.Busy);
    await _authService.setPassword(repeatPasswordController.text);
    if (changePassword != true) {
      if (_settings.canCheckBiometrics) {
        var confirmed = (await showConfirmationDialog(
                S.of(context).biometrics, S.of(context).biometricsEnableAsk))
            .confirmed;

        if (confirmed) {
          var authenticated =
              await _authService.biometricAuth(S.of(context).confirmAction);
          if (authenticated) {
            _settings
              ..biometricsEnabled = true
              ..save();
          }
        }
      }
    }
    this.onDone?.call();
  }

  @override
  void dispose() {
    passwordController.dispose();
    repeatPasswordController.dispose();
    super.dispose();
  }
}

class SetPasswordScreen extends StatelessWidget {
  String btnValue;
  Function onDone;
  bool changePassword;

  SetPasswordScreen(this.btnValue, this.onDone, {this.changePassword = false});

  final formKey = GlobalKey<FormState>();
  bool fingerprint = true;

  @override
  Widget build(BuildContext context) {
    return BaseView<SetPasswordModel>(
      onModelReady: (model) {
        model.changePassword = changePassword;
        model.onDone = onDone;
      },
      builder: (context, model, child) {
        return CScaffold(
          appBar: CAppBar(
            elevation: 0,
            title: Text(S.of(context).password),
          ),
          body: model.state == ViewState.Busy
              ? TBCCLoader()
              : SafeArea(
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: 40,
                                right: MediaQuery.of(context).size.width * 0.08,
                                left: MediaQuery.of(context).size.width * 0.08,
                              ),
                              child: Text(
                                S.of(context).passwordInfo,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .copyWith(
                                        color: AppColors.text.withOpacity(0.6)),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            TextFormField(
                              controller: model.passwordController,
                              decoration: generalTextFieldDecor(context,
                                  hintText: S.of(context).password),
                              obscureText: model.obscure,
                              validator: (val) {
                                if (val?.length != null && val!.length < 8) {
                                  return S.of(context).passwordSymbolAmount;
                                }
                              },
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: model.repeatPasswordController,
                              decoration: generalTextFieldDecor(context,
                                  hintText: S.of(context).repeatPassword),
                              obscureText: model.obscure,
                              validator: (val) {
                                if (model.passwordController.text != val) {
                                  return S.of(context).passwordDoNotMatch;
                                }
                              },
                            ),
                            Spacer(),
                            Button(
                              value: btnValue,
                              onTap: () {
                                if (formKey.currentState?.validate() == true) {
                                  showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (context) {
                                        return BottomSheet(
                                          onClosing: () {},
                                          builder: (BuildContext context) {
                                            return BaseView<
                                                    m.SettingsMainModel>(
                                                onModelReady: (model) {},
                                                builder:
                                                    (context, model1, child) {
                                                  return StatefulBuilder(
                                                      builder:
                                                          (BuildContext context,
                                                                  setState) =>
                                                              Container(
                                                                decoration: new BoxDecoration(
                                                                    borderRadius: new BorderRadius
                                                                            .only(
                                                                        topLeft:
                                                                            const Radius.circular(
                                                                                100.0),
                                                                        topRight:
                                                                            const Radius.circular(100.0))),
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            12),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: <
                                                                      Widget>[
                                                                    Padding(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              8),
                                                                      child:
                                                                          Container(
                                                                        padding:
                                                                            EdgeInsets.all(4),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.black12,
                                                                          borderRadius:
                                                                              BorderRadius.circular(24),
                                                                        ),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Expanded(
                                                                              child: GestureDetector(
                                                                                child: Container(
                                                                                  padding: EdgeInsets.symmetric(horizontal: 36, vertical: 4),
                                                                                  decoration: BoxDecoration(
                                                                                    color: fingerprint ? Color(0xff4E94D7) : Colors.black12,
                                                                                    borderRadius: BorderRadius.circular(24),
                                                                                  ),
                                                                                  child: Text(
                                                                                    S.of(context).fingerprint,
                                                                                    style: TextStyle(
                                                                                      color: fingerprint ? Colors.white : LightColors.text,
                                                                                      fontSize: 16,
                                                                                      fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                onTap: () {
                                                                                  setState(() {
                                                                                    fingerprint = !fingerprint;
                                                                                  });
                                                                                },
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              child: GestureDetector(
                                                                                child: Container(
                                                                                  padding: EdgeInsets.symmetric(horizontal: 36, vertical: 4),
                                                                                  decoration: BoxDecoration(
                                                                                    color: !fingerprint ? Color(0xff4E94D7) : Color(0xffF4F7FC),
                                                                                    borderRadius: BorderRadius.circular(24),
                                                                                  ),
                                                                                  child: Text(
                                                                                    S.of(context).faceDetection,
                                                                                    style: TextStyle(
                                                                                      color: !fingerprint ? Colors.white : LightColors.text,
                                                                                      fontSize: 16,
                                                                                      fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                onTap: () {
                                                                                  setState(() {
                                                                                    fingerprint = !fingerprint;
                                                                                  });
                                                                                },
                                                                              ),
                                                                            ),
                                                                          ],
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Divider(),
                                                                    SizedBox(
                                                                      height:
                                                                          36,
                                                                    ),
                                                                    Text(
                                                                      fingerprint
                                                                          ? S
                                                                              .of(context)
                                                                              .fingerprint
                                                                          : S.of(context).faceDetection,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color(
                                                                            0xff738390),
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          36,
                                                                    ),
                                                                    fingerprint
                                                                        ? AppIcons.fingerprint_scan(
                                                                            160,
                                                                            locator<UserSettings>().biometricsEnabled
                                                                                ? AppColors.active
                                                                                : AppColors.inactiveText)
                                                                        : AppIcons.face_detection(160),
                                                                    SizedBox(
                                                                      height:
                                                                          36,
                                                                    ),
                                                                    Text(
                                                                      fingerprint
                                                                          ? S
                                                                              .of(context)
                                                                              .touchSensor
                                                                          : S.of(context).lookCamera,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color(
                                                                            0xff151F32),
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          36,
                                                                    ),
                                                                    Button(
                                                                      value: locator<UserSettings>()
                                                                              .biometricsEnabled
                                                                          ? S
                                                                              .of(context)
                                                                              .disable
                                                                          : S.of(context).enable,
                                                                      onTap:
                                                                          () async {
                                                                        if (await model1
                                                                            .checkBiometrics()) {
                                                                          await model1
                                                                              .switchBiometrics(context);
                                                                          model.setPassword(
                                                                              context);
                                                                        }
                                                                      },
                                                                    ),
                                                                    SizedBox(
                                                                      height: 6,
                                                                    ),
                                                                    Container(
                                                                      width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width,
                                                                      child:
                                                                          OutlinedButton(
                                                                        style: OutlinedButton
                                                                            .styleFrom(
                                                                          padding:
                                                                              const EdgeInsets.all(16),
                                                                          shape:
                                                                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                          model.setPassword(
                                                                              context);
                                                                        },
                                                                        child:
                                                                            Text(
                                                                          S.of(context).cancel,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Color(0xff738390),
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ));
                                                });
                                          },
                                        );
                                      });
                                }
                              },
                            )
                          ],
                        ),
                      )),
                ),
        );
      },
    );
  }
}
