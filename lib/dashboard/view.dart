import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ode2code/dashboard/home/view.dart';
import 'package:ode2code/dashboard/orders/view.dart';

class BottomNavbarState extends GetxController {
  RxInt currentPage = 0.obs;
}

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _controller = PageController(initialPage: 0);

  final state = Get.put(BottomNavbarState());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _controller,
          children: const [
            HomeScreen(),
            Scaffold(),
            MyOrders(),
            Scaffold(),

          ],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: Obx(
        () => DotNavigationBar(
          backgroundColor: Colors.white,
          paddingR: const EdgeInsets.all(10),
          boxShadow: const [BoxShadow(blurRadius: 1, color: Colors.grey)],
          currentIndex: state.currentPage.value,
          onTap: (tap) {
            state.currentPage.value = tap;
            _controller.animateToPage(tap,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn);
          },
          items: [
            /// Likes
            DotNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              selectedColor: Colors.orange[800],
            ),

            /// Search
            DotNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              selectedColor: Colors.orange[800],
            ),

            /// Profile
            DotNavigationBarItem(
              icon: const Icon(Icons.shopping_bag_outlined),
              selectedColor: Colors.orange[800],
            ),

            DotNavigationBarItem(
              icon: const Icon(Icons.list),
              selectedColor: Colors.orange[800],
            ),
          ],
        ),
      ),
    );
  }
}
