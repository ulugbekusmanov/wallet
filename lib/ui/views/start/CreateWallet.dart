import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:tbccwallet/core/authentication/AuthService.dart';
import 'package:tbccwallet/locator.dart';
import 'package:tbccwallet/shared.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/foundation.dart';
import 'package:tbccwallet/ui/MainScreen.dart';
import 'package:tbccwallet/ui/views/start/SetPassword.dart';
import 'package:tbccwallet/ui/views/wallet/WalletMainScreenModel.dart';

import 'RestoreWallet.dart';

class CreateWalletModel extends BaseViewModel {
  final _authService = locator<AuthService>();
  bool addWallet = false;
  bool _24words = false;
  late String mnemonic;
  bool loseMnemonicCheckbox = false;
  bool loseMnemonicCheckboxErr = false;
  bool termsCheckbox = false;
  bool termsCheckboxErr = false;

  late List<String> newMnemonicList;
  late List<String> reformedMnemonicList;
  List<String> verifyMnemonicList = [];

  bool verifyValid = true;
  int lastCorrectIndex = -1;
  bool setPassworBtnActive = false;

  generateNewMnemonic() {
    mnemonic = bip39.generateMnemonic(strength: _24words ? 256 : 128);
    newMnemonicList = mnemonic.split(' ');
    reformedMnemonicList = List.from(newMnemonicList)..shuffle();

    setState();
  }

  Future<void> setPassword(BuildContext context) async {
    setState(ViewState.Busy);
    if (addWallet) {
      await createAccount(context);
      return;
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SetPasswordScreen(
            S.of(context).createWallet,
            () async {
              await this.createAccount(context);
            },
          ),
        ),
      );
    }
    setState(ViewState.Idle);
  }

  Future<void> createAccount(BuildContext context) async {
    var seed =
        await compute<String, Uint8List>(calculateSeedFromMnemonic, mnemonic);
    await _authService.createNewAccount(mnemonic, seed);
    locator<WalletMainScreenModel>().loadBalances();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => MainAppScreen()), (_) => false);
  }
}

class CreateWalletScreen extends StatelessWidget {
  bool addWallet;
  CreateWalletScreen({this.addWallet = false});

  @override
  Widget build(BuildContext context) {
    return BaseView<CreateWalletModel>(
      onModelReady: (model) {
        model.addWallet = addWallet;

        model.generateNewMnemonic();
      },
      builder: (context, model, child) {
        return CScaffold(
          appBar: CAppBar(
            elevation: 0,
            title: Text(
              S.of(context).createWallet,
            ),
          ),
          body: model.state == ViewState.Busy
              ? TBCCLoader()
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: <TextSpan>[
                              TextSpan(
                                  text: S.of(context).mnemonicDescription1,
                                  style: Theme.of(context).textTheme.bodyText1),
                              TextSpan(
                                text: S.of(context).mnemonicPhrase,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    ?.copyWith(color: AppColors.active),
                              ),
                              TextSpan(
                                  text:
                                      ' ${S.of(context).mnemonicDescription3}',
                                  style: Theme.of(context).textTheme.bodyText1)
                            ]),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '12 words ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(
                                      color: !model._24words
                                          ? AppColors.active
                                          : AppColors.text),
                            ),
                            CupertinoSwitch(
                                activeColor: AppColors.active,
                                value: model._24words,
                                onChanged: (val) {
                                  model._24words = val;
                                  model.generateNewMnemonic();
                                  model.setState();
                                }),
                            Text(
                              ' 24 words',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(
                                      color: model._24words
                                          ? AppColors.active
                                          : AppColors.text),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (var w in model.newMnemonicList.indexed())
                              MnemonicWordChip(w[0], w[1])
                          ],
                        ),
                        SizedBox(height: 30),
                        GestureDetector(
                          onTap: () async {
                            await Clipboard.setData(
                                ClipboardData(text: model.mnemonic));
                            Flushbar.success(
                                    title: S.of(context).copiedToClipboard(''))
                                .show();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${S.of(context).copy}  '),
                              AppIcons.copy(22, AppColors.active)
                            ],
                          ),
                        ),
                        Spacer(),
                        Row(children: [
                          Stack(children: [
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: model.loseMnemonicCheckboxErr
                                            ? AppColors.red
                                            : Colors.transparent),
                                  ),
                                ),
                              ),
                            ),
                            Checkbox(
                                value: model.loseMnemonicCheckbox,
                                activeColor: AppColors.active,
                                onChanged: (val) {
                                  model.loseMnemonicCheckbox = val!;
                                  model.loseMnemonicCheckboxErr = !val;
                                  model.setState();
                                }),
                          ]),
                          Expanded(child: Text(S.of(context).mnemonicWarning))
                        ]),
                        Row(children: [
                          Stack(children: [
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: model.termsCheckboxErr
                                            ? AppColors.red
                                            : Colors.transparent),
                                  ),
                                ),
                              ),
                            ),
                            Checkbox(
                                activeColor: AppColors.active,
                                value: model.termsCheckbox,
                                onChanged: (val) {
                                  model.termsCheckbox = val!;
                                  model.termsCheckboxErr = !val;
                                  model.setState();
                                }),
                          ]),
                          Expanded(
                              child: Text(
                                  '${S.of(context).confirmPhrase1} ${S.of(context).confirmPhrase2}'))
                        ]),
                        SizedBox(height: 12),
                        Button(
                            value: S.of(context).createWallet,
                            onTap: () {
                              model.loseMnemonicCheckboxErr =
                                  !model.loseMnemonicCheckbox;
                              model.termsCheckboxErr = !model.termsCheckbox;
                              if (!model.loseMnemonicCheckboxErr &&
                                  !model.termsCheckboxErr) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) =>
                                        CheckMnemonicScreen(model)));
                              } else {
                                model.setState();
                              }
                            }),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class CheckMnemonicScreen extends StatelessWidget {
  CreateWalletModel model;
  CheckMnemonicScreen(this.model, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<CreateWalletModel>(
      model: model,
      onModelReady: (model) {},
      builder: (context, model, child) {
        return WillPopScope(
          onWillPop: () async {
            model.verifyMnemonicList.clear();
            model.lastCorrectIndex = -1;
            model.verifyValid = true;
            model.reformedMnemonicList = List.from(model.newMnemonicList)
              ..shuffle();
            return true;
          },
          child: Scaffold(
            appBar: CAppBar(
              elevation: 0,
              title: Text('Check'),
            ),
            body: model.state == ViewState.Busy
                ? TBCCLoader()
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              S.of(context).verifyMnemonic,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 30.0, top: 40),
                              child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: AppColors.generalShapesBg,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  constraints: BoxConstraints(minHeight: 200),
                                  child: Wrap(
                                    runAlignment: WrapAlignment.center,
                                    alignment: WrapAlignment.center,
                                    runSpacing: 10,
                                    spacing: 10,
                                    children: List.generate(
                                        model.verifyMnemonicList.length,
                                        (index) => GestureDetector(
                                              onTap: () {
                                                model.reformedMnemonicList.add(
                                                    model.verifyMnemonicList[
                                                        index]);
                                                model.verifyMnemonicList
                                                    .removeAt(index);
                                                if (listEquals(
                                                    model.newMnemonicList.sublist(
                                                        0,
                                                        model.verifyMnemonicList
                                                            .length),
                                                    model.verifyMnemonicList)) {
                                                  model.verifyValid = true;
                                                  model.lastCorrectIndex = model
                                                          .verifyMnemonicList
                                                          .length -
                                                      1;
                                                } else
                                                  model.verifyValid = false;
                                                model.setState();
                                              },
                                              behavior: HitTestBehavior.opaque,
                                              child: MnemonicWordChipFilled(
                                                index,
                                                model.verifyMnemonicList[index],
                                                err: index >
                                                    model.lastCorrectIndex,
                                              ),
                                            )),
                                  )),
                            ),
                            model.verifyValid
                                ? Container()
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    child: Text(
                                      S.of(context).invalidOrder,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(color: AppColors.red),
                                    )),
                            Wrap(
                              alignment: WrapAlignment.center,
                              runSpacing: 10,
                              spacing: 10,
                              children: List.generate(
                                  model.reformedMnemonicList.length,
                                  (index) => GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          model.verifyMnemonicList.add(model
                                              .reformedMnemonicList[index]);
                                          model.reformedMnemonicList
                                              .removeAt(index);
                                          if (listEquals(
                                              model.newMnemonicList.sublist(
                                                  0,
                                                  model.verifyMnemonicList
                                                      .length),
                                              model.verifyMnemonicList)) {
                                            model.verifyValid = true;
                                            model.lastCorrectIndex = model
                                                    .verifyMnemonicList.length -
                                                1;
                                          } else
                                            model.verifyValid = false;
                                          if (listEquals(model.newMnemonicList,
                                              model.verifyMnemonicList)) {
                                            model.setPassworBtnActive = true;
                                          }
                                          model.setState();
                                        },
                                        child: MnemonicWordChip(null,
                                            model.reformedMnemonicList[index]),
                                      )),
                            ),
                          ],
                        ),
                        Button(
                          value: S.of(context).next,
                          isActive: model.setPassworBtnActive,
                          onTap: model.setPassworBtnActive
                              ? () {
                                  if (model.verifyValid) {
                                    model.setPassword(context);
                                  }
                                }
                              : null,
                        )
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class MnemonicWordChip extends StatelessWidget {
  int? index;
  String word;

  MnemonicWordChip(this.index, this.word, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: AppColors.mainGradient.createShader,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(12)),
        child: RichText(
          text: TextSpan(
            text: index != null ? '${index! + 1}  ' : '',
            style: Theme.of(context)
                .textTheme
                .caption!
                .copyWith(color: AppColors.text),
            children: [
              TextSpan(
                  text: word,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2!
                      .copyWith(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class MnemonicWordChipFilled extends StatelessWidget {
  int? index;
  String word;
  bool err;
  MnemonicWordChipFilled(this.index, this.word, {this.err = false, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: err ? Border.all(color: AppColors.red) : null,
        gradient: AppColors.mainGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: RichText(
        text: TextSpan(
          text: index != null ? '${index! + 1}  ' : '',
          style: Theme.of(context)
              .textTheme
              .caption!
              .copyWith(color: Colors.white),
          children: [
            TextSpan(
                text: word,
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
