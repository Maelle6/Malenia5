import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AudioPlayerScreen extends StatefulWidget {
  final String audioUrl;
  final String audioTitle;
  final String imageUrl;

  const AudioPlayerScreen({
    super.key,
    required this.audioUrl,
    required this.audioTitle,
    required this.imageUrl,
  });

  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer _audioPlayer;
  bool isAsset = true;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _isLooping = false;
  double _volume = 1.0;
  double _playbackSpeed = 1.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setAudioSource(
        AudioSource.asset(widget.audioUrl),
        initialPosition: Duration.zero,
      );

      final duration = _audioPlayer.duration;
      if (duration != null && mounted) {
        setState(() {
          _duration = duration;
        });
      }

      _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _position = position;
          });
        }
      });

      _audioPlayer.playerStateStream.listen((playerState) {
        if (mounted) {
          setState(() {
            _isPlaying = playerState.playing;
            _isLoading =
                playerState.processingState == ProcessingState.loading ||
                    playerState.processingState == ProcessingState.buffering;
          });
        }
      });

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error initializing audio: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _playPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      print("Error during play/pause: $e");
    }
  }

  Future<void> _skipForward() async {
    try {
      final newPosition = _position + const Duration(seconds: 10);
      if (_duration != Duration.zero && newPosition < _duration) {
        await _audioPlayer.seek(newPosition);
      } else {
        await _audioPlayer.seek(_duration);
      }
    } catch (e) {
      print("Error skipping forward: $e");
    }
  }

  Future<void> _skipBackward() async {
    try {
      final newPosition = _position - const Duration(seconds: 10);
      if (newPosition > Duration.zero) {
        await _audioPlayer.seek(newPosition);
      } else {
        await _audioPlayer.seek(Duration.zero);
      }
    } catch (e) {
      print("Error skipping backward: $e");
    }
  }

  Future<void> _seekAudio(double value) async {
    try {
      final duration = Duration(seconds: value.toInt());
      await _audioPlayer.seek(duration);
    } catch (e) {
      print("Error seeking audio: $e");
    }
  }

  void _toggleLooping() {
    setState(() {
      _isLooping = !_isLooping;
      _audioPlayer.setLoopMode(_isLooping ? LoopMode.all : LoopMode.off);
    });
  }

  void _updateVolume(double value) {
    setState(() {
      _volume = value;
      _audioPlayer.setVolume(value);
    });
  }

  void _updateSpeed(double value) {
    setState(() {
      _playbackSpeed = value;
      _audioPlayer.setSpeed(value);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade900,
              Colors.black87,
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: SpinKitPulse(
                    color: Colors.white,
                    size: 50.0,
                  ),
                )
              : Column(
                  children: [
                    // App Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 16.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Text(
                            'Now Playing',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _isLooping ? Icons.repeat_one : Icons.repeat,
                              color: _isLooping ? Colors.purple : Colors.white,
                            ),
                            onPressed: _toggleLooping,
                          ),
                        ],
                      ),
                    ),

                    // Album Art
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              widget.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: Colors.grey.shade800,
                                child: const Icon(
                                  Icons.music_note,
                                  size: 80,
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Title and Controls
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Title
                            Text(
                              widget.audioTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            // Progress Bar
                            Column(
                              children: [
                                SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 4,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 14,
                                    ),
                                    activeTrackColor: Colors.purple,
                                    inactiveTrackColor:
                                        Colors.white.withOpacity(0.2),
                                    thumbColor: Colors.purple,
                                    overlayColor:
                                        Colors.purple.withOpacity(0.3),
                                  ),
                                  child: Slider(
                                    value: _position.inSeconds.toDouble(),
                                    min: 0,
                                    max: _duration.inSeconds.toDouble() == 0
                                        ? 1
                                        : _duration.inSeconds.toDouble(),
                                    onChanged: _seekAudio,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDuration(_position),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                      Text(
                                        _formatDuration(_duration),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Controls
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.replay_10,
                                      color: Colors.white, size: 32),
                                  onPressed: _skipBackward,
                                ),
                                Container(
                                  height: 64,
                                  width: 64,
                                  decoration: BoxDecoration(
                                    color: Colors.purple,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.purple.withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      _isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      size: 38,
                                      color: Colors.white,
                                    ),
                                    onPressed: _playPause,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.forward_10,
                                      color: Colors.white, size: 32),
                                  onPressed: _skipForward,
                                ),
                              ],
                            ),

                            // Additional Controls
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Icon(Icons.volume_up,
                                        color: Colors.white.withOpacity(0.7)),
                                    SizedBox(
                                      width: 140,
                                      child: SliderTheme(
                                        data: SliderThemeData(
                                          trackHeight: 2,
                                          thumbShape:
                                              const RoundSliderThumbShape(
                                                  enabledThumbRadius: 4),
                                          overlayShape:
                                              const RoundSliderOverlayShape(
                                                  overlayRadius: 8),
                                          activeTrackColor:
                                              Colors.white.withOpacity(0.7),
                                          inactiveTrackColor:
                                              Colors.white.withOpacity(0.2),
                                          thumbColor:
                                              Colors.white.withOpacity(0.7),
                                        ),
                                        child: Slider(
                                          value: _volume,
                                          min: 0,
                                          max: 1,
                                          onChanged: _updateVolume,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Icon(Icons.speed,
                                        color: Colors.white.withOpacity(0.7)),
                                    SizedBox(
                                      width: 140,
                                      child: SliderTheme(
                                        data: SliderThemeData(
                                          trackHeight: 2,
                                          thumbShape:
                                              const RoundSliderThumbShape(
                                                  enabledThumbRadius: 4),
                                          overlayShape:
                                              const RoundSliderOverlayShape(
                                                  overlayRadius: 8),
                                          activeTrackColor:
                                              Colors.white.withOpacity(0.7),
                                          inactiveTrackColor:
                                              Colors.white.withOpacity(0.2),
                                          thumbColor:
                                              Colors.white.withOpacity(0.7),
                                        ),
                                        child: Slider(
                                          value: _playbackSpeed,
                                          min: 0.5,
                                          max: 2.0,
                                          divisions: 3,
                                          label:
                                              "${_playbackSpeed.toStringAsFixed(1)}x",
                                          onChanged: _updateSpeed,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String minutes = duration.inMinutes.toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}
