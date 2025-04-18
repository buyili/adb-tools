// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDeviceCollection on Isar {
  IsarCollection<Device> get devices => this.collection();
}

const DeviceSchema = CollectionSchema(
  name: r'Device',
  id: 3491430514663294648,
  properties: {
    r'device': PropertySchema(
      id: 0,
      name: r'device',
      type: IsarType.string,
    ),
    r'model': PropertySchema(
      id: 1,
      name: r'model',
      type: IsarType.string,
    ),
    r'product': PropertySchema(
      id: 2,
      name: r'product',
      type: IsarType.string,
    ),
    r'serialNumber': PropertySchema(
      id: 3,
      name: r'serialNumber',
      type: IsarType.string,
    ),
    r'transportId': PropertySchema(
      id: 4,
      name: r'transportId',
      type: IsarType.string,
    )
  },
  estimateSize: _deviceEstimateSize,
  serialize: _deviceSerialize,
  deserialize: _deviceDeserialize,
  deserializeProp: _deviceDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _deviceGetId,
  getLinks: _deviceGetLinks,
  attach: _deviceAttach,
  version: '3.1.0+1',
);

int _deviceEstimateSize(
  Device object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.device;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.model;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.product;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.serialNumber.length * 3;
  {
    final value = object.transportId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _deviceSerialize(
  Device object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.device);
  writer.writeString(offsets[1], object.model);
  writer.writeString(offsets[2], object.product);
  writer.writeString(offsets[3], object.serialNumber);
  writer.writeString(offsets[4], object.transportId);
}

Device _deviceDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Device();
  object.device = reader.readStringOrNull(offsets[0]);
  object.id = id;
  object.model = reader.readStringOrNull(offsets[1]);
  object.product = reader.readStringOrNull(offsets[2]);
  object.serialNumber = reader.readString(offsets[3]);
  object.transportId = reader.readStringOrNull(offsets[4]);
  return object;
}

P _deviceDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _deviceGetId(Device object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _deviceGetLinks(Device object) {
  return [];
}

void _deviceAttach(IsarCollection<dynamic> col, Id id, Device object) {
  object.id = id;
}

extension DeviceQueryWhereSort on QueryBuilder<Device, Device, QWhere> {
  QueryBuilder<Device, Device, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DeviceQueryWhere on QueryBuilder<Device, Device, QWhereClause> {
  QueryBuilder<Device, Device, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Device, Device, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Device, Device, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Device, Device, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DeviceQueryFilter on QueryBuilder<Device, Device, QFilterCondition> {
  QueryBuilder<Device, Device, QAfterFilterCondition> deviceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'device',
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> deviceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'device',
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> deviceEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'device',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> deviceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'device',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> deviceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'device',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> deviceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'device',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> deviceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'device',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> deviceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'device',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> deviceContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'device',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> deviceMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'device',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> deviceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'device',
        value: '',
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> deviceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'device',
        value: '',
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> modelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'model',
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> modelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'model',
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> modelEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> modelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> modelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> modelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'model',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> modelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> modelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> modelContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> modelMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'model',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> modelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'model',
        value: '',
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> modelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'model',
        value: '',
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> productIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'product',
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> productIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'product',
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> productEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'product',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> productGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'product',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> productLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'product',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> productBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'product',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> productStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'product',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> productEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'product',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> productContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'product',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> productMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'product',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> productIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'product',
        value: '',
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> productIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'product',
        value: '',
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> serialNumberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serialNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> serialNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serialNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> serialNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serialNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> serialNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serialNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> serialNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'serialNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> serialNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'serialNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> serialNumberContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'serialNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> serialNumberMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'serialNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> serialNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serialNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> serialNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serialNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> transportIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'transportId',
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> transportIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'transportId',
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> transportIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'transportId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> transportIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'transportId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> transportIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'transportId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> transportIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'transportId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> transportIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'transportId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> transportIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'transportId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> transportIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'transportId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> transportIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'transportId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> transportIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'transportId',
        value: '',
      ));
    });
  }

  QueryBuilder<Device, Device, QAfterFilterCondition> transportIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'transportId',
        value: '',
      ));
    });
  }
}

extension DeviceQueryObject on QueryBuilder<Device, Device, QFilterCondition> {}

extension DeviceQueryLinks on QueryBuilder<Device, Device, QFilterCondition> {}

extension DeviceQuerySortBy on QueryBuilder<Device, Device, QSortBy> {
  QueryBuilder<Device, Device, QAfterSortBy> sortByDevice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'device', Sort.asc);
    });
  }

  QueryBuilder<Device, Device, QAfterSortBy> sortByDeviceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'device', Sort.desc);
    });
  }

  QueryBuilder<Device, Device, QAfterSortBy> sortByModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.asc);
    });
  }

  QueryBuilder<Device, Device, QAfterSortBy> sortByModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.desc);
    });
  }

  QueryBuilder<Device, Device, QAfterSortBy> sortByProduct() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'product', Sort.asc);
    });
  }

  QueryBuilder<Device, Device, QAfterSortBy> sortByProductDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'product', Sort.desc);
    });
  }

  QueryBuilder<Device, Device, QAfterSortBy> sortBySerialNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serialNumber', Sort.asc);
    });
  }

  QueryBuilder<Device, Device, QAfterSortBy> sortBySerialNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serialNumber', Sort.desc);
    });
  }

  QueryBuilder<Device, Device, QAfterSortBy> sortByTransportId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transportId', Sort.asc);
    });
  }

  QueryBuilder<Device, Device, QAfterSortBy> sortByTransportIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transportId', Sort.desc);
    });
  }
}

extension DeviceQuerySortThenBy on QueryBuilder<Device, Device, QSortThenBy> {
  QueryBuilder<Device, Device, QAfterSortBy> thenByDevice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'device', Sort.asc);
    });
  }

  QueryBuilder<Device, Device, QAfterSortBy> thenByDeviceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'device', Sort.desc);
    });
  }

  QueryBuilder<Device, Device, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Device, Device, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Device, Device, QAfterSortBy> thenByModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.asc);
    });
  }

  QueryBuilder<Device, Device, QAfterSortBy> thenByModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.desc);
    });
  }

  QueryBuilder<Device, Device, QAfterSortBy> thenByProduct() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'product', Sort.asc);
    });
  }

  QueryBuilder<Device, Device, QAfterSortBy> thenByProductDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'product', Sort.desc);
    });
  }

  QueryBuilder<Device, Device, QAfterSortBy> thenBySerialNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serialNumber', Sort.asc);
    });
  }

  QueryBuilder<Device, Device, QAfterSortBy> thenBySerialNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serialNumber', Sort.desc);
    });
  }

  QueryBuilder<Device, Device, QAfterSortBy> thenByTransportId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transportId', Sort.asc);
    });
  }

  QueryBuilder<Device, Device, QAfterSortBy> thenByTransportIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transportId', Sort.desc);
    });
  }
}

extension DeviceQueryWhereDistinct on QueryBuilder<Device, Device, QDistinct> {
  QueryBuilder<Device, Device, QDistinct> distinctByDevice(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'device', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Device, Device, QDistinct> distinctByModel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'model', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Device, Device, QDistinct> distinctByProduct(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'product', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Device, Device, QDistinct> distinctBySerialNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serialNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Device, Device, QDistinct> distinctByTransportId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'transportId', caseSensitive: caseSensitive);
    });
  }
}

extension DeviceQueryProperty on QueryBuilder<Device, Device, QQueryProperty> {
  QueryBuilder<Device, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Device, String?, QQueryOperations> deviceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'device');
    });
  }

  QueryBuilder<Device, String?, QQueryOperations> modelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'model');
    });
  }

  QueryBuilder<Device, String?, QQueryOperations> productProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'product');
    });
  }

  QueryBuilder<Device, String, QQueryOperations> serialNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serialNumber');
    });
  }

  QueryBuilder<Device, String?, QQueryOperations> transportIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transportId');
    });
  }
}
