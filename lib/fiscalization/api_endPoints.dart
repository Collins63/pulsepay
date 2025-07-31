class  ApiEndpoints {
  final String deviceID;

  ApiEndpoints(this.deviceID);

  String get apiEndpointGetConfig =>
      "https://fdmsapi.zimra.co.zw/Device/v1/$deviceID/GetConfig";

  String get apiEndpointGetStatus =>
      "https://fdmsapi.zimra.co.zw/Device/v1/$deviceID/GetStatus";

  String get apiEndpointOpenDay =>
      "https://fdmsapi.zimra.co.zw/Device/v1/$deviceID/OpenDay";

  String get apiEndpointCloseDay =>
      "https://fdmsapi.zimra.co.zw/Device/v1/$deviceID/CloseDay";

  String get apiEndpointPing =>
      "https://fdmsapi.zimra.co.zw/Device/v1/$deviceID/Ping";

  String get apiEndpointSubmitReceipt =>
      "https://fdmsapi.zimra.co.zw/Device/v1/$deviceID/SubmitReceipt";
}