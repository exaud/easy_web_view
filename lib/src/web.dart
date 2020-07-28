import 'dart:html' as html;
import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'impl.dart';

class EasyWebView extends StatefulWidget implements EasyWebViewImpl {
  const EasyWebView({
    Key key,
    @required this.src,
    this.height,
    this.width,
    this.webAllowFullScreen = true,
    this.isHtml = false,
    this.isMarkdown = false,
    this.convertToWidgets = false,
    this.headers = const {},
    this.widgetsTextSelectable = false,
  })  : assert((isHtml && isMarkdown) == false),
        super(key: key);

  @override
  _EasyWebViewState createState() => _EasyWebViewState();

  @override
  final num height;

  @override
  final String src;

  @override
  final num width;

  @override
  final bool webAllowFullScreen;

  @override
  final bool isMarkdown;

  @override
  final bool isHtml;

  @override
  final bool convertToWidgets;

  @override
  final Map<String, String> headers;

  @override
  final bool widgetsTextSelectable;
}

class _EasyWebViewState extends State<EasyWebView> {
  @override
  void didUpdateWidget(EasyWebView oldWidget) {
    if (oldWidget.height != widget.height) {
      if (mounted) setState(() {});
    }
    if (oldWidget.width != widget.width) {
      if (mounted) setState(() {});
    }
    if (oldWidget.src != widget.src) {
      if (mounted) setState(() {});
    }
    if (oldWidget.headers != widget.headers) {
      if (mounted) setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return OptionalSizedChild(
      width: widget?.width,
      height: widget?.height,
      builder: (w, h) {
        String src = widget.src;
        if (widget.convertToWidgets) {
          if (EasyWebViewImpl.isUrl(src)) {
            return RemoteMarkdown(
              src: src,
              headers: widget.headers,
              isSelectable: widget.widgetsTextSelectable,
            );
          }
          String _markdown = '';
          if (widget.isMarkdown) {
            _markdown = src;
          }
          if (widget.isHtml) {
            src = EasyWebViewImpl.wrapHtml(src);
            _markdown = EasyWebViewImpl.html2Md(src);
          }
          return LocalMarkdown(
            data: _markdown,
            isSelectable: widget.widgetsTextSelectable,
          );
        }
        _setup(src, w, h);
        return AbsorbPointer(
          child: RepaintBoundary(
            child: HtmlElementView(
              key: widget?.key,
              viewType: 'div-$src',
            ),
          ),
        );
      },
    );
  }

  static final _divElementMap = Map<Key, html.DivElement>();

  void _setup(String src, num width, num height) {
    final src = widget.src;
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('div-$src', (int viewId) {
      if (_divElementMap[widget.key] == null) {
        _divElementMap[widget.key] = html.DivElement();
      }
      final element = _divElementMap[widget.key]
        ..style.border = '0'
        ..style.height = height.toInt().toString()
        ..style.width = width.toInt().toString()
        ..style.overflow = 'auto';

      element.addEventListener('wheel', (event) {
        if (event is WheelEvent) {
          element.scrollBy(0, event.deltaY);
        }
      });

      if (src != null) {
        String _src = src;
        if (widget.isMarkdown) {
          _src = EasyWebViewImpl.md2Html(src);
        }
        if (widget.isHtml) {
          _src = src;
        }
        element.setInnerHtml(_src,
            validator: NodeValidatorBuilder.common(),
            treeSanitizer: NodeTreeSanitizer.trusted);
      }
      return element;
    });
  }
}
