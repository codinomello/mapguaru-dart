import 'package:flutter/material.dart';
import '../services/emergency_service.dart';
import '../utils/theme.dart';

/// Tela de emergências com contatos importantes
class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  EmergencyCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final contacts = _getFilteredContacts();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergências'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showEmergencyInfo,
            tooltip: 'Informações',
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner de alerta
          _buildAlertBanner(),
          
          // Barra de busca
          _buildSearchBar(),
          
          // Filtros de categoria
          _buildCategoryFilters(),
          
          // Lista de contatos
          Expanded(
            child: contacts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      return _buildContactCard(contacts[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _buildPanicButton(),
    );
  }

  /// Banner de alerta
  Widget _buildAlertBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Central de Emergências',
                  style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Ligue apenas em situações de emergência',
                  style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Barra de busca
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Buscar contato de emergência...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  /// Filtros de categoria
  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryChip('Todos', null, Icons.grid_view),
          _buildCategoryChip('Saúde', EmergencyCategory.health, Icons.local_hospital),
          _buildCategoryChip('Segurança', EmergencyCategory.security, Icons.security),
          _buildCategoryChip('Bombeiros', EmergencyCategory.fire, Icons.fire_truck),
          _buildCategoryChip('Defesa Civil', EmergencyCategory.civil, Icons.shield),
          _buildCategoryChip('Serviços', EmergencyCategory.utilities, Icons.build),
        ],
      ),
    );
  }

  /// Chip de categoria
  Widget _buildCategoryChip(String label, EmergencyCategory? category, IconData icon) {
    final isSelected = _selectedCategory == category;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryColor,
      ),
    );
  }

  /// Card de contato
  Widget _buildContactCard(EmergencyContact contact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showContactOptions(contact),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícone
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: contact.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  contact.icon,
                  color: contact.color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // Informações
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contact.number,
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: contact.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contact.description,
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Botão de ligar
              IconButton(
                icon: Icon(
                  Icons.phone,
                  color: contact.color,
                ),
                onPressed: () => _makeCall(contact),
                tooltip: 'Ligar',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Estado vazio
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum contato encontrado',
              style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tente buscar por outro termo',
              style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Botão do pânico (acesso rápido aos principais)
  Widget _buildPanicButton() {
    return FloatingActionButton.extended(
      onPressed: _showQuickEmergencyDialog,
      backgroundColor: const Color(0xFFDC2626),
      icon: const Icon(Icons.emergency),
      label: const Text('EMERGÊNCIA'),
    );
  }

  /// Obtém contatos filtrados
  List<EmergencyContact> _getFilteredContacts() {
    var contacts = EmergencyService.emergencyContacts;
    
    // Filtra por categoria
    if (_selectedCategory != null) {
      contacts = EmergencyService.getContactsByCategory(_selectedCategory!);
    }
    
    // Filtra por busca
    if (_searchQuery.isNotEmpty) {
      contacts = EmergencyService.searchContacts(_searchQuery);
    }
    
    return contacts;
  }

  /// Faz ligação
  Future<void> _makeCall(EmergencyContact contact) async {
    final success = await EmergencyService.makeCall(contact.number);
    
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível fazer a ligação'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  /// Mostra opções de contato
  void _showContactOptions(EmergencyContact contact) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Informações do contato
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: contact.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    contact.icon,
                    color: contact.color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: const TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        contact.number,
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 16,
                          color: contact.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Botões de ação
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _makeCall(contact);
                },
                icon: const Icon(Icons.phone),
                label: const Text('Ligar Agora'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: contact.color,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Dialog de emergência rápida
  void _showQuickEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.emergency, color: Color(0xFFDC2626)),
            const SizedBox(width: 12),
            const Text(
              'Emergência',
              style: TextStyle(fontFamily: 'Helvetica'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Escolha o serviço de emergência:',
              style: TextStyle(fontFamily: 'Helvetica'),
            ),
            const SizedBox(height: 16),
            ..._buildQuickContactButtons(),
          ],
        ),
      ),
    );
  }

  /// Botões de contato rápido
  List<Widget> _buildQuickContactButtons() {
    final quickContacts = [
      EmergencyService.emergencyContacts[0], // SAMU
      EmergencyService.emergencyContacts[1], // PM
      EmergencyService.emergencyContacts[2], // Bombeiros
    ];
    
    return quickContacts.map((contact) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            _makeCall(contact);
          },
          icon: Icon(contact.icon),
          label: Text('${contact.name} - ${contact.number}'),
          style: ElevatedButton.styleFrom(
            backgroundColor: contact.color,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      );
    }).toList();
  }

  /// Mostra informações sobre emergências
  void _showEmergencyInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Quando Ligar?',
          style: TextStyle(fontFamily: 'Helvetica'),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoItem(
                '192 - SAMU',
                'Emergências médicas graves, acidentes, partos, etc.',
              ),
              _buildInfoItem(
                '190 - Polícia Militar',
                'Crimes em andamento, acidentes de trânsito, pessoas em risco.',
              ),
              _buildInfoItem(
                '193 - Bombeiros',
                'Incêndios, pessoas presas, resgates, vazamento de gás.',
              ),
              _buildInfoItem(
                '199 - Defesa Civil',
                'Enchentes, deslizamentos, situações de risco ambiental.',
              ),
              const SizedBox(height: 8),
              const Text(
                '⚠️ Use apenas em emergências reais. Trotes são crime!',
                style: TextStyle(
                  fontFamily: 'Helvetica',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDC2626),
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
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}