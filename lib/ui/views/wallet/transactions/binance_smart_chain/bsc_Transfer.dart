import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:tbccwallet/core/authentication/AccountManager.dart';
import 'package:tbccwallet/core/token/utils.dart';

import 'package:tbccwallet/global_env.dart';
import 'package:tbccwallet/locator.dart';
import 'package:tbccwallet/shared.dart';
import 'package:tbccwallet/ui/views/settings/address_book/AddressBookPicker.dart';

import 'package:tbccwallet/ui/widgets/SharedWidgets.dart';

import 'model.dart';
import 'bsc_ConfirmTx.dart';

class BSCTransferScreen extends StatelessWidget {
  WalletBalance balance;
  int accountFrom;
  BSCTransferScreen(this.balance, this.accountFrom, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<BSCTransferModel>(
      onModelReady: (model) async {
        model.balance = balance;
        model.account = model.accManager.allAccounts[accountFrom];
        model.bnbBalance = model.account.coinBalances.firstWhere((b) => b.token.symbol == 'BNB');
        model.init();
      },
      builder: (context, model, child) {
        return ChangeNotifierProvider.value(
            value: locator<AccountManager>(),
            child: Consumer<AccountManager>(builder: (_, __, ___) {
              balance = model.account.allBalances.firstWhere((element) => element.token == balance.token);
              model.balance = balance;
              model.bnbBalance = model.account.coinBalances.firstWhere((b) => b.token.symbol == 'BNB');

              return CScaffold(
                appBar: CAppBar(
                  elevation: 0,
                  title: RichText(
                    text: TextSpan(text: '${S.of(context).send} ', style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 20), children: [
                      TextSpan(text: '${balance.token.symbol}${balance.token.standard != 'Native' ? ' - ${balance.token.standard}' : ''}', style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 20, color: AppColors.inactiveText)),
                    ]),
                  ),
                ),
                body: model.state == ViewState.Busy
                    ? Center(child: CircularProgressIndicator())
                    : Form(
                        key: model.formKey1,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${S.of(context).balance}:'),
                                        Text('${model.balance.balance} ${model.balance.token.symbol}'),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () async {
                                        var addressBookPick = await Navigator.of(context).push<String?>(
                                          PageTransition(
                                            child: AddressBookPickerScreen(TokenNetwork.BinanceSmartChain),
                                            type: PageTransitionType.rightToLeft,
                                          ),
                                        );
                                        if (addressBookPick != null) {
                                          model.controllerAddress.text = addressBookPick;
                                          model.addressTo = EthereumAddress.fromHex(addressBookPick);
                                        }
                                      },
                                      child: InnerPageTile(
                                        null,
                                        'Open address book',
                                        actions: [AppIcons.chevron(22)],
                                        bradius: 16,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Stack(children: [
                                      TextFormField(
                                        controller: model.controllerAddress,
                                        validator: (val) => model.isAddrValid ? null : S.of(context).wrongAddr,
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        decoration: generalTextFieldDecor(context, hintText: S.of(context).addressOfRecipient, paddingRight: 86),
                                      ),
                                      Positioned(
                                        right: 46,
                                        top: 10,
                                        child: textFieldActionsButton(child: gradientIcon(AppIcons.book_open(22)), onTap: () => model.pasteAddress(context)),
                                      ),
                                      Positioned(
                                        right: 10,
                                        top: 10,
                                        child: textFieldActionsButton(child: gradientIcon(AppIcons.qr_code_scan(22)), onTap: () => model.scanAddressQr(context)),
                                      ),
                                    ]),
                                    SizedBox(height: 8),
                                    Stack(
                                      children: [
                                        TextFormField(
                                          controller: model.controllerValue,
                                          keyboardType: TextInputType.number,
                                          validator: (val) => model.balanceEnough
                                              ? null
                                              : model.value == null
                                                  ? S.of(context).typeCorrectAmount
                                                  : S.of(context).notEnoughTokens,
                                          onChanged: (val) {
                                            var parsedVal = Decimal.tryParse(val);
                                            model.value = parsedVal;

                                            model.valueInFiat = parsedVal != null ? model.value! * model.balance.fiatPrice : model.valueInFiat = null;

                                            model.setState();
                                          },
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          decoration: generalTextFieldDecor(context, hintText: S.of(context).amountToken(balance.token.symbol), paddingRight: 86),
                                        ),
                                        Positioned(
                                          right: 10,
                                          top: 10,
                                          child: textFieldActionsButton(child: gradientIcon(Text('Max')), onTap: () => model.setMax()),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: Text(
                                        '~ ${model.valueInFiat?.toStringWithFractionDigits(2) ?? 0.00} $FIAT_CURRENCY_SYMBOL',
                                        textAlign: TextAlign.left,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Button(
                              value: S.of(context).next,
                              onTap: () {
                                if (model.formKey1.currentState?.validate() == true) Navigator.of(context).push(PageTransition(child: ConfirmTx(model), type: PageTransitionType.rightToLeft));
                              },
                            )
                          ]),
                        ),
                      ),
              );
            }));
      },
    );
  }
}
