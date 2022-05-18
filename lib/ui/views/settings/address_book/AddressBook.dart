import 'dart:math';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tbccwallet/core/authentication/AccountManager.dart';
import 'package:tbccwallet/core/authentication/UserAccount.dart';
import 'package:tbccwallet/core/token/utils.dart';
import 'package:tbccwallet/global_env.dart';
import 'package:tbccwallet/locator.dart';
import 'package:tbccwallet/shared.dart';
import 'package:tbccwallet/ui/views/settings/address_book/AddressBookModel.dart';

import 'AddContact.dart';

class AddressBookMain extends StatelessWidget {
  const AddressBookMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<AddressBookModel>(
      onModelReady: (model) {},
      builder: (context, model, child) {
        return CScaffold(
          appBar: CAppBar(
            elevation: 0,
            title: Text(S.of(context).addressBook),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddContactScreen()));
                },
                icon: Icon(
                  Icons.add,
                  color: AppColors.active,
                  size: 28,
                ),
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                AddressBookContactTile(
                  AppIcons.wallet(22, AppColors.active),
                  'My wallets',
                  () => Navigator.of(context).push(PageTransition(type: PageTransitionType.rightToLeftWithFade, child: MyWalletsAddressBookScreen())),
                ),
                Divider(),
                if (model.contacts.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('No addresses saved'),
                          IconButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddContactScreen()));
                              },
                              icon: Icon(
                                Icons.add,
                                size: 32,
                                color: AppColors.active,
                              ))
                        ],
                      ),
                    ),
                  ),
                for (var contact in model.contacts) ...[
                  Dismissible(
                    key: Key(contact.id),
                    confirmDismiss: (_) async {
                      return (await locator<DialogService>().showConfirmationDialog(
                        title: 'Confirm',
                        description: 'Are you shure want to delete contact \"${contact.name}\"',
                      ))
                          ?.confirmed;
                    },
                    onDismissed: (_) {
                      model.contacts.removeWhere((element) => element.id == contact.id);
                      model.saveAddressBook();
                      model.setState();
                    },
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [SizedBox(width: 12), Icon(Icons.delete_forever_outlined), Spacer(), Icon(Icons.delete_forever_outlined), SizedBox(width: 12)],
                      ),
                    ),
                    child: AddressBookContactTile(
                      Icon(Icons.person_outline),
                      contact.name,
                      () => Navigator.of(context).push(PageTransition(type: PageTransitionType.rightToLeftWithFade, child: AddressListScreen(contact, contact.name, model: model))),
                    ),
                  ),
                  SizedBox(height: 16)
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}

class AddressBookContactTile extends StatelessWidget {
  String title;
  Widget icon;
  void Function() onTap;
  bool? expanded;
  AddressBookContactTile(this.icon, this.title, this.onTap, {this.expanded, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.generalShapesBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            icon,
            SizedBox(width: 18),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.bodyText1),
            ),
            Transform.rotate(angle: expanded == null ? pi * 2 : pi * (expanded == true ? 1.5 : 0.5), child: AppIcons.chevron(22, AppColors.text)),
          ],
        ),
      ),
    );
  }
}

class AddressBookAddressTile extends StatelessWidget {
  final String title;
  final String address;
  final Widget icon;
  final void Function() onTap;
  const AddressBookAddressTile(this.title, this.address, this.icon, this.onTap, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.generalShapesBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              icon,
              SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.bodyText1),
                    Text(
                      address,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

class MyWalletsAddressBookScreen extends StatelessWidget {
  const MyWalletsAddressBookScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var accManager = locator<AccountManager>();
    return CScaffold(
      appBar: CAppBar(
        title: Text('My wallets'),
      ),
      body: ListView.separated(
          separatorBuilder: (_, __) => SizedBox(height: 16),
          padding: const EdgeInsets.all(16),
          itemCount: accManager.allAccounts.length,
          itemBuilder: (c, index) {
            var acc = accManager.allAccounts[index];

            return AddressBookContactTile(
              AppIcons.wallet(22, AppColors.active),
              acc.accountAlias,
              () => Navigator.of(context).push(PageTransition(type: PageTransitionType.rightToLeftWithFade, child: AddressListScreen(acc, acc.accountAlias))),
            );
          }),
    );
  }
}

class AddressListScreen extends StatelessWidget {
  var source;
  String title;
  AddressBookModel? model;
  AddressListScreen(this.source, this.title, {this.model, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CScaffold(
      appBar: CAppBar(
        title: Text(title),
        actions: [
          if (!(source is UserAccount))
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => AddContactScreen(
                          mode: 2,
                          contactId: source.id,
                        )));
              },
              icon: Icon(
                Icons.add,
                color: AppColors.active,
                size: 28,
              ),
            )
        ],
      ),
      body: ChangeNotifierProvider.value(
        value: locator<AddressBookModel>(),
        builder: (_, __) => Consumer<AddressBookModel>(
          builder: (_, __, ___) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: () {
              var widgets = <Widget>[];
              if (source is UserAccount) {
                var source_ = source as UserAccount;
                var items = <dynamic>[
                  [TokenNetwork.BinanceChain, source_.bcWallet.address],
                  [TokenNetwork.BinanceSmartChain, source_.bscWallet.address.hexEip55],
                  [TokenNetwork.Ethereum, source_.ethWallet.address.hexEip55],
                  [TokenNetwork.Solana, source_.solWallet.address],
                ];
                widgets = [
                  for (var item in items)
                    AddressBookAddressTile(
                      '${item[0]}'.split('.').last,
                      '${item[1]}',
                      NETWORKS_INFO[item[0]]?.icon(24) ?? Text('?'),
                      () async {
                        await Clipboard.setData(ClipboardData(text: item[1]));
                        Flushbar.success(title: S.of(context).copiedToClipboard(S.of(context).address)).show();
                      },
                    )
                ];
              } else {
                var source_ = source as AddressBookContactEntity;
                widgets = [
                  for (var item in source_.addresses.indexed()) ...[
                    Dismissible(
                      key: Key('${item[1].address.hashCode ^ item[0].hashCode}'), ////wrong
                      confirmDismiss: (_) async {
                        return (await locator<DialogService>().showConfirmationDialog(
                          title: 'Confirm',
                          description: 'Are you shure want to delete contact \"${item[1].address}\"',
                        ))
                            ?.confirmed;
                      },
                      onDismissed: (_) {
                        if (model != null) {
                          var contactIndex = model?.contacts.indexWhere((element) => element.id == source_.id);
                          model?.contacts[contactIndex!].addresses.removeWhere((element) => element.address == item[1].address && element.network == item[1].network);
                          model?.saveAddressBook();
                          model?.setState();
                        }
                      },
                      background: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [SizedBox(width: 12), Icon(Icons.delete_forever_outlined), Spacer(), Icon(Icons.delete_forever_outlined), SizedBox(width: 12)],
                        ),
                      ),
                      child: AddressBookAddressTile(
                        item[1].description,
                        item[1].address,
                        NETWORKS_INFO[item[1].network]?.icon(32) ?? Text('?'),
                        () async {
                          await Clipboard.setData(ClipboardData(text: item[1].address));
                          Flushbar.success(title: S.of(context).copiedToClipboard(S.of(context).address)).show();
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                  ]
                ];
              }
              return ListView.builder(
                  itemCount: widgets.length,
                  itemBuilder: (c, index) {
                    return widgets[index];
                  });
            }(),
          ),
        ),
      ),
    );
  }
}
