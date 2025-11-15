<div align="center">

# 🗺️ MapGuaru

**Seu guia para os serviços de Guarulhos**

<p align="center">
<img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter"/>
<img alt="Dart" src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart"/>
<img alt="License" src="https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge"/>
<img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/codinomello/mapguaru-dart?style=for-the-badge&logo=github"/>
</p>

</div>

---

## 📱 Visão Geral

**MapGuaru** é um aplicativo mobile desenvolvido em Flutter que centraliza informações sobre serviços públicos e pontos de interesse da cidade de Guarulhos/SP. O app oferece navegação por categorias, visualização em mapa interativo com OpenStreetMap, sistema de favoritos, autenticação social e perfil de usuário completo.

> 📸 **Galeria de Screenshots** (em breve)

## ✨ Funcionalidades Principais

- ✅ **Autenticação de Usuários** - Login e cadastro com validação
- 🔐 **Login Social** - Google, Facebook e GitHub
- 🗂️ **6 Categorias de Serviços** - Saúde, Educação, Comunidade, Segurança, Transporte, Cultura & Lazer
- 🗺️ **Mapa Interativo** - OpenStreetMap com marcadores por categoria
- ⭐ **Sistema de Favoritos** - Salve seus locais preferidos
- 👤 **Perfil de Usuário** - Gerencie suas informações e favoritos
- 🔍 **Busca e Filtros** - Encontre serviços facilmente
- 📍 **Detalhes dos Locais** - Endereço, telefone, horários e mais
- 💾 **Banco de Dados Local** - SQLite para persistência offline
- 🎨 **Design Consistente** - UI/UX padronizada em todas as telas

---

## 🛠️ Tecnologias Utilizadas

### Core
- **Flutter** 3.x
- **Dart** 3.x
- **Firebase** (Autenticação)

### Principais Pacotes

```yaml
dependencies:
  # Banco de dados
  sqflite: ^2.3.0
  path: ^1.8.3
  
  # Mapas OpenStreetMap
  flutter_map: ^6.0.0
  latlong2: ^0.9.0
  
  # Gerenciamento de estado
  provider: ^6.1.0
  
  # Geolocalização
  geolocator: ^10.0.0
  
  # Criptografia
  crypto: ^3.0.3
  
  # Preferências
  shared_preferences: ^2.2.2
  
  # Icons
  font_awesome_flutter: ^10.7.0
  
  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.16.0
  google_sign_in: ^6.2.0
```

---

## 🚀 Como Executar

Siga os passos abaixo para rodar o projeto localmente.

### 1. Pré-requisitos

- Flutter SDK (versão 3.x ou superior)
- Android Studio ou VS Code com extensões Flutter/Dart
- Dispositivo Android/iOS ou emulador configurado
- Firebase CLI (opcional, para gerar `firebase_options.dart`)

### 2. Instalação

```bash
# Clone o repositório
git clone https://github.com/codinomello/mapguaru-dart.git

# Entre na pasta do projeto
cd mapguaru-dart/app

# Instale as dependências
flutter pub get

# Gere os arquivos gerados automaticamente
flutter pub run build_runner build
```

### 3. Configuração Firebase (Importante!)

Para usar autenticação com Google/Facebook/GitHub, você precisa gerar o arquivo `firebase_options.dart`:

```bash
# Instale o Firebase CLI globalmente (se ainda não tem)
npm install -g firebase-tools

# Use FlutterFire CLI para configurar
dart pub global activate flutterfire_cli

# Configure Firebase para seu projeto
flutterfire configure
```

### 4. Executando o App

```bash
# Inicie o app (certifique-se de ter um emulador/dispositivo conectado)
flutter run

# Ou com logs detalhados
flutter run -v
```

### 5. Build para Produção

```bash
# Gerar um APK (Android)
flutter build apk --release

# Gerar um app bundle (Android)
flutter build appbundle --release

# Gerar para iOS
flutter build ios --release
```

---

## 🎨 Design System

O aplicativo segue um guia de estilo coeso e intuitivo:

### Tipografia
- **Fonte Principal**: Helvetica
- **Tamanhos**: 12px (small), 14px (body), 16px (title), 20px+ (headers)

### Paleta de Cores

| Categoria | Cor | Hex |
|-----------|-----|-----|
| 🏥 Saúde | Roxo Escuro | `#4338CA` |
| 🎓 Educação | Verde | `#059669` |
| 👥 Comunidade | Vermelho | `#DC2626` |
| 🚨 Segurança | Amarelo | `#F59E0B` |
| 🚌 Transporte | Roxo | `#7C3AED` |
| 🎭 Cultura & Lazer | Laranja | `#EA580C` |

### Componentes
- **Cards**: Elevation 6, Border Radius 16
- **Botões**: ElevatedButton com estilos customizados
- **Inputs**: TextFormField com validação integrada
- **Ícones**: Font Awesome com tamanhos consistentes

---

## 🔐 Segurança

- 🔒 Senhas armazenadas com hash **SHA-256**
- ✔️ Validação de inputs no client-side
- 🛡️ Proteção contra SQL Injection (prepared statements do `sqflite`)
- 👤 Sessão de usuário gerenciada com `SharedPreferences`
- 🔑 Autenticação Firebase com OAuth2

---

## 📂 Estrutura do Projeto

<details>
<summary><b>📁 Estrutura de Pastas</b></summary>

```
lib/
├── main.dart                          # Ponto de entrada do app
├── firebase_options.dart              # Configurações Firebase (gerado)
│
├── models/
│   ├── user_model.dart               # Modelo de usuário
│   ├── service_category_model.dart   # Modelo de categoria
│   ├── service_unit_model.dart       # Modelo de unidade de serviço
│   ├── required_document_model.dart  # Modelo de documento necessário
│   ├── favorite_model.dart           # Modelo de favorito
│   ├── news_model.dart               # Modelo de notícia
│   └── custom_marker_model.dart      # Modelo de marcador customizado
│
├── database/
│   └── database_helper.dart          # Helper do SQLite (CRUD operations)
│
├── services/
│   ├── auth_service.dart             # Autenticação (Firebase + Social)
│   ├── geonetwork_service.dart       # Requisições de dados
│   ├── route_service.dart            # Cálculo de rotas
│   ├── news_service.dart             # Dados de notícias
│   ├── emergency_service.dart        # Serviços de emergência
│   └── theme_service.dart            # Tema do app
│
├── screens/
│   ├── splash_screen.dart            # Tela de splash
│   ├── menu_screen.dart              # Menu inicial
│   ├── login_screen.dart             # Login com email
│   ├── register_screen.dart          # Cadastro de novo usuário
│   ├── forgot_password_screen.dart   # Recuperação de senha
│   ├── main_menu_screen.dart         # Menu principal (6 categorias)
│   ├── category_detail_screen.dart   # Detalhes da categoria
│   ├── map_screen.dart               # Mapa interativo
│   ├── profile_screen.dart           # Perfil do usuário
│   ├── my_markers_screen.dart        # Marcadores customizados
│   ├── news_screen.dart              # Notícias e eventos
│   ├── service_guide_screen.dart     # Guia de serviços
│   ├── city_guide_screen.dart        # Guia cultural
│   ├── emergency_screen.dart         # Contatos de emergência
│   ├── admin_panel.dart              # Painel administrativo
│   └── profile_guide_screen.dart     # Guia de perfil
│
├── utils/
│   ├── constants.dart                # Constantes globais
│   ├── theme.dart                    # Tema, cores e estilos
│   └── validators.dart               # Funções de validação
│
└── build/
    └── generated_plugin_registrant.dart  # (Gerado automaticamente)
```

</details>

<details>
<summary><b>🗄️ Estrutura do Banco de Dados (SQLite)</b></summary>

### Tabela: `users`
```sql
CREATE TABLE users (
  user_id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  firebase_uid TEXT UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### Tabela: `service_categories`
```sql
CREATE TABLE service_categories (
  category_id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  icon TEXT
);
```

### Tabela: `service_units`
```sql
CREATE TABLE service_units (
  unit_id INTEGER PRIMARY KEY AUTOINCREMENT,
  category_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  address TEXT,
  neighborhood TEXT,
  zip_code TEXT,
  city TEXT DEFAULT 'Guarulhos',
  state TEXT DEFAULT 'SP',
  latitude REAL,
  longitude REAL,
  opening_hours TEXT,
  phone TEXT,
  email TEXT,
  website TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(category_id) REFERENCES service_categories(category_id)
);
```

### Tabela: `required_documents`
```sql
CREATE TABLE required_documents (
  document_id INTEGER PRIMARY KEY AUTOINCREMENT,
  unit_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  FOREIGN KEY(unit_id) REFERENCES service_units(unit_id)
);
```

### Tabela: `favorites`
```sql
CREATE TABLE favorites (
  favorite_id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  unit_id INTEGER NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, unit_id),
  FOREIGN KEY(user_id) REFERENCES users(user_id),
  FOREIGN KEY(unit_id) REFERENCES service_units(unit_id)
);
```

### Tabela: `news`
```sql
CREATE TABLE news (
  news_id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT,
  location TEXT,
  start_date DATETIME,
  end_date DATETIME,
  service_type TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### Tabela: `custom_markers`
```sql
CREATE TABLE custom_markers (
  marker_id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  description TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(user_id) REFERENCES users(user_id)
);
```

</details>

<details>
<summary><b>🔄 Fluxo de Navegação</b></summary>

```
┌──────────────────┐
│  Splash Screen   │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐      ┌─────────────┐
│  Menu Inicial    │◄─────┤   Logout    │
│ Login/Cadastro   │      └─────────────┘
└────────┬─────────┘
         │
    ┌────┼─────────┬──────────┐
    │    │         │          │
    ▼    ▼         ▼          ▼
┌─────────┐  ┌──────┐  ┌────────────┐
│ Login   │  │Regis │  │ Esqueci    │
│         │  │ tro  │  │ Senha      │
└────┬────┘  └───┬──┘  └────────────┘
     │           │
     └─────┬─────┘
           │
           ▼
    ┌──────────────────┐
    │ Menu Principal   │
    │ (6 Categorias)   │
    └────────┬─────────┘
             │
   ┌─────────┼──────────┬────────────┐
   │         │          │            │
   ▼         ▼          ▼            ▼
┌──────┐  ┌────┐  ┌─────────┐  ┌────────┐
│Categ │  │Mapa│  │Notícias │  │Perfil  │
│oria  │  │    │  │         │  │        │
└──────┘  └────┘  └─────────┘  └────────┘
   │         │          │            │
   └─────────┴──────────┴────────────┘
           │
           ▼
      ┌─────────┐
      │ Guias   │
      │ Utilitá│
      └─────────┘
```

</details>

<details>
<summary><b>📝 Funcionalidades por Tela</b></summary>

### 1. **Splash Screen**
- Animação de entrada com logo
- Carregamento de dados iniciais
- Verificação de sessão ativa
- Navegação automática

### 2. **Menu Inicial**
- Opções de Login e Cadastro destacadas
- Acesso como visitante
- Links para redes sociais (em breve)

### 3. **Login**
- Validação de email e senha
- Campo "Lembrar-me"
- Recuperação de senha
- Login social (Google, Facebook, GitHub)
- Redirecionamento para cadastro

### 4. **Cadastro**
- Validação em tempo real
- Confirmação de senha
- Aceite de termos de uso
- Login social durante registro

### 5. **Menu Principal**
- Grid de 6 categorias com ícones
- Boas-vindas personalizadas com nome do usuário
- Botão flutuante para mapa
- Acesso rápido ao perfil
- Card de notícias em destaque

### 6. **Detalhes da Categoria**
- Lista de unidades de serviço
- Busca por nome/bairro
- Sistema de favoritos (⭐)
- Visualização rápida em mapa
- Detalhes completos de cada unidade

### 7. **Mapa Interativo**
- Marcadores coloridos por categoria
- Filtro por categoria
- Detalhes ao clicar no marcador
- Lista alternativa de locais
- Centralização automática em local
- Cálculo de rotas
- Zoom e pan interativos
- Camadas WMS opcionais

### 8. **Perfil**
- Informações do usuário (nome, email)
- Lista de favoritos
- Marcadores customizados
- Documentos necessários por serviço
- Opções de edição
- Logout

### 9. **Notícias e Eventos**
- Lista de notícias e eventos
- Filtro por categoria
- Data de início/término
- Localização do evento

### 10. **Guias Informativos**
- **Guia de Serviços**: Tutorial de uso do app
- **Guia Cultural**: Informações sobre Guarulhos
- **Guia de Perfil**: Como usar o sistema de favoritos

### 11. **Emergências**
- Contatos de emergência
- SAMU, Polícia, Corpo de Bombeiros
- Números de utilidade pública

### 12. **Admin Panel** (Futuro)
- Gerenciamento de categorias
- CRUD de unidades de serviço
- Moderação de notícias

</details>

---

## 🗺️ Roadmap

Funcionalidades planejadas para as próximas versões:

### Versão 1.1 (Próxima)
- [ ] Compartilhamento de locais via WhatsApp/email
- [ ] Avaliações e comentários de serviços
- [ ] Sistema de notificações push

### Versão 1.2
- [ ] Dark mode (Modo Escuro)
- [ ] Múltiplos idiomas (pt-BR, en-US, es-ES)
- [ ] Acessibilidade aprimorada (WCAG 2.1)
- [ ] Histórico de locais visitados
- [ ] Modo offline completo

### Versão 2.0
- [ ] Integração com Google Maps (alternativa)
- [ ] Plataforma web (NextJS/React)
- [ ] Backend customizado (Go/Node.js)
- [ ] API GraphQL
- [ ] Sincronização em nuvem

---

## 🤝 Contribuindo

Contribuições são muito bem-vindas! Se você tem ideias para melhorias ou encontrou algum bug, sinta-se à vontade para:

1. Fazer um **Fork** do projeto
2. Criar uma **Branch** para sua feature (`git checkout -b feature/MinhaFeature`)
3. **Commit** suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. **Push** para a Branch (`git push origin feature/MinhaFeature`)
5. Abrir um **Pull Request**

### Padrões de Código
- Utilize **camelCase** para variáveis e métodos
- Mantenha **funções pequenas** e focadas
- Adicione **comentários** para lógica complexa
- Siga o **Dart style guide** oficial

Para problemas, abra uma [Issue](https://github.com/codinomello/mapguaru-dart/issues).

---

## 📄 Licença

Este projeto é distribuído sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 🙋 Suporte

Tem dúvidas ou sugestões? Abra uma issue ou entre em contato!

---

<div align="center">

**Desenvolvido com 💙 para a cidade de Guarulhos**  
Projeto acadêmico de desenvolvimento mobile

<br>

**⭐ Se este projeto foi útil, deixe uma estrela no GitHub! ⭐**

[![GitHub Stars](https://img.shields.io/github/stars/codinomello/mapguaru-dart?style=social)](https://github.com/codinomello/mapguaru-dart)

</div>