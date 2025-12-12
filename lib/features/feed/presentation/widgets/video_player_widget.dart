import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../domain/models/video_model.dart';

class VideoPlayerWidget extends StatefulWidget {
  final VideoModel video;
  final bool isActive;

  const VideoPlayerWidget({
    super.key,
    required this.video,
    required this.isActive,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller?.play();
        _controller?.setLooping(true);
      } else {
        _controller?.pause();
      }
    }
  }

  Future<void> _initializeController() async {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.media.srcUrl),
    );
    try {
      await _controller!.initialize();
      setState(() {
        _initialized = true;
      });
      if (widget.isActive) {
        _controller!.play();
        _controller!.setLooping(true);
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Layer
        Container(
          color: Colors.black,
          child: _initialized && _controller != null
              ? Center(
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
        ),

        // Overlay Layer
        Positioned(
          bottom: 20,
          left: 16,
          right: 80, // Space for right actions
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '@${widget.video.account.username}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              if (widget.video.caption != null)
                Text(
                  widget.video.caption!,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),

        // Right Actions (Like, Comment, etc.)
        Positioned(
          bottom: 40,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionButton(
                icon: Icons.favorite_border,
                label: '${widget.video.likes}',
                onTap: () {},
              ),
              const SizedBox(height: 20),
              _ActionButton(
                icon: Icons.chat_bubble_outline,
                label: '${widget.video.comments}',
                onTap: () {},
              ),
              const SizedBox(height: 20),
              _ActionButton(
                icon: Icons.share,
                label: '${widget.video.shares}',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: Colors.white, size: 30),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
