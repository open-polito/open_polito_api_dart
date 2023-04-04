import 'package:open_polito_api/src/constants.dart';
import 'package:open_polito_api/src/device.dart';
import 'package:open_polito_api/src/utils.dart';

enum ItemType {
  file,
  directory,
}

abstract class MaterialItem {
  final ItemType type;

  final String? code;

  /// A user-friendly name.
  ///
  /// Not necessarily a valid filename, if the item is a file.
  final String? name;

  const MaterialItem({required this.type, this.code, this.name});
}

class File extends MaterialItem {
  /// The filename for internal usage
  final String? filename;

  final String? mimeType;

  /// The size in kB
  final int? size;

  /// The creation date
  final DateTime? creationDate;

  const File({
    this.filename,
    this.mimeType,
    this.size,
    this.creationDate,
    String? code,
    String? name,
  }) : super(type: ItemType.file, code: code, name: name);
}

class Directory extends MaterialItem {
  final List<MaterialItem> children;

  const Directory({
    this.children = const [],
    String? code,
    String? name,
  }) : super(type: ItemType.directory, code: code, name: name);
}

/// Parses an item from an API response.
MaterialItem parseMaterial(dynamic item) {
  final type = item["tipo"];
  switch (type) {
    case "FILE":
      return File(
        code: item["code"],
        name: item["descrizione"],
        filename: item["nomefile"],
        mimeType: item["cont_type"],
        size: item["size_kb"],
        creationDate: parseDate(item["data_ins"], "yyyy/MM/dd HH:mm:ss"),
      );
    case "DIR":
      return Directory(
        code: item["code"],
        name: item["descrizione"],
        children: (item["files"] ?? []).map((e) => parseMaterial(e)).toList(),
      );
    default:
      throw Exception("Unknown file type $type");
  }
}

/// Gets a download URL for either a File object or a file code.
Future<String?> getDownloadURL(
  Device device, {
  String? code,
  File? file,
}) async {
  final String? fileCode = code ?? file?.code;
  if (fileCode == null) {
    return null;
  }
  final data = await device.post(downloadRoute, {"code": code});
  checkError(data);
  return data.data["directurl"] as String?;
}
