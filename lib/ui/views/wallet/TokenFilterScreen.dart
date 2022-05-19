import 'package:flutter/cupertino.dart';
import 'package:tbccwallet/core/token/TokenContainer.dart';

import 'package:tbccwallet/core/token/utils.dart';
import 'package:tbccwallet/locator.dart';
import 'package:tbccwallet/shared.dart';

import 'WalletMainScreen.dart';
import 'WalletMainScreenModel.dart';

class TokenFilterScreen extends StatefulWidget {
  const TokenFilterScreen({Key? key}) : super(key: key);

  @override
  _TokenFilterScreenState createState() => _TokenFilterScreenState();
}

class _TokenFilterScreenState extends State<TokenFilterScreen> {
  final controllerSearch = TextEditingController();
  late int index;
  bool needToReload = false;
  var values;
  @override
  void initState() {
    index = 0;
    values = [
      //['All', TokenFilterType.All],
      ['Coins', TokenFilterType.Native],
      ['BEP20', TokenFilterType.BEP20],
      ['ERC20', TokenFilterType.ERC20],
      ['BEP2', TokenFilterType.BEP2],
      ['BEP8', TokenFilterType.BEP8],
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (needToReload) {
          locator<WalletMainScreenModel>().loadBalances();
          saveTokenLists(locator<WALLET_TOKENS_CONTAINER>());
        }
        return true;
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: TextFormField(
              controller: controllerSearch,
              onChanged: (_) {
                setState(() {});
              },
              decoration: generalTextFieldDecor(
                context,
                hintText: "Search...",
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AppIcons.search(20, AppColors.inactiveText),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Сортировка',
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: AppColors.inactiveText,
                          ),
                    ),
                    Text(
                      'По алфавиту (A – Z)',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Скрыть пустые',
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: AppColors.inactiveText,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
          Divider(),
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SingleChildScrollView(
                clipBehavior: Clip.none,
                scrollDirection: Axis.horizontal,
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: () {
                      return [
                        for (var i in range(0, values.length))
                          GestureDetector(
                            onTap: () => setState(() => index = i),
                            child: TokenTypeButton(
                                values[i][0] as String, index == i),
                          )
                      ];
                    }()),
              )),
          Expanded(
              child: FilterTokensListView(values[index][1], controllerSearch,
                  (cb) {
            setState(() {
              needToReload = true;
              cb.call();
            });
          }))
        ],
      ),
    );
  }
}

class TokenCardFilter extends StatelessWidget {
  final WalletToken token;
  final bool active;
  final void Function(bool) onSwitchChanged;
  const TokenCardFilter(this.token, this.active, this.onSwitchChanged,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.fromLTRB(12, 12, 20, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColors.generalShapesBg,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03))],
      ),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 56,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.primaryBg
                    : AppColors.secondaryBG,
                borderRadius: BorderRadius.circular(16)),
            child: token.icon(45),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(token.symbol.split('-').first),
                Text(token.standard,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(color: AppColors.inactiveText)),
              ],
            ),
          ),
          CupertinoSwitch(
            value: active,
            activeColor: token.standard != 'Native'
                ? AppColors.active
                : AppColors.inactiveText,
            onChanged: token.standard != 'Native' ? onSwitchChanged : null,
          ),
        ],
      ),
    );
  }
}

class FilterTokensListView extends StatelessWidget {
  final tokensContainer = locator<WALLET_TOKENS_CONTAINER>();
  final TextEditingController controllerSearch;
  TokenFilterType tokenFilterType;
  void Function(void Function()) functionSetState;
  FilterTokensListView(
      this.tokenFilterType, this.controllerSearch, this.functionSetState,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var tokens = <WalletToken>[];
    switch (tokenFilterType) {
      case TokenFilterType.Native:
        tokens = tokensContainer.COINS;
        break;
      case TokenFilterType.BEP20:
        tokens = tokensContainer.BEP20;
        break;
      case TokenFilterType.ERC20:
        tokens = tokensContainer.ERC20;
        break;
      case TokenFilterType.BEP2:
        tokens = tokensContainer.BEP2;
        break;
      case TokenFilterType.BEP8:
        tokens = tokensContainer.BEP8;
        break;
      case TokenFilterType.All:
        // TODO: Handle this case.
        break;
    }
    if (controllerSearch.text.isNotEmpty) {
      var text = controllerSearch.text.toLowerCase();
      tokens = tokens
          .where((t) =>
              t.symbol.toLowerCase().contains(text) ||
              t.name.toLowerCase().contains(text))
          .toList();
    }
    return ListView.separated(
      //controller: walletMainModel.sc,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      //shrinkWrap: true,
      physics: ClampingScrollPhysics(),

      itemCount: tokens.length,
      addAutomaticKeepAlives: false,
      itemBuilder: (context, index) {
        var token = tokens[index];
        return AnimatedOpacityWrapper(
          index: index,
          child: TokenCardFilter(
              token,
              tokensContainer
                      .listByTypeShow(tokenFilterType)
                      ?.contains(token) ==
                  true, (val) {
            if (val) {
              locator<WALLET_TOKENS_CONTAINER>()
                  .listByTypeShow(tokenFilterType)
                  ?.add(token);
              functionSetState.call(() {});
            } else {
              locator<WALLET_TOKENS_CONTAINER>()
                  .listByTypeShow(tokenFilterType)
                  ?.remove(token);
              functionSetState.call(() {});
            }
          }),
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(
          height: 12,
        );
      },
    );
  }
}

class BaseDropMenu extends StatelessWidget {
  const BaseDropMenu({
    Key? key,
    required this.onChanged,
    required this.items,
    required this.value,
  }) : super(key: key);
  final void Function(dynamic) onChanged;
  final List<DropdownMenuItem<dynamic>> items;
  final dynamic value;

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      isExpanded: true,
      style: Theme.of(context).textTheme.bodyText2,
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      underline: SizedBox(),
      icon: Icon(
        Icons.arrow_drop_down,
        color: Colors.black54,
      ), //Icon(Icons.arrow_drop_down),
      items: items,
      value: value,
      onChanged: onChanged,
    );
  }
}
