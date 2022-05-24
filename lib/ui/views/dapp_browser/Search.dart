import 'package:voola/shared.dart';

import 'DAppLaunchScreen.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({Key? key, required this.list, required this.modelDapp})
      : super(key: key);
  final List<DApp> list;
  final DAppLaunchScreenModel modelDapp;

  @override
  Widget build(BuildContext context) {
    return BaseView<SearchModel>(
      onModelReady: (model) {
        model.list = list;
        model.model = modelDapp;
      },
      builder: (context, model, child) {
        return CScaffold(
          appBar: CAppBar(title: Text('Search screen')),
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Text('In develop...'),
                )
                // ListView.builder(
                //   padding: EdgeInsets.symmetric(horizontal: 20),
                //   itemCount: list.length,
                //   itemBuilder: (context, i) {
                //     return DAppCardFull(
                //       list[i],
                //       () async {
                //         var result = await showModalBottomSheet(
                //           context: context,
                //           backgroundColor: Colors.transparent.withOpacity(0),
                //           builder: (c) {
                //             return optionsBottomSheet(context);
                //           },
                //         );
                //         if (result == true) {
                //           model.model.currDapp = list[i];
                //           model.model.dappScreenModel.indexToShow = 2;
                //           model.model.dappScreenModel.browserScreenModel
                //               .launchDApp(list[i]);
                //         }
                //       },
                //       model.model,
                //     );
                //   },
                // )
              ],
            ),
          ),
        );
      },
    );
  }
}

class SearchModel extends BaseViewModel {
  late TextEditingController search = TextEditingController();
  late DAppLaunchScreenModel model;

  late List<DApp> list = [];

  void getSearchList() {}
}
