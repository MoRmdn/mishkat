// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FavoritesTable extends Favorites
    with TableInfo<$FavoritesTable, Favorite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _thikrIdMeta = const VerificationMeta(
    'thikrId',
  );
  @override
  late final GeneratedColumn<String> thikrId = GeneratedColumn<String>(
    'thikr_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [thikrId, addedAt, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<Favorite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('thikr_id')) {
      context.handle(
        _thikrIdMeta,
        thikrId.isAcceptableOrUnknown(data['thikr_id']!, _thikrIdMeta),
      );
    } else if (isInserting) {
      context.missing(_thikrIdMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {thikrId};
  @override
  Favorite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Favorite(
      thikrId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thikr_id'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $FavoritesTable createAlias(String alias) {
    return $FavoritesTable(attachedDatabase, alias);
  }
}

class Favorite extends DataClass implements Insertable<Favorite> {
  final String thikrId;
  final DateTime addedAt;
  final DateTime? deletedAt;
  const Favorite({
    required this.thikrId,
    required this.addedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['thikr_id'] = Variable<String>(thikrId);
    map['added_at'] = Variable<DateTime>(addedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  FavoritesCompanion toCompanion(bool nullToAbsent) {
    return FavoritesCompanion(
      thikrId: Value(thikrId),
      addedAt: Value(addedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Favorite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Favorite(
      thikrId: serializer.fromJson<String>(json['thikrId']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'thikrId': serializer.toJson<String>(thikrId),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Favorite copyWith({
    String? thikrId,
    DateTime? addedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Favorite(
    thikrId: thikrId ?? this.thikrId,
    addedAt: addedAt ?? this.addedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Favorite copyWithCompanion(FavoritesCompanion data) {
    return Favorite(
      thikrId: data.thikrId.present ? data.thikrId.value : this.thikrId,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Favorite(')
          ..write('thikrId: $thikrId, ')
          ..write('addedAt: $addedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(thikrId, addedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Favorite &&
          other.thikrId == this.thikrId &&
          other.addedAt == this.addedAt &&
          other.deletedAt == this.deletedAt);
}

class FavoritesCompanion extends UpdateCompanion<Favorite> {
  final Value<String> thikrId;
  final Value<DateTime> addedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const FavoritesCompanion({
    this.thikrId = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoritesCompanion.insert({
    required String thikrId,
    required DateTime addedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : thikrId = Value(thikrId),
       addedAt = Value(addedAt);
  static Insertable<Favorite> custom({
    Expression<String>? thikrId,
    Expression<DateTime>? addedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (thikrId != null) 'thikr_id': thikrId,
      if (addedAt != null) 'added_at': addedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoritesCompanion copyWith({
    Value<String>? thikrId,
    Value<DateTime>? addedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return FavoritesCompanion(
      thikrId: thikrId ?? this.thikrId,
      addedAt: addedAt ?? this.addedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (thikrId.present) {
      map['thikr_id'] = Variable<String>(thikrId.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesCompanion(')
          ..write('thikrId: $thikrId, ')
          ..write('addedAt: $addedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompletionsTable extends Completions
    with TableInfo<$CompletionsTable, Completion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, category, day, completedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Completion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {day, category},
  ];
  @override
  Completion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Completion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $CompletionsTable createAlias(String alias) {
    return $CompletionsTable(attachedDatabase, alias);
  }
}

class Completion extends DataClass implements Insertable<Completion> {
  final int id;
  final String category;

  /// Local calendar day as `YYYY-MM-DD`. Stored as text rather than derived
  /// from [completedAt] so day boundaries follow the user's timezone at the
  /// moment they finished, not the timezone they are in when it is read.
  final String day;
  final DateTime completedAt;
  const Completion({
    required this.id,
    required this.category,
    required this.day,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category'] = Variable<String>(category);
    map['day'] = Variable<String>(day);
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  CompletionsCompanion toCompanion(bool nullToAbsent) {
    return CompletionsCompanion(
      id: Value(id),
      category: Value(category),
      day: Value(day),
      completedAt: Value(completedAt),
    );
  }

  factory Completion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Completion(
      id: serializer.fromJson<int>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      day: serializer.fromJson<String>(json['day']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'category': serializer.toJson<String>(category),
      'day': serializer.toJson<String>(day),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  Completion copyWith({
    int? id,
    String? category,
    String? day,
    DateTime? completedAt,
  }) => Completion(
    id: id ?? this.id,
    category: category ?? this.category,
    day: day ?? this.day,
    completedAt: completedAt ?? this.completedAt,
  );
  Completion copyWithCompanion(CompletionsCompanion data) {
    return Completion(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      day: data.day.present ? data.day.value : this.day,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Completion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('day: $day, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, category, day, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Completion &&
          other.id == this.id &&
          other.category == this.category &&
          other.day == this.day &&
          other.completedAt == this.completedAt);
}

class CompletionsCompanion extends UpdateCompanion<Completion> {
  final Value<int> id;
  final Value<String> category;
  final Value<String> day;
  final Value<DateTime> completedAt;
  const CompletionsCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.day = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  CompletionsCompanion.insert({
    this.id = const Value.absent(),
    required String category,
    required String day,
    required DateTime completedAt,
  }) : category = Value(category),
       day = Value(day),
       completedAt = Value(completedAt);
  static Insertable<Completion> custom({
    Expression<int>? id,
    Expression<String>? category,
    Expression<String>? day,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (day != null) 'day': day,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  CompletionsCompanion copyWith({
    Value<int>? id,
    Value<String>? category,
    Value<String>? day,
    Value<DateTime>? completedAt,
  }) {
    return CompletionsCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      day: day ?? this.day,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompletionsCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('day: $day, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $ReaderCheckpointsTable extends ReaderCheckpoints
    with TableInfo<$ReaderCheckpointsTable, ReaderCheckpoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReaderCheckpointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionKeyMeta = const VerificationMeta(
    'sessionKey',
  );
  @override
  late final GeneratedColumn<String> sessionKey = GeneratedColumn<String>(
    'session_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snapshotMeta = const VerificationMeta(
    'snapshot',
  );
  @override
  late final GeneratedColumn<String> snapshot = GeneratedColumn<String>(
    'snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [sessionKey, snapshot];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reader_checkpoints';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReaderCheckpoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_key')) {
      context.handle(
        _sessionKeyMeta,
        sessionKey.isAcceptableOrUnknown(data['session_key']!, _sessionKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionKeyMeta);
    }
    if (data.containsKey('snapshot')) {
      context.handle(
        _snapshotMeta,
        snapshot.isAcceptableOrUnknown(data['snapshot']!, _snapshotMeta),
      );
    } else if (isInserting) {
      context.missing(_snapshotMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionKey};
  @override
  ReaderCheckpoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReaderCheckpoint(
      sessionKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_key'],
      )!,
      snapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snapshot'],
      )!,
    );
  }

  @override
  $ReaderCheckpointsTable createAlias(String alias) {
    return $ReaderCheckpointsTable(attachedDatabase, alias);
  }
}

class ReaderCheckpoint extends DataClass
    implements Insertable<ReaderCheckpoint> {
  final String sessionKey;
  final String snapshot;
  const ReaderCheckpoint({required this.sessionKey, required this.snapshot});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_key'] = Variable<String>(sessionKey);
    map['snapshot'] = Variable<String>(snapshot);
    return map;
  }

  ReaderCheckpointsCompanion toCompanion(bool nullToAbsent) {
    return ReaderCheckpointsCompanion(
      sessionKey: Value(sessionKey),
      snapshot: Value(snapshot),
    );
  }

  factory ReaderCheckpoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReaderCheckpoint(
      sessionKey: serializer.fromJson<String>(json['sessionKey']),
      snapshot: serializer.fromJson<String>(json['snapshot']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionKey': serializer.toJson<String>(sessionKey),
      'snapshot': serializer.toJson<String>(snapshot),
    };
  }

  ReaderCheckpoint copyWith({String? sessionKey, String? snapshot}) =>
      ReaderCheckpoint(
        sessionKey: sessionKey ?? this.sessionKey,
        snapshot: snapshot ?? this.snapshot,
      );
  ReaderCheckpoint copyWithCompanion(ReaderCheckpointsCompanion data) {
    return ReaderCheckpoint(
      sessionKey: data.sessionKey.present
          ? data.sessionKey.value
          : this.sessionKey,
      snapshot: data.snapshot.present ? data.snapshot.value : this.snapshot,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReaderCheckpoint(')
          ..write('sessionKey: $sessionKey, ')
          ..write('snapshot: $snapshot')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sessionKey, snapshot);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReaderCheckpoint &&
          other.sessionKey == this.sessionKey &&
          other.snapshot == this.snapshot);
}

class ReaderCheckpointsCompanion extends UpdateCompanion<ReaderCheckpoint> {
  final Value<String> sessionKey;
  final Value<String> snapshot;
  final Value<int> rowid;
  const ReaderCheckpointsCompanion({
    this.sessionKey = const Value.absent(),
    this.snapshot = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReaderCheckpointsCompanion.insert({
    required String sessionKey,
    required String snapshot,
    this.rowid = const Value.absent(),
  }) : sessionKey = Value(sessionKey),
       snapshot = Value(snapshot);
  static Insertable<ReaderCheckpoint> custom({
    Expression<String>? sessionKey,
    Expression<String>? snapshot,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionKey != null) 'session_key': sessionKey,
      if (snapshot != null) 'snapshot': snapshot,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReaderCheckpointsCompanion copyWith({
    Value<String>? sessionKey,
    Value<String>? snapshot,
    Value<int>? rowid,
  }) {
    return ReaderCheckpointsCompanion(
      sessionKey: sessionKey ?? this.sessionKey,
      snapshot: snapshot ?? this.snapshot,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionKey.present) {
      map['session_key'] = Variable<String>(sessionKey.value);
    }
    if (snapshot.present) {
      map['snapshot'] = Variable<String>(snapshot.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReaderCheckpointsCompanion(')
          ..write('sessionKey: $sessionKey, ')
          ..write('snapshot: $snapshot, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FavoritesTable favorites = $FavoritesTable(this);
  late final $CompletionsTable completions = $CompletionsTable(this);
  late final $ReaderCheckpointsTable readerCheckpoints =
      $ReaderCheckpointsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    favorites,
    completions,
    readerCheckpoints,
  ];
}

typedef $$FavoritesTableCreateCompanionBuilder =
    FavoritesCompanion Function({
      required String thikrId,
      required DateTime addedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$FavoritesTableUpdateCompanionBuilder =
    FavoritesCompanion Function({
      Value<String> thikrId,
      Value<DateTime> addedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$FavoritesTableFilterComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get thikrId => $composableBuilder(
    column: $table.thikrId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoritesTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get thikrId => $composableBuilder(
    column: $table.thikrId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoritesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get thikrId =>
      $composableBuilder(column: $table.thikrId, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$FavoritesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoritesTable,
          Favorite,
          $$FavoritesTableFilterComposer,
          $$FavoritesTableOrderingComposer,
          $$FavoritesTableAnnotationComposer,
          $$FavoritesTableCreateCompanionBuilder,
          $$FavoritesTableUpdateCompanionBuilder,
          (Favorite, BaseReferences<_$AppDatabase, $FavoritesTable, Favorite>),
          Favorite,
          PrefetchHooks Function()
        > {
  $$FavoritesTableTableManager(_$AppDatabase db, $FavoritesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> thikrId = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoritesCompanion(
                thikrId: thikrId,
                addedAt: addedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String thikrId,
                required DateTime addedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoritesCompanion.insert(
                thikrId: thikrId,
                addedAt: addedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FavoritesTable, Favorite>(table),
                  BaseReferences<_$AppDatabase, $FavoritesTable, Favorite>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoritesTable,
      Favorite,
      $$FavoritesTableFilterComposer,
      $$FavoritesTableOrderingComposer,
      $$FavoritesTableAnnotationComposer,
      $$FavoritesTableCreateCompanionBuilder,
      $$FavoritesTableUpdateCompanionBuilder,
      (Favorite, BaseReferences<_$AppDatabase, $FavoritesTable, Favorite>),
      Favorite,
      PrefetchHooks Function()
    >;
typedef $$CompletionsTableCreateCompanionBuilder =
    CompletionsCompanion Function({
      Value<int> id,
      required String category,
      required String day,
      required DateTime completedAt,
    });
typedef $$CompletionsTableUpdateCompanionBuilder =
    CompletionsCompanion Function({
      Value<int> id,
      Value<String> category,
      Value<String> day,
      Value<DateTime> completedAt,
    });

class $$CompletionsTableFilterComposer
    extends Composer<_$AppDatabase, $CompletionsTable> {
  $$CompletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CompletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CompletionsTable> {
  $$CompletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompletionsTable> {
  $$CompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$CompletionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompletionsTable,
          Completion,
          $$CompletionsTableFilterComposer,
          $$CompletionsTableOrderingComposer,
          $$CompletionsTableAnnotationComposer,
          $$CompletionsTableCreateCompanionBuilder,
          $$CompletionsTableUpdateCompanionBuilder,
          (
            Completion,
            BaseReferences<_$AppDatabase, $CompletionsTable, Completion>,
          ),
          Completion,
          PrefetchHooks Function()
        > {
  $$CompletionsTableTableManager(_$AppDatabase db, $CompletionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompletionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
              }) => CompletionsCompanion(
                id: id,
                category: category,
                day: day,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String category,
                required String day,
                required DateTime completedAt,
              }) => CompletionsCompanion.insert(
                id: id,
                category: category,
                day: day,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CompletionsTable, Completion>(table),
                  BaseReferences<_$AppDatabase, $CompletionsTable, Completion>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompletionsTable,
      Completion,
      $$CompletionsTableFilterComposer,
      $$CompletionsTableOrderingComposer,
      $$CompletionsTableAnnotationComposer,
      $$CompletionsTableCreateCompanionBuilder,
      $$CompletionsTableUpdateCompanionBuilder,
      (
        Completion,
        BaseReferences<_$AppDatabase, $CompletionsTable, Completion>,
      ),
      Completion,
      PrefetchHooks Function()
    >;
typedef $$ReaderCheckpointsTableCreateCompanionBuilder =
    ReaderCheckpointsCompanion Function({
      required String sessionKey,
      required String snapshot,
      Value<int> rowid,
    });
typedef $$ReaderCheckpointsTableUpdateCompanionBuilder =
    ReaderCheckpointsCompanion Function({
      Value<String> sessionKey,
      Value<String> snapshot,
      Value<int> rowid,
    });

class $$ReaderCheckpointsTableFilterComposer
    extends Composer<_$AppDatabase, $ReaderCheckpointsTable> {
  $$ReaderCheckpointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sessionKey => $composableBuilder(
    column: $table.sessionKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snapshot => $composableBuilder(
    column: $table.snapshot,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReaderCheckpointsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReaderCheckpointsTable> {
  $$ReaderCheckpointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sessionKey => $composableBuilder(
    column: $table.sessionKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snapshot => $composableBuilder(
    column: $table.snapshot,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReaderCheckpointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReaderCheckpointsTable> {
  $$ReaderCheckpointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sessionKey => $composableBuilder(
    column: $table.sessionKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get snapshot =>
      $composableBuilder(column: $table.snapshot, builder: (column) => column);
}

class $$ReaderCheckpointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReaderCheckpointsTable,
          ReaderCheckpoint,
          $$ReaderCheckpointsTableFilterComposer,
          $$ReaderCheckpointsTableOrderingComposer,
          $$ReaderCheckpointsTableAnnotationComposer,
          $$ReaderCheckpointsTableCreateCompanionBuilder,
          $$ReaderCheckpointsTableUpdateCompanionBuilder,
          (
            ReaderCheckpoint,
            BaseReferences<
              _$AppDatabase,
              $ReaderCheckpointsTable,
              ReaderCheckpoint
            >,
          ),
          ReaderCheckpoint,
          PrefetchHooks Function()
        > {
  $$ReaderCheckpointsTableTableManager(
    _$AppDatabase db,
    $ReaderCheckpointsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReaderCheckpointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReaderCheckpointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReaderCheckpointsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> sessionKey = const Value.absent(),
                Value<String> snapshot = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReaderCheckpointsCompanion(
                sessionKey: sessionKey,
                snapshot: snapshot,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionKey,
                required String snapshot,
                Value<int> rowid = const Value.absent(),
              }) => ReaderCheckpointsCompanion.insert(
                sessionKey: sessionKey,
                snapshot: snapshot,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReaderCheckpointsTable, ReaderCheckpoint>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ReaderCheckpointsTable,
                    ReaderCheckpoint
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReaderCheckpointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReaderCheckpointsTable,
      ReaderCheckpoint,
      $$ReaderCheckpointsTableFilterComposer,
      $$ReaderCheckpointsTableOrderingComposer,
      $$ReaderCheckpointsTableAnnotationComposer,
      $$ReaderCheckpointsTableCreateCompanionBuilder,
      $$ReaderCheckpointsTableUpdateCompanionBuilder,
      (
        ReaderCheckpoint,
        BaseReferences<
          _$AppDatabase,
          $ReaderCheckpointsTable,
          ReaderCheckpoint
        >,
      ),
      ReaderCheckpoint,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FavoritesTableTableManager get favorites =>
      $$FavoritesTableTableManager(_db, _db.favorites);
  $$CompletionsTableTableManager get completions =>
      $$CompletionsTableTableManager(_db, _db.completions);
  $$ReaderCheckpointsTableTableManager get readerCheckpoints =>
      $$ReaderCheckpointsTableTableManager(_db, _db.readerCheckpoints);
}
