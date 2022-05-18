import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tbccwallet/core/api/tbcc/TBCCApi.dart';
import 'package:tbccwallet/core/api/tbcc/models/News.dart';
import 'package:tbccwallet/core/authentication/AccountManager.dart';
import 'package:tbccwallet/core/authentication/AuthService.dart';
import 'package:tbccwallet/core/blockchain/binance_smart_chain/contracts/BEP20_abi.dart';
import 'package:tbccwallet/core/settings/AppSettings.dart';
import 'package:tbccwallet/core/settings/UserSettings.dart';
import 'package:tbccwallet/global_env.dart';
import 'package:tbccwallet/locator.dart';
import 'package:tbccwallet/shared.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:tbccwallet/ui/views/premium/Pro_Premium.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/web3dart.dart';

class NewsListViewModel extends BaseViewModel {
  var tbccApi = locator<TBCCApi>();
  List<NewsModel>? news;
  Future<void> loadNews() async {
    setState(ViewState.Busy);
    news = (await tbccApi
            .loadNews(locator<UserSettings>().language?.languageCode ?? 'en'))
        .load;
    //news = [
    //  NewsModel.fromJson({
    //    'id': 222,
    //    'header': "",
    //    'preview': "",
    //    'timestamp': "",
    //    'preview_image_url': "",
    //    'content': """该应用程序可通过 <a href="http://182.92.107.179/vpn/TBCCVPN-armv7-latest/"> aboba</a> 如果您在""",
    //  }),
    //  ...news!
    //];
    setState(ViewState.Idle);
  }
}

class NewsListView extends StatelessWidget {
  final NewsListViewModel model;
  const NewsListView(this.model, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var tt = Theme.of(context).textTheme;
    return BaseView<NewsListViewModel>(
      model: model,
      onModelReady: (model) {
        model.loadNews();
      },
      builder: (context, model, _) {
        return model.state == ViewState.Busy
            ? TBCCLoader()
            : Column(
                children: [
                  if (locator<AppSettings>().lottery) ...[
                    LotteryBanner(),
                    Divider(
                      color: AppColors.active,
                      thickness: 1.5,
                    )
                  ],
                  Expanded(
                    child: ListView.separated(
                      separatorBuilder: (c, i) => SizedBox(height: 12),
                      padding: const EdgeInsets.all(16),
                      itemCount: model.news!.length,
                      itemBuilder: (c, i) {
                        var post = model.news?[i];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: NewsDetailsView(post!)));
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 18,
                                    color: AppColors.shadowColor,
                                    offset: Offset(0, 13))
                              ],
                              gradient: AppColors.altGradient,
                              //color: AppColors.generalShapesBg,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: post!.previewImageUrl ?? '',
                                    width: 68,
                                    height: 68,
                                    errorWidget: (_, __, ___) => Padding(
                                        padding: EdgeInsets.zero,
                                        child: AppIcons.logo(0)),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                    child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text('${post.header}',
                                              style: tt.bodyText2),
                                        ),
                                        Text(
                                          post.timestamp?.toStringDMY() ?? '',
                                          style: tt.caption,
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '${post.preview}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: tt.bodyText1!
                                          .copyWith(fontSize: 14, height: 1.4),
                                    )
                                  ],
                                )),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
      },
    );
  }
}

class NewsDetailsView extends StatelessWidget {
  final NewsModel post;
  const NewsDetailsView(this.post, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var tt = Theme.of(context).textTheme;
    var mqsize = MediaQuery.of(context).size;
    return CScaffold(
      appBar: CAppBar(title: Text(S.of(context).news)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(post.timestamp?.toStringDMY() ?? '',
                      style: tt.caption!.copyWith(fontWeight: FontWeight.w600)),
                  SizedBox(height: 12),
                  Text('${post.header}',
                      style: tt.bodyText2!.copyWith(fontSize: 20, height: 1.2)),
                ],
              ),
            ),
            Html(
              data: post.content,
              onLinkTap: (url, _, __, ___) {
                launch(url!);
              },
              // customImageRenders: {
              //   networkSourceMatcher(): networkImageRender(
              //     loadingWidget: () => Shimmer.fromColors(
              //       child: shimmerBlock(mqsize.width, mqsize.width / 1.77, 16),
              //       baseColor: AppColors.inactiveText,
              //       highlightColor: AppColors.active,
              //     ),
              //   ),
              // },
            ),
          ],
        ),
      ),
    );
  }
}

// ImageRender networkImageRender({
//   Map<String, String>? headers,
//   String Function(String?)? mapUrl,
//   double? width,
//   double? height,
//   Widget Function(String?)? altWidget,
//   Widget Function()? loadingWidget,
// }) =>
//     (context, attributes, element) {
//       return ClipRRect(
//         borderRadius: BorderRadius.circular(24),
//         child: CachedNetworkImage(
//           imageUrl: attributes["src"] ?? "about:blank",
//           width: width,
//           height: height,
//           placeholder: loadingWidget != null ? (_, __) => loadingWidget() : null,
//         ),
//       );
//     };

class LotteryBanner extends StatelessWidget {
  const LotteryBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(PageTransition(
            type: PageTransitionType.rightToLeft, child: LotteryScreen()));
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                blurRadius: 18,
                color: AppColors.shadowColor,
                offset: Offset(0, 13))
          ],
          border: Border.all(color: AppColors.active),
          color: AppColors.generalShapesBg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/lottery.jpg',
                width: 68,
                height: 68,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  Text(
                    S.of(context).lottery,
                    style: tt.bodyText2,
                  ),
                  SizedBox(height: 8),
                  Text(
                    S.of(context).lotteryDesc1,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodyText1,
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LotteryScreen extends StatelessWidget {
  LotteryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<LotteryScreenModel>(
      onModelReady: (model) {
        model.init();
      },
      builder: (context, model, child) {
        //model.lotterySettings.status = 1;
        return CScaffold(
            appBar: CAppBar(
              title: Text(S.of(context).lottery),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: model.state == ViewState.Busy
                  ? TBCCLoader()
                  : () {
                      if (model.lotterySettings.status == 0) {
                        return SingleChildScrollView(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 30),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/lottery.jpg',
                                        width: 70,
                                      ),
                                      Expanded(
                                        child: Text(
                                          S.of(context).lotteryDesc1,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .copyWith(fontSize: 18),
                                        ),
                                      ),
                                    ],
                                  )),
                              for (var item in [
                                S.of(context).lotteryRule1,
                                S.of(context).lotteryRule2,
                                S.of(context).lotteryRule3(
                                    '${model.lotterySettings.ticketPrice}'),
                                S.of(context).lotteryRule4,
                              ])
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    item,
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  S.of(context).lotteryDesc3(
                                        '${model.lotterySettings.startTickets.toStringDMY()} - ${model.lotterySettings.endTickets.toStringDMY()}',
                                        '${model.lotterySettings.startCount.toStringDMY()} - ${model.lotterySettings.endCount.toStringDMY()}',
                                      ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .copyWith(color: AppColors.active),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  S.of(context).lotteryDesc4(
                                      '${model.lotterySettings.end.toStringDMY()}'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .copyWith(color: AppColors.active),
                                ),
                              ),
                              SizedBox(height: 30),
                              Center(
                                child: AccountSelector((index) {
                                  model
                                    ..accIndex = index
                                    ..init();
                                }, initIndex: model.accIndex),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text(
                                  '${S.of(context).lotteryAccepted} ${model.lotterySettings.userCount}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .copyWith(color: AppColors.active),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 30),
                                child: Button(
                                    value: S.of(context).lotteryAccept,
                                    onTap: () {
                                      model.acceptLottery(context);
                                    }),
                              )
                            ]));
                      } else if (model.lotterySettings.status == 1) {
                        return Center(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        S.of(context).lotteryDesc4(
                                            '${model.lotterySettings.end.toStringDMY()}'),
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .copyWith(fontSize: 18),
                                      ),
                                    ),
                                  ],
                                )
                              ]),
                        );
                      } else if (model.lotterySettings.status == 2) {
                        return SingleChildScrollView(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                S.of(context).lotteryWinnersDesc2,
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                          ],
                        ));
                      }
                    }(),
            ));
      },
    );
  }
}

class LotteryScreenModel extends BaseViewModel {
  var authService = locator<AuthService>();
  var tbccApi = locator<TBCCApi>();
  int accIndex = 0;

  late LotterySettings lotterySettings;

  Future<void> init() async {
    setState(ViewState.Busy);

    var resp = await tbccApi.loadLotterySettings(
        authService.accManager.allAccounts[accIndex].bscWallet.address.hex);
    lotterySettings = resp.load;

    setState(ViewState.Idle);
  }

  Future<void> acceptLottery(BuildContext context) async {
    if (authService.accManager.accountType != AccType.Free) {
      setState(ViewState.Busy);
      var confirmed = (await showConfirmationDialog('Lottery',
              S.of(context).lotteryRule3('${lotterySettings.ticketPrice}'),
              confirmationTitle: S.of(context).confirm))
          .confirmed;

      if (confirmed) {
        var tbccContract = DeployedContract(
            bep20BasicContractAbi,
            EthereumAddress.fromHex(
                '0xf29480344d8e21EFeAB7Fde39F8D8299056A7FEA'));
        var price = EtherAmount.fromUnitAndValue(
            EtherUnit.ether, lotterySettings.ticketPrice);

        var t = Transaction.callContract(
            contract: tbccContract,
            function: tbccContract.function('transfer'),
            parameters: [
              EthereumAddress.fromHex(
                  '0x0ac5eb7005f1da7bf43440aa9f2ee3f4c9ac8eec'),
              price.getInWei
            ]);
        try {
          var resp = await ENVS.BSC_ENV!.sendTransaction(
              authService.accManager.allAccounts[accIndex].bscWallet.privateKey,
              t,
              chainId: 56);
          lotterySettings.userCount += 1;
          Flushbar.success(title: S.of(context).success).show();
        } catch (e) {
          Flushbar.error(title: S.of(context).error + e.toString())
              .show(Duration(seconds: 5));
        }
      }
      setState(ViewState.Idle);
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => Pro_PremiumView()));
    }
  }
}
