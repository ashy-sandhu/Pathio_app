import 'package:flutter/material.dart';
import 'dart:async';
import '../screens/place_card.dart';
import '../../data/models/place_model.dart';

class AutoScrollList extends StatefulWidget {
  final List<Place> places;
  final double height;
  final double itemWidth;
  final double itemHeight;
  final Function(Place)? onTap;
  final Duration scrollDuration;
  final Duration pauseDuration;
  final bool reverseDirection;

  const AutoScrollList({
    super.key,
    required this.places,
    this.height = 200,
    this.itemWidth = 160,
    this.itemHeight = 200,
    this.onTap,
    this.scrollDuration = const Duration(milliseconds: 2000),
    this.pauseDuration = const Duration(seconds: 3),
    this.reverseDirection = false,
  });

  @override
  State<AutoScrollList> createState() => _AutoScrollListState();
}

class _AutoScrollListState extends State<AutoScrollList> {
  late ScrollController _scrollController;
  Timer? _autoScrollTimer;
  bool _isPaused = false;
  bool _isHovered = false;
  int _currentIndex = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Initialize scroll position after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.places.isNotEmpty) {
        _initializeScrollPosition();
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeScrollPosition() {
    final itemWidth = widget.itemWidth + 12;
    final listLength = widget.places.length;

    if (widget.reverseDirection) {
      // For reverse: start at END of middle copy (rightmost visible position)
      // Middle copy is at indices [listLength ... 2*listLength-1]
      _currentIndex = (2 * listLength) - 1; // Last item of middle copy
    } else {
      // For normal: start at START of middle copy
      _currentIndex = listLength; // First item of middle copy
    }

    final initialPosition = _currentIndex * itemWidth;
    _scrollController.jumpTo(initialPosition);
    _isInitialized = true;
  }

  void _startAutoScroll() {
    if (widget.places.length <= 1) return;

    _autoScrollTimer = Timer.periodic(widget.pauseDuration, (timer) {
      if (!_isPaused && !_isHovered && mounted) {
        _moveToNextCard();
      }
    });
  }

  void _moveToNextCard() {
    if (!mounted || widget.places.isEmpty || !_isInitialized) return;

    final itemWidth = widget.itemWidth + 12;
    final listLength = widget.places.length;

    // Move to next card
    if (widget.reverseDirection) {
      _currentIndex--; // Move leftward
    } else {
      _currentIndex++; // Move rightward
    }

    final targetPosition = _currentIndex * itemWidth;

    // Animate to target
    _scrollController
        .animateTo(
          targetPosition,
          duration: widget.scrollDuration,
          curve: Curves.easeInOut,
        )
        .then((_) {
          if (!mounted) return;

          // Check boundaries and jump if needed (seamless loop)
          if (widget.reverseDirection) {
            // If we've scrolled too far left (before first copy), jump to equivalent position in middle copy
            if (_currentIndex < listLength) {
              _currentIndex += listLength;
              final jumpPosition = _currentIndex * itemWidth;
              _scrollController.jumpTo(jumpPosition);
            }
          } else {
            // If we've scrolled too far right (past middle copy), jump to equivalent position in middle copy
            if (_currentIndex >= 2 * listLength) {
              _currentIndex -= listLength;
              final jumpPosition = _currentIndex * itemWidth;
              _scrollController.jumpTo(jumpPosition);
            }
          }
        });
  }

  void _pauseScroll() {
    setState(() {
      _isPaused = true;
    });
    _autoScrollTimer?.cancel();
  }

  void _resumeScroll() {
    setState(() {
      _isPaused = false;
    });
    _startAutoScroll();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.places.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(child: Text('No places available')),
      );
    }

    // Create infinite list by duplicating the places
    final infinitePlaces = [
      ...widget.places,
      ...widget.places,
      ...widget.places,
    ];

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
        _pauseScroll();
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
        _resumeScroll();
      },
      child: GestureDetector(
        onTapDown: (_) => _pauseScroll(),
        onTapUp: (_) => _resumeScroll(),
        onTapCancel: () => _resumeScroll(),
        child: SizedBox(
          height: widget.height,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: infinitePlaces.length,
            itemBuilder: (context, index) {
              final place = infinitePlaces[index];

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: PlaceCard(
                  place: place,
                  width: widget.itemWidth,
                  height: widget.itemHeight,
                  onTap: () {
                    _pauseScroll();
                    widget.onTap?.call(place);
                    // Resume after a delay
                    Future.delayed(const Duration(seconds: 3), () {
                      if (mounted) {
                        _resumeScroll();
                      }
                    });
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
