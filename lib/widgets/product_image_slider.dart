import 'package:flutter/material.dart';

class ProductImageSlider extends StatefulWidget {
  final List<String> imageUrls;
  const ProductImageSlider({super.key, required this.imageUrls});

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final ScrollController _thumbController = ScrollController();

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[100], // Lighter grey for empty state
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        // --- 1. รูปใหญ่ (Main Image) ---
        Container(
          // Wrap with Container for styling
          height: 350,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white, // ✅ Set background to White
            border: Border.all(
              color: Colors.grey.shade200,
            ), // ✅ Add a subtle border
          ),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.imageUrls.length,
                onPageChanged: (index) {
                  setState(() => _selectedIndex = index);
                  _scrollToThumbnail(index);
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Add fullscreen navigation logic here if needed
                    },
                    child: Image.network(
                      widget.imageUrls[index],
                      fit: BoxFit.contain, // Keep contain to see full image
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.error, color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),

              // Navigation Arrows (Left/Right)
              if (widget.imageUrls.length > 1) ...[
                Positioned(
                  left: 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: CircleAvatar(
                      backgroundColor:
                          Colors.black12, // Lighter background for arrows
                      radius: 16,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 16,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: CircleAvatar(
                      backgroundColor: Colors.black12,
                      radius: 16,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],

              // Image Counter Badge (bottom right)
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_selectedIndex + 1}/${widget.imageUrls.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // --- 2. แถบรูปเล็ก (Thumbnail Strip) ---
        if (widget.imageUrls.length > 1)
          SizedBox(
            height: 70, // Adjusted height
            child: Row(
              children: [
                // Left Arrow for Thumbnails
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.grey),
                  onPressed: () {
                    _thumbController.animateTo(
                      _thumbController.offset - 100,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                ),

                // Thumbnails List
                Expanded(
                  child: ListView.builder(
                    controller: _thumbController,
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.imageUrls.length,
                    itemBuilder: (context, index) {
                      final bool isSelected = _selectedIndex == index;
                      return GestureDetector(
                        onTap: () {
                          _pageController.jumpToPage(index);
                          setState(() => _selectedIndex = index);
                        },
                        child: Container(
                          width: 70,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.orange
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            // Add padding inside border
                            padding: const EdgeInsets.all(2.0),
                            child: Image.network(
                              widget.imageUrls[index],
                              fit: BoxFit.cover, // Thumbnails should be cover
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.error, size: 16),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Right Arrow for Thumbnails
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.grey),
                  onPressed: () {
                    _thumbController.animateTo(
                      _thumbController.offset + 100,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _scrollToThumbnail(int index) {
    if (_thumbController.hasClients) {
      _thumbController.animateTo(
        index * 78.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }
}
