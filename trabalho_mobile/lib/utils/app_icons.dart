const String _baseUrl   = "https://img.icons8.com";
const int    _iconSize  = 100;
const String _iconColor = "000000";

class AppIcons {
  
  static const String investimentoId  = "4LZYUOO2BWoN";
  static const String comprasId       = "85179";
  static const String alimentacaoId   = "8439";
  static const String contasId        = "61247";
  static const String cartaoId        = "So9Gvu5Hcyjh";
  static const String calendarioId    = "84997";
  static const String graficoUp       = "59811";
  static const String graficoDown     = "59774";
  static const String entrada         = "7977";

  static String getUrlById(String id) {
    return "$_baseUrl?size=$_iconSize&id=$id&format=png&color=$_iconColor";
  }

  static String get investimento =>
    getUrlById(investimentoId);

  static String get compras =>
    getUrlById(comprasId);

  static String get alimentacao =>
    getUrlById(alimentacaoId);

  static String get contas =>
    getUrlById(contasId);

  static String get cartao =>
    getUrlById(cartaoId);

  static String get calendario =>
    getUrlById(calendarioId);
}
