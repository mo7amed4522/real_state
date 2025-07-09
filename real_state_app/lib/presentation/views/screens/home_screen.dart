// ignore_for_file: deprecated_member_use, unnecessary_string_interpolations

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_state_app/core/assets/app_assets.dart';
import 'package:real_state_app/data/models/properties_model.dart';
import 'package:real_state_app/domain/usecases/companies_usecase.dart';
import 'package:real_state_app/data/repositories/companies_repositories_imp.dart';
import 'package:real_state_app/data/repositories/properties_repositories.dart';
import 'package:real_state_app/domain/usecases/properites_usease.dart';
import 'package:real_state_app/presentation/bloc/screens/home_widget.dart';
import 'package:real_state_app/presentation/widgets/loader.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeWidgetBloc(
        companiesUseCase: CompaniesUseCase(CompaniesRepositoriesImp()),
        propertiesUseCase: ProperitesUseCase(PropertiesRepositories()),
      )..add(FetchCompanies()),
      child: Platform.isIOS
          ? CupertinoPageScaffold(
              navigationBar: const CupertinoNavigationBar(middle: Text('Home')),
              child: SafeArea(child: _HomeContent(isCupertino: true)),
            )
          : Scaffold(
              appBar: AppBar(title: const Text('Home')),
              body: SafeArea(child: _HomeContent(isCupertino: false)),
            ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final bool isCupertino;
  const _HomeContent({required this.isCupertino});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isCupertino
        ? (isDark
              ? CupertinoColors.darkBackgroundGray
              : CupertinoColors.systemGrey6)
        : (isDark ? Colors.grey[900]! : Colors.white);
    final Color borderColor = isCupertino
        ? (isDark ? CupertinoColors.systemGrey : CupertinoColors.systemGrey4)
        : (isDark ? Colors.grey[700]! : Colors.grey.shade300);
    final Color selectedColor = isCupertino
        ? CupertinoColors.activeBlue.withOpacity(0.18)
        : Theme.of(context).colorScheme.primary.withOpacity(0.18);
    final Color textColor = isCupertino
        ? (isDark ? CupertinoColors.white : CupertinoColors.black)
        : (isDark ? Colors.white : Colors.black);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Companies',
            style: isCupertino
                ? CupertinoTheme.of(
                    context,
                  ).textTheme.navTitleTextStyle.copyWith(color: textColor)
                : Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: textColor),
          ),
        ),
        SizedBox(
          height: 120,
          child: BlocBuilder<HomeWidgetBloc, HomeWidgetState>(
            builder: (context, state) {
              List companies = [];
              String? selectedCompanyId;
              if (state is CompaniesLoaded) {
                companies = state.companies;
                selectedCompanyId = state.selectedCompanyId;
              } else if (state is PropertiesLoaded) {
                companies = state.companies;
                selectedCompanyId = state.selectedCompanyId;
              }
              if (companies.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: companies.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final company = companies[index];
                      final isSelected = selectedCompanyId == company.id;
                      return GestureDetector(
                        onTap: () {
                          if (!isSelected) {
                            context.read<HomeWidgetBloc>().add(
                              SelectCompany(company.id),
                            );
                            context.read<HomeWidgetBloc>().add(
                              FetchProperties(company.id),
                            );
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          width: 130,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? selectedColor : cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? (isCupertino
                                        ? CupertinoColors.activeBlue
                                        : Theme.of(context).colorScheme.primary)
                                  : borderColor,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color:
                                      (isCupertino
                                              ? CupertinoColors.activeBlue
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.primary)
                                          .withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Logo as background (centered, more visible)
                              Positioned.fill(
                                child: Center(
                                  child: Opacity(
                                    opacity: 0.32,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: company.logoUrl.isNotEmpty
                                          ? Image.network(
                                              company.logoUrl,
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, __, ___) =>
                                                  Image.asset(
                                                    AppAssets.logoApp,
                                                    width: 70,
                                                    height: 70,
                                                    fit: BoxFit.contain,
                                                  ),
                                            )
                                          : Image.asset(
                                              AppAssets.logoApp,
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.contain,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              // Name at the bottom
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        (isCupertino
                                                ? (isDark
                                                      ? CupertinoColors.black
                                                      : CupertinoColors.white)
                                                : (isDark
                                                      ? Colors.black
                                                      : Colors.white))
                                            .withOpacity(0.82),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(16),
                                      bottomRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    company.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isSelected
                                          ? (isCupertino
                                                ? CupertinoColors.activeBlue
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.primary)
                                          : textColor,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else if (state is CompaniesError) {
                return Center(child: Text(state.message));
              } else if (state is HomeWidgetLoading) {
                return Center(child: Loader().lottieWidget());
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Properties',
            style: isCupertino
                ? CupertinoTheme.of(
                    context,
                  ).textTheme.navTitleTextStyle.copyWith(color: textColor)
                : Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: textColor),
          ),
        ),
        Expanded(
          child: BlocBuilder<HomeWidgetBloc, HomeWidgetState>(
            builder: (context, state) {
              List properties = [];
              if (state is PropertiesLoaded) {
                properties = state.properties;
              }
              if (properties.isNotEmpty) {
                return isCupertino
                    ? CupertinoScrollbar(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          itemCount: properties.length,
                          itemBuilder: (context, index) =>
                              _PropertyCard(property: properties[index]),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        itemCount: properties.length,
                        itemBuilder: (context, index) =>
                            _PropertyCard(property: properties[index]),
                      );
              } else if (state is PropertiesError) {
                return Center(child: Text(state.message));
              } else if (state is HomeWidgetLoading) {
                return Center(child: Loader().lottieWidget());
              } else if (state is HomeWidgetInitial) {
                return isCupertino
                    ? const Center(child: CupertinoActivityIndicator())
                    : const Center(child: CircularProgressIndicator());
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

// Property Card (unchanged, but you can further style for Cupertino if needed)

final favoriteProvider = StateProvider.family<bool, String>((ref, id) => false);

class _PropertyCard extends ConsumerStatefulWidget {
  final PropertiesModel property;
  const _PropertyCard({required this.property});

  @override
  ConsumerState<_PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends ConsumerState<_PropertyCard> {
  int _currentImage = 0;
  late final bool isIOS;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isIOS = Theme.of(context).platform == TargetPlatform.iOS;
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.property.images.map((img) => img.imageUrl).toList();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isFavorite = ref.watch(favoriteProvider(widget.property.id));

    Widget favoriteIcon() {
      if (isIOS) {
        return Icon(
          isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
          color: isFavorite
              ? CupertinoColors.systemRed
              : CupertinoColors.inactiveGray,
          size: 28,
        );
      } else {
        return Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : Colors.grey,
          size: 28,
        );
      }
    }

    Widget priceText() {
      final priceStyle = isIOS
          ? CupertinoTheme.of(
              context,
            ).textTheme.navLargeTitleTextStyle.copyWith(
              color: CupertinoColors.activeGreen,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            )
          : theme.textTheme.titleLarge?.copyWith(
              color: Colors.green[700],
              fontWeight: FontWeight.bold,
            );
      return Text('${widget.property.price}', style: priceStyle);
    }

    Widget titleText() {
      final titleStyle = isIOS
          ? CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? CupertinoColors.white : CupertinoColors.black,
            )
          : theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            );
      return Text(
        widget.property.title,
        style: titleStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    Widget propertyTypeChip() {
      final chipColor = isIOS
          ? (isDark ? CupertinoColors.systemGrey : CupertinoColors.systemGrey4)
          : theme.colorScheme.primary.withOpacity(0.08);
      final chipTextStyle = isIOS
          ? CupertinoTheme.of(context).textTheme.textStyle.copyWith(
              color: CupertinoColors.activeBlue,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            )
          : theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            );
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: chipColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(widget.property.propertyType, style: chipTextStyle),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: isDark
            ? (isIOS ? CupertinoColors.darkBackgroundGray : theme.cardColor)
            : (isIOS ? CupertinoColors.systemGrey6 : theme.cardColor),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.18)
                : Colors.grey.withOpacity(0.13),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (images.isNotEmpty)
              Stack(
                children: [
                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: PageView.builder(
                      itemCount: images.length,
                      onPageChanged: (i) => setState(() => _currentImage = i),
                      itemBuilder: (context, idx) => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: ClipRRect(
                          key: ValueKey(images[idx]),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(22),
                            topRight: Radius.circular(22),
                          ),
                          child: Image.network(
                            images[idx],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 220,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[300],
                                  child: Center(
                                    child: isIOS
                                        ? Icon(
                                            CupertinoIcons.photo,
                                            size: 48,
                                            color: CupertinoColors.inactiveGray,
                                          )
                                        : Icon(
                                            Icons.image,
                                            size: 48,
                                            color: Colors.grey,
                                          ),
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Image indicator bar
                  if (images.length > 1)
                    Positioned(
                      bottom: 14,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentImage == i ? 22 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentImage == i
                                  ? (isIOS
                                        ? CupertinoColors.activeBlue
                                        : theme.colorScheme.primary)
                                  : (isIOS
                                        ? CupertinoColors.inactiveGray
                                        : Colors.grey[400]),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Heart icon
                  Positioned(
                    bottom: 18,
                    right: 18,
                    child: GestureDetector(
                      onTap: () =>
                          ref
                                  .read(
                                    favoriteProvider(
                                      widget.property.id,
                                    ).notifier,
                                  )
                                  .state =
                              !isFavorite,
                      child: AnimatedScale(
                        scale: isFavorite ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isIOS
                                ? (isDark
                                          ? CupertinoColors.systemGrey
                                          : CupertinoColors.white)
                                      .withOpacity(0.85)
                                : Colors.white.withOpacity(0.85),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: favoriteIcon(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleText(),
                        const SizedBox(height: 7),
                        propertyTypeChip(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  priceText(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
