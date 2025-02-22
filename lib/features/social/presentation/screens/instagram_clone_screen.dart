import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> with SingleTickerProviderStateMixin {
  File? _selectedImage;
  File? _selectedStoryImage;
  bool _viewingStory = false;
  String? _postCaption;
  final int _storyDuration = 5; // Duration in seconds
  double _storyProgress = 0.0;
  Timer? _storyTimer;
  int _currentStoryIndex = 0;
  final int _totalStories = 5; // Match with your ListView.builder itemCount
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _rotationAnimation;
  List<File> _storyImages = [];
  List<double> _storyProgresses = [];
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ).drive(Tween<double>(begin: 0.0, end: 1.0));

    _rotationAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ).drive(Tween<double>(begin: 0.0, end: 0.3));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _storyTimer?.cancel();
    super.dispose();
  }

  void _startStoryTimer() {
    const updateInterval = Duration(milliseconds: 50);
    final increment = updateInterval.inMilliseconds / (_storyDuration * 1000);
    
    _storyTimer?.cancel();
    _storyTimer = Timer.periodic(updateInterval, (timer) {
      if (!mounted) return; // Check if widget is still mounted
      
      setState(() {
        _storyProgresses[_currentImageIndex] += increment;
        if (_storyProgresses[_currentImageIndex] >= 1.0) {
          if (_currentImageIndex < _storyImages.length - 1) {
            _currentImageIndex++;
            _selectedStoryImage = _storyImages[_currentImageIndex];
            _startStoryTimer(); // Restart timer for next image
          } else {
            _viewingStory = false;
            _currentImageIndex = 0;
            _storyProgresses = List.filled(_storyImages.length, 0.0);
            timer.cancel();
          }
        }
      });
    });
  }

  Future<void> _pickPostImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        if (context.mounted) {
          await _showCaptionDialog();
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _showCaptionDialog() async {
    final controller = TextEditingController();
    final caption = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Add a caption',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Write a caption...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Post', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );

    if (caption != null) {
      setState(() => _postCaption = caption);
    }
  }

  Future<void> _pickStoryImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _storyImages.add(File(image.path));
          _storyProgresses = List.filled(_storyImages.length, 0.0); // Reset all progresses
          _selectedStoryImage = _storyImages[_currentImageIndex];
          _viewingStory = true;
          _currentImageIndex = _storyImages.length - 1; // Set to latest image
          _startStoryTimer(); // Restart timer for new image
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking story: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _animateToNextStory(bool forward) {
    if (forward) {
      setState(() {
        _slideAnimation = CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOutCubic,
        ).drive(Tween<double>(begin: 0.0, end: -1.0));

        _rotationAnimation = CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOutCubic,
        ).drive(Tween<double>(begin: 0.0, end: -0.3));
      });
    } else {
      setState(() {
        _slideAnimation = CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOutCubic,
        ).drive(Tween<double>(begin: 0.0, end: 1.0));

        _rotationAnimation = CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOutCubic,
        ).drive(Tween<double>(begin: 0.0, end: 0.3));
      });
    }

    _animationController.forward(from: 0.0).then((_) {
      setState(() {
        forward ? _currentStoryIndex++ : _currentStoryIndex--;
        _storyProgress = 0.0;
      });
      _animationController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_viewingStory && _storyImages.isNotEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTapDown: (details) {
            final screenWidth = MediaQuery.of(context).size.width;
            _storyTimer?.cancel(); // Cancel current timer
            
            if (details.globalPosition.dx < screenWidth / 2) {
              if (_currentImageIndex > 0) {
                setState(() {
                  _storyProgresses[_currentImageIndex] = 0.0;
                  _currentImageIndex--;
                  _selectedStoryImage = _storyImages[_currentImageIndex];
                  _startStoryTimer(); // Restart timer for previous image
                });
              }
            } else {
              if (_currentImageIndex < _storyImages.length - 1) {
                setState(() {
                  _storyProgresses[_currentImageIndex] = 1.0;
                  _currentImageIndex++;
                  _selectedStoryImage = _storyImages[_currentImageIndex];
                  _startStoryTimer(); // Restart timer for next image
                });
              } else {
                setState(() {
                  _viewingStory = false;
                  _currentImageIndex = 0;
                  _storyProgresses = List.filled(_storyImages.length, 0.0);
                });
              }
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                _storyImages[_currentImageIndex],
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 40,
                left: 10,
                right: 10,
                child: Row(
                  children: List.generate(
                    _storyImages.length,
                    (index) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: _storyProgresses[index],
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            minHeight: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    _storyTimer?.cancel();
                    setState(() {
                      _storyProgress = 0.0;
                      _viewingStory = false;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildStoryList(),
                  const Divider(
                    color: Colors.grey,
                    height: 1,
                    thickness: 0.2,
                  ),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                _buildProfileSection(),
                _buildPostContent(),
              ]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      titleSpacing: 16,
      title: const Text(
        'Eaglelion',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontFamily: 'Instagram Sans',
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.white),
          onPressed: () {},
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        IconButton(
          icon: const Icon(Icons.messenger_outline, color: Colors.white),
          onPressed: () {},
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ],
    );
  }

  Widget _buildStoryList() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) => _buildStoryItem(
          context: context,
          name: index == 0 ? 'Your story' : 'user_$index',
          isYourStory: index == 0,
        ),
      ),
    );
  }

  Widget _buildStoryItem({
    required BuildContext context,
    required String name,
    required bool isYourStory
  }) {
    return GestureDetector(
      onTap: () {
        if (isYourStory) {
          _pickStoryImage();
        } else if (_storyImages.isNotEmpty) {
          setState(() {
            _viewingStory = true;
            _currentImageIndex = 0;
            _selectedStoryImage = _storyImages[0];
            _storyProgresses = List.filled(_storyImages.length, 0.0);
          });
        }
      },
      child: Container(
        width: 72,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                gradient: isYourStory ? null : const LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color(0xFFF06292), Color(0xFFFF9800)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  border: isYourStory && _selectedStoryImage == null 
                      ? Border.all(color: Colors.grey[800]!, width: 1) 
                      : null,
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey[800],
                  backgroundImage: _selectedStoryImage != null && isYourStory 
                      ? FileImage(_selectedStoryImage!) 
                      : null,
                  child: isYourStory && _selectedStoryImage == null
                      ? const Icon(Icons.add, color: Colors.white, size: 24)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: isYourStory ? FontWeight.normal : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue[600],
            ),
            child: const Center(
              child: Text(
                'FR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Fraol19',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1),
              Text(
                'AA, Ethiopia',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: _selectedImage != null
              ? Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                )
              : Image.network(
                  'https://via.placeholder.com/400',
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
        ),
        _buildPostActions(),
        _buildPostDetails(),
      ],
    );
  }

  Widget _buildPostActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.favorite_border, color: Colors.white, size: 28),
          const SizedBox(width: 16),
          const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 24),
          const SizedBox(width: 16),
          const Icon(Icons.send_outlined, color: Colors.white, size: 24),
          const Spacer(),
          Icon(Icons.bookmark_border, color: Colors.white.withOpacity(0.9), size: 28),
        ],
      ),
    );
  }

  Widget _buildPostDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Firaol',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  _selectedImage != null ? (_postCaption ?? 'Add a caption...') : '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_selectedImage == null) Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ) else const SizedBox(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'view comments',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'now',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey[900]!,
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library_outlined),
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index == 2) {
            _pickPostImage();
          }
        },
      ),
    );
  }
} 