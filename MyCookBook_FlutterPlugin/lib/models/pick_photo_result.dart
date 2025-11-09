/// 选中的图片信息。
class PickPhotoResult {
  /// 图片uri列表。
  List<String>? photoUris;

  /// 是否原图。
  bool? isOriginalPhoto;

  @override
  String toString() {
    List<String> infoStrs = <String>[];
    if (photoUris != null && photoUris!.isNotEmpty) {
      String photoUriStr = '"${photoUris!.join('","')}"';
      infoStrs.add('"photoUris": [$photoUriStr]');
    }
    if (isOriginalPhoto != null) infoStrs.add('"isOriginalPhoto": $isOriginalPhoto');
    String infoStr = infoStrs.join(',');
    return '{$infoStr}';
  }

  Map<String, dynamic> toJson() {
    return {
      'photoUris': photoUris,
      'isOriginalPhoto': isOriginalPhoto,
    };
  }

  /// 从原始数据Map中构造一个选中的图片信息。
  static PickPhotoResult fromMap(Map<Object?, Object?> dataMap) {
    PickPhotoResult pickPhotoResult = PickPhotoResult();
    if (dataMap.containsKey('photoUris')) {
      List<Object?> photoUris = dataMap['photoUris'] as List<Object?>;
      if (photoUris.isNotEmpty) {
        pickPhotoResult.photoUris = [];
        for (var uriItem in photoUris) {
          if (uriItem != null) {
            pickPhotoResult.photoUris?.add(uriItem as String);
          }
        }
      }
    }
    if (dataMap.containsKey('isOriginalPhoto')) {
      pickPhotoResult.isOriginalPhoto = dataMap['isOriginalPhoto'] as bool;
    }
    return pickPhotoResult;
  }
}
