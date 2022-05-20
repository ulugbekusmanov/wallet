import 'package:provider/provider.dart';
import 'package:tbccwallet/core/authentication/AccountManager.dart';
import 'package:tbccwallet/global_env.dart';
import 'package:tbccwallet/locator.dart';
import 'package:tbccwallet/shared.dart';
import '../../WalletMainScreen.dart';
import '../ethereum/eth_Transfer.dart';
import 'model.dart';

class ConfirmTx extends StatelessWidget {
  final BCTransferModel model;
  const ConfirmTx(this.model, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<BCTransferModel>(
      model: model,
      onModelReady: (model) {
        model.calcTotalFee();
        model.maxTotal = model.totalFeeInFiat! + model.valueInFiat!;
      },
      builder: (context, model, child) {
        return ChangeNotifierProvider.value(
            value: locator<AccountManager>(),
            child: Consumer<AccountManager>(builder: (_, __, ___) {
              model.balance = model.account.allBalances.firstWhere(
                  (element) => element.token == model.balance.token);
              return CScaffold(
                appBar: CAppBar(
                  elevation: 0,
                  title: Text(
                    '${S.of(context).confirm}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(fontSize: 20),
                  ),
                  actions: [
                    Center(
                      child: PremiumSmallWidget(
                        acc: model.accManager,
                        state: model.state,
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: NotificationWidget(
                          onTap: () {},
                          isNewNotification: true,
                        ),
                      ),
                    ),
                  ],
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2!
                                        .copyWith(fontSize: 36),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    '~ ${model.valueInFiat?.toStringWithFractionDigits(2)} $FIAT_CURRENCY_SYMBOL',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .copyWith(
                                            color: AppColors.inactiveText,
                                            fontSize: 20),
                                  ),
                                  SizedBox(height: 16),
                                  InnerPageTile(S.of(context).from,
                                      '${model.account.bcWallet.address}  (${model.account.accountAlias})'),
                                  SizedBox(height: 8),
                                  InnerPageTile(S.of(context).to,
                                      model.addressTo.toString()),
                                  SizedBox(height: 8),
                                  InnerPageTile(S.of(context).networkFee,
                                      '${model.totalFee} BNB  ${model.totalFeeInFiat!.toStringWithFractionDigits(2)} $FIAT_CURRENCY_SYMBOL'),
                                  SizedBox(height: 8),
                                  InnerPageTile('Max total',
                                      '${model.maxTotal?.toStringWithFractionDigits(2)} $FIAT_CURRENCY_SYMBOL'),
                                  SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                          if (model.enoughBNBTotal != true) ...[
                            Text(S.of(context).notEnoughTokensFee('BNB'),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .copyWith(color: AppColors.red)),
                            SizedBox(height: 12),
                          ],
                          Button(
                            value: S.of(context).confirmTransfer,
                            onTap: () async {
                              if (model.enoughBNBTotal == true) {
                                model.sendTransaction(context);
                              }
                            },
                          ),
                          SizedBox(height: 8),
                          Button(
                            isOutLine: true,
                            value: S.of(context).edit,
                            onTap: () async {
                              Navigator.pop(context);
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
