import 'package:flutter/material.dart';
import 'full_screen_image.dart';

class ImagePopupDialog extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImagePopupDialog({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<ImagePopupDialog> createState() => _ImagePopupDialogState();
}

class _ImagePopupDialogState extends State<ImagePopupDialog> {
  late int _selectedIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  void _changeImage(int index) {
    setState(() => _selectedIndex = index);
    _pageController.jumpToPage(index);
  }

  void _nextPage() {
    if (_selectedIndex < widget.imageUrls.length - 1) {
      _changeImage(_selectedIndex + 1);
    }
  }

  void _prevPage() {
    if (_selectedIndex > 0) {
      _changeImage(_selectedIndex - 1);
    }
  }

  void _openFullScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImageView(
          imageUrls: widget.imageUrls,
          initialIndex: _selectedIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 800;

    // ปรับขนาดให้พอดีๆ (ไม่ใหญ่จนคับจอ)
    final double dialogWidth = isDesktop ? 850 : size.width * 0.95;
    final double dialogHeight = isDesktop ? 500 : size.height * 0.7;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: dialogWidth,
          height: dialogHeight,
          decoration: BoxDecoration(
            color: Colors.white, // พื้นหลังหลักเป็นสีขาว
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 25,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                // Layout Content
                isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),

                // Close Button (ปุ่มปิด)
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey, size: 28),
                    tooltip: 'ปิด',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Desktop Layout (Shopee Style: Clean White) ---
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // 1. รูปใหญ่ (ฝั่งซ้าย)
        Expanded(
          flex: 3,
          child: Container(
            // ✅ เปลี่ยนพื้นหลังเป็นสีเทาอ่อน (ให้ดูแยกส่วน แต่ไม่ตัดกันรุนแรงเหมือนสีดำ)
            color: Colors.grey[100],
            child: Stack(
              alignment: Alignment.center,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: widget.imageUrls.length,
                  onPageChanged: (index) =>
                      setState(() => _selectedIndex = index),
                  itemBuilder: (context, index) {
                    return InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Image.network(
                        widget.imageUrls[index],
                        fit: BoxFit.contain, // รูปจะลอยสวยๆ บนพื้นเทาอ่อน
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),

                // ปุ่ม Full Screen
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.fullscreen,
                        color: Colors.black87,
                        size: 28,
                      ),
                      onPressed: _openFullScreen,
                      tooltip: 'ดูเต็มจอ',
                    ),
                  ),
                ),

                // ปุ่มเลื่อนซ้าย (สีดำ เพราะพื้นหลังสว่างแล้ว)
                if (_selectedIndex > 0)
                  Positioned(
                    left: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.black87,
                          size: 18,
                        ),
                        onPressed: _prevPage,
                      ),
                    ),
                  ),
                // ปุ่มเลื่อนขวา
                if (_selectedIndex < widget.imageUrls.length - 1)
                  Positioned(
                    right: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black87,
                          size: 18,
                        ),
                        onPressed: _nextPage,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // เส้นแบ่งแนวตั้ง (เพื่อให้ดูมีสัดส่วน)
        const VerticalDivider(width: 1, color: Colors.grey),

        // 2. แถบรูปเล็ก (ฝั่งขวา)
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(15, 50, 15, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'รูปภาพทั้งหมด (${widget.imageUrls.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                    itemCount: widget.imageUrls.length,
                    itemBuilder: (context, index) {
                      final bool isSelected = _selectedIndex == index;
                      return GestureDetector(
                        onTap: () => _changeImage(index),
                        child: Container(
                          decoration: BoxDecoration(
                            border: isSelected
                                ? Border.all(
                                    color: const Color(0xFFE64A19),
                                    width: 2,
                                  ) // สีส้ม
                                : Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Image.network(
                              widget.imageUrls[index],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Mobile Layout ---
  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            color: Colors.grey[100], // พื้นหลังเทาอ่อนเหมือนกัน
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) => setState(() => _selectedIndex = index),
              itemBuilder: (context, index) =>
                  Image.network(widget.imageUrls[index], fit: BoxFit.contain),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.imageUrls.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _changeImage(index),
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: _selectedIndex == index
                          ? Border.all(color: const Color(0xFFE64A19), width: 2)
                          : null,
                    ),
                    child: Image.network(
                      widget.imageUrls[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
