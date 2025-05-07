const String _apiProdUrl = 'api.samacloud.io';
const String _apiDevUrl = 'api-dev.samacloud.io';

const String _organizationIdProd = '6821d147b2bb04e5fe564c73';
const String _organizationIdDev = '6821d147b2bb04e5fe564c73';

enum EnvType {
  prod(_apiProdUrl, _organizationIdProd),
  dev(_apiDevUrl, _organizationIdDev);

  final String url;
  final String organizationId;

  const EnvType(this.url, this.organizationId);
}
