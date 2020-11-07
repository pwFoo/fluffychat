import 'package:famedlysdk/famedlysdk.dart';
import 'package:famedlysdk/encryption.dart';
import 'package:famedlysdk/matrix_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

import '../components/adaptive_page_layout.dart';
import '../components/avatar.dart';
import '../components/dialogs/simple_dialogs.dart';
import '../components/matrix.dart';
import 'chat_list.dart';

class BootstrapView extends StatelessWidget {
  BootstrapView();

  @override
  Widget build(BuildContext context) {

    return AdaptivePageLayout(
      primaryPage: FocusPage.SECOND,
      firstScaffold: ChatList(),
      secondScaffold: BootstrapPage(Matrix.of(context).client),
    );
  }
}

class BootstrapPage extends StatefulWidget {
  final Client client;
  BootstrapPage(this.client);

  @override
  _BootstrapPageState createState() => _BootstrapPageState();
}

class _BootstrapPageState extends State<BootstrapPage> {
  Bootstrap bootstrap;

  @override
  void initState() {
    bootstrap = widget.client.encryption.bootstrap(onUpdate: () => setState(() => null));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    final buttons = <Widget>[];
    switch (bootstrap.state) {
      case BootstrapState.loading:
        body = CircularProgressIndicator();
        break;
      case BootstrapState.askWipeSsss:
        body = Text('Wipe SSSS?');
        buttons.add(RaisedButton(
          color: Theme.of(context).primaryColor,
          elevation: 5,
          textColor: Colors.white,
          child: Text('Yes'),
          onPressed: () => bootstrap.wipeSsss(true),
        ));
        buttons.add(RaisedButton(
          textColor: Theme.of(context).primaryColor,
          elevation: 5,
          color: Colors.white,
          child: Text('No'),
          onPressed: () => bootstrap.wipeSsss(false),
        ));
        break;
      case BootstrapState.askUseExistingSsss:
        body = Text('Use existing SSSS?');
        buttons.add(RaisedButton(
          color: Theme.of(context).primaryColor,
          elevation: 5,
          textColor: Colors.white,
          child: Text('Yes'),
          onPressed: () => bootstrap.useExistingSsss(true),
        ));
        buttons.add(RaisedButton(
          textColor: Theme.of(context).primaryColor,
          elevation: 5,
          color: Colors.white,
          child: Text('No'),
          onPressed: () => bootstrap.useExistingSsss(false),
        ));
        break;
      case BootstrapState.askBadSsss:
        body = Text('SSSS bad - continue nevertheless? DATALOSS!!!');
        buttons.add(RaisedButton(
          color: Theme.of(context).primaryColor,
          elevation: 5,
          textColor: Colors.white,
          child: Text('Yes'),
          onPressed: () => bootstrap.ignoreBadSecrets(true),
        ));
        buttons.add(RaisedButton(
          textColor: Theme.of(context).primaryColor,
          elevation: 5,
          color: Colors.white,
          child: Text('No'),
          onPressed: () => bootstrap.ignoreBadSecrets(false),
        ));
        break;
      case BootstrapState.askUnlockSsss:
        final widgets = <Widget>[Text('Unlock old SSSS')];
        for (final entry in bootstrap.oldSsssKeys.entries) {
          final keyId = entry.key;
          final key = entry.value;
          widgets.add(Flexible(child: _AskUnlockOldSsss(keyId, key)));
        }
        body = Column(
          children: widgets,
          mainAxisSize: MainAxisSize.min,
        );
        buttons.add(RaisedButton(
          textColor: Theme.of(context).primaryColor,
          elevation: 5,
          color: Colors.white,
          child: Text('Done'),
          onPressed: () => bootstrap.unlockedSsss(),
        ));
        break;
      case BootstrapState.askNewSsss:
        String passphrase;
        body = Column(
          children: <Widget>[
            Text('New SSSS passphrase'),
            Flexible(
              child: TextField(
                autofocus: false,
                autocorrect: false,
                onChanged: (s) {
                  passphrase = s;
                },
                minLines: 1,
                maxLines: 1,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'New passphrase',
                  prefixStyle: TextStyle(color: Theme.of(context).primaryColor),
                  suffixStyle: TextStyle(color: Theme.of(context).primaryColor),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
          mainAxisSize: MainAxisSize.min,
        );
        buttons.add(RaisedButton(
          textColor: Theme.of(context).primaryColor,
          elevation: 5,
          color: Colors.white,
          child: Text('Done'),
          onPressed: () => bootstrap.newSsss(passphrase?.isNotEmpty ?? false ? passphrase : null),
        ));
        break;
      case BootstrapState.openExistingSsss:
        body = Column(
          children: <Widget>[
            Text('Existing SSSS passphrase'),
            Flexible(child: _AskUnlockOldSsss('existing', bootstrap.newSsssKey)),
          ],
          mainAxisSize: MainAxisSize.min,
        );
        buttons.add(RaisedButton(
          textColor: Theme.of(context).primaryColor,
          elevation: 5,
          color: Colors.white,
          child: Text('Done'),
          onPressed: () => bootstrap.openExistingSsss(),
        ));
        break;
      case BootstrapState.askWipeCrossSigning:
        body = Text('Wipe cross-signing?');
        buttons.add(RaisedButton(
          color: Theme.of(context).primaryColor,
          elevation: 5,
          textColor: Colors.white,
          child: Text('Yes'),
          onPressed: () => bootstrap.wipeCrossSigning(true),
        ));
        buttons.add(RaisedButton(
          textColor: Theme.of(context).primaryColor,
          elevation: 5,
          color: Colors.white,
          child: Text('No'),
          onPressed: () => bootstrap.wipeCrossSigning(false),
        ));
        break;
      case BootstrapState.askSetupCrossSigning:
        body = Text('Set up cross-signing?');
        buttons.add(RaisedButton(
          color: Theme.of(context).primaryColor,
          elevation: 5,
          textColor: Colors.white,
          child: Text('Yes'),
          onPressed: () => bootstrap.askSetupCrossSigning(
            setupMasterKey: true,
            setupSelfSigningKey: true,
            setupUserSigningKey: true,
          ),
        ));
        buttons.add(RaisedButton(
          textColor: Theme.of(context).primaryColor,
          elevation: 5,
          color: Colors.white,
          child: Text('No'),
          onPressed: () => bootstrap.askSetupCrossSigning(),
        ));
        break;
      case BootstrapState.askWipeOnlineKeyBackup:
        body = Text('Wipe online key backup?');
        buttons.add(RaisedButton(
          color: Theme.of(context).primaryColor,
          elevation: 5,
          textColor: Colors.white,
          child: Text('Yes'),
          onPressed: () => bootstrap.wipeOnlineKeyBackup(true),
        ));
        buttons.add(RaisedButton(
          textColor: Theme.of(context).primaryColor,
          elevation: 5,
          color: Colors.white,
          child: Text('No'),
          onPressed: () => bootstrap.wipeOnlineKeyBackup(false),
        ));
        break;
      case BootstrapState.askSetupOnlineKeyBackup:
        body = Text('Set up online key backup?');
        buttons.add(RaisedButton(
          color: Theme.of(context).primaryColor,
          elevation: 5,
          textColor: Colors.white,
          child: Text('Yes'),
          onPressed: () => bootstrap.askSetupOnlineKeyBackup(true),
        ));
        buttons.add(RaisedButton(
          textColor: Theme.of(context).primaryColor,
          elevation: 5,
          color: Colors.white,
          child: Text('No'),
          onPressed: () => bootstrap.askSetupOnlineKeyBackup(false),
        ));
        break;
      case BootstrapState.error:
        body = Icon(Icons.cancel, color: Colors.red, size: 200.0);
        break;
      case BootstrapState.done:
        body = Icon(Icons.check_circle, color: Colors.green, size: 200.0);
        break;
    }
    body ??= Text('ERROR: Unknown state ' + bootstrap.state.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text('Bootstrapping'),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Center(
        child: body,
      ),
      persistentFooterButtons: buttons.isEmpty ? null : buttons,
    );
  }
}

class _AskUnlockOldSsss extends StatefulWidget {
  final String keyId;
  final OpenSSSS ssssKey;
  _AskUnlockOldSsss(this.keyId, this.ssssKey);

  @override
  _AskUnlockOldSsssState createState() => _AskUnlockOldSsssState();
}

class _AskUnlockOldSsssState extends State<_AskUnlockOldSsss> {
  bool valid = false;
  TextEditingController textEditingController = TextEditingController();
  String input;

  void checkInput(BuildContext context) async {
    if (input == null) {
      return;
    }
    SimpleDialogs(context).showLoadingDialog(context);
    valid = false;
    try {
      await widget.ssssKey.unlock(keyOrPassphrase: input);
      valid = true;
    } catch (_) {
      valid = false;
    }
    await Navigator.of(context)?.pop();
    setState(() => null);
  }

  @override
  Widget build(BuildContext build) {
    if (valid) {
      return Row(
        children: <Widget>[
          Text(widget.keyId),
          Text('unlocked'),
        ],
        mainAxisSize: MainAxisSize.min,
      );
    }
    return Row(
      children: <Widget>[
        Text(widget.keyId),
        Flexible(
          child: TextField(
            controller: textEditingController,
            autofocus: false,
            autocorrect: false,
            onSubmitted: (s) {
              input = s;
              checkInput(context);
            },
            minLines: 1,
            maxLines: 1,
            obscureText: true,
            decoration: InputDecoration(
              hintText: L10n.of(context).passphraseOrKey,
              prefixStyle: TextStyle(color: Theme.of(context).primaryColor),
              suffixStyle: TextStyle(color: Theme.of(context).primaryColor),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        RaisedButton(
          color: Theme.of(context).primaryColor,
          elevation: 5,
          textColor: Colors.white,
          child: Text(L10n.of(context).submit),
          onPressed: () {
            input = textEditingController.text;
            checkInput(context);
          },
        ),
      ],
      mainAxisSize: MainAxisSize.min,
    );
  }
}
