import 'package:flutter/material.dart';

import 'fake_db.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                await FakeDB().openDB();
              },
              child: const Text(
                "Open DB",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await FakeDB().doLongUpdate();
              },
              child: const Text(
                "Long update query",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await FakeDB().doShortSelect();
              },
              child: const Text(
                "Short select query",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            const Divider(),
            ElevatedButton(
              onPressed: () async {
                await FakeDB().deleteDB();
              },
              child: const Text(
                "Delete DB",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
