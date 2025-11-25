// lib/models/mock_data.dart

// 1. Model สำหรับงานจ้าง (Job Posting)
class Job {
  final String id;
  final String title; // หัวข้อโพสต์
  final String description; // รายละเอียด
  final String price; // ราคาว่าจ้าง
  final String location; // สถานที่
  final String imageUrl; // รูปประกอบ
  final String type; // ประเภท (เผื่ออนาคต)

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.imageUrl,
    this.type = 'job',
  });
}

// 2. Model สำหรับฟรีแลนซ์/คนรับงาน (Freelancer Profile)
class Freelancer {
  final String id;
  final String name; // ชื่อเล่นหรือนามแฝง
  final String skill; // ความถนัดหลัก
  final double rating; // คะแนนดาว (0.0 - 5.0)
  final String startingPrice; // ราคาเริ่มต้น
  final String imageUrl; // รูปโปรไฟล์
  final String bio; // คำแนะนำตัว
  final String type;

  Freelancer({
    required this.id,
    required this.name,
    required this.skill,
    required this.rating,
    required this.startingPrice,
    required this.imageUrl,
    required this.bio,
    this.type = 'person',
  });
}

// --- Mock Data (ข้อมูลจำลอง) ---

// รายการงานจ้าง (เน้นหมวดอาหารและงานทั่วไป)
List<Job> mockJobs = [
  Job(
    id: 'j1',
    title: 'ฝากซื้อข้าวมันไก่ ร้านป้าแดง',
    description: 'เอาเนื้อน่อง ไม่หนัง 2 ห่อ ส่งที่หอพักชาย 3 รอหน้าตึกครับ',
    price: 'ค่าหิ้ว 20 บาท',
    location: 'หอพักชาย 3',
    imageUrl:
        'https://images.pexels.com/photos/616354/pexels-photo-616354.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  Job(
    id: 'j2',
    title: 'ช่วยขนของย้ายหอ',
    description:
        'ของไม่เยอะมาก มีตู้เย็นเล็ก 1 ใบ กับกล่องหนังสือ ต้องการคนช่วยยกวันเสาร์นี้',
    price: '300 บาท',
    location: 'หอ City Park',
    imageUrl:
        'https://images.pexels.com/photos/4246202/pexels-photo-4246202.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  Job(
    id: 'j3',
    title: 'หาคนจองโต๊ะร้านหมูกระทะ',
    description: 'ร้านดังหลังมอ ไปจองโต๊ะให้หน่อยช่วง 6 โมงเย็น เดี๋ยวตามไป',
    price: '50 บาท',
    location: 'ร้านหมูกระทะหลังมอ',
    imageUrl:
        'https://images.pexels.com/photos/5774154/pexels-photo-5774154.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  Job(
    id: 'j4',
    title: 'ตามหาชีสเรียนวิชา GenEd',
    description: 'ใครเรียนเทอมที่แล้ว ขอยืมถ่ายเอกสารหรือซื้อต่อครับ',
    price: '100 บาท',
    location: 'ตึกเรียนรวม',
    imageUrl:
        'https://images.pexels.com/photos/3059747/pexels-photo-3059747.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
];

// รายการยอดฝีมือ (Freelancers)
List<Freelancer> mockFreelancers = [
  Freelancer(
    id: 'f1',
    name: 'น้องเอ รับหิ้ว (โซนหอใน)',
    skill: 'Delivery / รับหิ้วของ',
    rating: 4.8,
    startingPrice: 'เริ่ม 10 บ.',
    imageUrl:
        'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=400',
    bio: 'วิ่งงานทุกวันเย็นๆ ครับ ฝากเซเว่น ฝากร้านข้าวในมอ ทักได้ตลอด',
  ),
  Freelancer(
    id: 'f2',
    name: 'พี่บี ติวเตอร์',
    skill: 'ติวแคลคูลัส / ฟิสิกส์',
    rating: 5.0,
    startingPrice: '200 บ./ชม.',
    imageUrl:
        'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=400',
    bio: 'เกรด A แคล 1-2 สอนเข้าใจง่าย มีชีสสรุปให้',
  ),
  Freelancer(
    id: 'f3',
    name: 'ซี ดีไซน์',
    skill: 'ออกแบบโปสเตอร์ / Canva',
    rating: 4.5,
    startingPrice: 'เริ่ม 150 บ.',
    imageUrl:
        'https://images.pexels.com/photos/733872/pexels-photo-733872.jpeg?auto=compress&cs=tinysrgb&w=400',
    bio: 'รับทำปกรายงาน โปสเตอร์กิจกรรม งานด่วนรับได้ครับ',
  ),
  Freelancer(
    id: 'f4',
    name: 'ช่างภาพ โดม',
    skill: 'ถ่ายรูปรับปริญญา / โปรไฟล์',
    rating: 4.9,
    startingPrice: '500 บ.',
    imageUrl:
        'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=400',
    bio: 'กล้อง Sony ตัวท็อป แต่งรูปสวย มู้ดดี ทักมาขอดูพอร์ตได้',
  ),
];
