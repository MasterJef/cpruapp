import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String title;
  final String price;
  final String imageUrl;
  final VoidCallback onTap;

  final String location;
  final String authorName;
  final String authorAvatar;
  final String? tagText;
  final String? footerText;

  const ItemCard({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.onTap,
    this.location = '',
    this.authorName = '',
    this.authorAvatar = '',
    this.tagText,
    this.footerText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. รูปภาพ ---
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  if (tagText != null && tagText!.isNotEmpty)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tagText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // --- 2. ข้อมูล ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          price.contains('฿') ? price : '฿$price',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // ส่วนผู้โพสต์ / Location
                        Row(
                          children: [
                            if (authorAvatar.isNotEmpty) ...[
                              CircleAvatar(
                                radius: 10, // ✅ เพิ่มขนาดรูป
                                backgroundImage: NetworkImage(authorAvatar),
                                onBackgroundImageError: (_, __) {},
                              ),
                              const SizedBox(width: 6),
                            ] else if (location.isNotEmpty) ...[
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                            ],

                            Expanded(
                              child: Text(
                                // ถ้ามี footerText (เช่น ชื่อคนขาย) ให้โชว์ก่อน ถ้าไม่มีให้โชว์ location
                                (footerText != null && footerText!.isNotEmpty)
                                    ? footerText!
                                    : (location.isNotEmpty
                                          ? location
                                          : authorName),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ), // ✅ เพิ่มขนาดตัวหนังสือ
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
    );
  }
}
