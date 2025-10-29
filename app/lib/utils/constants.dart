class AppConstants {
  // ==================== INFORMAÇÕES DO APP ====================
  
  static const String appName = 'MapGuaru';
  static const String appTagline = 'Seu guia para os serviços de Guarulhos';
  static const String version = '1.0.0';
  
  // ==================== COORDENADAS DE GUARULHOS ====================
  
  /// Coordenadas do centro de Guarulhos
  static const double guarulhosCenterLat = -23.4538;
  static const double guarulhosCenterLng = -46.5333;
  
  /// Zoom padrão do mapa
  static const double defaultMapZoom = 13.0;
  static const double detailMapZoom = 15.0;
  
  // ==================== CONFIGURAÇÕES DO MAPA ====================
  
  /// URL do tile server OpenStreetMap
  static const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  
  /// Atribuição do mapa
  static const String mapAttribution = '© OpenStreetMap contributors';
  
  /// Limites do mapa (Guarulhos e arredores)
  static const double minLat = -23.6;
  static const double maxLat = -23.3;
  static const double minLng = -46.7;
  static const double maxLng = -46.3;
  
  // ==================== VALIDAÇÕES ====================
  
  /// Tamanho mínimo de senha
  static const int minPasswordLength = 6;
  
  /// Tamanho máximo de nome
  static const int maxNameLength = 100;
  
  /// RegEx para validação de email
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  
  // ==================== MENSAGENS ====================
  
  static const String errorGeneric = 'Ocorreu um erro. Tente novamente.';
  static const String errorNetwork = 'Erro de conexão. Verifique sua internet.';
  static const String errorEmailInvalid = 'Email inválido.';
  static const String errorPasswordShort = 'Senha deve ter no mínimo 6 caracteres.';
  static const String errorLoginFailed = 'Email ou senha incorretos.';
  static const String errorRegisterFailed = 'Erro ao criar conta. Email pode já estar em uso.';
  
  static const String successLogin = 'Login realizado com sucesso!';
  static const String successRegister = 'Conta criada com sucesso!';
  static const String successFavoriteAdded = 'Adicionado aos favoritos!';
  static const String successFavoriteRemoved = 'Removido dos favoritos!';
  
  // ==================== CATEGORIAS ====================
  
  /// Mapa de IDs para nomes de categorias
  static const Map<int, String> categoryNames = {
    1: 'Saúde',
    2: 'Educação',
    3: 'Comunidade',
    4: 'Segurança',
    5: 'Transporte',
    6: 'Cultura & Lazer',
  };
  
  /// Mapa de IDs para descrições de categorias
  static const Map<int, String> categoryDescriptions = {
    1: 'Hospitais, UBS, Clínicas e Postos de Saúde',
    2: 'Escolas, Universidades e Instituições de Ensino',
    3: 'Centros Comunitários e Serviços Sociais',
    4: 'Delegacias, Bombeiros e Defesa Civil',
    5: 'Pontos de Ônibus, Terminais e Estações',
    6: 'Museus, Teatros, Parques e Áreas de Lazer',
  };
  
  // ==================== DURAÇÃO DE ANIMAÇÕES ====================
  
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // ==================== STORAGE KEYS ====================
  
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyFirstTime = 'first_time';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLastDataUpdate = 'last_data_update';
  
  // ==================== ROTAS ====================
  
  static const String routeSplash = '/';
  static const String routeMenu = '/menu';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeMainMenu = '/main';
  static const String routeCategory = '/category';
  static const String routeMap = '/map';
  static const String routeProfile = '/profile';
  static const String routeServiceGuide = '/service-guide';
  static const String routeMapGuide = '/map-guide';
  static const String routeProfileGuide = '/profile-guide';
  
  // ==================== DADOS DE EXEMPLO ====================
  
  /// Unidades de serviço de exemplo para Guarulhos
  static List<Map<String, dynamic>> get sampleServiceUnits => [
    // SAÚDE
    {
      'category_id': 1,
      'name': 'Hospital Municipal Pimentas Bonsucesso',
      'description': 'Hospital de referência com pronto-socorro 24h',
      'address': 'R. Francisco de Faria, 255',
      'neighborhood': 'Pimentas',
      'zip_code': '07252-000',
      'city': 'Guarulhos',
      'state': 'SP',
      'latitude': -23.4456,
      'longitude': -46.4123,
      'opening_hours': '24 horas',
      'phone': '(11) 2461-5050',
    },
    {
      'category_id': 1,
      'name': 'UBS Bom Clima',
      'description': 'Unidade Básica de Saúde',
      'address': 'Av. João Paulo I, 500',
      'neighborhood': 'Bom Clima',
      'zip_code': '07175-000',
      'city': 'Guarulhos',
      'state': 'SP',
      'latitude': -23.4789,
      'longitude': -46.5012,
      'opening_hours': 'Seg-Sex: 7h-17h',
      'phone': '(11) 2408-4200',
    },
    
    // EDUCAÇÃO
    {
      'category_id': 2,
      'name': 'UNIFESP - Campus Guarulhos',
      'description': 'Universidade Federal de São Paulo',
      'address': 'Estrada do Caminho Velho, 333',
      'neighborhood': 'Jardim Nova Cidade',
      'zip_code': '07252-312',
      'city': 'Guarulhos',
      'state': 'SP',
      'latitude': -23.4789,
      'longitude': -46.5234,
      'opening_hours': 'Seg-Sex: 7h-22h',
      'phone': '(11) 5576-4000',
      'website': 'https://www.unifesp.br',
    },
    {
      'category_id': 2,
      'name': 'ETEC Guarulhos',
      'description': 'Escola Técnica Estadual',
      'address': 'Av. Salgado Filho, 2333',
      'neighborhood': 'Centro',
      'zip_code': '07115-000',
      'city': 'Guarulhos',
      'state': 'SP',
      'latitude': -23.4612,
      'longitude': -46.5334,
      'opening_hours': 'Seg-Sex: 7h-23h',
      'phone': '(11) 2087-5555',
    },
    
    // COMUNIDADE
    {
      'category_id': 3,
      'name': 'Centro Comunitário Bonsucesso',
      'description': 'Atividades sociais e culturais',
      'address': 'R. Nova Esperança, 123',
      'neighborhood': 'Bonsucesso',
      'zip_code': '07251-000',
      'city': 'Guarulhos',
      'state': 'SP',
      'latitude': -23.4523,
      'longitude': -46.4890,
      'opening_hours': 'Seg-Sex: 8h-18h',
      'phone': '(11) 2408-5000',
    },
    
    // SEGURANÇA
    {
      'category_id': 4,
      'name': '4º Distrito Policial',
      'description': 'Delegacia de Polícia',
      'address': 'Av. Tiradentes, 4321',
      'neighborhood': 'Centro',
      'zip_code': '07094-000',
      'city': 'Guarulhos',
      'state': 'SP',
      'latitude': -23.4601,
      'longitude': -46.5289,
      'opening_hours': '24 horas',
      'phone': '(11) 2475-0444',
    },
    {
      'category_id': 4,
      'name': 'Corpo de Bombeiros - 8º GB',
      'description': 'Grupamento de Bombeiros',
      'address': 'R. Santos Dumont, 789',
      'neighborhood': 'Gopouva',
      'zip_code': '07040-000',
      'city': 'Guarulhos',
      'state': 'SP',
      'latitude': -23.4678,
      'longitude': -46.5456,
      'opening_hours': '24 horas',
      'phone': '193',
    },
    
    // TRANSPORTE
    {
      'category_id': 5,
      'name': 'Terminal Taboão',
      'description': 'Terminal de ônibus municipal',
      'address': 'Av. Paulo Faccini, 1000',
      'neighborhood': 'Taboão',
      'zip_code': '07175-000',
      'city': 'Guarulhos',
      'state': 'SP',
      'latitude': -23.4534,
      'longitude': -46.5123,
      'opening_hours': '4h-0h',
      'phone': '(11) 2087-8000',
    },
    {
      'category_id': 5,
      'name': 'Aeroporto Internacional de Guarulhos',
      'description': 'Aeroporto Internacional de São Paulo',
      'address': 'Rod. Hélio Smidt, s/n',
      'neighborhood': 'Cumbica',
      'zip_code': '07190-100',
      'city': 'Guarulhos',
      'state': 'SP',
      'latitude': -23.4356,
      'longitude': -46.4731,
      'opening_hours': '24 horas',
      'phone': '(11) 2445-2945',
      'website': 'https://www.gru.com.br',
    },
    
    // CULTURA E LAZER
    {
      'category_id': 6,
      'name': 'Parque Estadual da Cantareira',
      'description': 'Parque de preservação ambiental',
      'address': 'Av. Senador José Ermírio de Moraes, s/n',
      'neighborhood': 'Cabuçu',
      'zip_code': '07000-000',
      'city': 'Guarulhos',
      'state': 'SP',
      'latitude': -23.3567,
      'longitude': -46.5890,
      'opening_hours': 'Ter-Dom: 8h-17h',
      'phone': '(11) 2231-8555',
    },
    {
      'category_id': 6,
      'name': 'Bosque Maia',
      'description': 'Parque municipal com área de lazer',
      'address': 'Av. Paulo Faccini, 1260',
      'neighborhood': 'Jardim Maia',
      'zip_code': '07115-000',
      'city': 'Guarulhos',
      'state': 'SP',
      'latitude': -23.4623,
      'longitude': -46.5445,
      'opening_hours': 'Diariamente: 6h-18h',
      'phone': '(11) 2087-7800',
    },
  ];
}