const String _apiProdUrl = 'api.samacloud.io';
const String _apiDevUrl = 'api-dev.samacloud.io';

const String _organizationIdProd = '68273ebe767d95c4f251de2c';
const String _organizationIdDev = '6821d147b2bb04e5fe564c73';

enum EnvType {
  prod(_apiProdUrl, _organizationIdProd),
  dev(_apiDevUrl, _organizationIdDev);

  final String url;
  final String organizationId;

  const EnvType(this.url, this.organizationId);
}
