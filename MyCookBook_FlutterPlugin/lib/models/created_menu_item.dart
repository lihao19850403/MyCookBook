/// 菜谱详情。
class CreatedMenuItem {
  /// 菜谱ID。5012
  num? id;

  /// 分类ID。443
  num? type_id;

  /// 分类名称。"禽肉及其他肉类"
  String? type_name;

  /// 菜谱名称。
  String? cp_name; // "家常鹅肉"

  /// 菜谱缩略图。
  String? cp_thumbnail; // 缩略图链接。

  /// 菜谱做法。"1.将鹅肉洗净切块；青笋切滚刀块；葱、姜切片；2.将油烧热，把豆瓣酱、葱片、姜片下锅煸炒，待出香味后，把鹅肉放入稍炒，烹入料酒、酱油，放入精盐、味精后继续煸炒；3.待肉上色时，加入适量开水，烧开后，转小火慢烧，待肉将熟时放入辣椒、青笋，青笋烧熟后即可。"
  String? zuofa;

  /// 菜谱特性。"咸鲜适口，鹅肉香浓。"
  String? texing;

  /// 菜谱提示。"鹅肉的肉质较粗，烹制时要多炖一会，烧至鹅肉完全酥烂后口感更佳。"
  String? tishi;

  /// 菜谱调料。"食用油50克；酱油3小匙(9克)；料酒3小匙(9克)；豆瓣酱1大匙(30克)；精盐1小匙(3克)；味精1/2小匙(1.5克)"
  String? tiaoliao;

  /// 菜谱原料。"鹅肉300克；青笋100克；红辣椒2个；大葱1根；生姜1小块"
  String? yuanliao;

  /// 菜谱作者。
  String? author;

  /// 创建时间。
  String? createdTime;

  @override
  String toString() {
    List<String> infoStrs = <String>[];
    if (id != null) infoStrs.add('"id": $id');
    if (type_id != null) infoStrs.add('"type_id": $type_id');
    if (type_name != null) infoStrs.add('"type_name": "$type_name"');
    if (cp_name != null) infoStrs.add('"cp_name": "$cp_name"');
    if (cp_thumbnail != null) infoStrs.add('"cp_thumbnail": "$cp_thumbnail"');
    if (zuofa != null) infoStrs.add('"zuofa": "$zuofa"');
    if (texing != null) infoStrs.add('"texing": "$texing"');
    if (tishi != null) infoStrs.add('"tishi": "$tishi"');
    if (tiaoliao != null) infoStrs.add('"tiaoliao": "$tiaoliao"');
    if (yuanliao != null) infoStrs.add('"yuanliao": "$yuanliao"');
    if (author != null) infoStrs.add('"author": "$author"');
    if (createdTime != null) infoStrs.add('"createdTime": "$createdTime"');
    String infoStr = infoStrs.join(',');
    return '{$infoStr}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type_id': type_id,
      'type_name': type_name,
      'cp_name': cp_name,
      'cp_thumbnail': cp_thumbnail,
      'zuofa': zuofa,
      'texing': texing,
      'tishi': tishi,
      'tiaoliao': tiaoliao,
      'yuanliao': yuanliao,
      'author': author,
      'createdTime': createdTime,
    };
  }

  /// 从原始数据Map中构造一个菜谱详情对象。
  static CreatedMenuItem fromMap(Map<Object?, Object?> dataMap) {
    CreatedMenuItem createdMenuItem = CreatedMenuItem();
    createdMenuItem.id =
        dataMap.containsKey('id') ? dataMap['id'] as num : null;
    createdMenuItem.type_id =
        dataMap.containsKey('type_id') ? dataMap['type_id'] as num : null;
    createdMenuItem.type_name = dataMap.containsKey('type_name')
        ? dataMap['type_name'] as String
        : null;
    createdMenuItem.cp_name =
        dataMap.containsKey('cp_name') ? dataMap['cp_name'] as String : null;
    createdMenuItem.cp_thumbnail = dataMap.containsKey('cp_thumbnail')
        ? dataMap['cp_thumbnail'] as String
        : null;
    createdMenuItem.zuofa =
        dataMap.containsKey('zuofa') ? dataMap['zuofa'] as String : null;
    createdMenuItem.texing =
        dataMap.containsKey('texing') ? dataMap['texing'] as String : null;
    createdMenuItem.tishi =
        dataMap.containsKey('tishi') ? dataMap['tishi'] as String : null;
    createdMenuItem.tiaoliao =
        dataMap.containsKey('tiaoliao') ? dataMap['tiaoliao'] as String : null;
    createdMenuItem.yuanliao =
        dataMap.containsKey('yuanliao') ? dataMap['yuanliao'] as String : null;
    createdMenuItem.author =
        dataMap.containsKey('author') ? dataMap['author'] as String : null;
    createdMenuItem.createdTime = dataMap.containsKey('createdTime')
        ? dataMap['createdTime'] as String
        : null;
    return createdMenuItem;
  }
}
