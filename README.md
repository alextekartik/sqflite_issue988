# sqflite_issue988

Experiment for https://github.com/tekartik/sqflite/issues/988: a long update
on one table should not block a short select on another table.

The app uses `sqflite_common_ffi` (`databaseFactory = databaseFactoryFfi` in
`lib/main.dart`, desktop: Linux, macOS, Windows), a database in WAL mode
(`PRAGMA journal_mode=WAL`) and a second read-only connection
(`singleInstance: false`) for the select.

You'll have to create the flutter project (platform folders are not checked
in):

```
flutter create .
flutter run -d linux
```

Then:

1. *Open DB*: creates 10 000 000 users the first time (progress in the logs).
2. *Short select query*: a few ms.
3. *Long update query* then *Short select query* right away: compare the
   select time (in the logs) with step 2; in the issue, the select waited
   for the end of the update.
