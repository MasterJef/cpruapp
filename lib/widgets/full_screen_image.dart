import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kIsWeb

class FullScreenImageView extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageView({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  void _nextPage() {
    if (_currentIndex < widget.imageUrls.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.imageUrls.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    widget.imageUrls[index],
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              );
            },
          ),

          // ปุ่มลูกศรสำหรับ Web หรือ Tablet
          if (kIsWeb || MediaQuery.of(context).size.width > 600) ...[
            if (_currentIndex > 0)
              Positioned(
                left: 20,
                child: IconButton(
                  onPressed: _prevPage,
                  icon: const Icon(
                    Icons.arrow_circle_left,
                    color: Colors.white70,
                    size: 50,
                  ),
                ),
              ),
            if (_currentIndex < widget.imageUrls.length - 1)
              Positioned(
                right: 20,
                child: IconButton(
                  onPressed: _nextPage,
                  icon: const Icon(
                    Icons.arrow_circle_right,
                    color: Colors.white70,
                    size: 50,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
