import 'package:flutter/material.dart';
import 'package:famedlysdk/famedlysdk.dart';
import 'chat_list.dart';
import '../components/adaptive_page_layout.dart';

class KeyVerificationView extends StatelessWidget {
  final KeyVerification request;

  KeyVerificationView({this.request});

  @override
  Widget build(BuildContext context) {
    return AdaptivePageLayout(
      primaryPage: FocusPage.SECOND,
      firstScaffold: ChatList(),
      secondScaffold: KeyVerificationPage(request: request),
    );
  }
}

class KeyVerificationPage extends StatefulWidget {
  final KeyVerification request;

  KeyVerificationPage({this.request});

  @override
  _KeyVerificationPageState createState() => _KeyVerificationPageState();
}

class _KeyVerificationPageState extends State<KeyVerificationPage> {
  @override
  void initState() {
    widget.request.onUpdate = () => setState(() => null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.request.state) {
      case KeyVerificationState.askAccept:
        return Text('Accept this request? (you should never see this)');
      case KeyVerificationState.waitingAccept:
        return Text('Waiting for partner to accept the request...');
      case KeyVerificationState.askSas:
        final emojis = widget.request.sasEmojis;
        final emojiWidgets = emojis.map((e) => Text(e.emoji, style: TextStyle(fontSize: 20))).toList();
        return Column(
          children: <Widget>[
            Row(
              children: emojiWidgets,
            ),
            FlatButton(
               child: Text('Match'),
               onPressed: () => widget.request.acceptSas(),
            ),
            FlatButton(
              child: Text('Reject'),
              onPressed: () => widget.request.rejectSas(),
            )
          ],
        );
      case KeyVerificationState.waitingSas:
        return Text('Waiting for partner to accept the emoji...');
      case KeyVerificationState.done:
        return Text('Verification done!');
      case KeyVerificationState.error:
        return Text('Error ${widget.request.canceledCode}: ${widget.request.canceledReason}');
    }
    return Text('Unknown state');
  }
}
