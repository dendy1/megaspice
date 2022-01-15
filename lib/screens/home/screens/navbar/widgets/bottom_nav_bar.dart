import 'package:flutter/material.dart';
import 'package:megaspice/screens/home/screens/navbar/cubit/NavBarCubit.dart';

class CustomBottomNavBar extends StatelessWidget {
  final Map<NavBarItem, IconData> items;
  final NavBarItem selectedItem;
  final Function(int) onTap;

  const CustomBottomNavBar({
    required this.items,
    required this.selectedItem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        onTap: onTap,
        backgroundColor: Colors.white,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: NavBarItem.values.indexOf(selectedItem),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: items
            .map((item, icon) {
              return MapEntry(
                item,
                BottomNavigationBarItem(
                  icon: Icon(icon, size: 40.0),
                  label: item.toString(),
                  tooltip: item.toString(),
                ),
              );
            })
            .values
            .toList());
  }
}
