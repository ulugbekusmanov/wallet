import 'package:tbccwallet/core/api/binance_chain/BCApi.dart';
import 'package:tbccwallet/core/api/coingecko/CoingeckoAPI.dart';
import 'package:tbccwallet/core/authentication/AccountManager.dart';
import 'package:tbccwallet/core/authentication/AuthService.dart';

import 'package:tbccwallet/core/token/TokenContainer.dart';
import 'package:tbccwallet/locator.dart';
import 'package:tbccwallet/shared.dart';

class BuyPremiumModel extends BaseViewModel {
  String mode = '0';
  int accIndex = 0;
  var _api = locator<BinanceChainApi>();
  AccountManager accManager = locator<AuthService>().accManager;
  WalletBalance? bnbBal;
  Decimal usdPrice = Decimal.parse('20');
  Decimal fee = Decimal.parse('0.000075');
  Decimal? bnbPrice;

  Future<void> init() async {
    setState(ViewState.Busy);

    await findBNBBal();
    var bnbPriceUsd = (await locator<CoingeckoApi>().loadTickers(ids: ['binancecoin'], vsCurrencies: ['usd'])).load['binancecoin']!.inCurrency;

    bnbPrice = Decimal.parse((usdPrice / bnbPriceUsd!).toStringWithFractionDigits(3, shrinkZeros: true));
    //model.bnbPrice = Decimal.parse('0.0001');
    setState(ViewState.Idle);
  }

  Future<void> buyPremium(BuildContext context) async {
    setState(ViewState.Busy);

    var resp = await _api.sendToken(accManager.allAccounts[accIndex].bcWallet, 'bnb1axkzc707rl7nqlzxl3jftkm72vmdh7gvqyvy2j', 'BNB', bnbPrice!, 'TBCC Premium', sync: true);

    if (resp.ok) {
      accManager.allAccounts[accIndex].tbccUser.paidFee = 1.5;
      accManager.allAccounts[accIndex].tbccUser.subPurchaseDate = DateTime.now().toUtc();
      accManager.notifyListeners();
      Navigator.of(context).popUntil((route) => route.isFirst);

      Flushbar.success(title: S.of(context).success).show();
    } else {
      Flushbar.error(title: resp.load.first.data ?? S.of(context).error).show();
    }

    setState(ViewState.Idle);
  }

  Future<void> findBNBBal() async {
    bnbBal = accManager.bcBalanceByToken(accIndex, locator<WALLET_TOKENS_CONTAINER>().BEP2.firstWhere((element) => element.symbol == 'BNB'));

    if (bnbBal?.fiatPrice == Decimal.zero) {
      bnbBal?.fiatPrice = accManager.balanceByToken(accIndex, locator<WALLET_TOKENS_CONTAINER>().COINS.firstWhere((element) => element.symbol == 'BNB'))!.fiatPrice;
    }
  }
}
