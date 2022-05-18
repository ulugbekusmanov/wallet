import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tbccwallet/core/authentication/AccountManager.dart';
import 'package:tbccwallet/global_env.dart';
import 'package:tbccwallet/locator.dart';
import 'package:tbccwallet/shared.dart';
import 'package:tbccwallet/ui/views/settings/SettingsMainModel.dart';
import 'package:tbccwallet/ui/views/wallet/WalletMainScreenModel.dart';

class CurrencyScreen extends StatelessWidget {
  final SettingsMainModel model;
  CurrencyScreen(this.model, {Key? key}) : super(key: key);
  bool needToReload = false;
  @override
  Widget build(BuildContext context) {
    return BaseView<SettingsMainModel>(
      model: model,
      builder: (context, model, child) {
        return WillPopScope(
          onWillPop: () async {
            if (needToReload) {
              () async {
                locator<WalletMainScreenModel>().manualRefresh = true;

                await locator<AccountManager>().reloadTickers();
                locator<WalletMainScreenModel>().manualRefresh = false;
              }();
            }
            return true;
          },
          child: Scaffold(
              appBar: CAppBar(
                elevation: 0,
                title: Text(S.of(context).currency),
              ),
              body: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: FIAT_CURRENCIES.length,
                  itemBuilder: (context, index) {
                    var symbol = FIAT_CURRENCIES[index];

                    return GestureDetector(
                      onTap: () {
                        needToReload = true;
                        model.currencyChanged(symbol);
                      },
                      child: currencyCard(symbol),
                    );
                  })),
        );
      },
    );
  }

  Widget currencyCard(String symbol) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.generalShapesBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 35,
              height: 25,
              child: SvgPicture.asset(
                'assets/images/flags/${symbol.toLowerCase()}.svg',
                fit: BoxFit.fill,
                clipBehavior: Clip.hardEdge,
              ),
            ),
          ),
          SizedBox(width: 25),
          Text('${symbol.toUpperCase()}'),
          Spacer(),
          RadioSelectorCircle(active: symbol == FIAT_CURRENCY_SYMBOL),
        ],
      ),
    );
  }
}