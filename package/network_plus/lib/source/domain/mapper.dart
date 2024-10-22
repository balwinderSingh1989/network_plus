part of retail_core;

//map data layer response models to domain models
abstract class Mapper<ResponseModel, UiModel> {
  UiModel mapFrom(ResponseModel from);
}