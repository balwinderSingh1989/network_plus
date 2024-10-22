part of retail_core;


//This decodes and performs mapping in isolate
class NetworkDecoderX {
  static var shared = NetworkDecoderX();

  Future<K> decode<T extends BaseResponseModel, M extends Mapper<T, K>, K>({
    required Response<dynamic> response,
    required T responseType,
    required M mapper,
  }) async {
    try {
      if (response.data is List) {
        var list = response.data as List;
        var dataList = await compute(
          _decodeAndMapListHelper,
          _DecodeAndMapListHelperArgs(
            list: list.map((item) => item as Map<String, dynamic>).toList(),
            responseType: responseType,
            mapper: mapper,
          ),
        );
        return dataList as K;
      } else {
        var data = await compute(
          _decodeAndMapSingleHelper,
          _DecodeAndMapSingleHelperArgs(
            data: response.data as Map<String, dynamic>,
            responseType: responseType,
            mapper: mapper,
          ),
        );
        return data as K;
      }
    } on TypeError catch (e) {
      throw e;
    }
  }
}

class _DecodeAndMapListHelperArgs<T extends BaseResponseModel, K> {
  final List<Map<String, dynamic>> list;
  final T responseType;
  final Mapper<T, K> mapper;

  _DecodeAndMapListHelperArgs({required this.list, required this.responseType, required this.mapper});
}

class _DecodeAndMapSingleHelperArgs<T extends BaseResponseModel, K> {
  final Map<String, dynamic> data;
  final T responseType;
  final Mapper<T, K> mapper;

  _DecodeAndMapSingleHelperArgs({required this.data, required this.responseType, required this.mapper});
}

List<K> _decodeAndMapListHelper<T extends BaseResponseModel, K>(_DecodeAndMapListHelperArgs<T, K> args) {
  var decodedList = List<T>.from(args.list.map((item) => args.responseType.fromJson(item)).toList());
  return decodedList.map((item) => args.mapper.mapFrom(item)).toList();
}

K _decodeAndMapSingleHelper<T extends BaseResponseModel, K>(_DecodeAndMapSingleHelperArgs<T, K> args) {
  var decoded = args.responseType.fromJson(args.data);
  return args.mapper.mapFrom(decoded);
}




//only json parsing in isolate and not mapper.
class NetworkDecoder {
  static var shared = NetworkDecoder();

  Future<T> decode<T extends BaseResponseModel>({required Response<dynamic> response, required T responseType}) async {
    try {
      if (response.data is List) {
        var list = response.data as List;
        var dataList = await compute(_decodeListHelper, _DecodeListHelperArgs(list: list.map((item) => item as Map<String, dynamic>).toList(), responseType: responseType));
        return dataList as T;
      } else {
        var data = await compute(_decodeSingleHelper, _DecodeSingleHelperArgs(data: response.data as Map<String, dynamic>, responseType: responseType));
        return data as T;
      }
    } on TypeError catch (e) {
      throw e;
    }
  }
}


class _DecodeListHelperArgs {
  final List<Map<String, dynamic>> list;
  final BaseResponseModel responseType;

  _DecodeListHelperArgs({required this.list, required this.responseType});
}

class _DecodeSingleHelperArgs {
  final Map<String, dynamic> data;
  final BaseResponseModel responseType;

  _DecodeSingleHelperArgs({required this.data, required this.responseType});
}

List<T> _decodeListHelper<T extends BaseResponseModel>(_DecodeListHelperArgs args) {
  return List<T>.from(args.list.map((item) => args.responseType.fromJson(item)).toList());
}

T _decodeSingleHelper<T extends BaseResponseModel>(_DecodeSingleHelperArgs args) {
  return args.responseType.fromJson(args.data);
}