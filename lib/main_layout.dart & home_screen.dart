import 'package:flutter/material.dart';

// هذا الـ Widget يمثل الهيكل الأساسي مع الشريط السفلي
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // قائمة الشاشات (للتنقل)
  final List<Widget> _screens = [
    const HomeScreen(),
    const Center(child: Text('My Courses Screen')), // Placeholder
    const Center(child: Text('Schedule Screen')),   // Placeholder
    const Center(child: Text('Profile Screen')),    // Placeholder
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // زر الـ QR العائم في المنتصف
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // هنا تفتح شاشة الكاميرا (السيناريو 4)
          showDialog(
            context: context,
            builder: (ctx) => const AlertDialog(title: Text("Open QR Scanner")),
          );
        },
        backgroundColor: const Color(0xFFFF6F61), // Coral Color
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // الشريط السفلي
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, "Home", 0),
            _buildNavItem(Icons.book, "Courses", 1),
            const SizedBox(width: 40), // مسافة للزر العائم
            _buildNavItem(Icons.calendar_today, "Schedule", 2),
            _buildNavItem(Icons.person, "Profile", 3),
          ],
        ),
      ),
      body: _screens[_currentIndex],
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? const Color(0xFF3F51B5) : Colors.grey,
      ),
      onPressed: () => setState(() => _currentIndex = index),
      tooltip: label,
    );
  }
}

// ---------------------------------------------------------
// تصميم الشاشة الرئيسية (الداشبورد)
// ---------------------------------------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'), // صورة تخيلية
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Welcome Back,", style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text("Ahmed Ali", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Next Session Card (أهم عنصر في التصميم)
            const Text("Next Session", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text("Flutter Course", style: TextStyle(color: Colors.white)),
                      ),
                      const Text("10:00 AM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text("Mobile App Development",
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  const Text("Lab 3 • Instructor: Eng. Sarah", style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF3F51B5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Check In Now"),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Quick Stats (الإحصائيات)
            Row(
              children: [
                _buildStatCard("Attendance", "85%", Colors.green),
                const SizedBox(width: 12),
                _buildStatCard("Assignments", "12", Colors.orange),
                const SizedBox(width: 12),
                _buildStatCard("Due Fees", "500 LE", Colors.redAccent),
              ],
            ),

            const SizedBox(height: 24),

            // 3. Today's Classes List
            const Text("Today's Schedule", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildClassTile("Database Systems", "12:30 PM", "Hall A", true),
            _buildClassTile("Soft Skills", "02:00 PM", "Room 102", false),
          ],
        ),
      ),
    );
  }

  // Widget مساعد لبناء كروت الإحصائيات
  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // Widget مساعد لبناء قائمة المحاضرات
  Widget _buildClassTile(String title, String time, String location, bool isLive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF3F51B5).withAlpha(10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.class_, color: Color(0xFF3F51B5)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("$time • $location", style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          if (isLive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: const Text("LIVE", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}