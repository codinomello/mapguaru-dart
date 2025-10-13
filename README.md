# MapGuaru

![MapGuaru Logo](https://img.shields.io/badge/MapGuaru-1.0.0-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)

**Seu guia para os serviços de Guarulhos**

---

## 📱 Sobre o Projeto

MapGuaru é um aplicativo mobile desenvolvido em Flutter que centraliza informações sobre serviços públicos e pontos de interesse da cidade de Guarulhos/SP. O app oferece navegação por categorias (Saúde, Educação, Comunidade, Segurança, Transporte, Cultura & Lazer), visualização em mapa interativo com OpenStreetMap, sistema de favoritos e perfil de usuário completo.

---

## ✨ Funcionalidades Principais

- ✅ **Autenticação de usuários** - Login e cadastro completo
- 🗂️ **6 Categorias de Serviços** - Saúde, Educação, Comunidade, Segurança, Transporte, Cultura & Lazer
- 🗺️ **Mapa Interativo** - Visualização com OpenStreetMap
- ⭐ **Sistema de Favoritos** - Salve seus locais preferidos
- 👤 **Perfil de Usuário** - Gerencie suas informações
- 🔍 **Busca e Filtros** - Encontre serviços facilmente
- 📍 **Detalhes dos Locais** - Endereço, telefone, horários e mais
- 💾 **Banco de Dados Local** - SQLite para persistência de dados

---

## 🛠️ Tecnologias Utilizadas

### Framework & Linguagem
- **Flutter** 3.x
- **Dart** 3.x

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
  
  # Criptografia
  crypto: ^3.0.3
  
  # Preferências
  shared_preferences: ^2.2.2
```

---

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                          # Ponto de entrada do app
├── models/
│   ├── user.dart                      # Modelo de usuário
│   ├── service_category.dart          # Modelo de categoria
│   ├── service_unit.dart              # Modelo de unidade de serviço
│   ├── required_document.dart         # Modelo de documento
│   ├── favorite.dart                  # Modelo de favorito
│   └── news.dart                      # Modelo de notícia
├── database/
│   └── database_helper.dart           # Helper do SQLite
├── screens/
│   ├── splash_screen.dart             # Tela de splash
│   ├── menu_screen.dart               # Menu inicial
│   ├── login_screen.dart              # Tela de login
│   ├── register_screen.dart           # Tela de cadastro
│   ├── main_menu_screen.dart          # Menu principal
│   ├── category_detail_screen.dart    # Detalhes da categoria
│   ├── map_screen.dart                # Mapa interativo
│   ├── profile_screen.dart            # Perfil do usuário
│   └── service_guide_screen.dart      # Guia de serviços
├── widgets/
│   ├── category_card.dart             # Card de categoria
│   ├── service_unit_card.dart         # Card de unidade
│   └── custom_button.dart             # Botão customizado
└── utils/
    ├── constants.dart                 # Constantes do app
    └── theme.dart                     # Tema e cores
```

---

## 🗄️ Estrutura do Banco de Dados

### Tabelas

#### `users`
Informações dos usuários do sistema
- `user_id` (PK) - ID do usuário
- `name` - Nome completo
- `email` (UNIQUE) - Email
- `password_hash` - Hash da senha (SHA-256)
- `firebase_uid` (UNIQUE) - UID do Firebase (opcional)
- `created_at` - Data de criação

#### `service_categories`
Categorias de serviços
- `category_id` (PK) - ID da categoria
- `name` - Nome da categoria
- `description` - Descrição
- `icon` - Nome do ícone

#### `service_units`
Unidades prestadoras de serviço
- `unit_id` (PK) - ID da unidade
- `category` (FK) - Categoria da unidade
- `name` - Nome da unidade
- `description` - Descrição
- `address` - Endereço
- `neighborhood` - Bairro
- `zip_code` - CEP
- `city` - Cidade
- `state` - Estado
- `latitude` - Latitude
- `longitude` - Longitude
- `opening_hours` - Horário de funcionamento
- `phone` - Telefone
- `email` - Email
- `website` - Website
- `created_at` - Data de criação

#### `required_documents`
Documentos necessários por unidade
- `document_id` (PK) - ID do documento
- `unit_id` (FK) - ID da unidade
- `name` - Nome do documento
- `description` - Descrição

#### `favorites`
Favoritos dos usuários
- `favorite_id` (PK) - ID do favorito
- `user_id` (FK) - ID do usuário
- `unit_id` (FK) - ID da unidade
- `created_at` - Data de criação
- UNIQUE(user_id, unit_id)

#### `news`
Notícias e eventos
- `news_id` (PK) - ID da notícia
- `title` - Título
- `description` - Descrição
- `location` - Local
- `start_date` - Data de início
- `end_date` - Data de término
- `service_type` - Tipo de serviço
- `created_at` - Data de criação

---

## 🚀 Como Executar

### Pré-requisitos

- Flutter SDK instalado (versão 3.x ou superior)
- Android Studio ou VS Code com extensões Flutter/Dart
- Dispositivo Android/iOS ou emulador configurado

### Instalação

1. **Clone o repositório**
```bash
git clone https://github.com/seu-usuario/mapguaru.git
cd mapguaru
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Execute o aplicativo**
```bash
flutter run
```

### Build para Produção

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

---

## 🎨 Design

O aplicativo segue o design system com:

- **Fonte Principal**: Helvetica
- **Cores das Categorias**:
  - 🏥 Saúde: Roxo Escuro (`#4338CA`)
  - 🎓 Educação: Verde (`#059669`)
  - 👥 Comunidade: Vermelho (`#DC2626`)
  - 🚨 Segurança: Amarelo (`#F59E0B`)
  - 🚌 Transporte: Roxo (`#7C3AED`)
  - 🎭 Cultura & Lazer: Laranja (`#EA580C`)

---

## 🔄 Fluxo de Navegação

```
┌─────────────────┐
│  Splash Screen  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Menu Inicial  │◄────┐
│  Login/Cadastro │     │
└────────┬────────┘     │
         │              │
    ┌────┼────┐         │
    │    │    │         │
    ▼    ▼    ▼         │
┌───────┐ ┌──────┐     │
│ Login │ │Regis-│     │
│       │ │ tro  │     │
└───┬───┘ └───┬──┘     │
    │         │        │
    └────┬────┘        │
         │             │
         ▼             │
┌─────────────────┐    │
│  Menu Principal │    │
│  (6 Categorias) │    │
└────────┬────────┘    │
         │             │
    ┌────┼─────┬───────┤
    │    │     │       │
    ▼    ▼     ▼       ▼
┌────────┐ ┌────┐ ┌──────┐
│Detalhes│ │Mapa│ │Perfil│
│Categoria│ │    │ │      │
└────────┘ └────┘ └──┬───┘
                     │
                     ▼
                 ┌────────┐
                 │ Logout │
                 └────────┘
```

---

## 📝 Funcionalidades por Tela

### 1. Splash Screen
- Animação de entrada com logo
- Carregamento de dados iniciais
- Navegação automática

### 2. Menu Inicial
- Opções de Login e Cadastro
- Acesso como visitante
- Login social (Facebook, WhatsApp, Instagram)

### 3. Login
- Validação de email e senha
- Recuperação de senha
- Feedback visual de erros

### 4. Cadastro
- Validação de dados
- Confirmação de senha
- Aceite de termos de uso

### 5. Menu Principal
- Grid de 6 categorias
- Boas-vindas personalizadas
- Acesso rápido ao perfil
- Botão flutuante para mapa

### 6. Detalhes da Categoria
- Lista de unidades
- Busca por nome/bairro
- Sistema de favoritos
- Visualização em mapa

### 7. Mapa Interativo
- Marcadores coloridos por categoria
- Filtro por categoria
- Detalhes ao clicar no marcador
- Lista de locais
- Centralização e zoom

### 8. Perfil
- Informações do usuário
- Edição de nome
- Lista de favoritos
- Documentos necessários
- Logout

### 9. Guia de Serviços
- Tutorial de uso
- Descrição das categorias
- Dicas úteis
- Informações de contato

---

## 🔐 Segurança

- Senhas armazenadas com hash SHA-256
- Validação de inputs no client-side
- Proteção contra SQL Injection (uso de prepared statements)
- Sessão de usuário com SharedPreferences

---

## 🌍 Localização

O aplicativo está focado na cidade de **Guarulhos/SP** com:
- Coordenadas centrais: -23.4538, -46.5333
- Dados de exemplo de unidades reais
- Mapa OpenStreetMap otimizado para a região

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Para contribuir:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 👨‍💻 Autor

**Desenvolvido com 💙 para a cidade de Guarulhos**

Projeto acadêmico de desenvolvimento mobile

---

## 📞 Contato e Suporte

Para dúvidas, sugestões ou reportar problemas:

- 🐛 Issues: [GitHub Issues](https://github.com/seu-usuario/mapguaru/issues)
- 📧 Email: contato@mapguaru.com.br
- 🌐 Website: www.mapguaru.com.br

---

## 🗺️ Roadmap

### Versão 1.1 (Planejada)
- [ ] Notificações push para eventos
- [ ] Modo offline completo
- [ ] Integração com Google Maps
- [ ] Compartilhamento de locais
- [ ] Avaliações de serviços

### Versão 1.2 (Planejada)
- [ ] Dark mode
- [ ] Múltiplos idiomas
- [ ] Acessibilidade aprimorada
- [ ] Widget de busca rápida
- [ ] Histórico de locais visitados

---

## 📊 Estatísticas do Projeto

- 📱 **Telas**: 9 telas completas
- 🗄️ **Tabelas**: 6 tabelas no banco
- 🏛️ **Categorias**: 6 categorias de serviços
- 📍 **Locais de Exemplo**: 12+ unidades cadastradas
- 🎨 **Componentes Customizados**: 15+

---

## 🙏 Agradecimentos

- OpenStreetMap pela API de mapas gratuita
- Flutter Team pelo excelente framework
- Comunidade Dart/Flutter pelo suporte
- Prefeitura de Guarulhos pelos dados públicos

---

<div align="center">

**⭐ Se este projeto foi útil, deixe uma estrela no GitHub! ⭐**

Made with ❤️ and Flutter

</div>