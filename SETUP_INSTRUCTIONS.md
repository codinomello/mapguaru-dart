# 🚀 Intruções de Configuração - MapGuaru

## ✅ Checklist de Implementação

### 1. Atualizar Dependências

**Arquivo: `pubspec.yaml`**

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  
  # Banco de dados
  sqflite: ^2.3.0
  path: ^1.8.3
  
  # Mapas
  flutter_map: ^6.0.0
  latlong2: ^0.9.0
  
  # HTTP
  http: ^1.1.2
  
  # Estado
  provider: ^6.1.0
  
  # Armazenamento
  shared_preferences: ^2.2.2
```

**Execute**:
```bash
flutter pub get
```

---

### 2. Substituir Arquivos Atualizados

Copie os seguintes arquivos dos artifacts:

#### ✅ Serviços
- `lib/services/auth_service.dart` ← **auth_service_improved**
- `lib/services/geonetwork_service.dart` ← **geonetwork_service**

#### ✅ Telas
- `lib/screens/login_screen.dart` ← **login_screen_improved**
- `lib/screens/forgot_password_screen.dart` ← **forgot_password_screen**

#### ✅ Database
- `lib/database/database_helper.dart` ← **database_helper_fixed**

#### ✅ Main
- `lib/main.dart` ← **main_updated**

---

### 3. Configurar Firebase

#### 3.1. Criar Projeto no Firebase Console

1. Acesse https://console.firebase.google.com
2. Crie novo projeto: **MapGuaru**
3. Ative Google Analytics (opcional)

#### 3.2. Adicionar App Android

```bash
# Nome do pacote
com.mapguaru.app
```

Baixe `google-services.json` → `android/app/`

#### 3.3. Adicionar App iOS (opcional)

```bash
# Bundle ID
com.mapguaru.app
```

Baixe `GoogleService-Info.plist` → `ios/Runner/`

#### 3.4. Configurar Firebase CLI

```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar projeto
flutterfire configure
```

#### 3.5. Ativar Autenticação

No Firebase Console:
1. **Authentication** > **Sign-in method**
2. Ative:
   - ✅ Email/Password
   - ✅ Google
   - ✅ Facebook (configure OAuth)
   - ✅ GitHub (configure OAuth)

---

### 4. Configurar OAuth (Opcional)

#### 4.1. Google
Já configurado automaticamente pelo Firebase

#### 4.2. Facebook

1. Crie app em https://developers.facebook.com
2. Copie **App ID** e **App Secret**
3. Cole no Firebase Console > Authentication > Facebook
4. Configure OAuth redirect:
   ```
   https://mapguaru-xxxxx.firebaseapp.com/__/auth/handler
   ```

#### 4.3. GitHub

1. Acesse https://github.com/settings/developers
2. Crie **New OAuth App**
3. Authorization callback URL:
   ```
   https://mapguaru-xxxxx.firebaseapp.com/__/auth/handler
   ```
4. Copie **Client ID** e **Client Secret**
5. Cole no Firebase Console > Authentication > GitHub

---

### 5. Configurar Permissões

#### Android: `android/app/src/main/AndroidManifest.xml`

```xml
<manifest>
    <!-- Internet -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    
    <!-- Biometria -->
    <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
    <uses-permission android:name="android.permission.USE_FINGERPRINT"/>
    
    <!-- Localização (opcional) -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
</manifest>
```

#### iOS: `ios/Runner/Info.plist`

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

---

### 6. Testar Funcionalidades

#### 6.1. Teste de Compilação

```bash
flutter clean
flutter pub get
flutter run
```

#### 6.2. Teste de Login Email/Senha

1. Abra o app
2. Clique em **Realizar cadastro**
3. Preencha os dados
4. Clique em **Criar conta**
5. Verifique se foi para tela principal

#### 6.3. Teste de Login Social

**Google**:
1. Clique no botão do Google
2. Selecione uma conta
3. Autorize o acesso
4. Verifique login bem-sucedido

**Facebook/GitHub**: Similar ao Google

#### 6.4. Teste de Biometria

**Android**:
1. Emulador > Extended Controls (...)
2. Fingerprint > Touch sensor
3. No app, clique no botão de biometria
4. "Toque" no sensor virtual

**iOS**:
1. Simulator > Features > Face ID
2. Enrolled
3. No app, clique no botão de biometria
4. Simulator > Features > Matching Face

#### 6.5. Teste de Recuperação de Senha

1. Tela de login > **Esqueci a senha**
2. Digite um email válido
3. Clique em **Enviar Link**
4. Verifique email (pode ir para spam)
5. Clique no link recebido
6. Defina nova senha

#### 6.6. Teste de API do GeoNetwork

```dart
// Adicione na tela principal temporariamente
ElevatedButton(
  onPressed: () async {
    final layers = await GeoNetworkService.getWMSLayers();
    print('Camadas encontradas: ${layers.length}');
    
    for (var layer in layers) {
      print('- ${layer['title']}');
    }
  },
  child: Text('Testar API'),
)
```

---

### 7. Debug de Problemas Comuns

#### Problema: Erro ao compilar

```bash
flutter clean
rm -rf pubspec.lock
flutter pub get
flutter run
```

#### Problema: Firebase não inicializa

```bash
flutterfire configure --force
flutter clean
flutter run
```

#### Problema: Biometria não funciona

**Android**:
- Verifique permissões no `AndroidManifest.xml`
- Configure impressão digital no emulador

**iOS**:
- Verifique `NSFaceIDUsageDescription` no `Info.plist`
- Ative Face ID no simulador

#### Problema: API do GeoNetwork retorna vazia

- Verifique conexão com internet
- Teste URL manualmente:
  ```bash
  curl "https://geonetwork.guarulhos.sp.gov.br:8443/geonetwork/srv/api/search/records/_search"
  ```
- Verifique logs no console com `flutter run -v`

---

### 8. Build para Produção

#### Android APK

```bash
# Debug APK (para testes)
flutter build apk --debug

# Release APK (para distribuição)
flutter build apk --release
```

**Arquivo gerado**: `build/app/outputs/flutter-apk/app-release.apk`

#### Android App Bundle (Google Play)

```bash
flutter build appbundle --release
```

**Arquivo gerado**: `build/app/outputs/bundle/release/app-release.aab`

#### iOS

```bash
flutter build ios --release
```

Depois abra `ios/Runner.xcworkspace` no Xcode para archive e upload.

---

### 9. Variáveis de Ambiente (Opcional)

Para proteger chaves de API, crie `.env`:

```env
FIREBASE_API_KEY=sua_chave_aqui
GEONETWORK_URL=https://geonetwork.guarulhos.sp.gov.br:8443
```

Adicione ao `.gitignore`:
```
.env
*.env
google-services.json
GoogleService-Info.plist
```

---

### 10. Checklist Final

Antes de fazer deploy, verifique:

- ✅ Todos os testes passando
- ✅ Firebase configurado corretamente
- ✅ Permissões configuradas (Android + iOS)
- ✅ OAuth configurado (se usando login social)
- ✅ API do GeoNetwork funcionando
- ✅ Ícone do app personalizado
- ✅ Splash screen configurado
- ✅ Nome do app correto
- ✅ Versão atualizada em `pubspec.yaml`
- ✅ Build de release testado
- ✅ Sem dados sensíveis no código

---

## 📱 Estrutura Final do Projeto

```
mapguaru/
├── android/
│   └── app/
│       ├── google-services.json     ✅
│       └── src/main/AndroidManifest.xml ✅
├── ios/
│   └── Runner/
│       ├── GoogleService-Info.plist ✅
│       └── Info.plist               ✅
├── lib/
│   ├── database/
│   │   └── database_helper.dart     ✅ Atualizado
│   ├── models/
│   │   ├── favorite_model.dart
│   │   ├── news_model.dart
│   │   ├── required_document_model.dart
│   │   ├── service_category_model.dart
│   │   ├── service_unit_model.dart
│   │   ├── user_model.dart
│   ├── screens/
│   │   ├── category_detail_screen.dart
│   │   ├── forgot_password_screen.dart ✅ Atualizado
│   │   ├── login_screen.dart          ✅ Atualizado
│   │   ├── main_menu_screen.dart
│   │   ├── map_screen.dart
│   │   ├── menu_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── register_screen.dart
│   │   ├── service_guide_screen.dart
│   │   └── splash_screen.dart
│   ├── services/
│   │   ├── auth_service.dart          ✅ Atualizado
│   │   ├── geonetwork_service.dart    ✅ Atualizado
│   │   └── theme_service.dart
│   ├── utils/
│   │   ├── constants.dart
│   │   └── theme.dart
│   ├── firebase_options.dart          ✅ Gerado
│   └── main.dart                      ✅ Atualizado
├── pubspec.yaml                       ✅ Atualizado
└── README.md
```

---

## 🎓 Recursos Adicionais

- [Documentação Flutter](https://docs.flutter.dev/)
- [Firebase Flutter](https://firebase.flutter.dev/)
- [GeoNetwork API](https://geonetwork-opensource.org/manuals/trunk/en/api/index.html)
- [Flutter Map](https://docs.fleaflet.dev/)
- [Local Auth](https://pub.dev/packages/local_auth)

---

## 🆘 Suporte

**Problemas?**
1. Verifique os logs: `flutter run -v`
2. Consulte o arquivo `CORREÇÕES.md`
3. Abra uma issue no GitHub

**Tudo funcionando?** 
🎉 Parabéns! Seu app MapGuaru está pronto!

---

**Última atualização**: Outubro 2025
**Versão**: 1.0.0