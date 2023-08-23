import 'package:auto_reply_sync/auto_reply_sync.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String fileName = "autoReplySync";

  @override
  void initState() {
    StartAutoSync.instance;
    super.initState();
  }

  Map<String, dynamic> contents = {
    // "squadName": "Super hero squad",
    // "homeTown": "Metro City",
    // "formed": 2016,
    // "secretBase": "Super tower",
    // "active": true,
    "members": [
      {
        "name": "Molecule Man",
        "age": 29,
        "secretIdentity": "Dan Jukes",
        "powers": ["Radiation resistance", "Turning tiny", "Radiation blast"]
      },
      {
        "name": "Madame Uppercut",
        "age": 39,
        "secretIdentity": "Jane Wilson",
        "powers": [
          "Million tonne punch",
          "Damage resistance",
          "Superhuman reflexes"
        ]
      },
      // {
      //   "name": "Eternal Flame",
      //   "age": 1000000,
      //   "secretIdentity": "Unknown",
      //   "powers": [
      //     "Immortality",
      //     "Heat Immunity",
      //     "Inferno",
      //     "Teleportation",
      //     "Interdimensional travel"
      //   ]
      // }
    ]
  };

  @override
  Widget build(BuildContext context) {
    return AutoReplySubcViewer(
      autoReplySyncName: fileName,
      backgroundColor: Colors.red,
      iconColor: Colors.black,
      textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white,
          ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '101',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            BackButton(
              onPressed: () {
                setState(() {});
                StartAutoSync.setAutoSync(
                    fileName: fileName, contents: contents);
              },
            )
          ],
        ),
      ),
    );
  }
}
