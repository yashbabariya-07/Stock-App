import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabTapped;
  const CustomBottomNavigationBar({
    required this.selectedIndex,
    required this.onTabTapped,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      child: BottomAppBar(
        color: Color(0xFFf5f7f9),
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomNavItem(Icons.home, 'Home', 1, selectedIndex),
            SizedBox(
              width: 10,
            ),
            _buildBottomNavItem(
                Icons.insert_chart_outlined_sharp, 'Stock', 2, selectedIndex),
            SizedBox(
              width: 10,
            ),
            _buildBottomNavItem(
                Icons.shop_2_rounded, 'My Share', 3, selectedIndex),
            SizedBox(
              width: 10,
            ),
            _buildBottomNavItem(
                Icons.person_2_sharp, 'Profile', 4, selectedIndex),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
      IconData icon, String label, int index, int selectedIndex) {
    return GestureDetector(
      onTap: () => onTabTapped(index),
      child: Column(
        children: [
          Icon(icon,
              color: selectedIndex == index
                  ? Colors.black
                  : const Color.fromARGB(255, 103, 103, 103)),
          Text(
            label,
            style: TextStyle(
                color: selectedIndex == index
                    ? Colors.black
                    : const Color.fromARGB(255, 103, 103, 103),
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
                fontSize: 12),
          ),
        ],
      ),
    );
  }
}
