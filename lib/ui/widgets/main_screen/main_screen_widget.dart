import 'package:flutter/material.dart';
import 'package:movie_list/domain/data_providers/session_data_provider.dart';
import 'package:movie_list/domain/factories/screen_factory.dart';

class MainScreenWidget extends StatefulWidget {
  const MainScreenWidget({super.key});

  @override
  State<MainScreenWidget> createState() => _MainScreenWidgetState();
}

class _MainScreenWidgetState extends State<MainScreenWidget> {
  int _selectedTab = 0;

  final _screenFactory = ScreenFactory();

  void onSelectedTab(int index) {
    if (_selectedTab == index) {
      return;
    } else {
      setState(() {
        _selectedTab = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TMDB'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(
              onPressed: SessionDataProvider().deleteSessionId, 
              icon: const Icon(Icons.exit_to_app),
              ),
          )
        ],
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: onSelectedTab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Новини'),
          BottomNavigationBarItem(
              icon: Icon(Icons.movie_filter), label: 'Фільми'),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'Серіали'),
        ],
      ),
      body: IndexedStack( // всі дочірні віджети існюють одночасно і зберігають state
        index: _selectedTab,
        children: [
          const Text('Новини'),
          _screenFactory.makeMovieList(),
          const Text('Серіали'),
        ],
      ),
    );
  }
}
