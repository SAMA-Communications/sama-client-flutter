class SamaSettings {
  String apiEndpoint = 'api.samacloud.io';

  String apiProdUrl = 'api.samacloud.io';
  String apiDevUrl = 'api-dev.samacloud.io';

  String organizationId = '68273ebe767d95c4f251de2c';

  String organizationIdProd = '68273ebe767d95c4f251de2c';
  String organizationIdDev = '6821d147b2bb04e5fe564c73';

  static final SamaSettings _instance = SamaSettings._internal();

  SamaSettings._internal();

  static SamaSettings get instance => _instance;

  setEndpoints(String apiEndpoint, String organizationId) {
    if (apiEndpoint.isEmpty || organizationId.isEmpty) {
      throw ArgumentError(
          "'apiEndpoint' and(or) 'organizationId' can not be empty or null");
    }

    this.apiEndpoint = apiEndpoint;
    this.organizationId = organizationId;
  }
}