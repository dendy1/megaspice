part of 'NavBarCubit.dart';

class NavBarState extends Equatable {
  final NavBarItem selectedItem;
  const NavBarState({required this.selectedItem});

  @override
  List<Object> get props => [selectedItem];
}