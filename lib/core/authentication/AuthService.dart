import 'package:local_auth/local_auth.dart';
import 'package:tbccwallet/core/authentication/AccountManager.dart';
import 'package:tbccwallet/core/settings/UserSettings.dart';
import 'package:tbccwallet/global_env.dart';
import 'package:tbccwallet/locator.dart';
import 'package:tbccwallet/ui/views/start/StartScreen.dart';
import 'package:tbccwallet/ui/views/wallet/WalletMainScreen.dart';
import 'package:tbccwallet/ui/views/wallet/WalletMainScreenModel.dart';
import 'dart:typed_data';
import 'package:solana/solana.dart' as sol;

import 'package:pointycastle/digests/sha256.dart';
import '../storage/SecureStorage.dart';
import 'UserAccount.dart';
import 'wallets/BSCWallet.dart';
import 'wallets/BinanceChainWallet.dart';
import 'wallets/EthereumWallet.dart';
import 'package:tbccwallet/shared.dart';

class AuthService {
  final localAuth = LocalAuthentication();
  final accManager = locator<AccountManager>();
  final _storage = locator<Storage>();
  final _settings = locator<UserSettings>();

  Future<void> createNewAccount(String mnemonic, Uint8List seed,
      {bool setCurrent = true,
      String? alias,
      bool? cardAttached,
      String? privHalf}) async {
    UserAccount newAccount = UserAccount();
    newAccount.bcWallet = BCWallet.fromSeed(seed, ENVS.BC_ENV!.env!);
    newAccount.ethWallet = EthWallet.fromSeed(seed);
    newAccount.bscWallet = BSCWallet(
        address: newAccount.ethWallet.address,
        privateKey: newAccount.ethWallet.privateKey);
    newAccount.solWallet = sol.Wallet(
        rpcClient: ENVS.SOL_ENV!,
        signer: await sol.Ed25519HDKeyPair.fromSeedWithHdPath(
            seed: seed.toList(), hdPath: "m/44'/501'/0'"));

    newAccount.mnemonic = mnemonic;
    if (alias == null) {
      if (accManager.allAccounts.isEmpty) {
        newAccount.accountAlias = 'Wallet 1';
      } else {
        var i = accManager.allAccounts.length;
        while (true) {
          var alias = 'Wallet ${i + 1}';
          if (accManager.allAccounts
              .any((element) => element.accountAlias == alias)) {
            i += 1;
          } else {
            newAccount.accountAlias = alias;
            break;
          }
        }
      }
    } else {
      newAccount.accountAlias = alias;
    }
    newAccount.cardAttached = cardAttached == true;
    newAccount.privHalf = privHalf ?? '';

    accManager.allAccounts.add(newAccount);
    accManager.saveAccounts();
    if (setCurrent)
      locator<WalletMainScreenModel>().currAccIndex =
          accManager.allAccounts.length - 1;
  }

  Future<bool> biometricAuth(String reason) async {
    try {
      return await localAuth.authenticate(
        localizedReason: reason,
        stickyAuth: true,
      );
    } catch (e, st) {
      print('$e: $st');
      return false;
    }
  }

  Future<void> setPassword(String password) async {
    var passwordHash = bytesToHex(
        SHA256Digest().process(Uint8List.fromList(password.codeUnits)));
    await _storage.writeNewPassword(passwordHash);
    _settings.loggedIn = true;
    await _settings.save();
  }

  Future<bool> checkPassword(String password) async {
    var passwordHash = bytesToHex(
        SHA256Digest().process(Uint8List.fromList(password.codeUnits)));
    return passwordHash == await _storage.readPassword();
  }

  Future<void> logoutAll(BuildContext context) async {
    accManager.deleteAllAccounts();

    _settings
      ..loggedIn = false
      ..save();

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => StartScreen()), (route) => false);
  }
}
