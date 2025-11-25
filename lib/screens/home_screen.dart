import 'package:flutter/material.dart';
import '../models/job_model.dart'; // นำเข้า Model ที่เราสร้างไว้

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ส่วนหัวของแอป (App Bar)
      appBar: AppBar(
        title: const Text(
          'UniJobs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2, // ใส่เงาเล็กน้อย
      ),
      // ส่วนเนื้อหาหลัก
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0), // เว้นขอบรอบๆ 16 พิกเซล
        itemCount: mockJobs.length, // จำนวนรายการเท่ากับข้อมูลใน mockJobs
        itemBuilder: (context, index) {
          final job = mockJobs[index]; // ดึงข้อมูลงานทีละชิ้น

          return Card(
            margin: const EdgeInsets.only(
              bottom: 16.0,
            ), // เว้นระยะห่างระหว่างการ์ด
            elevation: 2, // ความลึกของเงา (Material 3 style)
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // ขอบมน
            ),
            clipBehavior: Clip.antiAlias, // ตัดขอบรูปภาพให้มนตามการ์ด
            child: InkWell(
              onTap: () {
                // พื้นที่สำหรับเขียนโค้ดเมื่อกดที่การ์ด (เช่น ไปหน้ารายละเอียด)
                print('Clicked on ${job.title}');
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. ส่วนรูปภาพทางซ้าย
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Image.network(
                      job.imageUrl,
                      fit: BoxFit.cover, // ขยายรูปให้เต็มพื้นที่
                      errorBuilder: (context, error, stackTrace) {
                        // กรณีโหลดรูปไม่ได้ ให้แสดงไอคอนแทน
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),

                  // 2. ส่วนข้อความทางขวา
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ชื่องาน (ตัวหนา)
                          Text(
                            job.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary, // สีส้มตามธีม
                                ),
                            maxLines: 2, // แสดงได้สูงสุด 2 บรรทัด
                            overflow:
                                TextOverflow.ellipsis, // ถ้าเกินให้แสดง ...
                          ),
                          const SizedBox(height: 8),

                          // สถานที่ (ใช้ Row ใส่ไอคอนเล็กๆ)
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  job.location,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // ราคา/ค่าตอบแทน
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer, // สีพื้นหลังอ่อนๆ
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              job.price,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
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
        },
      ),
    );
  }
}
