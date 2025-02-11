import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:walletconnect_flutter_v2_wallet/dependencies/deep_link_handler.dart';
import 'package:walletconnect_flutter_v2_wallet/dependencies/i_web3wallet_service.dart';
import 'package:walletconnect_flutter_v2_wallet/utils/constants.dart';
import 'package:walletconnect_flutter_v2_wallet/utils/namespace_model_builder.dart';
import 'package:walletconnect_flutter_v2_wallet/utils/string_constants.dart';
import 'package:walletconnect_flutter_v2_wallet/widgets/custom_button.dart';

class AppDetailPage extends StatefulWidget {
  final PairingInfo pairing;

  const AppDetailPage({
    super.key,
    required this.pairing,
  });

  @override
  AppDetailPageState createState() => AppDetailPageState();
}

class AppDetailPageState extends State<AppDetailPage> {
  @override
  Widget build(BuildContext context) {
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(widget.pairing.expiry * 1000);
    int year = dateTime.year;
    int month = dateTime.month;
    int day = dateTime.day;

    String expiryDate =
        '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

    List<SessionData> sessions = GetIt.I
        .get<IWeb3WalletService>()
        .getWeb3Wallet()
        .sessions
        .getAll()
        .where((element) => element.pairingTopic == widget.pairing.topic)
        .toList();

    List<Widget> sessionWidgets = [];
    for (final SessionData session in sessions) {
      final namespaceWidget = ConnectionWidgetBuilder.buildFromNamespaces(
        session.topic,
        session.namespaces,
      );
      // Loop through and add the namespace widgets, but put 20 pixels between each one
      for (int i = 0; i < namespaceWidget.length; i++) {
        sessionWidgets.add(namespaceWidget[i]);
        if (i != namespaceWidget.length - 1) {
          sessionWidgets.add(const SizedBox(height: 20.0));
        }
      }
    }
    final scheme = widget.pairing.peerMetadata?.redirect?.native ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pairing.peerMetadata?.name ?? 'Unknown'),
        actions: [
          Visibility(
            visible: scheme.isNotEmpty,
            child: IconButton(
              icon: const Icon(
                Icons.open_in_new_rounded,
              ),
              onPressed: () {
                DeepLinkHandler.goTo(scheme);
              },
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: StyleConstants.linear8,
          top: StyleConstants.linear8,
          right: StyleConstants.linear8,
          bottom: StyleConstants.linear32,
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40.0,
                  backgroundImage: (widget
                              .pairing.peerMetadata!.icons.isNotEmpty
                          ? NetworkImage(widget.pairing.peerMetadata!.icons[0])
                          : const AssetImage('assets/images/default_icon.png'))
                      as ImageProvider<Object>,
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.pairing.peerMetadata!.url),
                      Text('Expires on: $expiryDate'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: sessionWidgets,
            ),
            const SizedBox(height: 20.0),
            Row(
              children: [
                CustomButton(
                  type: CustomButtonType.invalid,
                  onTap: () async {
                    try {
                      await GetIt.I<IWeb3WalletService>()
                          .getWeb3Wallet()
                          .core
                          .pairing
                          .disconnect(topic: widget.pairing.topic);
                      _back();
                    } catch (e) {
                      //debugPrint(e.toString());
                    }
                  },
                  child: const Center(
                    child: Text(
                      StringConstants.delete,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _back() {
    Navigator.of(context).pop();
  }
}
