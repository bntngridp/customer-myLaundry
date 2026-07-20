import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../../auth/views/login_view.dart';
import '../view_models/home_view_model.dart';
import 'closest_branches_view.dart';
import 'order_bottom_sheet.dart';
import 'active_order_view.dart';

// HomeContainer manages bottom navigation tabs
class HomeContainer extends StatefulWidget {
  const HomeContainer({super.key});

  @override
  State<HomeContainer> createState() => _HomeContainerState();
}

class _HomeContainerState extends State<HomeContainer> {
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeViewModel>(context, listen: false).checkActiveOrder();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeView(),
      const _MockBasketView(),
      const _MockProfileView(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentTab,
            children: pages,
          ),
          
          // Floating Bottom Navigation Bar
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Tab 0: Home
                  _buildTabItem(
                    index: 0,
                    icon: Icons.home_filled,
                    isActive: _currentTab == 0,
                  ),
                  
                  // Tab 1: Orders (Middle floating button)
                  _buildFloatingCenterTab(
                    index: 1,
                    icon: Icons.local_laundry_service,
                    isActive: _currentTab == 1,
                  ),
                  
                  // Tab 2: Profile
                  _buildTabItem(
                    index: 2,
                    icon: Icons.person_rounded,
                    isActive: _currentTab == 2,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTabItem({required int index, required IconData icon, required bool isActive}) {
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.transparent,
        child: Icon(
          icon,
          size: 28,
          color: isActive ? const Color(0xFF0007B0) : Colors.black26,
        ),
      ),
    );
  }

  Widget _buildFloatingCenterTab({required int index, required IconData icon, required bool isActive}) {
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: Transform.translate(
        offset: const Offset(0, -10),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF0007B0),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0007B0).withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ],
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

// HomeView represents the actual content of the Dashboard
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final homeViewModel = Provider.of<HomeViewModel>(context);
    final user = authViewModel.authRepository.currentUser;
    final statusData = homeViewModel.getOrderStatusDetails();

    return RefreshIndicator(
      onRefresh: () => homeViewModel.checkActiveOrder(),
      color: const Color(0xFF0007B0),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Blue Curved Header Card
            _buildHeaderCard(context, user?.username ?? 'Nidu', statusData, homeViewModel),
            
            const SizedBox(height: 24),

            // Promos section (#PenggunaSetia)
            _buildPromoSection(context, homeViewModel),
            
            const SizedBox(height: 28),

            // Services Grid ("Layanan Kami")
            _buildServicesSection(context),
            
            const SizedBox(height: 28),

            // Closest Branches ("Cabang Terdekat")
            _buildBranchesSection(context, homeViewModel),

            const SizedBox(height: 120), // Spacing for floating bottom bar
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, String username, Map<String, dynamic> statusData, HomeViewModel viewModel) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0007B0),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo $username',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            'Pakaian kamu sudah tumpuk nih, pesan yuk',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          
          // Floating Status Card
          GestureDetector(
            onTap: viewModel.activeOrder == null
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ActiveOrderView()),
                    );
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusData['color'],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      statusData['text'],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B1739),
                      ),
                    ),
                  ),
                  if (viewModel.activeOrder != null)
                    const Icon(Icons.arrow_forward_ios, color: Colors.black26, size: 14),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPromoSection(BuildContext context, HomeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '#PenggunaSetia',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B1739),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Semua promo sudah ditampilkan! 🎟️')),
                  );
                },
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF0007B0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 140,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: viewModel.promos.length,
            itemBuilder: (context, index) {
              final promo = viewModel.promos[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0B1739), Color(0xFF0007B0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promo['title']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      promo['subtitle']!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            promo['code']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: promo['code']!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Promo ${promo['code']} disalin! 🎟️')),
                            );
                          },
                          child: const Icon(Icons.copy_rounded, color: Colors.white, size: 20),
                        )
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    final List<Map<String, dynamic>> services = [
      {'label': 'Jemput-Antar', 'icon': Icons.local_shipping, 'color': const Color(0xFFEF4444)},
      {'label': 'Cuci Lipat', 'icon': Icons.dry_cleaning, 'color': const Color(0xFFEAB308)},
      {'label': 'Cuci Satuan', 'icon': Icons.layers, 'color': const Color(0xFF22C55E)},
      {'label': 'Cuci Setrika', 'icon': Icons.iron, 'color': const Color(0xFF38BDF8)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Layanan Kami',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B1739),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: services.map((s) {
              return GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const OrderBottomSheet(),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: s['color'].withValues(alpha: 0.15),
                      ),
                      child: Icon(s['icon'], color: s['color'], size: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s['label'],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B1739),
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
          ),
        )
      ],
    );
  }

  Widget _buildBranchesSection(BuildContext context, HomeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cabang Terdekat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B1739),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClosestBranchesView(branches: viewModel.branches),
                    ),
                  );
                },
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF0007B0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: viewModel.branches.length,
            itemBuilder: (context, index) {
              final branch = viewModel.branches[index];
              return Container(
                width: 220,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 110,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
                            image: DecorationImage(
                              image: NetworkImage(branch.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0007B0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '+${branch.distance} Km',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            branch.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0B1739)),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(branch.address, style: const TextStyle(fontSize: 10, color: Colors.black38)),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Color(0xFFFFD700), size: 14),
                                  Text(branch.rating.toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }
}

// Mock Views for Navigation
class _MockBasketView extends StatelessWidget {
  const _MockBasketView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Keranjang Belanja 🧺', style: TextStyle(fontSize: 18, color: Colors.black54)),
      ),
    );
  }
}

class _MockProfileView extends StatelessWidget {
  const _MockProfileView();

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Profil Pelanggan 👤', style: TextStyle(fontSize: 18, color: Colors.black54)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await authViewModel.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginView()),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Keluar (Logout)'),
            )
          ],
        ),
      ),
    );
  }
}
