import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

// story item shape: { "type": "image", "url": String, "duration": int }
class StoryViewer extends StatefulWidget {
  final String userName;
  final List<Map<String, dynamic>> stories;
  final String avatarUrl; // ✅ Added avatar URL

  const StoryViewer({
    super.key,
    required this.userName,
    required this.stories,
    required this.avatarUrl,
  });

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _progressTimer;
  double _progress = 0.0;
  late int _currentDuration;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startStory(0);
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startStory(int index) {
    _progressTimer?.cancel();
    _currentIndex = index;
    final item = widget.stories[_currentIndex];
    _currentDuration = (item['duration'] ?? 5) as int;
    _progress = 0.0;

    final tick = 50;
    final totalTicks = (_currentDuration * 1000 / tick).round();
    int ticks = 0;

    _progressTimer = Timer.periodic(Duration(milliseconds: tick), (timer) {
      ticks++;
      setState(() {
        _progress = (ticks / totalTicks).clamp(0.0, 1.0);
      });
      if (ticks >= totalTicks) {
        timer.cancel();
        _goNext();
      }
    });
  }

  void _goNext() {
    if (_currentIndex < widget.stories.length - 1) {
      _pageController.animateToPage(
        _currentIndex + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startStory(_currentIndex + 1);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _goPrev() {
    if (_currentIndex > 0) {
      _pageController.animateToPage(
        _currentIndex - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startStory(_currentIndex - 1);
    } else {
      _startStory(0);
    }
  }

  void _onTapDown(TapDownDetails details, BuildContext ctx) {
    final w = MediaQuery.of(ctx).size.width;
    final dx = details.globalPosition.dx;
    if (dx < w * 0.30) {
      _progressTimer?.cancel();
      _goPrev();
    } else if (dx > w * 0.70) {
      _progressTimer?.cancel();
      _goNext();
    } else {
      if (_progressTimer?.isActive ?? false) {
        _progressTimer?.cancel();
      } else {
        _startStory(_currentIndex);
      }
    }
  }

  Widget _buildProgressBars() {
    return Row(
      children: widget.stories.map((s) {
        final idx = widget.stories.indexOf(s);
        double value = 0.0;
        if (idx < _currentIndex) value = 1.0;
        if (idx == _currentIndex) value = _progress;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.white24,
              color: Colors.white,
              minHeight: 3,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStoryItem(Map<String, dynamic> item) {
    final type = item['type'] ?? 'image';
    final url = item['url'] as String? ?? '';

    if (type == 'image') {
      final isLocal = url.startsWith('/') || url.startsWith('file:');
      if (isLocal) {
        final file = File(url);
        return Center(
          child: InteractiveViewer(
            child: Image.file(
              file,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        );
      } else {
        return Center(
          child: InteractiveViewer(
            child: Image.network(
              url,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.userName;
    final avatarUrl = widget.avatarUrl;

    return GestureDetector(
      onVerticalDragUpdate: (d) {
        if (d.delta.dy > 10) Navigator.of(context).pop();
      },
      onTapDown: (details) => _onTapDown(details, context),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.stories.length,
                onPageChanged: (index) {
                  _startStory(index);
                },
                itemBuilder: (context, index) {
                  return _buildStoryItem(widget.stories[index]);
                },
              ),

              // Top overlay: progress bars + avatar + name + close
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Column(
                  children: [
                    _buildProgressBars(),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey[800],
                          backgroundImage: avatarUrl.isNotEmpty
                              ? NetworkImage(avatarUrl)
                              : null,
                          child: avatarUrl.isEmpty
                              ? Text(
                                  name.isNotEmpty ? name[0] : '?',
                                  style: const TextStyle(color: Colors.white),
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "Active now",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
