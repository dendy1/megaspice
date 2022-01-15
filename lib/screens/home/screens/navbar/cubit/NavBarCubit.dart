import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'NavBarState.dart';

part 'NavBarItem.dart';

class NavBarCubit extends Cubit<NavBarState> {
  NavBarCubit()
      : super(NavBarState(
          selectedItem: NavBarItem.feed,
        ));

  void updateSelectedItem(NavBarItem item) {
    if (item != state.selectedItem) {
      emit(NavBarState(selectedItem: item));
    }
  }
}
