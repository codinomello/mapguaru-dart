import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../database/database_helper.dart';
import '../models/service_unit_model.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../main.dart';

/// Tela de perfil do usuário
/// 
/// Exibe informações do usuário, favoritos e configurações
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<ServiceUnit> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  /// Carrega favoritos do usuário
  Future<void> _loadFavorites() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (!userProvider.isLoggedIn) {
      setState(() => _isLoading = false);
      return;
    }

    final dbHelper = DatabaseHelper();
    final favoritesData = await dbHelper.getUserFavorites(userProvider.userId!);
    
    setState(() {
      _favorites = favoritesData.map((data) => ServiceUnit.fromMap(data)).toList();
      _isLoading = false;
    });
  }

  /// Faz logout
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Sair da conta',
          style: TextStyle(fontFamily: 'Helvetica'),
        ),
        content: const Text(
          'Tem certeza que deseja sair?',
          style: TextStyle(fontFamily: 'Helvetica'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
      
      await userProvider.logout();
      favoritesProvider.clearFavorites();
      
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppConstants.routeMenu,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          if (userProvider.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _handleLogout,
              tooltip: 'Sair',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header do perfil
                  _buildProfileHeader(userProvider),
                  
                  // Alerta de conta anônima
                  _buildAnonymousAlert(),

                  const SizedBox(height: 24),

                  // Informações da conta
                  if (userProvider.isLoggedIn) ...[
                    _buildAccountInfo(userProvider),
                    const SizedBox(height: 24),
                  ],
                  
                  // Favoritos
                  if (userProvider.isLoggedIn) ...[
                    _buildFavoritesSection(),
                    const SizedBox(height: 24),
                  ],
                  
                  const SizedBox(height: 24),
                  _buildMyMarkersSection(),
                  const SizedBox(height: 24),

                  // Documentos necessários
                  _buildDocumentsSection(),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  /// Constrói header do perfil
  Widget _buildProfileHeader(UserProvider userProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppTheme.cardShadow,
            ),
            child: Icon(
              userProvider.isLoggedIn ? Icons.person : Icons.person_outline,
              size: 50,
              color: AppTheme.primaryColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Nome
          Text(
            userProvider.isLoggedIn
                ? userProvider.userName ?? 'Usuário'
                : 'Visitante',
            style: const TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Email
          if (userProvider.isLoggedIn && userProvider.userEmail != null)
            Text(
              userProvider.userEmail!,
              style: const TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          
          // Botão de login para visitantes
          if (!userProvider.isLoggedIn) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppConstants.routeLogin);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Fazer Login'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnonymousAlert() {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Só mostra se usuário é anônimo
    if (!authService.isAnonymous) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: AppTheme.warning.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppTheme.warning.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber,
                      color: AppTheme.warning,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Conta Temporária',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Seus dados serão perdidos se desinstalar o app',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Mostrar mais informações
                        _showAnonymousInfoDialog();
                      },
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('Saiba mais'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.warning,
                        side: BorderSide(color: AppTheme.warning),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navegar para upgrade
                        Navigator.of(context).pushNamed('/upgrade-account');
                      },
                      icon: const Icon(Icons.upgrade, size: 18),
                      label: const Text('Criar Conta'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.warning,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Dialog com informações sobre conta anônima
  void _showAnonymousInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppTheme.info),
            SizedBox(width: 12),
            Text('Conta Temporária'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Você está usando o MapGuaru como visitante.',
                style: TextStyle(
                  fontFamily: 'Helvetica',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoItem(
                Icons.check_circle_outline,
                'Você pode explorar todos os serviços',
                AppTheme.success,
              ),
              _buildInfoItem(
                Icons.check_circle_outline,
                'Pode usar o mapa interativo',
                AppTheme.success,
              ),
              _buildInfoItem(
                Icons.cancel_outlined,
                'Não pode salvar favoritos',
                AppTheme.error,
              ),
              _buildInfoItem(
                Icons.cancel_outlined,
                'Dados perdidos se desinstalar',
                AppTheme.error,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, 
                      color: AppTheme.warning, 
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Crie uma conta para salvar seus favoritos permanentemente!',
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/upgrade-account');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warning,
            ),
            child: const Text('Criar Conta'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói informações da conta
  Widget _buildAccountInfo(UserProvider userProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações da Conta',
            style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(
                    'Nome',
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color
                    ),
                  ),
                  subtitle: Text(
                    userProvider.userName ?? '-',
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _showEditNameDialog(userProvider),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title:  Text(
                    'E-mail',
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  subtitle: Text(
                    userProvider.userEmail ?? '-',
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: Text(
                    'Senha',
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  subtitle: Text(
                    '••••••••',
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Funcionalidade em desenvolvimento'),
                          backgroundColor: AppTheme.info,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói seção de favoritos
  Widget _buildFavoritesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Meus Favoritos',
                style: TextStyle(
                  fontFamily: 'Helvetica',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const Spacer(),
              Text(
                '${_favorites.length}',
                style: const TextStyle(
                  fontFamily: 'Helvetica',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (_favorites.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 48,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhum favorito ainda',
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ..._favorites.map((unit) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.getCategoryColor(unit.category)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.place,
                    color: AppTheme.getCategoryColor(unit.category),
                    size: 20,
                  ),
                ),
                title: Text(
                  unit.name,
                  style: const TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  unit.neighborhood ?? unit.address,
                  style: const TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red, size: 20),
                  onPressed: () async {
                    final userProvider = Provider.of<UserProvider>(
                      context,
                      listen: false,
                    );
                    final favoritesProvider = Provider.of<FavoritesProvider>(
                      context,
                      listen: false,
                    );
                    
                    await favoritesProvider.toggleFavorite(
                      userProvider.userId!,
                      unit.unitId!,
                    );
                    
                    _loadFavorites();
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Removido dos favoritos'),
                          backgroundColor: AppTheme.success,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                ),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildMyMarkersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meus Marcadores',
            style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          
          FutureBuilder<int>(
            future: DatabaseHelper().countUserCustomMarkers(
              Provider.of<UserProvider>(context, listen: false).userId ?? 0,
            ),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              
              return Card(
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.add_location_alt,
                      color: AppTheme.accentColor,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Marcadores Personalizados',
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '$count ${count == 1 ? 'marcador' : 'marcadores'}',
                    style: const TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 12,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).pushNamed('/my-markers');
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Constrói seção de documentos necessários
  Widget _buildDocumentsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Documentos Necessários',
            style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          
          Card(
            child: Column(
              children: [
                _buildDocumentItem(
                  '1. Carteira de Identidade (RG)',
                  'Documento original com foto',
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildDocumentItem(
                  '2. CPF',
                  'Original ou cópia',
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildDocumentItem(
                  '3. Comprovante de Residência',
                  'Conta de luz, água ou telefone (máximo 3 meses)',
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildDocumentItem(
                  '4. Cartão SUS',
                  'Para serviços de saúde',
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          Card(
            color: AppTheme.info.withOpacity(0.1),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.info,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Documentos podem variar de acordo com o serviço. Consulte a unidade antes de comparecer.',
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói item de documento
  Widget _buildDocumentItem(String title, String description) {
    return ListTile(
      leading: const Icon(
        Icons.description_outlined,
        color: AppTheme.primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
      subtitle: Text(
        description,
        style: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: 12,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  /// Mostra dialog para editar nome
  void _showEditNameDialog(UserProvider userProvider) {
    final controller = TextEditingController(text: userProvider.userName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Editar Nome',
          style: TextStyle(fontFamily: 'Helvetica'),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nome completo',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                final dbHelper = DatabaseHelper();
                await dbHelper.updateUser(
                  userProvider.userId!,
                  {'name': newName},
                );
                await userProvider.updateName(newName);
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nome atualizado com sucesso!'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
  
}
