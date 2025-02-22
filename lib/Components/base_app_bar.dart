import 'package:flood_mobile/Constants/theme_provider.dart';
import 'package:flood_mobile/Provider/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBar appBar;
  final int index;
  const BaseAppBar({
    Key? key,
    required this.appBar,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context, homeModel, child) {
      return AppBar(
        key: Key('AppBar Key'),
        title: Image(
          key: Key('App icon key'),
          image: AssetImage(
            'assets/images/icon.png',
          ),
          width: 60,
          height: 60,
        ),
        centerTitle: true,
        backgroundColor: ThemeProvider.theme(index).primaryColor,
        elevation: 0,
      );
    });
  }

  @override
  Size get preferredSize => new Size.fromHeight(appBar.preferredSize.height);
}
