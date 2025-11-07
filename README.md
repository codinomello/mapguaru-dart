# Guia de Configuração - MapGuaru

## 📋 Pré-requisitos

- Flutter SDK 3.x ou superior
- Dart 3.x ou superior
- Android Studio ou VS Code com extensões Flutter/Dart
- Conta no Firebase (gratuita)
- Git

## 🔥 Configuração do Firebase

### 1. Criar Projeto no Firebase

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Clique em "Adicionar projeto"
3. Nome do projeto: "MapGuaru" (ou outro de sua preferência)
4. Siga os passos até finalizar a criação

### 2. Adicionar Aplicativo Android

1. No console do Firebase, clique no ícone do Android
2. Nome do pacote: `com.mapguaru.app`
3. Baixe o arquivo `google-services.json`
4. Coloque o arquivo em: `android/app/google-services.json`

### 3. Adicionar Aplicativo iOS (opcional)

1. No console do Firebase, clique no ícone do iOS
2. ID do pacote: `com.mapguaru.app`
3. Baixe o arquivo `GoogleService-Info.plist`
4. Coloque o arquivo em: `ios/Runner/GoogleService-Info.plist`

### 4. Ativar Métodos de Autenticação

No Firebase Console:

1. Vá em **Authentication** > **Sign-in method**
2. Ative os seguintes provedores:

#### Email/Password
- Status: **Ativado**
- Nenhuma configuração adicional necessária

#### Google
- Status: **Ativado**
- Configuração:
  - **Android**: Nenhuma configuração adicional
  - **iOS**: Adicione o `REVERSED_CLIENT_ID` no `Info.plist`

#### Facebook
- Status: **Ativado**
- Configuração:
  1. Criar app no [Facebook Developers](https://developers.facebook.com/)
  2. Copie App ID e App Secret
  3. Cole no Firebase
  4. Configure OAuth redirect URI:
     ```
     https://mapguaru-xxxxx.firebaseapp.com/__/auth/handler
     ```

#### GitHub
- Status: **Ativado**
- Configuração:
  1. Criar OAuth App em [GitHub Settings](https://github.com/settings/developers)
  2. Authorization callback URL:
     ```
     https://mapguaru-xxxxx.firebaseapp.com/__/auth/handler
     ```
  3. Copie Client ID e Client Secret
  4. Cole no Firebase

## 📦 Instalação das Dependências

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/mapguaru.git
cd mapguaru

# Instale as dependências
flutter pub get

# Configure o Firebase CLI (primeira vez)
dart pub global activate flutterfire_cli
flutterfire configure
```

## ⚙️ Configuração do Projeto

### 1. Atualizar `pubspec.yaml`

Certifique-se de que as seguintes dependências estão instaladas:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  
  # Banco de dados local
  sqflite: ^2.3.0
  path: ^1.8.3
  
  # Mapas
  flutter_map: ^6.0.0
  latlong2: ^0.9.0
  
  # HTTP
  http: ^1.1.2
  
  # Gerenciamento de estado
  provider: ^6.1.0
  
  # Autenticação biométrica
  local_auth: ^2.1.7
  
  # Armazenamento local
  shared_preferences: ^2.2.2
```

### 2. Configurar `android/build.gradle`

```gradle
buildscript {
    dependencies {
        // Firebase
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

### 3. Configurar `android/app/build.gradle`

```gradle
apply plugin: 'com.google.gms.google-services'

android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 23
        targetSdkVersion 34
    }
}
```

### 4. Configurar Permissões

#### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<manifest>
    <!-- Permissões de internet -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    
    <!-- Permissões de localização (opcional) -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    
    <!-- Biometria -->
    <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
    <uses-permission android:name="android.permission.USE_FINGERPRINT"/>
</manifest>
```

#### iOS (`ios/Runner/Info.plist`)

```xml
<dict>
    <!-- Biometria -->
    <key>NSFaceIDUsageDescription</key>
    <string>Usamos Face ID para login rápido e seguro</string>
    
    <!-- Localização (opcional) -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Precisamos da sua localização para mostrar serviços próximos</string>
</dict>
```

## 🗺️ Configuração da API do GeoNetwork

O aplicativo se conecta automaticamente ao GeoNetwork de Guarulhos:

```
Base URL: https://geonetwork.guarulhos.sp.gov.br:8443
```

### Camadas Disponíveis

O serviço busca automaticamente as seguintes camadas (ajuste conforme disponibilidade):

- **Saúde**: `guarulhos:saude_equipamentos`, `guarulhos:hospitais`
- **Educação**: `guarulhos:escolas_municipais`, `guarulhos:educacao`
- **Comunidade**: `guarulhos:equipamentos_sociais`
- **Segurança**: `guarulhos:seguranca_publica`
- **Transporte**: `guarulhos:transporte_publico`
- **Cultura**: `guarulhos:equipamentos_culturais`

### Testar Conexão

```bash
# Liste camadas disponíveis
curl "https://geonetwork.guarulhos.sp.gov.br:8443/geoserver/wfs?service=WFS&version=2.0.0&request=GetCapabilities"

# Busque metadados
curl "https://geonetwork.guarulhos.sp.gov.br:8443/geonetwork/srv/api/search/records/_search" \
  -H "Content-Type: application/json" \
  -d '{"query":{"query_string":{"query":"*"}}}'
```

## ▶️ Executando o Projeto

### Modo Debug

```bash
# Android
flutter run

# iOS (requer macOS)
flutter run -d ios

# Web
flutter run -d chrome
```

### Modo Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (para Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 🧪 Testando Funcionalidades

### 1. Login Email/Senha

```dart
// Email de teste
email: teste@mapguaru.com.br
senha: 123456
```

### 2. Login Social

- **Google**: Use uma conta Google real
- **Facebook**: Configure OAuth em developers.facebook.com
- **GitHub**: Configure OAuth em github.com/settings/developers

### 3. Biometria

- **Android**: Configure impressão digital no emulador via Extended Controls
- **iOS**: Configure Face ID/Touch ID no simulador

## 🐛 Troubleshooting

### Erro: "Multidex is disabled"

```gradle
// android/app/build.gradle
android {
    defaultConfig {
        multiDexEnabled true
    }
}

dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

### Erro: "Firebase not initialized"

```bash
# Reconfigure o Firebase
flutterfire configure
flutter clean
flutter pub get
```

### Erro: "Certificate verification failed"

Para desenvolvimento local (GeoNetwork com certificado auto-assinado):

```dart
// Apenas para DESENVOLVIMENTO
HttpOverrides.global = MyHttpOverrides();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
```

### Erro: "Biometric not available"

- Certifique-se de que o dispositivo/emulador tem biometria configurada
- Verifique as permissões no `AndroidManifest.xml` / `Info.plist`

## 📚 Recursos Adicionais

- [Documentação Firebase](https://firebase.google.com/docs)
- [Flutter Firebase Codelab](https://firebase.google.com/codelabs/firebase-get-to-know-flutter)
- [GeoServer Documentation](https://docs.geoserver.org/)
- [GeoNetwork Documentation](https://geonetwork-opensource.org/docs.html)

## 🤝 Suporte

Para dúvidas ou problemas:

1. Verifique as [Issues no GitHub](https://github.com/seu-usuario/mapguaru/issues)
2. Crie uma nova issue com detalhes do erro
3. Entre em contato: contato@mapguaru.com.br

---

**Desenvolvido com ❤️ para a cidade de Guarulhos**