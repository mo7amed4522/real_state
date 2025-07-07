// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:real_state_app/core/assets/app_assets.dart';
import 'package:real_state_app/presentation/bloc/upload_photo_bloc.dart';
import 'package:real_state_app/presentation/widgets/animated_photo.dart';

class UploadPhotoScreen extends StatelessWidget {
  const UploadPhotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final cupertinoTheme = CupertinoTheme.of(context);
    final materialTheme = Theme.of(context);
    return BlocProvider(
      create: (context) => UploadPhotoBloc(),
      child: BlocBuilder<UploadPhotoBloc, UploadPhotoState>(
        builder: (context, state) {
          final photoWidget = state is UploadSuccess
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(state.imagePath),
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(
                  isIOS ? CupertinoIcons.photo_camera : Icons.add_a_photo,
                  size: 50,
                  color: isIOS
                      ? (cupertinoTheme.brightness == Brightness.dark
                            ? CupertinoColors.white.withOpacity(0.7)
                            : CupertinoColors.inactiveGray)
                      : materialTheme.colorScheme.onSurface.withOpacity(0.5),
                );
          return isIOS
              ? CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(
                    leading: GestureDetector(
                      onTap: () {
                        Future.microtask(() {
                          if (context.mounted &&
                              Navigator.of(
                                context,
                                rootNavigator: true,
                              ).canPop()) {
                            Navigator.of(context, rootNavigator: true).pop();
                          }
                        });
                      },
                      child: Icon(
                        CupertinoIcons.back,
                        color: cupertinoTheme.brightness == Brightness.dark
                            ? CupertinoColors.white
                            : CupertinoColors.label,
                      ),
                    ),
                    middle: const Text('Upload Photo'),
                    backgroundColor: CupertinoColors.systemBackground,
                    border: null,
                  ),
                  child: SafeArea(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 32),
                            Center(
                              child: AnimatedPhoto(
                                imageAsset: AppAssets.logoApp,
                                height: 100,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Upload Your Photo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                fontFamily: '.SF Pro Text',
                                color:
                                    cupertinoTheme.brightness == Brightness.dark
                                    ? CupertinoColors.white
                                    : CupertinoColors.label,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            GestureDetector(
                              onTap: () => context.read<UploadPhotoBloc>().add(
                                PhotoSelected(source: ImageSource.gallery),
                              ),
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        cupertinoTheme.brightness ==
                                            Brightness.dark
                                        ? CupertinoColors.activeBlue
                                        : CupertinoColors.activeBlue
                                              .withOpacity(0.7),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  color:
                                      cupertinoTheme.brightness ==
                                          Brightness.dark
                                      ? CupertinoColors.darkBackgroundGray
                                            .withOpacity(0.4)
                                      : CupertinoColors.systemGrey5.withOpacity(
                                          0.4,
                                        ),
                                ),
                                child: Center(child: photoWidget),
                              ),
                            ),
                            const SizedBox(height: 32),
                            CupertinoButton.filled(
                              onPressed: () =>
                                  context.read<UploadPhotoBloc>().add(
                                    PhotoSelected(source: ImageSource.gallery),
                                  ),
                              child: const Text('Change Photo'),
                            ),
                            const SizedBox(height: 16),
                            CupertinoButton(
                              onPressed: () => context.push('/home'),
                              child: const Text('Skip'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : Scaffold(
                  appBar: AppBar(
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: materialTheme.brightness == Brightness.dark
                            ? Colors.white
                            : materialTheme.colorScheme.onBackground,
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
                  backgroundColor: materialTheme.colorScheme.background,
                  body: SafeArea(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 32),
                            Center(
                              child: AnimatedPhoto(
                                imageAsset: AppAssets.logoApp,
                                height: 100,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Upload Your Photo',
                              style: materialTheme.textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                    color:
                                        materialTheme.brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : materialTheme
                                              .colorScheme
                                              .onBackground,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            GestureDetector(
                              onTap: () => context.read<UploadPhotoBloc>().add(
                                PhotoSelected(source: ImageSource.gallery),
                              ),
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: materialTheme.colorScheme.primary
                                        .withOpacity(0.5),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  color:
                                      materialTheme.brightness ==
                                          Brightness.dark
                                      ? materialTheme.colorScheme.surface
                                            .withOpacity(0.3)
                                      : materialTheme.colorScheme.surface
                                            .withOpacity(0.5),
                                ),
                                child: Center(child: photoWidget),
                              ),
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () =>
                                    context.read<UploadPhotoBloc>().add(
                                      PhotoSelected(
                                        source: ImageSource.gallery,
                                      ),
                                    ),
                                child: const Text('Change Photo'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => Navigator.of(context).maybePop(),
                              child: const Text(
                                'Skip',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }
}
