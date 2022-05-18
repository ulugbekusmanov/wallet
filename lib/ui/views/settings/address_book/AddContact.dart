import 'package:binance_chain/binance_chain.dart';
import 'package:tbccwallet/core/token/utils.dart';
import 'package:tbccwallet/global_env.dart';
import 'package:tbccwallet/locator.dart';
import 'package:tbccwallet/shared.dart';
import 'package:tbccwallet/ui/QrCodeReader.dart';
import 'package:tbccwallet/ui/views/settings/address_book/AddressBookModel.dart';
import 'package:tbccwallet/ui/widgets/NetworkSelector.dart';
import 'package:solana/solana.dart' as sol;
import 'AddressBook.dart';

class AddContactScreen extends StatelessWidget {
  int mode;
  String? contactId;
  AddContactScreen({this.mode = 1, this.contactId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<AddContactModel>(
      onModelReady: (model) {
        model.mode = mode;
        model.contactId = contactId;
      },
      builder: (context, model, child) {
        return CScaffold(
          appBar: CAppBar(
            elevation: 0,
            title: Text(mode == 1 ? 'Add contact' : 'Add address'),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: model.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (mode == 1) ...[
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text('Name'),
                    ),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: model.controllerName,
                      validator: (val) {
                        if (val!.length < 1) {
                          return 'Too short';
                        }
                      },
                      decoration: generalTextFieldDecor(context),
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text('Note (not required)'),
                  ),
                  TextFormField(
                    controller: model.controllerNote,
                    decoration: generalTextFieldDecor(context),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(S.of(context).address),
                  ),
                  Stack(children: [
                    TextFormField(
                      controller: model.controllerAddress,
                      validator: (val) => model.isAddrValid(val ?? '', context) ? null : S.of(context).wrongAddr,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: generalTextFieldDecor(context, paddingRight: 44),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: textFieldActionsButton(child: gradientIcon(AppIcons.qr_code_scan(22)), onTap: () => model.scanAddressQr(context)),
                    ),
                  ]),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text('Network'),
                  ),
                  AddressBookContactTile(model.network!.icon(28), model.network!.name, () async {
                    var network = await Navigator.of(context).push(PageTransition(type: PageTransitionType.rightToLeftWithFade, child: NetworkSelectorScreen()));
                    if (network != null) {
                      model
                        ..network = network
                        ..setState();
                    }
                  }),
                  SizedBox(height: 32),
                  Button(
                    value: 'Add contact',
                    onTap: () {
                      if (model.formKey.currentState?.validate() == true) {
                        model.addContact();
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class AddContactModel extends BaseViewModel {
  final controllerName = TextEditingController();
  final controllerNote = TextEditingController();
  final controllerAddress = TextEditingController();
  final formKey = GlobalKey<FormState>();
  TokenNetworkInfoWrapper? network;

  /// 1 = new contact
  /// 2 = add address to contact
  int mode = 1;

  /// need when mode = 2
  String? contactId;

  String? name;
  String? note;
  String? address;
  AddContactModel() {
    network = NETWORKS_INFO.entries.first.value;
  }

  Future<void> scanAddressQr(context) async {
    var qr = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => QRCodeReader()));
    if (isAddrValid(qr, context)) {
      address = qr;
      controllerAddress.text = address!;
    } else {
      Flushbar.error(title: S.of(context).noValidAddrFound).show();
    }
  }

  bool isAddrValid(String val, context) {
    switch (network!.network) {
      case TokenNetwork.BinanceChain:
        return validateAddress(val);
      case TokenNetwork.Ethereum:
        try {
          EthereumAddress.fromHex(val).hex;
        } catch (e) {
          return false;
        }
        break;
      case TokenNetwork.BinanceSmartChain:
        try {
          EthereumAddress.fromHex(val).hex;
        } catch (e) {
          return false;
        }
        break;
      case TokenNetwork.Solana:
        return sol.isValidAddress(val);
    }
    return true;
  }

  void addContact() {
    var abm = locator<AddressBookModel>();
    if (mode == 1) {
      var contact = AddressBookContactEntity()
        ..addresses = [
          AddressBookAddressEntity()
            ..address = controllerAddress.text
            ..description = controllerNote.text
            ..network = network!.network
        ]
        ..name = controllerName.text
        ..id = '${DateTime.now().toString().hashCode}';
      abm.contacts.add(contact);
    } else {
      var contact = abm.contacts.firstWhere((element) => element.id == contactId);
      contact.addresses.add(AddressBookAddressEntity()
        ..address = controllerAddress.text
        ..description = controllerNote.text
        ..network = network!.network);
    }
    abm.saveAddressBook();
    abm.setState();
  }
}
