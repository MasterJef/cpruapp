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
        color: Colors.grey[100],
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        // --- 1. รูปใหญ่ (Main Image) ---
        Container(
          height: 400, // ✅ ปรับความสูงให้เต็มตา (400)
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white, // ✅ พื้นหลังขาว
            border: Border.all(color: Colors.grey.shade200), // ✅ เส้นขอบบางๆ
            borderRadius: BorderRadius.circular(8),
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
                      // ใส่โค้ดเปิดดูรูปเต็มจอ (FullScreenImageView) ตรงนี้
                    },
                    child: Image.network(
                      widget.imageUrls[index],
                      fit: BoxFit.contain, // ✅ รูปไม่โดนตัด
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.error, color: Colors.grey),
                      ),
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
                      backgroundColor: Colors.black12,
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

              // ตัวนับรูป
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
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

        // ✅ เพิ่มระยะห่างให้สวยงาม
        const SizedBox(height: 20),

        // --- 2. แถบรูปเล็ก (Thumbnail Strip) ---
        if (widget.imageUrls.length > 1)
          SizedBox(
            height: 80, // ความสูงแถบรูปเล็ก
            child: Row(
              children: [
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
                          padding: const EdgeInsets.all(
                            2,
                          ), // Padding ให้เห็นกรอบชัด
                          decoration: BoxDecoration(
                            color: Colors.white, // ✅ พื้นหลังขาว
                            border: Border.all(
                              color: isSelected
                                  ? Colors.orange
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Image.network(
                            widget.imageUrls[index],
                            fit: BoxFit.cover, // รูปเล็กเต็มช่อง
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.error, size: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ),

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
