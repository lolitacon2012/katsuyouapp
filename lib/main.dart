import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_app/data/constants.dart';
import 'package:my_app/service/generate_word.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(DoushiKatsuyou());
}

class DoushiKatsuyou extends StatelessWidget {
  const DoushiKatsuyou({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GlobalState(),
      child: MaterialApp(
        title: 'Katsuyou Renshuu',
        theme: ThemeData(
          fontFamily: 'KleeOne',
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.tealAccent),
        ),
        home: HomePage(),
      ),
    );
  }
}

class GlobalState extends ChangeNotifier {
  static const defaultSelectedKatsuyous = [
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11
  ];
  var selectedKatsuyous = defaultSelectedKatsuyous;
  var current = generateRandomWord(defaultSelectedKatsuyous);
  var answerShown = false;

  GlobalState() {
    try {
      _loadSettings();
    } catch (e) {
      print('Failed to load settings. Perhaps user is using web browser.');
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final readFromPreviousSettings =
        prefs.getStringList('katsuyou_settings') ?? [];
    if (readFromPreviousSettings.isEmpty) {
      selectedKatsuyous = defaultSelectedKatsuyous;
    } else {
      selectedKatsuyous = readFromPreviousSettings
          .map((e) => int.parse(e))
          .where((e) => e < katsuyouName.length)
          .toList();
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('katsuyou_settings',
        selectedKatsuyous.map((e) => e.toString()).toList());
  }

  void getNextStep() {
    if (!answerShown) {
      answerShown = true;
    } else {
      current = generateRandomWord(selectedKatsuyous);
      answerShown = false;
    }
    notifyListeners();
  }

  void reset() {
    current = generateRandomWord(selectedKatsuyous);
    answerShown = false;
    notifyListeners();
  }

  void setSelectedKatsuyous(List<int> katsuyou) {
    selectedKatsuyous = katsuyou;
    notifyListeners();
    _saveSettings();
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              selectedIndex = index;
            });
          },
          selectedIndex: selectedIndex,
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.book),
              label: '練習',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: '設置',
            ),
          ],
        ),
        body: [
          Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: LearnPage(),
          ),
          Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: SettingsPage(),
          )
        ][selectedIndex],
      );
    });
  }
}

class LearnPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<GlobalState>();
    var wordToLearn = appState.current;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FromWordCard(wordToLearn: wordToLearn),
          Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'の「${wordToLearn.toType}」は',
                style: TextStyle(fontSize: 24),
              )),
          ToWordCard(wordToLearn: wordToLearn, shown: appState.answerShown),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                  onPressed: () {
                    appState.getNextStep();
                  },
                  child: Text(appState.answerShown ? '次へ' : '答え')),
            ],
          )
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<GlobalState>();
    var selectedKatsuyous = appState.selectedKatsuyous;
    return Container(
        color: Colors.white,
        padding: EdgeInsets.all(12),
        child: SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: katsuyouName.map((k) {
                    var isSelected =
                        selectedKatsuyous.contains(katsuyouName.indexOf(k));
                    var canNotToggleOff = selectedKatsuyous.length <= 2;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(k),
                        Switch(
                            value: isSelected,
                            onChanged: (canNotToggleOff && isSelected)
                                ? null
                                : ((v) {
                                    if (!v) {
                                      appState.setSelectedKatsuyous(
                                          selectedKatsuyous
                                              .where((element) =>
                                                  element !=
                                                  katsuyouName.indexOf(k))
                                              .toList());
                                    } else {
                                      appState.setSelectedKatsuyous([
                                        ...selectedKatsuyous,
                                        katsuyouName.indexOf(k)
                                      ]);
                                    }
                                    appState.reset();
                                  }))
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ));
  }
}

class FromWordCard extends StatelessWidget {
  const FromWordCard({
    super.key,
    required this.wordToLearn,
  });

  final WordToLearn wordToLearn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Text(
          wordToLearn.fromWord,
          style: style,
          semanticsLabel: wordToLearn.fromWord,
        ),
      ),
    );
  }
}

class ToWordCard extends StatelessWidget {
  const ToWordCard({
    super.key,
    required this.wordToLearn,
    required this.shown,
  });

  final WordToLearn wordToLearn;
  final bool shown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onSecondary.withOpacity(shown ? 1 : 0),
    );
    return Card(
      color: theme.colorScheme.secondary,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Text(
          wordToLearn.toWord,
          style: style,
          semanticsLabel: wordToLearn.toWord,
        ),
      ),
    );
  }
}
