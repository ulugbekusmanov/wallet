import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tbccwallet/shared.dart';

import 'package:webview_flutter/webview_flutter.dart';
//import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import './RequestHandler.dart';
import 'DAppLaunchScreen.dart';
import 'DAppScreen.dart';
import 'InteractionUI.dart';

String DAPP_INPAGE_PROVIDER_SCRIPT = """
(function(){
    if(typeof EthereumProvider === "undefined"){
    var callbackId = 0;
    var callbacks = {};

    function bridgeSend (data) {
        window.tbccwalletprovider.postMessage(JSON.stringify(data));
    }

    var history = window.history;
    var pushState = history.pushState;
    history.pushState = function(state) {
        setTimeout(function () {
            bridgeSend({
               type: 'history-state-changed',
               navState: { url: location.href, title: document.title }
            });
        }, 100);
        return pushState.apply(history, arguments);
    };

    function sendAPIrequest(permission, params) {
        var messageId = callbackId++;
        var params = params || {};

        bridgeSend({
            type: 'api-request',
            permission: permission,
            messageId: messageId,
            params: params
        });

        return new Promise(function (resolve, reject) {
            params['resolve'] = resolve;
            params['reject'] = reject;
            callbacks[messageId] = params;
        });
    }

    function qrCodeResponse(data, callback){
        var result = data.data;
        var regex = new RegExp(callback.regex);
        if (!result) {
            if (callback.reject) {
                callback.reject(new Error("Cancelled"));
            }
        }
        else if (regex.test(result)) {
            if (callback.resolve) {
                callback.resolve(result);
            }
        } else {
            if (callback.reject) {
                callback.reject(new Error("Doesn't match"));
            }
        }
    }

    function Unauthorized() {
      this.name = "Unauthorized";
      this.id = 4100;
      this.code = 4100;
      this.message = "The requested method and/or account has not been authorized by the user.";
    }
    Unauthorized.prototype = Object.create(Error.prototype);

    function UserRejectedRequest() {
      this.name = "UserRejectedRequest";
      this.id = 4001;
      this.code = 4001;
      this.message = "The user rejected the request.";
    }
    UserRejectedRequest.prototype = Object.create(Error.prototype);

    tbccwalletprovider.onMessage = function (message) {
        //console.log(message);
        data = JSON.parse(message);
        var id = data.messageId;
        var callback = callbacks[id];
        //console.log(callback);
        if (callback) {
            if (data.type === "api-response") {
                if (data.permission == 'qr-code'){
                    qrCodeResponse(data, callback);
                } else if (data.isAllowed) {
                    if (data.permission == 'web3') {
                        window.statusAppcurrentAccountAddress = data.data[0];
                        window.ethereum.emit("accountsChanged", data.data);
                    }
                    callback.resolve(data.data);
                } else {
                    callback.reject(new UserRejectedRequest());
                }
            }
            else if (data.type === "web3-send-async-callback")
            {
                if (callback.beta)
                {
                    if (data.error)
                    {
                        if (data.error.code == 4100)
                            callback.reject(new Unauthorized());
                        else
                            callback.reject(data.error);
                    }
                    else
                    {                   
                        callback.resolve(data.result.result);
                    }
                }
                else if (callback.results)
                {
                    callback.results.push(data.error || data.result);
                    if (callback.results.length == callback.num)
                        callback.callback(undefined, callback.results);
                }
                else
                {
                    callback.callback(data.error, data.result);
                }
            }
        }
    };

    function web3Response (payload, result){
        return {id: payload.id,
                jsonrpc: "2.0",
                result: result};
    }
  
    function getSyncResponse (payload) {
        if (payload.method == "eth_accounts" && (typeof window.statusAppcurrentAccountAddress !== "undefined")) {
            return web3Response(payload, [window.statusAppcurrentAccountAddress])
        } else if (payload.method == "eth_coinbase" && (typeof window.statusAppcurrentAccountAddress !== "undefined")) {
            return web3Response(payload, window.statusAppcurrentAccountAddress)
        } else if (payload.method == "net_version" || payload.method == "eth_chainId"){
            return web3Response(payload, window.statusAppNetworkId)
        } else if (payload.method == "eth_uninstallFilter"){
            return web3Response(payload, true);
        } else {
            return null;
        }
    }

    var StatusAPI = function () {};

    StatusAPI.prototype.getContactCode = function () {
        return sendAPIrequest('contact-code');
    };

    var EthereumProvider = function () {};

    EthereumProvider.prototype.isStatus = true;
    EthereumProvider.prototype.chainId = 1;
    EthereumProvider.prototype.status = new StatusAPI();
    EthereumProvider.prototype.isConnected = function () { return true; };

    EthereumProvider.prototype._events = {};

    EthereumProvider.prototype.on = function(name, listener) {
        if (!this._events[name]) {
          this._events[name] = [];
        }
        this._events[name].push(listener);
    }

    EthereumProvider.prototype.removeListener = function (name, listenerToRemove) {
        if (!this._events[name]) {
          return
        }

        const filterListeners = (listener) => listener !== listenerToRemove;
        this._events[name] = this._events[name].filter(filterListeners);
    }

    EthereumProvider.prototype.emit = function (name, data) {
        if (!this._events[name]) {
          return
        }
        this._events[name].forEach(cb => cb(data));
    }
    EthereumProvider.prototype.enable = function () {
        if (window.statusAppDebug) { console.log("enable"); }
        return sendAPIrequest('web3');
    };

    EthereumProvider.prototype.scanQRCode = function (regex) {
        return sendAPIrequest('qr-code', {regex: regex});
    };

    EthereumProvider.prototype.request = function (requestArguments)
    {
         if (window.statusAppDebug) { console.log("request: " + JSON.stringify(requestArguments)); }
         if (!requestArguments) {
           return new Error('Request is not valid.');
         }
         var method = requestArguments.method;

         if (!method) {
           return new Error('Request is not valid.');  
         }

         //Support for legacy send method
         if (typeof method !== 'string') {
           return this.sendSync(method);
         }

         if (method == 'eth_requestAccounts'){
             return sendAPIrequest('web3');
         }

         var syncResponse = getSyncResponse({method: method});
         if (syncResponse){
             return new Promise(function (resolve, reject) {
                                        resolve(syncResponse.result);
                                    });
         }

         var messageId = callbackId++;
         var payload = {id:      messageId,
                        jsonrpc: "2.0",
                        method:  method,
                        params:  requestArguments.params};

         bridgeSend({type:      'web3-send-async-read-only',
                     messageId: messageId,
                     payload:   payload});

         return new Promise(function (resolve, reject) {
                                callbacks[messageId] = {beta:    true,
                                                        resolve: resolve,
                                                        reject:  reject};
                            });
    };

    // (DEPRECATED) Support for legacy send method
    EthereumProvider.prototype.send = function (method, params = [])
    {
        if (window.statusAppDebug) { console.log("send (legacy): " + method);}
        return this.request({method: method, params: params});
    }

    // (DEPRECATED) Support for legacy sendSync method
    EthereumProvider.prototype.sendSync = function (payload)
    {
        if (window.statusAppDebug) { console.log("sendSync (legacy)" + JSON.stringify(payload));}
        if (payload.method == "eth_uninstallFilter"){
            this.sendAsync(payload, function (res, err) {})
        }
        var syncResponse = getSyncResponse(payload);
        if (syncResponse){
            return syncResponse;
        } else {
            return web3Response(payload, null);
        }
    };

    // (DEPRECATED) Support for legacy sendAsync method
    EthereumProvider.prototype.sendAsync = function (payload, callback)
    {
      if (window.statusAppDebug) { console.log("sendAsync (legacy)" + JSON.stringify(payload));}
      if (!payload) {
          return new Error('Request is not valid.');
      }
      if (payload.method == 'eth_requestAccounts'){
          return sendAPIrequest('web3');
      }
      var syncResponse = getSyncResponse(payload);
      if (syncResponse && callback) {
          callback(null, syncResponse);
      }
      else
      {
          var messageId = callbackId++;

          if (Array.isArray(payload))
          {
              callbacks[messageId] = {num:      payload.length,
                                      results:  [],
                                      callback: callback};
              for (var i in payload) {
                  bridgeSend({type:      'web3-send-async-read-only',
                              messageId: messageId,
                              payload:   payload[i]});
              }
          }
          else
          {
              callbacks[messageId] = {callback: callback};
              bridgeSend({type:      'web3-send-async-read-only',
                          messageId: messageId,
                          payload:   payload});
          }
      }
    };
    }
    
    window.ethereum = new EthereumProvider();
    window.statusAppDebug = false;
    return true;
})();""";

class DAppBrowserScreenModel extends BaseViewModel {
  bool firstPageLoad = true;
  late StreamController<bool> webviewinitCompleteStreamController;
  late Stream<bool> webviewinitCompleteStream;
  late BuildContext context;
  DAppBrowserScreenModel() {
    webviewinitCompleteStreamController = StreamController();
    webviewinitCompleteStream = webviewinitCompleteStreamController.stream.asBroadcastStream();
    webviewinitCompleteStream.listen((event) {
      initCompleted = event;
    });
  }
  late bool initCompleted = false;
  late DAppScreenModel dappScreenModel;
  late WebViewController controller;
  late JavascriptChannel ethprovchannel;
  late Web3RequestHandler web3requestHandler;
  String? _pageTitle;
  String? currUrl;
  late int? chainId = 1;

  String? get pageTitle => _pageTitle;
  set pageTitle(String? title) {
    _pageTitle = title;
    setState();
  }

  loadEmpty() {
    try {
      var str = "<!DOCTYPE html><html><head></head><body></body></html>";
      var contentBase64 = base64Encode(const Utf8Encoder().convert(str));
      controller.loadUrl('data:text/html;base64,$contentBase64');
    } catch (e) {
      print('cant load empty');
    }
  }

  GlobalKey? screenKey;

  Future<void> launchDApp(DApp dapp) async {
    if (initCompleted != true) {
      var event = await webviewinitCompleteStream.first;
    }
    firstPageLoad = true;
    chainId = network_chainId[dapp.network];
    controller.loadUrl(dapp.url.toString());
  }

  Future<void> injectProvider() async {
    await controller.evaluateJavascript(DAPP_INPAGE_PROVIDER_SCRIPT);
  }

  Future<void> setChainID([int? id]) async {
    if (id != null) {
      this.chainId = chainId;
    }
    await controller.evaluateJavascript("window.ethereum.chainId=${this.chainId};window.statusAppNetworkId=${this.chainId};");
  }

  Future<void> init() async {
    setState(ViewState.Busy);

    web3requestHandler = Web3RequestHandler(this);
    await web3requestHandler.init();

    web3requestHandler.screenKey = screenKey;

    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    ethprovchannel = JavascriptChannel(
        name: 'tbccwalletprovider',
        onMessageReceived: (JavascriptMessage msg) async {
          assert(() {
            print('message received: ${msg.message}');
            return true;
          }());
          var decodedMsg = json.decode(msg.message);
          handleMsg(decodedMsg);
        });
    setState(ViewState.Idle);
  }

  void handleMsg(Map<String, dynamic> msg) async {
    var response = await web3requestHandler.handleRequest(msg);
    if (response != null) {
      var js = "tbccwalletprovider.onMessage('${json.encode(response)}')";
      while (true) {
        try {
          var result = await controller.evaluateJavascript(js);
          assert(() {
            print('handleMsgResult: $result');
            return true;
          }());

          break;
        } catch (e) {
          print('channel err:$e');
          await Future.delayed(Duration(seconds: 1));
        }
      }
    } else {
      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!resp is NULL');
    }
  }

  @override
  void dispose() {
    webviewinitCompleteStreamController.sink.close();
    super.dispose();
  }
}

class DAppBrowserScreen extends StatefulWidget {
  DAppBrowserScreenModel model;
  GlobalKey? key;
  DAppBrowserScreen(this.model, {this.key}) : super(key: key);

  @override
  _DAppBrowserScreenState createState() => _DAppBrowserScreenState();
}

class _DAppBrowserScreenState extends State<DAppBrowserScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Widget loader() => Scaffold(body: TBCCLoader());
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BaseView<DAppBrowserScreenModel>(
        model: widget.model,
        onModelReady: (model) {
          model.screenKey = widget.key;
          model.init();
        },
        builder: (context, model, _) {
          model.context = context;
          return Scaffold(
              appBar: CAppBar(
                elevation: 0,
                title: Row(children: [
                  AppIcons.token_ic(chainID_symbol[model.chainId]!.toLowerCase(), 24),
                  SizedBox(width: 10),
                  Expanded(child: Text('${model.pageTitle}')),
                ]),
                actions: [
                  IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      showModalBottomSheet(context: context, builder: (c) => optionsBottomSheet(context, model));
                    },
                  ),
                  IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        model.dappScreenModel.indexToShow = 0;
                        model.loadEmpty();
                      })
                ],
              ),
              body: model.state == ViewState.Busy
                  ? loader()
                  : WebView(
                      initialUrl: model.currUrl,
                      debuggingEnabled: true,
                      javascriptMode: JavascriptMode.unrestricted,
                      javascriptChannels: {model.ethprovchannel},
                      onWebViewCreated: (WebViewController webViewController) async {
                        model.controller = webViewController;
                        model.webviewinitCompleteStreamController.add(true);
                      },
                      onPageStarted: (String url) async {},
                      onPageFinished: (String url) async {
                        if (model.firstPageLoad) {
                          model.firstPageLoad = false;
                          model.dappScreenModel.launchScreenModel.setState();
                          model.dappScreenModel.indexToShow = 1;
                        }
                        model.pageTitle = await model.controller.getTitle();
                        await model.injectProvider();
                        await model.setChainID();
                        var providerCheck = await model.controller.evaluateJavascript('window.ethereum');
                        if (providerCheck == 'null') {
                          await model.injectProvider();
                          await model.setChainID();
                        }
                      },
                      navigationDelegate: (navigation) async {
                        if (navigation.url.startsWith('wc:')) {
                          return NavigationDecision.prevent;
                        } else {
                          return NavigationDecision.navigate;
                        }
                      },
                      gestureNavigationEnabled: true,
                    ));
        });
  }

  optionsBottomSheet(BuildContext context, DAppBrowserScreenModel model) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          option(S.of(context).reload, () {
            Navigator.pop(context);
            model.controller.reload();
          }),
          option(S.of(context).goBack, () {
            Navigator.pop(context);

            model.controller.goBack();
          }),
          option(S.of(context).goForward, () {
            Navigator.pop(context);
            model.controller.goForward();
          }),
          option(S.of(context).clearCache, () {
            Navigator.pop(context);
            model.controller.clearCache();
          }),
        ],
      ),
    );
  }

  option(String text, void Function()? onTap) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Text('$text'),
        ),
      );
  // Future<void> wchandler(String str) async {
  //   locator<WalletConnectService>().connect(str);
  // }
}
