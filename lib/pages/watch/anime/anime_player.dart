import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:mixnma/api/anime/hotmanga_api.dart';

class AnimePlayer extends StatefulWidget {
  final String pathword;
  final String uuid;
  final String chapterName;

  const AnimePlayer({
    required this.pathword,
    required this.uuid,
    required this.chapterName,
    super.key,
  });

  @override
  State<AnimePlayer> createState() => _AnimePlayerState();
}

class _AnimePlayerState extends State<AnimePlayer> {
  late final VideoPlayerController _controller;
  late final Future<void> _initializeVideoFuture;
  bool _isControlsVisible = false;
  double _currentSliderValue = 0.0;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideoFuture = _initializeVideo();

    // 設置橫向模式
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();

    // 恢復縱向模式
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  Future<void> _initializeVideo() async {
    final videoURL = await HotMangaAPI.getAnimeVideo(widget.pathword, widget.uuid);
    _controller = VideoPlayerController.networkUrl(Uri.parse(videoURL))
      ..initialize().then((_) {
        setState(() {
          _controller.play();
        });
      });
    _controller.addListener(() {
      setState(() {
        _currentSliderValue = _controller.value.position.inMilliseconds.toDouble();
      });
    });
  }

  void _toggleControls() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });

    if(_isControlsVisible) _startHiderTimer();
  }

  void _startHiderTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _isControlsVisible = false;
      });
    });
  }

  void _togglePlayPause() {
    setState(() {
      if(_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  void _onSliderChanged(double value) {
    final position = Duration(milliseconds: value.toInt());
    _controller.seekTo(position);
    setState(() {
      _currentSliderValue = value;
    });
  }

  void _handleDoubleTapDown(BuildContext context, TapDownDetails details) {
    final dx = details.globalPosition.dx;
    final screenWidth = MediaQuery.of(context).size.width;
    if(dx < screenWidth / 2) {
      _rewind();
    } else {
      _fastForword();
    }
  }

  void _rewind() {
    final currentPosition = _controller.value.position;
    _controller.seekTo(currentPosition - const Duration(seconds: 5));
  }

  void _fastForword() {
    final currentPosition = _controller.value.position;
    _controller.seekTo(currentPosition + const Duration(seconds: 10));
  }

  void _onLongPress() {
    _controller.setPlaybackSpeed(2.0);
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    _controller.setPlaybackSpeed(1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<void>(
          future: _initializeVideoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Error loading video');
            } else {
              return GestureDetector(
                onTap: _toggleControls,
                onDoubleTapDown: (details) => _handleDoubleTapDown(context, details),
                onLongPress: _onLongPress,
                onLongPressEnd: _onLongPressEnd,
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    if(_isControlsVisible) _buildControls(),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Positioned.fill(
      child: Column(
        children: [
          // 影片標題
          Container(
            padding: const EdgeInsets.all(10),
            alignment: Alignment.centerLeft,
            child: Text(widget.chapterName),
          ),
          // 暫停/播放鍵
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: IconButton(
                onPressed: _togglePlayPause,
                icon: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 50,
                ),
              ),
            )
          ),
          // 播放進度條
          Slider(
            onChanged: _onSliderChanged,
            value: _currentSliderValue,
            min: 0.0,
            max: _controller.value.duration.inMilliseconds.toDouble(),
          ),
          // 顯示播放時間及設定按鈕
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(25, 0, 0, 10),
                child: Text(
                  '${_controller.value.position.inMinutes}:${(_controller.value.position.inSeconds % 60).toString().padLeft(2, '0')}/'
                  '${_controller.value.duration.inMinutes}:${(_controller.value.duration.inSeconds % 60).toString().padLeft(2, '0')}',
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 0, 25, 10),
                child: IconButton(
                  onPressed: () => _showPlaySpeedDialog(context),
                  icon: const Icon(Icons.speed),
                )
              )
            ],
          ),
        ],
      )
    );
  }

  void _showPlaySpeedDialog(BuildContext context) {
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: const Text('播放速度'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPlaybackSpeedTile(context, '0.25x', 0.25),
                _buildPlaybackSpeedTile(context, '0.5x', 0.5),
                _buildPlaybackSpeedTile(context, '0.75x', 0.75),
                _buildPlaybackSpeedTile(context, '1.0x', 1.0),
                _buildPlaybackSpeedTile(context, '1.25x', 1.25),
                _buildPlaybackSpeedTile(context, '1.5x', 1.5),
                _buildPlaybackSpeedTile(context, '1.75x', 1.75),
                _buildPlaybackSpeedTile(context, '2.0x', 2.0),
              ],
            ),
          )
        );
      }
    );
  }

  Widget _buildPlaybackSpeedTile(BuildContext context, String title, double speed) {
    return ListTile(
      title: Text(title),
      onTap: () {
        _controller.setPlaybackSpeed(speed);
        Navigator.of(context).pop();
      },
    );
  }
}
