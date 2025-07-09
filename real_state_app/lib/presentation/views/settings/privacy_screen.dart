// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
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
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
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
    return BlocBuilder<PrivacyBloc, PrivacyState>(
      builder: (context, state) {
        if (state is PrivacyLoading || state is PrivacyInitial) {
          return const Center(child: CupertinoActivityIndicator());
        } else if (state is PrivacyError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is PrivacyLoaded) {
          _controller.loadHtmlString(state.html);
          return WebViewWidget(controller: _controller);
        }
        return const SizedBox.shrink();
      },
    );
  }
}
