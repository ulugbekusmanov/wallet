import 'package:tbccwallet/global_env.dart';
import 'package:tbccwallet/shared.dart';

class MoreInformation extends StatelessWidget {
  int mode;
  String? contactId;
  MoreInformation({this.mode = 1, this.contactId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<MoreInformationModel>(
      onModelReady: (model) {},
      builder: (context, model, child) {
        return CScaffold(
          appBar: CAppBar(
            elevation: 0,
            title: Text('More information'),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'In develop...',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MoreInformationModel extends BaseViewModel {
  TokenNetworkInfoWrapper? network;
}
