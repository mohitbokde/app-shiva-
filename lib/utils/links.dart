import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> openExternal(Uri u) async {
  try {
    return await launchUrl(u, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

void _toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

/// WhatsApp में संदेश भेजने के लिए खोलता है।
Future<void> shareOnWhatsApp(BuildContext context, String text) async {
  final ok = await openExternal(Uri.https('wa.me', '/', {'text': text}));
  if (!ok && context.mounted) {
    _toast(context, 'WhatsApp नहीं खुल सका');
  }
}

/// Google Maps में जगह खोजता है।
Future<void> openMaps(BuildContext context, String query) async {
  final ok = await openExternal(
    Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': query}),
  );
  if (!ok && context.mounted) {
    _toast(context, 'Google Maps नहीं खुल सका');
  }
}
