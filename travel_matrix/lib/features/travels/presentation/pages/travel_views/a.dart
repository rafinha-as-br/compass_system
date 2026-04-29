import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alpine Traverse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C3E50),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const TripDetailScreen(),
    );
  }
}

class TripDetailScreen extends StatelessWidget {
  const TripDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TripAppBar(
        ref: 'TMX-8892-A',
        title: 'The Alpine Traverse',
        date: 'Oct 12 - Oct 24, 2024',
        travelers: '2 Travelers',
      ),
      body: const TripTabView(),
    );
  }
}

class TripAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String ref;
  final String title;
  final String date;
  final String travelers;

  const TripAppBar({
    super.key,
    required this.ref,
    required this.title,
    required this.date,
    required this.travelers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE8ECF0),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Active Trip badge and ref
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A5F4A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ACTIVE TRIP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Text(
                    'Ref: $ref',
                    style: const TextStyle(
                      color: Color(0xFF8E9AAB),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A2C3A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              // Date and travelers row
              Row(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Color(0xFF8E9AAB),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5B6E8C),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 14,
                        color: Color(0xFF8E9AAB),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        travelers,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5B6E8C),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(170);
}

class TripTabView extends StatefulWidget {
  const TripTabView({super.key});

  @override
  State<TripTabView> createState() => _TripTabViewState();
}

class _TripTabViewState extends State<TripTabView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar
        Container(
          margin: const EdgeInsets.only(left: 20, right: 20, top: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            labelColor: const Color(0xFF1A2C3A),
            unselectedLabelColor: const Color(0xFF8E9AAB),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'OVERVIEW'),
              Tab(text: 'ITINERARY'),
              Tab(text: 'PRACTICAL INFO'),
            ],
          ),
        ),
        // Tab bar view
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              OverviewTab(),
              ItineraryTab(),
              PracticalInfoTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// Overview Tab
class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('ROUTE OVERVIEW'),
          const SizedBox(height: 12),
          _buildInfoCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('HIGHLIGHTS'),
          const SizedBox(height: 12),
          _buildHighlightsList(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF8E9AAB),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_outlined, size: 20, color: Color(0xFF1A5F4A)),
              const SizedBox(width: 8),
              const Text(
                '7 Days • 6 Nights',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF1A2C3A),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Moderate',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A5F4A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE8ECF0)),
          const SizedBox(height: 12),
          _buildRoutePoint('Start', 'Chamonix, France', '8:00 AM'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Icon(Icons.arrow_downward, size: 16, color: Color(0xFFB0BEC5)),
          ),
          _buildRoutePoint('End', 'Zermatt, Switzerland', '6:00 PM'),
        ],
      ),
    );
  }

  Widget _buildRoutePoint(String label, String location, String time) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: label == 'Start'
              ? const Color(0xFF1A5F4A)
              : const Color(0xFFE8ECF0),
          child: Icon(
            label == 'Start' ? Icons.play_arrow : Icons.flag,
            size: 12,
            color: label == 'Start' ? Colors.white : const Color(0xFF8E9AAB),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8E9AAB),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                location,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A2C3A),
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF5B6E8C),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightsList() {
    final highlights = [
      'Mont Blanc massif crossing',
      'Matterhorn views',
      'Overnight in mountain huts',
      'Valley descents through larch forests',
    ];
    return Column(
      children: highlights.map((highlight) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A5F4A),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  highlight,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2C3E50),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// Itinerary Tab
class ItineraryTab extends StatelessWidget {
  const ItineraryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ITINERARY TIMELINE',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8E9AAB),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          _buildTimelineItem(
            day: 'Day 1',
            title: 'Travel Start',
            subtitle: 'Departure from Origin',
            location: 'New York City (JFK)',
            isFirst: true,
          ),
          _buildTimelineItem(
            day: 'Day 2',
            title: 'Arrival in Chamonix',
            subtitle: 'Welcome briefing & gear check',
            location: 'Chamonix, France',
          ),
          _buildTimelineItem(
            day: 'Day 3',
            title: 'Col de Balme Crossing',
            subtitle: 'First mountain day',
            location: 'Switzerland Border',
          ),
          _buildTimelineItem(
            day: 'Day 4',
            title: 'Trient Valley',
            subtitle: 'Descent to village',
            location: 'Trient, Switzerland',
          ),
          _buildTimelineItem(
            day: 'Day 5',
            title: 'Fenêtre d\'Arpette',
            subtitle: 'Challenging alpine pass',
            location: 'Val Ferret',
          ),
          _buildTimelineItem(
            day: 'Day 6',
            title: 'Champex-Lac',
            subtitle: 'Rest day by the lake',
            location: 'Champex, Switzerland',
          ),
          _buildTimelineItem(
            day: 'Day 7',
            title: 'Grand Col Ferret',
            subtitle: 'Crossing into Italy',
            location: 'Italian Border',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String day,
    required String title,
    required String subtitle,
    required String location,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline line and dot
        SizedBox(
          width: 50,
          child: Column(
            children: [
              if (!isFirst)
                Container(
                  width: 2,
                  height: 20,
                  color: const Color(0xFFE8ECF0),
                ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A5F4A),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  color: const Color(0xFFE8ECF0),
                ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A5F4A),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2C3A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5B6E8C),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: Color(0xFF8E9AAB)),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8E9AAB),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Practical Info Tab
class PracticalInfoTab extends StatelessWidget {
  const PracticalInfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            'Essential Gear',
            Icons.backpack_outlined,
            [
              'Hiking boots (broken in)',
              'Waterproof jacket & pants',
              'Layered clothing system',
              '30-40L daypack',
              'Sun protection & first aid kit',
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoSection(
            'Weather & Season',
            Icons.wb_sunny_outlined,
            [
              'Daytime: 10-15°C (50-59°F)',
              'Nighttime: 2-7°C (36-45°F)',
              'Possible afternoon showers',
              'Early snow possible at high passes',
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoSection(
            'Documents Required',
            Icons.description_outlined,
            [
              'Valid passport',
              'Travel insurance (mountain coverage)',
              'Hotel/hut vouchers',
              'Emergency contact sheet',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, List<String> items) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF1A5F4A)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2C3A),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFE8ECF0), height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '•',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1A5F4A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2C3E50),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}