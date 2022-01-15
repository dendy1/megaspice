import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:megaspice/screens/home/screens/navbar/cubit/NavBarCubit.dart';

import 'widgets/widgets.dart';

class NavBar extends StatelessWidget {
  static const String routeName = "/navbar";

  static Route route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: NavBar.routeName),
      builder: (context) => BlocProvider<NavBarCubit>(
        create: (context) => NavBarCubit(),
        child: NavBar(),
      ),
    );
  }

  final Map<NavBarItem, GlobalKey<NavigatorState>> navigatorKeys = {
    NavBarItem.feed: GlobalKey<NavigatorState>(),
    NavBarItem.create: GlobalKey<NavigatorState>(),
    NavBarItem.profile: GlobalKey<NavigatorState>(),
  };

  final Map<NavBarItem, IconData> items = {
    NavBarItem.feed: Icons.home_outlined,
    NavBarItem.create: Icons.add_box_outlined,
    NavBarItem.profile: Icons.account_circle_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavBarCubit, NavBarState>(builder: (context, state) {
      return Scaffold(
        body: Stack(
          children: items
              .map((item, _) => MapEntry(item,
                  _buildOffstageNavigator(item, item == state.selectedItem)))
              .values
              .toList(),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          items: items,
          onTap: (index) {
            final selectedItem = NavBarItem.values[index];
            _selectedBottomNavItem(
                context, selectedItem, selectedItem == state.selectedItem);
          },
          selectedItem: state.selectedItem,
        ),
      );
    });
  }

  void _selectedBottomNavItem(
      BuildContext context, NavBarItem selectedItem, bool isSameItem) {
    if (isSameItem) {
      navigatorKeys[selectedItem]!
          .currentState!
          .popUntil((route) => route.isFirst);
    }
    context.read<NavBarCubit>().updateSelectedItem(selectedItem);
  }

  Widget _buildOffstageNavigator(NavBarItem currentItem, bool isSelected) {
    return Offstage(
      offstage: !isSelected,
      child: TabNavigator(
        navigatorKey: navigatorKeys[currentItem]!,
        item: currentItem,
      ),
    );
  }
}
