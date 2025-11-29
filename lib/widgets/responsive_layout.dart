// lib/widgets/responsive_layout.dart
import 'package:flutter/foundation.dart'; // สำหรับ kIsWeb
import 'package:flutter/material.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // เงื่อนไข: ถ้าเป็น Web หรือหน้าจอกว้างกว่า 600px
        if (kIsWeb || constraints.maxWidth > 800) {
          return Center(
            child: Container(
              // ล็อกความกว้างให้เหมือน Tablet/Mobile แนวตั้ง
              constraints: const BoxConstraints(maxWidth: 900),
              decoration: BoxDecoration(
                color:
                    backgroundColor ??
                    Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20), // ขอบมน
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // เงานุ่มๆ
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade200),
              ),
              // ใช้ ClipRRect เพื่อตัดขอบ Child ให้มนตาม Container
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: child,
              ),
            ),
          );
        }
        // ถ้าเป็น Mobile ปกติ ให้แสดงเต็มจอ
        return Container(
          color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
          child: child,
        );
      },
    );
  }
}
