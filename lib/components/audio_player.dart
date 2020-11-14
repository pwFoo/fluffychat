import 'dart:async';
import 'dart:typed_data';

import 'package:famedlysdk/famedlysdk.dart';
import 'package:fluffychat/components/message_download_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/prefer_universal/html.dart' as html;
import 'dialogs/simple_dialogs.dart';
import '../utils/ui_fake.dart' if (dart.library.html) 'dart:ui' as ui;
import 'matrix.dart';

class AudioPlayer extends StatefulWidget {
  final Color color;
  final Event event;

  static String currentId;

  const AudioPlayer(this.event, {this.color = Colors.black, Key key})
      : super(key: key);

  @override
  _AudioPlayerState createState() => _AudioPlayerState();
}

enum AudioPlayerStatus { NOT_DOWNLOADED, DOWNLOADING, DOWNLOADED }

class _AudioPlayerState extends State<AudioPlayer> {
  AudioPlayerStatus status = AudioPlayerStatus.NOT_DOWNLOADED;

  FlutterSoundPlayer flutterSound = FlutterSoundPlayer();

  StreamSubscription soundSubscription;
  Uint8List audioFile;

  String statusText = '00:00';
  double currentPosition = 0;
  double maxPosition = 0;

  String webSrcUrl;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      ui.platformViewRegistry.registerViewFactory(
          'web_audio_player',
          (int viewId) => html.AudioElement()
            ..src = webSrcUrl
            ..autoplay = false
            ..controls = true
            ..style.border = 'none');
    }
  }

  @override
  void dispose() {
    if (flutterSound.playerState == PlayerState.isPlaying) {
      flutterSound.stopPlayer();
    }
    soundSubscription?.cancel();
    flutterSound?.closeAudioSession();
    flutterSound = null;
    super.dispose();
  }

  Future<void> _downloadAction() async {
    if (status != AudioPlayerStatus.NOT_DOWNLOADED) return;
    setState(() => status = AudioPlayerStatus.DOWNLOADING);
    final matrixFile = await SimpleDialogs(context)
        .tryRequestWithErrorToast(widget.event.downloadAndDecryptAttachment());
    setState(() {
      audioFile = matrixFile.bytes;
      status = AudioPlayerStatus.DOWNLOADED;
    });
    _playAction();
  }

  void _playAction() async {
    if (AudioPlayer.currentId != widget.event.eventId) {
      if (AudioPlayer.currentId != null) {
        if (flutterSound.playerState != PlayerState.isStopped) {
          await flutterSound.stopPlayer();
          setState(() => null);
        }
      }
      AudioPlayer.currentId = widget.event.eventId;
    }
    switch (flutterSound.playerState) {
      case PlayerState.isPlaying:
        await flutterSound.pausePlayer();
        break;
      case PlayerState.isPaused:
        await flutterSound.resumePlayer();
        break;
      case PlayerState.isStopped:
        await flutterSound.startPlayer(
          fromDataBuffer: audioFile,
        );
        soundSubscription ??= flutterSound.onProgress.listen((disposition) {
          if (AudioPlayer.currentId != widget.event.eventId) {
            soundSubscription?.cancel()?.then((f) => soundSubscription = null);
            setState(() {
              currentPosition = 0;
              statusText = '00:00';
            });
            AudioPlayer.currentId = null;
          } else if (disposition != null) {
            var date = DateTime.fromMillisecondsSinceEpoch(
                disposition.position.inMilliseconds.toInt());
            var txt = DateFormat('mm:ss', 'en_US').format(date);
            setState(() {
              maxPosition = disposition.duration.inMilliseconds.toDouble();
              currentPosition = disposition.position.inMilliseconds.toDouble();
              statusText = txt;
            });
            if (disposition.duration == disposition.position) {
              soundSubscription
                  ?.cancel()
                  ?.then((f) => soundSubscription = null);
            }
          }
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      if (widget.event.content['url'] is String) {
        webSrcUrl = Uri.parse(widget.event.content['url'])
            .getDownloadLink(Matrix.of(context).client);
        return Container(
          height: 50,
          width: 300,
          child: HtmlElementView(viewType: 'web_audio_player'),
        );
      }
      return MessageDownloadContent(widget.event, widget.color);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 30,
          child: status == AudioPlayerStatus.DOWNLOADING
              ? CircularProgressIndicator(strokeWidth: 2)
              : IconButton(
                  icon: Icon(
                    flutterSound.playerState == PlayerState.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: widget.color,
                  ),
                  onPressed: () {
                    if (status == AudioPlayerStatus.DOWNLOADED) {
                      _playAction();
                    } else {
                      _downloadAction();
                    }
                  },
                ),
        ),
        Expanded(
          child: Slider(
            value: currentPosition,
            onChanged: (double position) => flutterSound
                .seekToPlayer(Duration(milliseconds: position.toInt())),
            max: status == AudioPlayerStatus.DOWNLOADED ? maxPosition : 0,
            min: 0,
          ),
        ),
        Text(
          statusText,
          style: TextStyle(
            color: widget.color,
          ),
        ),
      ],
    );
  }
}
