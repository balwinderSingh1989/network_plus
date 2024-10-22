part of network_plus;

abstract class BaseResponseModel<T> {
  bool? status;

  BaseResponseModel({this.status});

  T fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson();
}

abstract class BaseRequestModel {
  Map<String, dynamic>? buildParams();
}

class EmptyRequest extends BaseRequestModel{
  @override
  Map<String, dynamic>? buildParams() {
   return null;
  }


}