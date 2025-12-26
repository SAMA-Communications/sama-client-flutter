const int maxParticipants = 50;
const int maxChatsToSelect = 20;

class SamaSettings {
  String apiEndpoint = '';
  String organizationId = '';

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
