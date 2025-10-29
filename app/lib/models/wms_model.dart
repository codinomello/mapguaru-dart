/// Modelo para representar uma camada WMS
class WMSLayer {
  final String name;
  final String title;
  final String? abstract;
  final String? crs;
  final double? minLat;
  final double? minLon;
  final double? maxLat;
  final double? maxLon;
  final List<String>? styles;
  final bool visible;

  WMSLayer({
    required this.name,
    required this.title,
    this.abstract,
    this.crs,
    this.minLat,
    this.minLon,
    this.maxLat,
    this.maxLon,
    this.styles,
    this.visible = false,
  });

  /// Gera URL de tile para flutter_map
  String getTileUrl() {
    const geoserverUrl = 'https://geonetwork.guarulhos.sp.gov.br:8443/geoserver';
    const wmsUrl = '$geoserverUrl/wms';
    
    return '$wmsUrl?'
        'service=WMS&'
        'version=1.1.1&'
        'request=GetMap&'
        'layers=$name&'
        'styles=${styles?.first ?? ""}&'
        'bbox={bbox}&'
        'width=256&'
        'height=256&'
        'srs=${crs ?? "EPSG:4326"}&'
        'format=image/png&'
        'transparent=true';
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'title': title,
        'abstract': abstract,
        'crs': crs,
        'visible': visible,
      };

  /// Copia a camada com novos valores
  WMSLayer copyWith({
    String? name,
    String? title,
    String? abstract,
    String? crs,
    double? minLat,
    double? minLon,
    double? maxLat,
    double? maxLon,
    List<String>? styles,
    bool? visible,
  }) {
    return WMSLayer(
      name: name ?? this.name,
      title: title ?? this.title,
      abstract: abstract ?? this.abstract,
      crs: crs ?? this.crs,
      minLat: minLat ?? this.minLat,
      minLon: minLon ?? this.minLon,
      maxLat: maxLat ?? this.maxLat,
      maxLon: maxLon ?? this.maxLon,
      styles: styles ?? this.styles,
      visible: visible ?? this.visible,
    );
  }
}