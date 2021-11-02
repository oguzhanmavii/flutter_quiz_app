import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: MyHomePage(
        title: 'Quiz App',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> database = new List<String>.empty();
  int index = -1, clickHint = 0;

  String correctAnswer = "";
  String suggest = "";
  Map<int?, int?> correctAnswerKey = new Map();
  Map<int?, int?> showSuggestAnswerMap =
      new Map(); //Izgara görünümü önerme durumunu tutmaktadir.
  Map<int?, bool?> showCorrectAnswerMap =
      new Map(); //Yanit tablosu görünümünün durumunu tutmaktadir.
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //Load Database
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      await addToDatabaseFromAssets();
      if (database.length > 0) {
        startGame();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.amber,
        appBar: AppBar(
          title: Center(
            child: Container(
              margin: EdgeInsets.only(left: 80),
              child: Text(
                'Quiz App',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  startGame();
                },
                icon: Icon(
                  Icons.refresh,
                  color: Colors.white,
                )),
            IconButton(
                onPressed: () {
                  if (clickHint < 3) {
                    int? hint;
                    for (var i in showCorrectAnswerMap.entries) {
                      if (i.value == false) {
                        showCorrectAnswerMap[i.key] = true;
                        hint = correctAnswerKey[i.key];
                        break;
                      }
                    }
                    var list = suggest.runes.toList();
                    for (int i = 0; i < list.length; i++) {
                      if (list[i] == hint) {
                        if (showSuggestAnswerMap[i] != 1) {
                          showSuggestAnswerMap[i] = 1;
                          break;
                        } else
                          continue;
                      }
                    }
                    setState(() {
                      clickHint++;
                    });
                  }
                },
                icon: Icon(
                  Icons.help,
                  color: Colors.white,
                )),
          ],
        ),
        body: database.length > 0
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    database.length > 0
                        ? Expanded(
                            flex: 2,
                            child: Image.asset(database[index]),
                          )
                        : Container(),
                    SizedBox(
                      height: 30,
                    ),

                    //CorrectAnswer
                    database.length > 0
                        ? Expanded(
                            flex: 2,
                            child: GridView.builder(
                              itemCount: correctAnswer.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 8),
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
                                    color: Colors.grey,
                                    child: showCorrectAnswerMap[index] == true
                                        ? Center(
                                            child: Text(
                                              '{String.fromCharCode(correctAnswerKey[index])}',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          )
                                        : Container());
                              },
                            ),
                          )
                        : Container(),
                    //Suggest List
                    database.length > 0
                        ? Expanded(
                            flex: 3,
                            child: GridView.builder(
                              itemCount: suggest.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 8),
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    // button when user choose word
                                    // If CorrectAnswer
                                    if (correctAnswer.toUpperCase().contains(
                                        suggest[index].toUpperCase())) {
                                      // show all character correct
                                      correctAnswerKey.forEach((key, value) {
                                        if (String.fromCharCode(value!)
                                                .toUpperCase() ==
                                            suggest[index].toUpperCase())
                                          setState(() {
                                            showCorrectAnswerMap[key] = true;
                                            showSuggestAnswerMap[index] =
                                                1; // check true
                                          });
                                      });
                                    }
                                    //Wrong Answer
                                    else {
                                      showSuggestAnswerMap[index] = 0;
                                    }
                                  },
                                  child: Card(
                                      color: showSuggestAnswerMap[index] == -1
                                          ? Colors.blueGrey
                                          : showSuggestAnswerMap[index] == 0
                                              ? Colors.red
                                              : Colors.green,
                                      child: Center(
                                          child: showSuggestAnswerMap[index] ==
                                                  1
                                              ? Icon(Icons.check,
                                                  color: Colors.white)
                                              : showSuggestAnswerMap[index] == 0
                                                  ? Icon(Icons.clear)
                                                  : Text(
                                                      '${suggest[index]}',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ))),
                                );
                              },
                            ),
                          )
                        : Container(),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        onPressed: showCorrectAnswerMap.values.contains(false)
                            ? null
                            : () => startGame(),
                        child: Text('NEXT'),
                      ),
                    )
                  ],
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              )); // This trailing comma makes auto-formatting nicer for build methods.
  }

  Future addToDatabaseFromAssets() async {
    //resimlerin saklandıgı dosya alanı
    final manifestContent = await DefaultAssetBundle.of(context).loadString(
        'AssetManifest.json'); // Klasorun döndürdügü içerik formatı tipi
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final imagePaths = manifestMap.keys
        .where((element) =>
            element.contains("images/")) // dosyaların tutuldugu yer
        .where((element) => element.contains(".png")) // dosyaların tipi
        .toList(); // listeleme fonksiyonu

    // refresh

    setState(() {
      database = imagePaths;
    });
  }

  void startGame() {
    // ne zaman oyun başlatılacak ve tekrardan başlatılacak
    this.correctAnswer = suggest = "";
    showSuggestAnswerMap.clear();
    showCorrectAnswerMap.clear();
    correctAnswerKey = new Map();
    var lastIndex = index;
    do {
      index = Random().nextInt(database.length - 1);
    } while (index == lastIndex);

    // after have index (logo) , we will get name of logo
    correctAnswer = database[index]
        .substring(database[index].lastIndexOf('/') + 1,
            database[index].lastIndexOf('.'))
        .toUpperCase();

    // Base on correctAnswer, we wil generate CorrectAnswerKey too
    correctAnswerKey = correctAnswer.runes.toList().asMap();
    correctAnswerKey.forEach((key, value) {
      showCorrectAnswerMap.putIfAbsent(key, () => false);
    });
    suggest = randomWithAnswer(correctAnswer)!.toUpperCase();

    var list = suggest.runes.toList();

    list.shuffle();

    list.asMap().forEach((key, value) {
      showSuggestAnswerMap.putIfAbsent(key, () => -1);
    });
    suggest = String.fromCharCodes(list);
    setState(() {});
  }

  String? randomWithAnswer(String correctAnswer) {
    const aToz = "abcdefghijklmnopqestuvwxyz";
    int originalLenght = correctAnswer.length;
    var randomText = "";

    for (int i = 0; i < originalLenght; i++) {
      randomText += aToz[Random().nextInt(aToz.length)];

      randomText = String.fromCharCodes(randomText.runes.toSet().toList());

      correctAnswer += randomText;

      return correctAnswer;
    }
  }
}
