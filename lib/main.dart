

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'word_data.dart';

void main() {
  runApp(const DictionaryApp());
}

// ASOSIY ILOVA
class DictionaryApp extends StatefulWidget {
  const DictionaryApp({super.key});

  @override
  State<DictionaryApp> createState() => _DictionaryAppState();
}

class _DictionaryAppState extends State<DictionaryApp> {
  bool tungiRejim = false;

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  // Tungi rejimni yuklash
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      tungiRejim = prefs.getBool('darkMode') ?? false;
    });
  }

  // Tungi rejimni almashtirish
  Future<void> rejimAlmashtir() async {
    final prefs = await SharedPreferences.getInstance();

    final newMode = !tungiRejim;

    await prefs.setBool('darkMode', newMode);

    setState(() {
      tungiRejim = newMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'English Dictionary',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.dark,
        ),
      ),

      themeMode: tungiRejim ? ThemeMode.dark : ThemeMode.light,

      home: DictionaryHome(
        tungiRejim: tungiRejim,
        onThemeChanged: rejimAlmashtir,
      ),
    );
  }
}

// LUG'AT OYNASI
class DictionaryHome extends StatefulWidget {
  final bool tungiRejim;
  final VoidCallback onThemeChanged;

  const DictionaryHome({
    super.key,
    required this.tungiRejim,
    required this.onThemeChanged,
  });

  @override
  State<DictionaryHome> createState() => _DictionaryHomeState();
}

class _DictionaryHomeState extends State<DictionaryHome> {
  final TextEditingController searchController =
      TextEditingController();

  Set<String> favorites = {};

  int selectedIndex = 0;

  String searchText = '';

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  // Sevimli so'zlarni yuklash
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      favorites = (prefs.getStringList('favorites') ?? []).toSet();
    });
  }

  // Sevimlilarga qo'shish va o'chirish
  Future<void> toggleFavorite(String word) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (favorites.contains(word)) {
        favorites.remove(word);
      } else {
        favorites.add(word);
      }
    });

    await prefs.setStringList(
      'favorites',
      favorites.toList(),
    );
  }

  // Qidiruv va saralash
  List<Word> get filteredWords {
    List<Word> result = wordList;

    if (selectedIndex == 1) {
      result = result
          .where((word) => favorites.contains(word.english))
          .toList();
    }

    if (searchText.isNotEmpty) {
      result = result.where((word) {
        return word.english.toLowerCase().contains(
              searchText.toLowerCase(),
            ) ||
            word.uzbek.toLowerCase().contains(
              searchText.toLowerCase(),
            );
      }).toList();
    }

    return result;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final words = filteredWords;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.menu_book_rounded),
            SizedBox(width: 10),
            Text(
              'English Dictionary',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: widget.onThemeChanged,
            icon: Icon(
              widget.tungiRejim
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            tooltip: 'Tungi rejim',
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Column(
        children: [
          // Yuqoridagi ma'lumot
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ingliz tilini o‘rganing!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Yangi so‘zlarni o‘rganing va lug‘at boyligingizni oshiring.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'Jami so‘zlar: ${wordList.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Qidiruv maydoni
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Inglizcha yoki o‘zbekcha qidiring...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchText.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchText = '';
                          });
                        },
                        icon: const Icon(Icons.close),
                      )
                    : null,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // So'zlar soni
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedIndex == 0
                      ? 'Barcha so‘zlar'
                      : 'Sevimli so‘zlar',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${words.length} ta so‘z',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // So'zlar ro'yxati
          Expanded(
            child: words.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 65,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          selectedIndex == 1
                              ? 'Sevimli so‘zlar mavjud emas'
                              : 'So‘z topilmadi',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 5,
                    ),
                    itemCount: words.length,
                    itemBuilder: (context, index) {
                      final word = words[index];

                      final isFavorite =
                          favorites.contains(word.english);

                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 7,
                          ),

                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: Icon(
                              Icons.translate,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary,
                            ),
                          ),

                          title: Text(
                            word.english,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),

                          subtitle: Text(
                            word.uzbek,
                            style: const TextStyle(fontSize: 15),
                          ),

                          trailing: IconButton(
                            onPressed: () {
                              toggleFavorite(word.english);
                            },
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),

                          onTap: () {
                            showWordDetails(word);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // Pastki menyu
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
            searchText = '';
            searchController.clear();
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Lug‘at',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Sevimlilar',
          ),
        ],
      ),
    );
  }

  // So'z haqida batafsil ma'lumot
  void showWordDetails(Word word) {

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            final currentFavorite =
                favorites.contains(word.english);

            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.translate,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Center(
                    child: Text(
                      word.english,
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Center(
                    child: Text(
                      word.uzbek,
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const Divider(height: 30),

                  const Text(
                    'Izoh:',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    word.description,
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Misol:',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    word.example,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        await toggleFavorite(word.english);
                        modalSetState(() {});
                      },
                      icon: Icon(
                        currentFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      label: Text(
                        currentFavorite
                            ? 'Sevimlilardan olib tashlash'
                            : 'Sevimlilarga qo‘shish',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
