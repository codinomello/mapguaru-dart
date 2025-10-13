import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../models/models.dart';
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

  /// Constrói informações da conta
  Widget _buildAccountInfo(UserProvider userProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informações da Conta',
            style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text(
                    'Nome',
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  subtitle: Text(
                    userProvider.userName ?? '-',
                    style: const TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
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
                  title: const Text(
                    'E-mail',
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  subtitle: Text(
                    userProvider.userEmail ?? '-',
                    style: const TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text(
                    'Senha',
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  subtitle: const Text(
                    '••••••••',
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
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
              const Text(
                'Meus Favoritos',
                style: TextStyle(
                  fontFamily: 'Helvetica',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
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
                        color: AppTheme.textLight,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Nenhum favorito ainda',
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 14,
                          color: AppTheme.textSecondary,
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

  /// Constrói seção de documentos necessários
  Widget _buildDocumentsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Documentos Necessários',
            style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
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
            child: const Padding(
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
                        color: AppTheme.textSecondary,
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
        style: const TextStyle(
          fontFamily: 'Helvetica',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        description,
        style: const TextStyle(
          fontFamily: 'Helvetica',
          fontSize: 12,
          color: AppTheme.textSecondary,
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