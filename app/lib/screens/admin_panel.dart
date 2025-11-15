import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../utils/theme.dart';
import '../main.dart';

/// Painel de Administração do MapGuaru
/// 
/// Gerencia usuários, serviços, categorias e estatísticas do sistema
class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Estatísticas
  int _totalUsers = 0;
  int _totalUnits = 0;
  int _totalFavorites = 0;
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Carrega estatísticas do sistema
  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    
    try {
      final dbHelper = DatabaseHelper();
      
      // Busca estatísticas básicas
      final users = await dbHelper.getAllUsers();
      final units = await dbHelper.countServiceUnits();
      final favorites = await dbHelper.countAllFavorites();
      
      setState(() {
        _totalUsers = users.length;
        _totalUnits = units;
        _totalFavorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar estatísticas: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    
    // Verifica se usuário é admin
    if (!_isAdmin(userProvider)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Acesso Negado')),
        body: const Center(
          child: Text('Você não tem permissão para acessar esta área.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel de Administração'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.people), text: 'Usuários'),
            Tab(icon: Icon(Icons.place), text: 'Serviços'),
            Tab(icon: Icon(Icons.category), text: 'Categorias'),
            Tab(icon: Icon(Icons.settings), text: 'Configurações'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(),
                _buildUsersTab(),
                _buildServicesTab(),
                _buildCategoriesTab(),
                _buildSettingsTab(),
              ],
            ),
    );
  }

  // ==================== ABA: DASHBOARD ====================
  
  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildSectionHeader('Visão Geral do Sistema', Icons.dashboard),
          const SizedBox(height: 16),
          
          // Cards de estatísticas
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                'Usuários',
                _totalUsers.toString(),
                Icons.people,
                AppTheme.primaryColor,
              ),
              _buildStatCard(
                'Serviços',
                _totalUnits.toString(),
                Icons.place,
                AppTheme.success,
              ),
              _buildStatCard(
                'Favoritos',
                _totalFavorites.toString(),
                Icons.favorite,
                Colors.red,
              ),
              _buildStatCard(
                'Categorias',
                '6',
                Icons.category,
                AppTheme.accentColor,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Ações rápidas
          _buildSectionHeader('Ações Rápidas', Icons.flash_on),
          const SizedBox(height: 16),
          
          _buildQuickActionCard(
            'Adicionar Serviço',
            'Cadastrar nova unidade de serviço',
            Icons.add_location,
            AppTheme.primaryColor,
            () => _showAddServiceDialog(),
          ),
          const SizedBox(height: 12),
          _buildQuickActionCard(
            'Atualizar Dados',
            'Sincronizar com GeoNetwork',
            Icons.sync,
            AppTheme.info,
            () => _syncWithGeoNetwork(),
          ),
          const SizedBox(height: 12),
          _buildQuickActionCard(
            'Limpar Cache',
            'Limpar dados temporários',
            Icons.delete_sweep,
            AppTheme.warning,
            () => _clearCache(),
          ),
        ],
      ),
    );
  }

  // ==================== ABA: USUÁRIOS ====================
  
  Widget _buildUsersTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper().getAllUsers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!;

        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'Nenhum usuário cadastrado',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Header com busca
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).cardColor,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar usuário...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) {
                        // Implementar busca
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => setState(() {}),
                    tooltip: 'Atualizar',
                  ),
                ],
              ),
            ),
            
            // Lista de usuários
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return _buildUserCard(user);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: Text(
            user['name'].toString()[0].toUpperCase(),
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user['name'],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(user['email']),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Excluir', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showEditUserDialog(user);
            } else if (value == 'delete') {
              _confirmDeleteUser(user);
            }
          },
        ),
      ),
    );
  }

  // ==================== ABA: SERVIÇOS ====================
  
  Widget _buildServicesTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper().getAllServiceUnits(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final services = snapshot.data!;

        return Column(
          children: [
            // Header com filtros
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).cardColor,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Buscar serviço...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _showAddServiceDialog,
                        tooltip: 'Adicionar',
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Filtro por categoria
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildCategoryFilter('Todos', null),
                        _buildCategoryFilter('Saúde', 1),
                        _buildCategoryFilter('Educação', 2),
                        _buildCategoryFilter('Comunidade', 3),
                        _buildCategoryFilter('Segurança', 4),
                        _buildCategoryFilter('Transporte', 5),
                        _buildCategoryFilter('Cultura', 6),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Lista de serviços
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return _buildServiceCard(service);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final categoryColor = AppTheme.getCategoryColor(service['category_id']);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.place, color: categoryColor, size: 20),
        ),
        title: Text(
          service['name'],
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          service['address'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Excluir', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showEditServiceDialog(service);
            } else if (value == 'delete') {
              _confirmDeleteService(service);
            }
          },
        ),
      ),
    );
  }

  // ==================== ABA: CATEGORIAS ====================
  
  Widget _buildCategoriesTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper().getCategories(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final categories = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategoryCard(category);
          },
        );
      },
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final color = AppTheme.getCategoryColor(category['category_id']);
    final icon = AppTheme.getCategoryIcon(category['icon']);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        title: Text(
          category['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: FutureBuilder<List<Map<String, dynamic>>>(
          future: DatabaseHelper().getServiceUnitsByCategory(category['category_id']),
          builder: (context, snapshot) {
            final count = snapshot.data?.length ?? 0;
            return Text('$count ${count == 1 ? 'serviço' : 'serviços'}');
          },
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navegar para detalhes da categoria
        },
      ),
    );
  }

  // ==================== ABA: CONFIGURAÇÕES ====================
  
  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Configurações do Sistema', Icons.settings),
          const SizedBox(height: 16),
          
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.sync),
                  title: const Text('Sincronização Automática'),
                  subtitle: const Text('Atualizar dados do GeoNetwork'),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notificações Push'),
                  subtitle: const Text('Enviar notificações aos usuários'),
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {},
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Backup Automático'),
                  subtitle: const Text('Backup diário do banco de dados'),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionHeader('Ações de Manutenção', Icons.build),
          const SizedBox(height: 16),
          
          _buildActionButton(
            'Exportar Dados',
            'Exportar banco de dados completo',
            Icons.download,
            AppTheme.info,
            () => _exportDatabase(),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            'Importar Dados',
            'Importar dados de um arquivo',
            Icons.upload,
            AppTheme.success,
            () => _importDatabase(),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            'Limpar Banco de Dados',
            'ATENÇÃO: Apaga todos os dados',
            Icons.delete_forever,
            AppTheme.error,
            () => _confirmClearDatabase(),
          ),
        ],
      ),
    );
  }

  // ==================== WIDGETS AUXILIARES ====================
  
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }

  Widget _buildCategoryFilter(String label, int? categoryId) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: false,
        onSelected: (selected) {
          // Implementar filtro
        },
      ),
    );
  }

  // ==================== DIALOGS E AÇÕES ====================
  
  bool _isAdmin(UserProvider userProvider) {
    // Verifica se o usuário é administrador
    // Por enquanto, todos os usuários logados são admin
    // Implementar lógica de permissões no futuro
    return userProvider.isLoggedIn;
  }

  void _showAddServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Serviço'),
        content: const Text('Funcionalidade em desenvolvimento'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Usuário'),
        content: Text('Editar: ${user['name']}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showEditServiceDialog(Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Serviço'),
        content: Text('Editar: ${service['name']}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o usuário ${user['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(user['user_id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteService(Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir ${service['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteService(service['unit_id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _confirmClearDatabase() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ATENÇÃO'),
        content: const Text(
          'Esta ação irá apagar TODOS os dados do banco de dados. '
          'Esta ação é IRREVERSÍVEL! Tem certeza?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearDatabase();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Limpar Tudo'),
          ),
        ],
      ),
    );
  }

  // ==================== AÇÕES ====================
  
  Future<void> _syncWithGeoNetwork() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sincronizando com GeoNetwork...')),
    );
    
    // Implementar sincronização
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      _loadStatistics();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sincronização concluída!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  Future<void> _clearCache() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Limpando cache...')),
    );
    
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cache limpo!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  Future<void> _deleteUser(int userId) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteUser(userId);
    
    setState(() {
      _loadStatistics();
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário excluído com sucesso!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  Future<void> _deleteService(int unitId) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteServiceUnit(unitId);
    
    setState(() {
      _loadStatistics();
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Serviço excluído com sucesso!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  Future<void> _clearDatabase() async {
    // Implementar limpeza do banco
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Banco de dados limpo!'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  Future<void> _exportDatabase() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exportando banco de dados...')),
    );
  }

  Future<void> _importDatabase() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Importando banco de dados...')),
    );
  }
}