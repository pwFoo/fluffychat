import 'package:famedlysdk/famedlysdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import '../matrix.dart';

class UiaDialog extends StatefulWidget {
  final UiaRequest uia;

  UiaDialog({this.uia});

  @override
  _UiaDialogState createState() => _UiaDialogState();
}

class _UiaDialogState extends State<UiaDialog> {
  bool loading = true;

  @override
  void initState() {
    loading = widget.uia.nextStages.isEmpty; // initial test if the first reply returned
    widget.uia.onUpdate = () {
      loading = false;
      setState(() => null);
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return AlertDialog(
        title: Text(L10n.of(context).loadingPleaseWait),
        content: LinearProgressIndicator(),
      );
    }
    if (widget.uia.fail) {
      return AlertDialog(
        title: Text('UIA fail'),
        actions: <Widget>[
          FlatButton(
            child: Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    }
    if (widget.uia.done) {
      return AlertDialog(
        title: Text('UIA done'),
        actions: <Widget>[
          FlatButton(
            child: Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    }
    if (widget.uia.nextStages.isEmpty) {
      return AlertDialog(
        title: Text('UIA error'),
        actions: <Widget>[
          FlatButton(
            child: Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    }
    // TODO: pick next stage
    final nextStage = widget.uia.nextStages.first;
    switch (nextStage) {
      case 'm.login.password':
        final controller = TextEditingController();
        String input;
        final submit = () {
          final client = Matrix.of(context).client;
          final auth = <String, dynamic>{
            'password': input,
            'user': client.userID,
            'identifier': <String, dynamic>{
              'type': 'm.id.user',
              'user': client.userID,
            },
          };
          widget.uia.completeStage('m.login.password', auth);
          setState(() => loading = true);
        };
        return AlertDialog(
          title: Text('Ender password'),
          content: TextField(
            controller: controller,
            autofocus: true,
            autocorrect: false,
            onSubmitted: (s) {
              input = s;
              submit();
            },
            minLines: 1,
            maxLines: 1,
            obscureText: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Submit'),
              onPressed: () {
                input = controller.text;
                submit();
              },
            ),
          ],
        );
      default:
        return AlertDialog(
          title: Text('Unknown UIA stage ' + nextStage),
        );
    }
  }
}
