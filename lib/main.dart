// ignore_for_file: avoid_print, unused_import, unused_element

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/positionData.dart';
import 'package:flutter_application_1/musicList.dart';
import 'package:flutter_application_1/seekbar.dart';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 23, 23, 23),
      ),
      home: const MyHomePage(title: 'Ynovify'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int musicIndex = 0;
  bool playing = false;
  final _player = AudioPlayer();

  Future<void> _init() async {
    try {
      await _player.setAsset(musicList[musicIndex].urlSong);
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 33, 34, 49),
      appBar: AppBar(
          title: Center(child: Text(widget.title)),
          backgroundColor: const Color.fromARGB(255, 23, 23, 23)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              musicList[musicIndex].imagePath,
              height: 350,
              width: 350,
            ),
            const SizedBox(height: 25),
            Text(
              musicList[musicIndex].title,
              style: const TextStyle(
                  fontSize: 26, color: Color.fromARGB(255, 255, 255, 255)),
            ),
            const SizedBox(height: 15),
            Text(
              musicList[musicIndex].singer,
              style: const TextStyle(
                  fontSize: 22, color: Color.fromARGB(255, 255, 255, 255)),
            ),
            const SizedBox(height: 35),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                    onPressed: _previousMusic,
                    icon: const Icon(Icons.skip_previous),
                    iconSize: 45,
                    color: const Color.fromARGB(255, 255, 255, 255)),
                const SizedBox(width: 15),
                IconButton(
                  onPressed: _pauseMusic,
                  icon:
                      Icon((playing == false) ? Icons.play_arrow : Icons.pause),
                  iconSize: 45,
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
                const SizedBox(width: 15),
                IconButton(
                    onPressed: _nextMusic,
                    icon: const Icon(Icons.skip_next),
                    iconSize: 45,
                    color: const Color.fromARGB(255, 255, 255, 255)),
              ],
            ),
            const SizedBox(height: 20),
            StreamBuilder<PositionData>(
              stream: _positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return SeekBar(
                  duration: positionData?.duration ?? Duration.zero,
                  position: positionData?.position ?? Duration.zero,
                  bufferedPosition:
                      positionData?.bufferedPosition ?? Duration.zero,
                  onChangeEnd: _player.seek,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _previousMusic() {
    setState(() {
      if (musicIndex <= 0) {
        musicIndex = musicList.length - 1;
        stderr.writeln('test 1');
      } else {
        musicIndex--;
        stderr.writeln('test 2');
      }
      _init();
    });
  }

  void _pauseMusic() {
    setState(() {
      if (playing) {
        _player.stop();
        playing = false;
      } else {
        _player.play();
        playing = true;
      }
    });
  }

  void _nextMusic() {
    setState(() {
      if (musicIndex >= musicList.length - 1) {
        musicIndex = 0;
        stderr.writeln('test 3');
      } else {
        musicIndex++;
        stderr.writeln('test 4');
      }
      _init();
    });
  }
}
