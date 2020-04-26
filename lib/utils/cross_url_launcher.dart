import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:url_launcher/url_launcher.dart' as native_launcher;
import 'package:system/system.dart';

void launch(String url) {
  if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
    native_launcher.launch(url);
  } else if (Platform.isLinux) {
    System.invoke('xdg-open $url');
  } else if (Platform.isMacOS) {
    System.invoke('open $url');
  } else {
    showToast('Open urls is not yet supported on this platform.');
  }
}
