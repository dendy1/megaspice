part of 'NavBarCubit.dart';

class NavBarState extends Equatable {
  final NavBarItem selectedItem;
  final bool show;

  const NavBarState({required this.selectedItem, this.show = true});

  NavBarState copyWith({
    NavBarItem? selectedItem,
    bool? show,
  }) {
    return NavBarState(
      selectedItem: selectedItem ?? this.selectedItem,
      show: show ?? this.show,
    );
  }

  @override
  List<Object> get props => [selectedItem, show];
}