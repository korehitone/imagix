// import 'package:flutter/material.dart';
// import '../../core/theme/app_colors.dart';
// import '../widgets/app_back_button.dart';
// import '../widgets/app_bottom_nav.dart';
// import '../widgets/app_image_details.dart';

// class ImageDetailPage extends StatefulWidget {
//   final String? imageUrl;
//   final String title;
//   final String description;

//   const ImageDetailPage({
//     super.key,
//     this.imageUrl,
//     this.title = 'Image Title',
//     this.description = 'Description',
//   });

//   @override
//   State<ImageDetailPage> createState() => _ImageDetailPageState();
// }

// class _ImageDetailPageState extends State<ImageDetailPage> {
//   int _currentIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBody: true,
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         bottom: false,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Back Button
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: const AppBackButton(),
//             ),

//             // Image
//             Container(
//               width: double.infinity,
//               height: 420,
//               decoration: BoxDecoration(
//                 border: Border.all(color: AppColors.primary, width: 2),
//               ),
//               child: widget.imageUrl != null
//                   ? Image.network(
//                       widget.imageUrl!,
//                       fit: BoxFit.cover,
//                     )
//                   : Center(
//                       child: Text(
//                         'Image',
//                         style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                               color: AppColors.primary.withOpacity(0.4),
//                             ),
//                       ),
//                     ),
//             ),

//             // Actions + Title + Description
//             AppImageActions(
//               title: widget.title,
//               description: widget.description,
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: AppBottomNav(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() => _currentIndex = index);
//         },
//       ),
//     );
//   }
// }