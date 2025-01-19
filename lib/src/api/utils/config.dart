const String apiProdUrl = 'api.samacloud.io';
const String apiDevUrl = 'api-dev.samacloud.io';

enum EnvType {
  dev(apiDevUrl),
  prod(apiProdUrl);

  final String url;

  const EnvType(this.url);

  factory EnvType.fromUrl(String url) {
    return values.firstWhere((e) => e.url == url);
  }
}
