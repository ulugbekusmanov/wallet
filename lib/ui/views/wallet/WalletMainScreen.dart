import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:tbccwallet/core/authentication/AccountManager.dart';
import 'package:tbccwallet/core/settings/AppSettings.dart';

import 'package:tbccwallet/core/settings/UserSettings.dart';
import 'package:tbccwallet/global_env.dart';
import 'package:tbccwallet/locator.dart';
import 'package:tbccwallet/shared.dart';
import 'package:tbccwallet/ui/MainScreen.dart';

import 'package:tbccwallet/ui/styles/AppTheme.dart';
import 'package:tbccwallet/ui/views/premium/Pro_Premium.dart';
import 'package:tbccwallet/ui/views/wallet/market/MarketScreen.dart';
import 'package:tbccwallet/ui/widgets/SharedWidgets.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:tbccwallet/ui/widgets/TokenCard.dart';
import 'package:tbccwallet/ui/widgets/bottom_sheet/CustomBottomSheet.dart';
import 'package:shimmer/shimmer.dart';
//import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'AccountsSettings.dart';
import 'News.dart';
import 'SparklineChart.dart';
import 'TokenFilterScreen.dart';
import 'WalletMainScreenModel.dart';

import 'package:showcaseview/showcaseview.dart';

class WalletMainScreen extends StatefulWidget {
  const WalletMainScreen({Key? key}) : super(key: key);

  @override
  _WalletMainScreenState createState() => _WalletMainScreenState();
}

class _WalletMainScreenState extends State<WalletMainScreen> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final tt = Theme.of(context).textTheme;
    return BaseView<WalletMainScreenModel>(
      onModelReady: (model) async {
        bool inited = false;

        try {
          inited = model.accManager.allAccounts.first.allBalances.isNotEmpty;
        } catch (e) {}
        if (!inited && model.state != ViewState.Busy) await model.loadBalances();
      },
      builder: (context, model, _) => Scaffold(
        body: ChangeNotifierProvider.value(
          value: model.accManager,
          builder: (context, _) => Consumer<AccountManager>(
            builder: (_, val, __) => SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (model.barValue == 0)
                    await model.loadBalances(refresh: true);
                  else if (model.barValue == 1) {
                    await model.newsModel.loadNews();
                  }
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Row(
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          () {
                            var active = false;
                            var type = 'Premium';
                            if (model.accManager.accountType == AccType.Free) {
                              active = false;
                            } else {
                              active = true;
                              switch (model.accManager.accountType) {
                                case AccType.Pro:
                                  type = 'PRO';
                                  break;
                                case AccType.Premium:
                                  type = 'Premium';
                                  break;
                                case AccType.Free:
                                  // TODO: Handle this case.
                                  break;
                              }
                            }

                            return GestureDetector(
                                onTap: () {
                                  if (model.state != ViewState.Busy) {
                                    if (active) {
                                      Flushbar.success(title: S.of(context).youProNow(type)).show();
                                    } else {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => Pro_PremiumView()));
                                    }
                                  }
                                },
                                child: PremiumGlobalButton(
                                  type,
                                  active,
                                  true,
                                  shimmer: model.state == ViewState.Busy,
                                ));
                          }(),
                          SizedBox(width: 12),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => MarketScreen()));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: AppColors.altGradient),
                              child: AppIcons.market(24, AppColors.active),
                            ),
                          )
                          // NotificationsBell(),
                        ],
                      ),
                    ),
                    BlockchainConnectionState(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AnimatedButtonBar([
                        ButtonBarEntry(
                          child: Text(S.of(context).wallet, style: 0 == model.barValue ? tt.bodyText2 : tt.bodyText1!.copyWith(color: AppColors.inactiveText)),
                          onTap: () {
                            if (model.barValue != 0) {
                              model.barValue = 0;
                              model.setState();
                            }
                          },
                        ),
                        ButtonBarEntry(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(S.of(context).news, style: 1 == model.barValue ? tt.bodyText2 : tt.bodyText1!.copyWith(color: AppColors.inactiveText)),
                              //if (locator<AppSettings>().lastNewsId != locator<UserSettings>().lastNewsRedId)
                              if (locator<AppSettings>().lottery)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.active),
                                  margin: const EdgeInsets.only(bottom: 10, left: 4),
                                ),
                            ],
                          ),
                          onTap: () {
                            if (model.barValue != 1) {
                              model.barValue = 1;
                              model.setState();
                            }
                          },
                        ),
                      ]),
                    ),
                    ...() {
                      if (model.barValue == 0)
                        return [
                          if (model.manualRefresh) Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: LinearProgressIndicator()),
                          Showcase(
                            key: locator<MainScreenModel>().showcaseKeys['account_carousel'],
                            //key: locator<MainScreenModel>().showcaseKeys[0],
                            contentPadding: EdgeInsets.all(8.0),
                            description: 'Swipe to change account',
                            child: AccountCarousel(),
                          ),
                          Padding(padding: const EdgeInsets.all(16), child: TokenTypeSwitch()),
                          Expanded(
                            child: model.state == ViewState.Busy
                                ? ShimmerBalancesListView()
                                : ChangeNotifierProvider.value(
                                    value: model.balListModel,
                                    builder: (_, __) => Consumer<BalListModel>(
                                      builder: (_, balModel, __) => BalancesListView(
                                        model,
                                        key: ValueKey(model.currAccIndex + model.accManager.allAccounts[model.currAccIndex].hashCode),
                                      ),
                                    ),
                                  ),
                          ),
                        ];
                      else
                        return [Expanded(child: NewsListView(model.newsModel))];
                    }()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TokenTypeSwitch extends StatefulWidget {
  TokenTypeSwitch({Key? key}) : super(key: key);

  @override
  _TokenTypeSwitchState createState() => _TokenTypeSwitchState();
}

class _TokenTypeSwitchState extends State<TokenTypeSwitch> {
  late int index;
  @override
  void initState() {
    index = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Showcase(
      key: locator<MainScreenModel>().showcaseKeys['token_filter_switch_bar'],
      contentPadding: EdgeInsets.all(8.0),
      description: 'Filter tokens by type',
      child: Container(
          child: SingleChildScrollView(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => TokenFilterScreen()));
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.generalShapesBg,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(blurRadius: 18, color: AppColors.shadowColor, offset: Offset(0, 13))],
                ),
                child: AppIcons.filter(24, AppColors.inactiveText),
              ),
            ),
            ...() {
              var values = [
                ['All', TokenFilterType.All],
                ['Coins', TokenFilterType.Native],
                ['BEP20', TokenFilterType.BEP20],
                ['ERC20', TokenFilterType.ERC20],
                ['BEP2', TokenFilterType.BEP2],
                ['BEP8', TokenFilterType.BEP8],
              ];
              return [
                for (var i in range(0, values.length))
                  GestureDetector(
                      onTap: () => setState(() {
                            index = i;
                            locator<WalletMainScreenModel>().tokenFilterType = values[i][1] as TokenFilterType;
                          }),
                      child: TokenTypeButton(values[i][0] as String, values[i][1] == locator<WalletMainScreenModel>().tokenFilterType))
              ];
            }()
          ],
        ),
      )),
    );
  }
}

class TokenTypeButton extends StatelessWidget {
  final String value;
  final bool selected;
  const TokenTypeButton(this.value, this.selected, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(boxShadow: selected ? [BoxShadow(blurRadius: 18, color: AppColors.shadowColor, offset: Offset(0, 13))] : null),
      child: AnimatedContainer(
        decoration: BoxDecoration(
          color: AppColors.generalShapesBg.withOpacity(selected ? 1 : 0),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
        duration: Duration(milliseconds: 200),
        child: Text(value, style: selected ? tt.bodyText2 : tt.bodyText1!.copyWith(color: AppColors.inactiveText)),
      ),
    );
  }
}

class AccountCard extends StatelessWidget {
  final bool expanded;
  final int index;

  const AccountCard(this.expanded, this.index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var tt = Theme.of(context).textTheme;
    return Consumer<WalletMainScreenModel>(builder: (_, model, __) {
      var acc = model.accManager.allAccounts[index];

      return AspectRatio(
        aspectRatio: expanded ? 16 / 9 : 30 / 9,
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: AppColors.altGradient,
          ),
          child: expanded
              ? Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  Text('${acc.accountAlias}', style: tt.bodyText1!.copyWith(color: AppColors.inactiveText)),
                  ...() {
                    if (model.state == ViewState.Busy)
                      return [
                        Shimmer.fromColors(
                          child: shimmerBlock(130, 30, 16),
                          baseColor: AppColors.inactiveText,
                          highlightColor: AppColors.active,
                        ),
                        Shimmer.fromColors(
                          child: shimmerBlock(90, 30, 16),
                          baseColor: AppColors.inactiveText,
                          highlightColor: AppColors.active,
                        ),
                      ];
                    else
                      return [
                        Text('$FIAT_CURRENCY_LITERAL${acc.totalBalance.toStringWithFractionDigits(2)}', style: tt.headline5),
                        AccountPNL('${acc.totalPNL.toStringWithFractionDigits(2)}', '${acc.totalPNLPercent.toStringWithFractionDigits(2)}'),
                      ];
                  }()
                ])
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(acc.accountAlias, style: tt.bodyText1!.copyWith(color: AppColors.inactiveText)),
                    Text('$FIAT_CURRENCY_LITERAL${acc.totalBalance.toStringWithFractionDigits(2)}', style: tt.headline6),
                  ],
                ),
        ),
      );
    });
  }
}

class EditAccountsCard extends StatelessWidget {
  bool expanded;
  EditAccountsCard(this.expanded, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: expanded ? 16 / 9 : 30 / 9,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => AccountsSettingsScreen()));
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: AppColors.altGradient,
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: expanded
                  ? [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: SvgPicture(
                          AppIcons.plus(15).pictureProvider,
                          allowDrawingOutsideViewBox: true,
                          fit: BoxFit.contain,
                          colorFilter: ColorFilter.mode(AppColors.inactiveText, BlendMode.srcIn),
                        ),
                      )),
                      Text(S.of(context).addChange, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyText1!.copyWith(color: AppColors.inactiveText)),
                    ]
                  : [
                      Expanded(
                          child: SvgPicture(
                        AppIcons.plus(15).pictureProvider,
                        allowDrawingOutsideViewBox: true,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(AppColors.inactiveText, BlendMode.srcIn),
                      )),
                    ]),
        ),
      ),
    );
  }
}

class AccountCarousel extends StatefulWidget {
  AccountCarousel();
  @override
  State<StatefulWidget> createState() {
    return _AccountCarouselState();
  }
}

class _AccountCarouselState extends State<AccountCarousel> with TickerProviderStateMixin {
  late List<Widget> slides;
  late bool _expanded;
  final CarouselController _controller = CarouselController();

  int index = 1;
  @override
  void initState() {
    _expanded = locator<UserSettings>().accountCarouselExpanded;
    locator<WalletMainScreenModel>().addListener(() {
      index = locator<WalletMainScreenModel>().currAccIndex + 1;
      _controller.animateToPage(index);
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    slides = [];
    locator<AccountManager>().allAccounts.forEachIndexed((e, i) {
      slides.add(AccountCard(_expanded, i));
    });

    slides.insert(0, EditAccountsCard(_expanded));

    return Consumer<WalletMainScreenModel>(
      builder: (_, model, __) => Column(children: [
        Stack(children: [
          AnimatedSize(
            duration: Duration(milliseconds: 300),
            child: CarouselSlider(
              items: slides,
              carouselController: _controller,
              options: CarouselOptions(
                  initialPage: index,
                  aspectRatio: _expanded ? 16 / 9 : 30 / 9,
                  autoPlay: false,
                  enlargeCenterPage: false,
                  enableInfiniteScroll: false,
                  viewportFraction: 0.9,
                  onPageChanged: (index_, reason) {
                    setState(() {
                      index = index_;
                      if (index_ != 0 && model.currAccIndex != index - 1) model.currAccIndex = index_ - 1;
                    });
                  }),
            ),
          ),
          Positioned(
            right: 40,
            top: 40,
            child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    _expanded = !_expanded;
                    locator<UserSettings>()
                      ..accountCarouselExpanded = _expanded
                      ..save();
                  });
                },
                child: Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down)),
          ),
        ]),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: range(0, slides.length).map((entry) {
              return GestureDetector(
                onTap: () => setState(() {
                  index = entry;
                  _controller.animateToPage(entry);
                }),
                child: entry == 0
                    ? Icon(Icons.add, size: 14, color: index == 0 ? AppColors.active : AppColors.inactiveText)
                    : Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: entry == index ? AppColors.mainGradient : null,
                          color: AppColors.inactiveText,
                        ),
                      ),
              );
            }).toList()),
      ]),
    );
  }
}

class ShimmerBalancesListView extends StatelessWidget {
  const ShimmerBalancesListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return TokenCardShimmerPlaceholder();
      },
      separatorBuilder: (context, index) {
        return SizedBox(
          height: 12,
        );
      },
    );
  }
}

class BalancesListView extends StatelessWidget {
  final WalletMainScreenModel walletMainModel;
  const BalancesListView(this.walletMainModel, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var balances = <WalletBalance>[];
    switch (walletMainModel.tokenFilterType) {
      case TokenFilterType.All:
        balances = walletMainModel.accManager.allAccounts[walletMainModel.currAccIndex].allBalances;
        break;
      case TokenFilterType.Native:
        balances = walletMainModel.accManager.allAccounts[walletMainModel.currAccIndex].coinBalances;
        break;
      case TokenFilterType.BEP20:
        balances = walletMainModel.accManager.allAccounts[walletMainModel.currAccIndex].bep20Balances;
        break;
      case TokenFilterType.ERC20:
        balances = walletMainModel.accManager.allAccounts[walletMainModel.currAccIndex].erc20Balances;
        break;
      case TokenFilterType.BEP2:
        balances = walletMainModel.accManager.allAccounts[walletMainModel.currAccIndex].bc_bep2_Balances;
        break;
      case TokenFilterType.BEP8:
        balances = walletMainModel.accManager.allAccounts[walletMainModel.currAccIndex].bc_bep8_Balances;
        break;
    }

    return ListView.separated(
      //controller: walletMainModel.sc,
      padding: const EdgeInsets.all(16),
      //shrinkWrap: true,
      physics: ClampingScrollPhysics(),

      itemCount: balances.length,
      addAutomaticKeepAlives: false,
      itemBuilder: (context, index) {
        return AnimatedOpacityWrapper(index: index, child: TokenCardHeroWrapper('cardAllBalances$index', balances[index]));
      },
      separatorBuilder: (context, index) {
        return SizedBox(
          height: 12,
        );
      },
    );
  }
}

class TokenCardShimmerPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(color: AppColors.inactiveText.withOpacity(0.3), borderRadius: BorderRadius.circular(24)),
        height: 90,
        padding: const EdgeInsets.fromLTRB(12, 12, 20, 12),
        child: Shimmer.fromColors(
          baseColor: AppColors.inactiveText,
          highlightColor: AppColors.active,
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.secondaryBG, borderRadius: BorderRadius.circular(16)),
                child: Icon(
                  Icons.ac_unit,
                  size: 45,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            shimmerBlock(80, 18, 8),
                          ],
                        ),
                        Spacer(),
                        shimmerBlock(50, 18, 8),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            shimmerBlock(120, 18, 8),
                          ],
                        ),
                        Spacer(),
                        shimmerBlock(60, 18, 8),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}

class TokenCardHeroWrapper extends StatelessWidget {
  final String heroTag;
  final WalletBalance balance;
  const TokenCardHeroWrapper(this.heroTag, this.balance, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var card = TokenCard(balance);
    return GestureDetector(
      onTap: () async {
        locator<WalletMainScreenModel>().currentTokenMarketsModel = TokenMarketsModel();
        await showCupertinoModalBottomSheet(
          elevation: 0,
          enableDrag: true,
          expand: false,
          barrierColor: Color(0xA6272323),
          backgroundColor: Colors.transparent,
          context: context,
          builder: (context) => TokenCardActionsBottomSheet(heroTag, card),
        );

        locator<WalletMainScreenModel>().currentTokenMarketsModel = null;
      },
      child: Hero(tag: heroTag, child: card),
    );
  }
}

class BlockchainConnectionState extends StatelessWidget {
  BlockchainConnectionState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<BLOCKCHAIN_CONNECTION_STATE>(
      onModelReady: (model) {},
      builder: (context, model, child) {
        var children = [
          for (var i in model.states.entries)
            if (i.value == false) Text('⚠️ No connection to ${i.key.toString().split('.').last}', textAlign: TextAlign.center),
        ];
        return children.isNotEmpty
            ? Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children))
            : SizedBox();
      },
    );
  }
}
