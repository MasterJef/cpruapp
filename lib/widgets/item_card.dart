import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String title;
  final String price;
  final String imageUrl;
  final VoidCallback onTap;

  // ✅ เพิ่มตัวแปรพวกนี้เพื่อให้รับค่าได้ (ตั้งเป็น optional มีค่า default)
  final String location;
  final String authorName;
  final String authorAvatar;
  final String? tagText; // สำหรับสภาพสินค้า (มือสอง)
  final String? footerText; // สำหรับข้อความด้านล่างสุด (ถ้ามี)

  const ItemCard({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.onTap,
    this.location = '', // ✅ ค่าเริ่มต้นเป็นว่าง
    this.authorName = '', // ✅ ค่าเริ่มต้นเป็นว่าง
    this.authorAvatar = '', // ✅ ค่าเริ่มต้นเป็นว่าง
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
              aspectRatio: 1, // สี่เหลี่ยมจัตุรัส
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
                  // Tag มุมขวาบน (เช่น "มือสอง")
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
                    // ชื่อ
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // ราคา + รายละเอียด
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          price.contains('฿')
                              ? price
                              : '฿$price', // เช็คว่ามี ฿ หรือยัง
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // แสดง Location (งาน) หรือ FooterText (สินค้า)
                        if (footerText != null && footerText!.isNotEmpty)
                          Text(
                            footerText!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        else if (location.isNotEmpty)
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 10,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  location,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
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
