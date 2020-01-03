import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'models/Message.dart';

// database table and column names
// Table - Message
final String tableMessages = 'messages';
final String columnId = '_id';
final String columnMessage = 'message';
final String columnTime = 'message_time';
final String columnDelivered = 'delivered';
final String columnIsMe = 'is_me';
final String columnFormat = 'format';
final String columnIsLocalFile = 'is_local_file';

// Table - Cards
final String tableCards = 'cards';
final String columnCardId = 'card_id';
final String columnMessageId = 'message_id';
final String columnCardTitle = 'card_title';
final String columnCardText = 'card_text';
final String columnCardImage = 'card_image';
final String columnCardActions = 'card_actions';

final String cardCreateQuery = ''' 
                                CREATE TABLE $tableCards (
                                          \"$columnCardId\" INTEGER PRIMARY KEY,
                                          \"$columnMessageId\" INTEGER PRIMARY KEY,
                                          \"$columnCardTitle\" TEXT NOT NULL,
                                          \"$columnCardText\" TEXT NULL,
                                          \"$columnCardImage\" TEXT NULL,
                                          \"$columnCardActions\" TEXT NULL,
                                        )
                                ''';

// singleton class to manage the database
class DatabaseHelper {
  // This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "YMDB.db";
  // Increment this version when you need to change the schema.
  static final _databaseVersion = 1;

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    print(path);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
            version: _databaseVersion, onCreate: _onCreate)
        .catchError((onError) {
      print(onError);
    });
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    var query = '''
        CREATE TABLE $tableMessages ( 
          \"$columnId\" INTEGER PRIMARY KEY,
          \"$columnMessage\" TEXT NOT NULL,
          \"$columnTime\" TEXT NOT NULL,
          \"$columnDelivered\" INTEGER NOT NULL,
          \"$columnIsMe\" INTEGER NOT NULL,
          \"$columnFormat\" TEXT NOT NULL,
          \"$columnIsLocalFile\" INTEGER NOT NULL
          )
        ''';
    print(query);
    await db.execute(query).catchError((error) {
      print(error);
    });
  }

  // Database helper methods:

  Future<int> insertMessage(Message message) async {
    Database db = await database;
    int id = await db.insert(tableMessages, message.toMap());
    return id;
  }

  Future<List<Message>> queryMessage(int id) async {
    Database db = await database;
    List<Message> messages = [];
    List<Map> maps =
        await db.query(tableMessages, columns: [], orderBy: columnTime);

    if (maps.length > 0) {
      print(maps.first);
      for (var map in maps) {
        messages.add(Message.fromMap(map));
      }
      return messages;
    }
    return null;
  }

  Future clearTable() async {
    Database db = await database;
    String query = "DELETE FROM $tableMessages; VACUUM;";
    await db.execute(query).catchError((error) {
      print(error);
    });
  }
}
