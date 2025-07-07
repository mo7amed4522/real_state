// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:real_state_app/core/assets/app_assets.dart';
import '../../bloc/settings_bloc/privacy_bloc.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PrivacyBloc()..add(LoadPrivacyHtml()),
      child: const _PrivacyView(),
    );
  }
}

class _PrivacyView extends StatefulWidget {
  const _PrivacyView();

  @override
  State<_PrivacyView> createState() => _PrivacyViewState();
}

class _PrivacyViewState extends State<_PrivacyView> {
  String? _htmlContent;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    _loadHtml();
  }

  Future<void> _loadHtml() async {
    final html = await rootBundle.loadString(AppAssets.termsPrivacy);
    setState(() {
      _htmlContent = html;
    });
    _controller.loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;
    final title = 'My Privacy & Policy';
    final leading = isIOS
        ? CupertinoNavigationBarBackButton(
            onPressed: () => Navigator.of(context).maybePop(),
          )
        : IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          );

    final header = isIOS
        ? CupertinoNavigationBar(
            middle: Text(title),
            leading: leading,
            backgroundColor: CupertinoTheme.of(
              context,
            ).barBackgroundColor.withOpacity(0.95),
          )
        : AppBar(
            title: Text(title),
            leading: leading,
            backgroundColor: Theme.of(
              context,
            ).appBarTheme.backgroundColor?.withOpacity(0.95),
            elevation: 1,
          );

    return isIOS
        ? CupertinoPageScaffold(
            navigationBar: header as ObstructingPreferredSizeWidget,
            child: _buildWebView(),
          )
        : Scaffold(
            appBar: header as PreferredSizeWidget,
            body: _buildWebView(),
          );
  }

  Widget _buildWebView() {
    if (_htmlContent == null) {
      return const Center(child: CupertinoActivityIndicator());
    }
    return WebViewWidget(controller: _controller);
  }
}
