import 'package:flutter/material.dart';

import './settings_screen.dart';
import '../widgets/cards.dart';

class CardsScreen extends StatelessWidget {
  static const routeName = '/cards-screen';
  // final _showOnlyFavorites = false;
  @override
  Widget build(BuildContext context) {
    print('card_screen build');
    return Scaffold(
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
              onPressed: () {
                // Scaffold.of(context).openEndDrawer();
                Navigator.of(context).pushNamed(SettingsScreen.routeName);
              },
              child: Icon(Icons.menu),
              mini: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      body: NameCards(),
      endDrawer: SettingsScreen(),
      // drawer: SettingsScreen(),
    );
  }
}
