# 📋 Instruções de Configuração - MapGuaru

Este documento contém todas as instruções necessárias para configurar o projeto MapGuaru do zero.

---

## 📂 Estrutura Completa de Diretórios

Crie a seguinte estrutura de pastas no seu projeto:

```
mapguaru/
├── android/
├── ios/
├── lib/
│   ├── database/
│   │   └── database_helper.dart
│   ├── models/
│   │   └── models.dart
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── menu_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── main_menu_screen.dart
│   │   ├── category_detail_screen.dart
│   │   ├── map_screen.dart
│   │   ├── profile_screen.dart
│   │   └── service_guide_screen.dart
│   ├── utils/
│   │   ├── constants.dart
│   │   └── theme.dart
│   └── main.dart
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
│       ├── Helvetica.ttf
│       └── Helvetica-Bold.ttf
├── pubspec.yaml
└── README.md
```

---

## 🔤 Fontes Helvetica

### Opção 1: Usar fontes alternativas (Recomendado)

Como Helvetica é uma fonte comercial, você pode usar alternativas gratuitas similares:

**Substitua no `pubspec.yaml`:**

```yaml
fonts:
  - family: Helvetica
    fonts:
      - asset: assets/fonts/Roboto-Regular.ttf
      - asset: assets/fonts/Roboto-Bold.ttf
        weight: 700
```

E adicione as fontes Roboto (já inclusas no Flutter) ou baixe gratuitamente de:
- [Google Fonts - Roboto](https://fonts.google.com/specimen/Roboto)
- [Google Fonts - Inter](https://fonts.google.com/specimen/Inter)
- [Google Fonts - Open Sans](https://fonts.google.com/specimen/Open+Sans)

### Opção 2: Usar Helvetica Neue (se disponível)

Se você tem acesso à fonte Helvetica:

1. Crie a pasta `assets/fonts/`
2. Adicione os arquivos:
   - `Helvetica.ttf`
   - `Helvetica-Bold.ttf`
3. Configure conforme o `pubspec.yaml` fornecido

### Opção 3: Remover fonte customizada

Remova a seção `fonts` do `pubspec.yaml` e a propriedade `fontFamily` de todos os TextStyle no código. O Flutter usará a fonte padrão do sistema.

---

## 🖼️ Assets (Imagens e Ícones)

### Criando a pasta de assets

```bash
mkdir -p assets/images
mkdir -p assets/icons
mkdir -p assets/fonts
```

### Imagens necessárias (opcional)

O app não requer imagens obrigatórias, mas você pode adicionar:

- **Logo**: `assets/images/logo.png` (120x120px)
- **Splash**: `assets/images/splash_bg.png`

Se não tiver as imagens, o app usará ícones do Material Design.

---

## ⚙️ Configuração Passo a Passo

### 1. Criar Projeto Flutter

```bash
flutter create mapguaru
cd mapguaru
```

### 2. Substituir pubspec.yaml

Copie todo o conteúdo do arquivo `pubspec.yaml` fornecido.

### 3. Instalar Dependências

```bash
flutter pub get
```

### 4. Criar Estrutura de Pastas

```bash
# No diretório lib/
mkdir database models screens utils

# No diretório raiz
mkdir -p assets/fonts assets/images assets/icons
```

### 5. Copiar Arquivos Dart

Copie todos os arquivos `.dart` fornecidos para suas respectivas pastas:

- `main.dart` → `lib/`
- `database_helper.dart` → `lib/database/`
- `models.dart` → `lib/models/`
- `theme.dart` → `lib/utils/`
- `constants.dart` → `lib/utils/`
- Todas as screens → `lib/screens/`

### 6. Configurar Permissões

#### Android (`android/app/src/main/AndroidManifest.xml`)

Adicione antes do `</manifest>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

#### iOS (`ios/Runner/Info.plist`)

Adicione antes do `</dict>`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Este app precisa da sua localização para mostrar serviços próximos</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Este app precisa da sua localização para mostrar serviços próximos</string>
```

---

## 🔧 Problemas Comuns e Soluções

### Erro: "Font not found"

**Solução**: Remova a seção `fonts` do `pubspec.yaml` ou use fontes alternativas gratuitas.

### Erro: "Package not found"

**Solução**: Execute `flutter pub get` novamente.

### Erro no mapa: "Tile not loading"

**Solução**: Verifique conexão com internet e permissões de rede.

### Erro de build Android

**Solução**: 
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Erro de build iOS

**Solução**:
```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

---

## 🧪 Testando o Aplicativo

### Teste em Emulador Android

```bash
# Listar emuladores
flutter emulators

# Iniciar emulador
flutter emulators --launch <nome_emulador>

# Executar app
flutter run
```

### Teste em Dispositivo Físico

1. Ative **Modo Desenvolvedor** no dispositivo
2. Ative **Depuração USB**
3. Conecte via USB
4. Execute: `flutter run`

### Teste em Emulador iOS (macOS apenas)

```bash
open -a Simulator
flutter run
```

---

## 📱 Gerando APK para Distribuição

### Debug APK (para testes)

```bash
flutter build apk --debug
```

O APK estará em: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK (para produção)

```bash
flutter build apk --release
```

O APK estará em: `build/app/outputs/flutter-apk/app-release.apk`

### App Bundle (Google Play Store)

```bash
flutter build appbundle --release
```

---

## 🎨 Personalizando o App

### Alterando Nome do App

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<application android:label="MapGuaru" ...>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>CFBundleName</key>
<string>MapGuaru</string>
```

### Alterando Ícone do App

Use o pacote `flutter_launcher_icons`:

1. Adicione ao `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"
```

2. Execute:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

### Alterando Cores do Tema

Edite `lib/utils/theme.dart` e altere as cores conforme desejado:

```dart
static const Color primaryColor = Color(0xFF2563EB); // Sua cor aqui
```

---

## 🗄️ Populando Banco de Dados

O banco será populado automaticamente na primeira execução com dados de exemplo.

Para adicionar mais dados:

1. Abra `lib/utils/constants.dart`
2. Adicione entradas no array `sampleServiceUnits`
3. Limpe os dados do app ou desinstale e reinstale

Para resetar o banco em desenvolvimento:

```dart
// Adicione temporariamente no main.dart
await DatabaseHelper().deleteDatabase();
```

---

## 🔍 Debugging e Logs

### Habilitar logs detalhados

```bash
flutter run --verbose
```

### Ver logs do dispositivo

**Android**:
```bash
adb logcat
```

**iOS**:
```bash
xcrun simctl spawn booted log stream --predicate 'processImagePath contains "Runner"'
```

### Inspecionar banco de dados

Use ferramentas como:
- **Android**: DB Browser for SQLite
- **iOS**: Core Data Lab

Localização do banco:
- Android: `/data/data/com.mapguaru.app/databases/mapguaru.db`
- iOS: `Library/Application Support/mapguaru.db`

---

## 📚 Recursos Úteis

### Documentação Oficial

- [Flutter Docs](https://docs.flutter.dev/)
- [Dart Docs](https://dart.dev/guides)
- [flutter_map Docs](https://docs.fleaflet.dev/)

### Tutoriais Recomendados

- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [SQLite em Flutter](https://docs.flutter.dev/cookbook/persistence/sqlite)
- [Provider State Management](https://