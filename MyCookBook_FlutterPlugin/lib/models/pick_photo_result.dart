/// 选中的图片信息。
class PickPhotoResult {
  /// 图片uri列表。
  List<String>? photoUris;

  @override
  String toString() {
    List<String> infoStrs = <String>[];
    if (photoUris != null && photoUris!.isNotEmpty) {
      String photoUriStr = '"${photoUris!.join('","')}"';
      infoStrs.add('"photoUris": [$photoUriStr]');
    }
    String infoStr = infoStrs.join(',');
    return '{$infoStr}';
  }

  Map<String, dynamic> toJson() {
    return {
      'photoUris': photoUris
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
    return pickPhotoResult;
  }
}
