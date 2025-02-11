import 'package:flutter/material.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class PairingItem extends StatelessWidget {
  const PairingItem({
    super.key,
    required this.pairing,
    required this.onTap,
  });

  final PairingInfo pairing;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    PairingMetadata? metadata = pairing.peerMetadata;
    if (metadata == null) {
      return const ListTile(
        title: Text('Unknown'),
        subtitle: Text('No metadata available'),
      );
    }

    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(pairing.expiry * 1000);
    int year = dateTime.year;
    int month = dateTime.month;
    int day = dateTime.day;

    String expiryDate =
        '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: (metadata.icons.isNotEmpty
                ? NetworkImage(metadata.icons[0])
                : const AssetImage('assets/images/default_icon.png'))
            as ImageProvider<Object>,
      ),
      title: Text(
        metadata.name,
        style: const TextStyle(color: Colors.black),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expires on: $expiryDate',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 20.0,
        color: Colors.black,
      ),
      onTap: onTap,
    );
  }
}
