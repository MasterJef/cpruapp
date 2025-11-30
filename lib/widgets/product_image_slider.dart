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
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.image_not_supported, size: 50)),
      );
    }

    return Column(
      children: [
        // --- 1. รูปใหญ่ (Main Image) ---
        SizedBox(
          height: 350, // ปรับความสูงรูปใหญ่
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.imageUrls.length,
                onPageChanged: (index) {
                  setState(() => _selectedIndex = index);
                  _scrollToThumbnail(index); // เลื่อนรูปเล็กตาม
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // กดแล้วดู Fullscreen (ถ้ามีหน้า FullScreenImageView)
                      // Navigator.push(...)
                    },
                    child: Image.network(
                      widget.imageUrls[index],
                      fit: BoxFit.contain, // เห็นครบ
                      errorBuilder: (_, __, ___) => const Icon(Icons.error),
                    ),
                  );
                },
              ),

              // ปุ่มลูกศรซ้ายขวา (บนรูปใหญ่)
              if (widget.imageUrls.length > 1) ...[
                Positioned(
                  left: 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: CircleAvatar(
                      backgroundColor: Colors.black26,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
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
                      backgroundColor: Colors.black26,
                      child: IconButton(
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
            ],
          ),
        ),

        const SizedBox(height: 10),

        // --- 2. แถบรูปเล็ก (Thumbnail Strip) ---
        if (widget.imageUrls.length > 1)
          SizedBox(
            height: 80, // ความสูงแถบรูปเล็ก
            child: Row(
              children: [
                // ปุ่มเลื่อนซ้าย
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    _thumbController.animateTo(
                      _thumbController.offset - 100,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                ),

                // รายการรูปเล็ก
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
                            border: isSelected
                                ? Border.all(color: Colors.orange, width: 2)
                                : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              widget.imageUrls[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ปุ่มเลื่อนขวา
                IconButton(
                  icon: const Icon(Icons.chevron_right),
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

  // ฟังก์ชันช่วยเลื่อนแถบรูปเล็กให้ตรงกับรูปใหญ่
  void _scrollToThumbnail(int index) {
    if (_thumbController.hasClients) {
      _thumbController.animateTo(
        index * 78.0, // ขนาดรูป + margin
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }
}
