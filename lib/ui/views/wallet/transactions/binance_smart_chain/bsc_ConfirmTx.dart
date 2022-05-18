import 'package:provider/provider.dart';
import 'package:tbccwallet/core/authentication/AccountManager.dart';
import 'package:tbccwallet/global_env.dart';
import 'package:tbccwallet/locator.dart';
import 'package:tbccwallet/shared.dart';
import 'bsc_Advanced.dart';
import 'model.dart';

class ConfirmTx extends StatelessWidget {
  final BSCTransferModel model;
  const ConfirmTx(this.model, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<BSCTransferModel>(
      onModelReady: (model) async {
        model.initAdvanced();
      },
      model: model,
      builder: (context, model, child) {
        return ChangeNotifierProvider.value(
            value: locator<AccountManager>(),
            child: Consumer<AccountManager>(builder: (_, __, ___) {
              model.balance = model.account.allBalances.firstWhere((element) => element.token == model.balance.token);
              return CScaffold(
                appBar: CAppBar(
                  elevation: 0,
                  title: RichText(
                    text: TextSpan(text: '${S.of(context).send} ', style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 20), children: [TextSpan(text: model.balance.token.symbol, style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 20, color: AppColors.inactiveText))]),
                  ),
                ),
                body: model.state == ViewState.Busy
                    ? Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    '- ${model.value.toString()} ${model.balance.token.symbol}',
                                    style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 36),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    '~ ${model.valueInFiat?.toStringWithFractionDigits(2)} $FIAT_CURRENCY_SYMBOL',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyText1!.copyWith(color: AppColors.inactiveText, fontSize: 20),
                                  ),
                                  SizedBox(height: 16),
                                  InnerPageTile(S.of(context).from, '${model.account.bscWallet.address.hex}  (${model.account.accountAlias})'),
                                  SizedBox(height: 8),
                                  InnerPageTile(S.of(context).to, model.addressTo.toString()),
                                  SizedBox(height: 8),
                                  InnerPageTile(S.of(context).networkFee, '${model.totalFee} BNB  ${model.totalFeeInFiat!.toStringWithFractionDigits(2)} $FIAT_CURRENCY_SYMBOL'),
                                  SizedBox(height: 8),
                                  InnerPageTile('Max total', '${model.maxTotal?.toStringWithFractionDigits(2)} $FIAT_CURRENCY_SYMBOL'),
                                  SizedBox(height: 16),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => BSCAdvancedScreen(model)));
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: InnerPageTile(null, S.of(context).advanced, actions: [AppIcons.chevron(22)], bradius: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (model.enoughBNBTotal != true) ...[
                            Text(S.of(context).notEnoughTokensFee('BNB'), style: Theme.of(context).textTheme.bodyText2!.copyWith(color: AppColors.red)),
                            SizedBox(height: 12),
                          ],
                          Button(
                            value: S.of(context).confirmTransfer,
                            onTap: () async {
                              if (model.enoughBNBTotal == true) {
                                model.sendTransaction(context);
                              }
                            },
                          )
                        ]),
                      ),
              );
            }));
      },
    );
  }
}
