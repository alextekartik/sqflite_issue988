import 'dart:io';

import 'package:faker/faker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';
import 'package:sqflite_common/utils/utils.dart';
import 'package:path_provider/path_provider.dart';

class FakeDB {
  static int maxNumberOfItem = 10000000;
  static int batchInsertSteps =
      20000; // just to prevent crash on too big insert batch
  static Database? database;
  static Database? databaseReadOnly;

  FakeDB();

  Future<String> getPath() async {
    final String databasesPath = (await getApplicationSupportDirectory()).path;
    await Directory(databasesPath).create(recursive: true);
    return join(databasesPath, 'test.db');
  }

  Future<void> openDB() async {
    // open the database
    if (database != null) {
      print("Database already opened");
    }
    var path = await getPath();
    database = await openDatabase(
      path,
      version: 1,
      onConfigure: (Database db) async {
        await db.execute('PRAGMA journal_mode=WAL');
      },
      onCreate: (Database db, int version) async {
        final Batch batch = db.batch();
        batch.execute(
          "CREATE TABLE users ("
          "id INTEGER PRIMARY KEY, "
          "firstname TEXT NOT NULL, "
          "lastname TEXT NOT NULL, "
          "email TEXT NOT NULL, "
          "last_connection INTEGER NOT NULL"
          ");",
        );

        batch.execute(
          "CREATE TABLE sports ("
          "id INTEGER PRIMARY KEY, "
          "name TEXT NOT NULL"
          ");",
        );
        await batch.commit();
      },
    );

    // Open a second instance for read access.
    databaseReadOnly =
        await openDatabase(path, readOnly: true, singleInstance: false);
    print("DB CREATED !");

    print("DB creating fake data...");

    // Don't create if already created
    if (firstIntValue(await database!.rawQuery("SELECT COUNT(*) FROM users")) ==
        0) {
      Batch batch = database!.batch();

      int batchLenght = 0;
      for (int index = 0; index < maxNumberOfItem; ++index) {
        final Faker fake = Faker();
        batch.insert(
          "users",
          <String, dynamic>{
            "id": index,
            "firstname": fake.person.firstName(),
            "lastname": fake.person.lastName(),
            "email": fake.internet.email(),
            "last_connection": 0,
          },
        );
        if (batchLenght > batchInsertSteps) {
          print("current-index: $index");
          await batch.commit(noResult: true);
          batch = database!.batch();
          batchLenght = 0;
        } else {
          ++batchLenght;
        }
      }

      batch.insert(
        "sports",
        <String, dynamic>{
          "id": 0,
          "name": "football",
        },
      );

      print(batch.length);
      await batch.commit();
      print("DB WITH FAKE DATA PROCESSED");
    }
  }

  Future<void> deleteDB() async {
    await database?.close();
    database = null;
    await File(await getPath()).delete();
    print("DB DELETED");
  }

  Future<void> doLongUpdate() async {
    final Stopwatch watch = Stopwatch()..start();
    print("LONG UPDATE START");
    final Batch batch = database!.batch();
    batch.update(
      "users",
      <String, dynamic>{
        "last_connection": DateTime.now().millisecondsSinceEpoch,
      },
      where: "id between 1 and $maxNumberOfItem",
    );
    await batch.commit(noResult: true);
    watch.stop();
    print("LONG UPDATE DONE: ${watch.elapsedMilliseconds}");
  }

  Future<List<Map<String, Object?>>> doShortSelect() async {
    final Stopwatch watch = Stopwatch()..start();

    print("SHORT SELECT START");
    final List<Map<String, Object?>> result = await databaseReadOnly!.query(
      "sports",
      limit: 1,
    );
    watch.stop();
    print("SHORT SELECT DONE: ${watch.elapsedMilliseconds}");
    return result;
  }
}
