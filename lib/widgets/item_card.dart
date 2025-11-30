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
            // --- 1. รูปภาพ (Square 1:1) ---
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
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // กระจายเนื้อหา
                  children: [
                    // ส่วนบน: ชื่อ + สถานที่ + ราคา
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ชื่อสินค้า/งาน
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        // สถานที่ (ถ้ามี)
                        if (location.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 12,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  location,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 4),
                        // ราคา
                        Text(
                          price.contains('฿') ? price : '฿$price',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),

                    // ส่วนล่าง: ข้อมูลผู้โพสต์
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.only(top: 8),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.black12)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 10, // ขนาดรูปโปรไฟล์
                            backgroundImage: NetworkImage(
                              authorAvatar.isNotEmpty
                                  ? authorAvatar
                                  : 'https://cdn-icons-png.flaticon.com/512/149/149071.png',
                            ),
                            onBackgroundImageError: (_, __) {},
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              authorName.isNotEmpty
                                  ? authorName
                                  : 'ไม่ระบุตัวตน',
                              style: const TextStyle(
                                fontSize: 11, // ขนาดตัวหนังสือชื่อคน
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
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
