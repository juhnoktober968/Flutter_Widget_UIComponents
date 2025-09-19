import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const VideoPlayerApp());

class VideoPlayerApp extends StatelessWidget {
  const VideoPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Player Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const VideoPlayerScreen(),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final VideoPlayerController _controller = VideoPlayerController.networkUrl(
    Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
  );
  late final Future<void> _initializeVideoPlayerFuture = _controller.initialize();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {}); // rebuild UI when video state changes
    });
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player Layout'),
      ),
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Text(_formatDuration(_controller.value.position)),
                      Expanded(
                        child: Slider(
                          value: _controller.value.position.inSeconds.toDouble().clamp(
                                0,
                                _controller.value.duration.inSeconds.toDouble(),
                              ),
                          min: 0,
                          max: _controller.value.duration.inSeconds.toDouble(),
                          onChanged: (value) {
                            _controller.seekTo(Duration(seconds: value.toInt()));
                          },
                        ),
                      ),
                      Text(_formatDuration(_controller.value.duration)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                IconButton(
                  icon: Icon(
                    _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  iconSize: 50,
                  color: Colors.blue,
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying ? _controller.pause() : _controller.play();
                    });
                  },
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading video: ${snapshot.error}'));
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading video...'),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
