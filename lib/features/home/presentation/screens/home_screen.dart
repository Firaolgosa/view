import 'package:flutter/material.dart';
import 'package:view/core/widgets/responsive_layout.dart';
import 'package:view/features/web/presentation/screens/web_view_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:view/core/widgets/theme_toggle_button.dart';
import 'package:view/features/social/presentation/screens/instagram_clone_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _HomeMobileLayout(),
      desktop: _HomeDesktopLayout(),
    );
  }
}

class _HomeMobileLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height * 0.3,
              floating: true,
              pinned: true,
              stretch: true,
              actions: const [
                ThemeToggleButton(),
                SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                ],
                background: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/img.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: const Text(
                  'Welcome',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ],
                  ),
                ),
                centerTitle: true,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([                  const SizedBox(height: 24),
                  _buildActionButtons(context),
                  const SizedBox(height: 24),
                  _buildFeaturedSection(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildWelcomeCard() {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome Back!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Explore our latest features and updates',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildActionButtons(BuildContext context) {
  return GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 2,
    mainAxisSpacing: 16,
    crossAxisSpacing: 16,
    childAspectRatio: 1.5,
    children: [
      _buildActionButton(
        'Explore',
        Icons.explore,
        Colors.blue,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WebViewScreen()),
        ),
      ),
      _buildActionButton(
        'Profile',
        Icons.person,
        Colors.green,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WebViewScreen(
              url: 'https://www.google.com',
            ),
          ),
        ),
      ),
      _buildActionButton(
        'House Tour',
        Icons.house,
        Colors.blue,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WebViewScreen(
              url: 'https://cbrs-dashboard-8mig.vercel.app/',
            ),
          ),
        ),
      ),
      _buildActionButton(
        'Help',
        Icons.help,
        Colors.purple,
        ()=> Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const StoryScreen(),
          ),
        ),
      ),
    ],
  );
}

Widget _buildActionButton(
    String title, IconData icon, Color color, VoidCallback onTap) {
  return Material(
    color: color.withOpacity(0.1),
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildFeaturedSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Featured',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          itemBuilder: (context, index) {
            return Container(
              width: 160,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.blue[400]!,
                    Colors.blue[800]!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Work ${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            );
          },
        ),
      ),
    ],
  );
}

class _HomeDesktopLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: CustomScrollView(
              slivers: [
                const SliverAppBar(
                  floating: true,
                  title: Text('Dashboard'),
                  centerTitle: true,
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(24.0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 24.0,
                      crossAxisSpacing: 24.0,
                      childAspectRatio: 1.2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildDashboardCard(index),
                      childCount: 6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildSidebar() {
  return Container(
    width: 250,
    color: Colors.white,
    child: Column(
      children: [
        const SizedBox(height: 24),
        _buildSidebarItem('Dashboard', Icons.dashboard),
        _buildSidebarItem('Analytics', Icons.analytics),
        _buildSidebarItem('Settings', Icons.settings),
      ],
    ),
  );
}

Widget _buildSidebarItem(String title, IconData icon) {
  return ListTile(
    leading: Icon(icon, color: const Color(0xFF8BC34A)),
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
    onTap: () {},
  );
}

Widget _buildDashboardCard(int index) {
  final List<Map<String, dynamic>> items = [
    {'title': 'Analytics', 'icon': Icons.analytics},
    {'title': 'Reports', 'icon': Icons.description},
    {'title': 'Settings', 'icon': Icons.settings},
    {'title': 'Profile', 'icon': Icons.person},
    {'title': 'Messages', 'icon': Icons.message},
    {'title': 'Tasks', 'icon': Icons.task},
  ];

  return Card(
    elevation: 2,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8BC34A).withOpacity(0.7),
            const Color(0xFF8BC34A).withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            items[index]['icon'],
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            items[index]['title'],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}