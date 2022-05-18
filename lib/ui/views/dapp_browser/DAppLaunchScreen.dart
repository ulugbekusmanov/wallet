import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tbccwallet/core/authentication/AccountManager.dart';
import 'package:tbccwallet/core/token/utils.dart';
import 'package:tbccwallet/locator.dart';
import 'package:tbccwallet/shared.dart';
import 'DAppScreen.dart';

String dappImageUrlBase = 'https://raw.githubusercontent.com/trustwallet/assets/master/dapps';

enum DAppType { DeFi, Games, Tools }

var network_chainId = <TokenNetwork, int>{
  TokenNetwork.BinanceSmartChain: 56,
  TokenNetwork.Ethereum: 1,
};

class DApp {
  late Uri url;
  String? customImageUrl;
  late String name;
  TokenNetwork? network;
  late DAppType type;
  String? description;
  late bool fromAsset;
  late Widget image;
  DApp(this.url, this.name, this.network, this.type, {this.customImageUrl, this.fromAsset = false, this.description}) {
    image = fromAsset
        ? Image.asset(
            customImageUrl!,
            height: 60,
            width: 60,
          )
        : CachedNetworkImage(
            height: 60,
            width: 60,
            imageUrl: customImageUrl ?? '$dappImageUrlBase/${url.host}.png',
          );
  }
}

class DAppLaunchScreenModel extends BaseViewModel {
  final accManager = locator<AccountManager>();
  DApp? currDapp;
  int selectedAccIndex = 0;
  bool needToLoadEmpty = false;
  late DAppScreenModel dappScreenModel;
  var ethDApps = [
    DApp(Uri.parse('https://app.uniswap.org'), 'Uniswap', TokenNetwork.Ethereum, DAppType.DeFi, description: 'AMM DEX'),
    DApp(Uri.parse('https://app.sushi.com/'), 'SushiSwap', TokenNetwork.Ethereum, DAppType.DeFi, description: 'AMM DEX', customImageUrl: 'https://raw.githubusercontent.com/trustwallet/assets/master/dapps/sushiswapclassic.org.png'),
    DApp(Uri.parse('https://app.compound.finance/'), 'Compound', TokenNetwork.Ethereum, DAppType.DeFi, description: 'Lending and borrowing DeFi app'),
    DApp(Uri.parse('https://app.1inch.io/#/1'), '1inch (Ethereum)', TokenNetwork.Ethereum, DAppType.DeFi, description: 'AMM & DEX aggregator', customImageUrl: 'https://raw.githubusercontent.com/trustwallet/assets/master/dapps/1inch.exchange.png'),
    DApp(Uri.parse('https://shibaswap.com/#/'), 'ShibaSwap', TokenNetwork.Ethereum, DAppType.DeFi, description: 'AMM DEX', customImageUrl: 'https://shibaswap.com/images/logo-512x512.png'),
  ];

  var bscDApps = [
    //DApp(Uri.parse('https://tbccswap.com'), 'TBCC Swap', TokenNetwork.BinanceSmartChain, DAppType.DeFi, description: 'AMM DEX', fromAsset: true, customImageUrl: 'assets/images/logo.png'),
    DApp(Uri.parse('https://pancakeswap.finance/'), 'PancakeSwap', TokenNetwork.BinanceSmartChain, DAppType.DeFi, description: 'AMM DEX'),
    DApp(Uri.parse('https://app.1inch.io/#/56'), '1inch (SmartChain)', TokenNetwork.BinanceSmartChain, DAppType.DeFi, description: 'AMM & DEX aggregator', customImageUrl: 'https://raw.githubusercontent.com/trustwallet/assets/master/dapps/1inch.exchange.png'),
    DApp(Uri.parse('https://app.venus.io/'), 'Venus', TokenNetwork.BinanceSmartChain, DAppType.DeFi, description: 'Decentralized Marketplace'),
    DApp(Uri.parse('https://apeswap.finance/'), 'ApeSwap', TokenNetwork.BinanceSmartChain, DAppType.DeFi, description: 'AMM DEX'),
    DApp(Uri.parse('https://www.bakeryswap.org/'), 'BakerySwap', TokenNetwork.BinanceSmartChain, DAppType.DeFi, description: 'AMM DEX'),
  ];

  var toolsApps = [
    DApp(Uri.parse('https://bscscan.com/'), 'BscScan', TokenNetwork.BinanceSmartChain, DAppType.Tools, description: 'Binance Smart Chain Explorer', fromAsset: true, customImageUrl: 'assets/images/bscscan_logo.png'),
    DApp(Uri.parse('https://etherscan.com/'), 'Etherscan', TokenNetwork.Ethereum, DAppType.Tools, description: 'ETH blockchain explorer', fromAsset: true, customImageUrl: 'assets/images/etherscan_logo.png'),
    DApp(Uri.parse('https://cn.etherscan.com/'), 'Etherscan CN', TokenNetwork.Ethereum, DAppType.Tools, description: '[China] ETH blockchain explorer', fromAsset: true, customImageUrl: 'assets/images/etherscan_cn_logo.png'),
    DApp(Uri.parse('https://explorer.binance.org/'), 'DEX Explorer', TokenNetwork.BinanceChain, DAppType.Tools, description: 'Binance Chain explorer', customImageUrl: 'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/binance/info/logo.png'),
    DApp(Uri.parse('https://coingecko.com/'), 'CoinGecko', null, DAppType.Tools, description: 'Market information', fromAsset: true, customImageUrl: 'assets/images/coingecko_logo.png'),
    DApp(Uri.parse('https://coinmarketcap.com/'), 'CoinMarketCap', null, DAppType.Tools, description: 'Market information', fromAsset: true, customImageUrl: 'assets/images/coinmarketcap_logo.png'),
    DApp(Uri.parse('https://info.uniswap.org/#/'), 'Uniswap info', TokenNetwork.Ethereum, DAppType.Tools, description: 'Uniswap statistics'),
    DApp(Uri.parse('https://pancakeswap.info/'), 'PancakeSwap info', TokenNetwork.BinanceSmartChain, DAppType.Tools, description: 'PancakeSwap statistics', customImageUrl: 'https://raw.githubusercontent.com/trustwallet/assets/master/dapps/pancakeswap.finance.png'),
  ];
}

class DAppLaunchScreen extends StatelessWidget {
  DAppLaunchScreenModel model;
  DAppLaunchScreen(this.model, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<DAppLaunchScreenModel>(
      model: model,
      onModelReady: (model) {},
      builder: (context, model, child) {
        return Scaffold(
            appBar: CAppBar(
              elevation: 0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('DApp Browser'),
                  AccountSelector((index) {
                    if (model.selectedAccIndex != index) {
                      model.selectedAccIndex = index;
                      model.setState();
                    }
                  }),
                ],
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //SingleChildScrollView(
                  //  scrollDirection: Axis.horizontal,
                  //  padding: const EdgeInsets.all(16),
                  //  child: Column(
                  //    children: [
                  //      SingleChildScrollView(
                  //        child: Row(
                  //          children: [
                  //            DAppCardMin(model.dApps[0]),
                  //            DAppCardMin(model.dApps[1]),
                  //            DAppCardMin(model.dApps[2]),
                  //            DAppCardMin(model.dApps[3]),
                  //            DAppCardMin(model.dApps[4]),
                  //          ],
                  //        ),
                  //      )
                  //    ],
                  //  ),
                  //),

                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('Binance Smart Chain', style: Theme.of(context).textTheme.headline6!.copyWith(color: AppColors.text)),
                  ),
                  dappsBlock(model.bscDApps, model),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('Ethereum', style: Theme.of(context).textTheme.headline6!.copyWith(color: AppColors.text)),
                  ),
                  dappsBlock(model.ethDApps, model),

                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('Tools', style: Theme.of(context).textTheme.headline6!.copyWith(color: AppColors.text)),
                  ),
                  dappsBlock(model.toolsApps, model),
                ],
              ),
            ));
      },
    );
  }

  Widget dappsBlock(List<DApp> dapps, DAppLaunchScreenModel model) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: () sync* {
              int packCnt = 0;
              List<Widget> pack = [];
              for (var i in List<int>.generate(dapps.length, (index) => index)) {
                var app = dapps[i];
                pack.add(
                  DAppCardFull(
                    app,
                    () {
                      model.currDapp = app;
                      model.dappScreenModel.indexToShow = 2;
                      model.dappScreenModel.browserScreenModel.launchDApp(app);
                    },
                    model,
                  ),
                );

                packCnt += 1;

                if (packCnt == 3 || dapps.length == i + 1) {
                  packCnt = 0;
                  yield Column(crossAxisAlignment: CrossAxisAlignment.start, children: pack);
                  pack = [];
                }
              }
            }()
                .toList()));
  }
}

class DAppCardMin extends StatelessWidget {
  DApp dapp;
  DAppCardMin(this.dapp, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.all(12),
        width: 60,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: dapp.fromAsset
                  ? Image.asset(dapp.customImageUrl!)
                  : CachedNetworkImage(
                      imageUrl: dapp.customImageUrl ?? '$dappImageUrlBase/${dapp.url.host}.png',
                    ),
            ),
            SizedBox(height: 10),
            AutoSizeText(
              dapp.name,
              softWrap: true,
              maxLines: dapp.name.split(' ').length,
            )
          ],
        ),
      ),
    );
  }
}

class DAppCardFull extends StatelessWidget {
  DAppLaunchScreenModel launchScreenModel;
  DApp dapp;
  void Function() onTap;
  DAppCardFull(this.dapp, this.onTap, this.launchScreenModel, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 260,
          margin: const EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: dapp.image,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dapp.name, style: Theme.of(context).textTheme.bodyText1),
                    Text(
                      dapp.description ?? '',
                      style: Theme.of(context).textTheme.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}

class DAppLoadingScreen extends StatefulWidget {
  DAppLaunchScreenModel launchScreenModel;
  DAppLoadingScreen(this.launchScreenModel, {Key? key}) : super(key: key);

  @override
  _DAppLoadingScreenState createState() => _DAppLoadingScreenState();
}

class _DAppLoadingScreenState extends State<DAppLoadingScreen> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(milliseconds: 700), vsync: this);
    animation = Tween<double>(begin: 140, end: 160).animate(controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed)
          controller.reverse();
        else if (status == AnimationStatus.dismissed) controller.forward();
      });
    controller.forward();
  }
  // #enddocregion print-state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CAppBar(
          elevation: 0,
          title: Text('Loading...'),
          actions: [
            IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  widget.launchScreenModel.dappScreenModel.indexToShow = 0;
                  widget.launchScreenModel.dappScreenModel.browserScreenModel.firstPageLoad = false;
                  widget.launchScreenModel.dappScreenModel.browserScreenModel.loadEmpty();
                })
          ],
        ),
        body: Center(
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return SizedBox(
                height: animation.value,
                width: animation.value,
                child: child,
              );
            },
            child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)), clipBehavior: Clip.hardEdge, child: widget.launchScreenModel.currDapp?.image),
          ),
        ));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  // #docregion print-state
}
