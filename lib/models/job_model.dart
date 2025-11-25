// lib/models/job_model.dart

class Job {
  final String id;
  final String title; // ชื่องาน
  final String description; // รายละเอียดงาน
  final String price; // ค่าตอบแทน (ใช้ String เพื่อใส่หน่วยเงินได้ง่าย)
  final String location; // สถานที่ทำงาน
  final String imageUrl; // ลิงก์รูปภาพ

  // Constructor (ตัวสร้างวัตถุ)
  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.imageUrl,
  });
}

// ข้อมูลจำลอง (Mock Data) สำหรับทดสอบแสดงผล
List<Job> mockJobs = [
  Job(
    id: '1',
    title: 'สอนพิเศษคณิตศาสตร์ ประถม',
    description: 'สอนน้องประถม ป.4-6 ช่วงเย็นหลังเลิกเรียน',
    price: '300 บาท/ชม.',
    location: 'ห้องสมุดมหาวิทยาลัย',
    imageUrl:
        'https://images.pexels.com/photos/5428003/pexels-photo-5428003.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  Job(
    id: '2',
    title: 'พนักงานชงกาแฟ Part-time',
    description: 'ช่วยงานในร้านกาแฟหน้ามอ เสาร์-อาทิตย์',
    price: '50 บาท/ชม.',
    location: 'Coffee House หน้ามอ',
    imageUrl:
        'https://images.pexels.com/photos/373639/pexels-photo-373639.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  Job(
    id: '3',
    title: 'ช่วยงานเอกสาร คณะบริหาร',
    description: 'คีย์ข้อมูลและจัดเรียงเอกสารราชการ',
    price: '400 บาท/วัน',
    location: 'ตึกคณะบริหารธุรกิจ ชั้น 2',
    imageUrl:
        'https://images.pexels.com/photos/590016/pexels-photo-590016.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  Job(
    id: '4',
    title: 'ออกแบบกราฟิกโปสเตอร์',
    description: 'ทำโปสเตอร์โปรโมทงานรับน้อง (ทำที่ห้องได้)',
    price: '1,000 บาท/ชิ้น',
    location: 'Work form Home',
    imageUrl:
        'https://images.pexels.com/photos/196644/pexels-photo-196644.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  Job(
    id: '5',
    title: 'Staff งานอีเวนท์ดนตรี',
    description: 'ดูแลความเรียบร้อยหน้างาน จัดเก้าอี้',
    price: '600 บาท/วัน',
    location: 'หอประชุมใหญ่',
    imageUrl:
        'https://images.pexels.com/photos/1190297/pexels-photo-1190297.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
];
