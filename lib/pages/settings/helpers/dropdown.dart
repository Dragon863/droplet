import 'dart:ui';

import 'package:droplet/pages/settings/helpers/dropdown_select.dart';
import 'package:droplet/pages/settings/helpers/text_font.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Tappable extends StatelessWidget {
  const Tappable({
    Key? key,
    this.onTap,
    this.onHighlightChanged,
    this.borderRadius = 0,
    this.color,
    this.type = MaterialType.canvas,
    required this.child,
    this.onLongPress,
  }) : super(key: key);

  final double borderRadius;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onHighlightChanged;
  final Color? color;
  final Widget child;
  final MaterialType type;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    Widget tappable = Material(
      color: color ?? Theme.of(context).canvasColor,
      type: type,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        splashFactory:
            kIsWeb
                ? InkRipple.splashFactory
                : InkSparkle.constantTurbulenceSeedSplashFactory,
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        onHighlightChanged: onHighlightChanged,
        onLongPress: onLongPress,
        child: child,
      ),
    );
    if (!kIsWeb) {
      return tappable;
    }
    // return ContextMenuRegion(
    //   contextMenu: ContextMenuButton(
    //     ContextMenuButtonConfig(
    //       "test",
    //       icon: Icon(Icons.edit),
    //       onPressed: () {
    //         return;
    //       },
    //     ),
    //     style: ContextMenuButtonStyle(
    //       bgColor: Theme.of(context).colorScheme.secondaryContainer,
    //     ),
    //   ),
    //   child: tappable,
    // );
    Future<void> _onPointerDown(PointerDownEvent event) async {
      // Check if right mouse button clicked
      if (event.kind == PointerDeviceKind.mouse &&
          event.buttons == kSecondaryMouseButton) {
        if (onLongPress != null) onLongPress!();
      }
    }

    return Listener(onPointerDown: _onPointerDown, child: tappable);
  }
}

class SettingsContainer extends StatelessWidget {
  const SettingsContainer({
    Key? key,
    required this.title,
    this.description,
    this.icon,
    this.afterWidget,
    this.onTap,
    this.verticalPadding,
    this.iconSize,
  }) : super(key: key);

  final String title;
  final String? description;
  final IconData? icon;
  final Widget? afterWidget;
  final VoidCallback? onTap;
  final double? verticalPadding;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    const double maxWidth = 450;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Tappable(
        color: Colors.transparent,
        onTap: onTap,
        child: Column(
          children: [
            Container(),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: verticalPadding ?? 11,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            icon == null
                                ? const SizedBox.shrink()
                                : Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: Icon(
                                    icon,
                                    size: iconSize ?? 30,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                            Expanded(
                              child:
                                  description == null
                                      ? TextFont(
                                        fixParagraphMargin: true,
                                        text: title,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        maxLines: 5,
                                      )
                                      : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextFont(
                                            fixParagraphMargin: true,
                                            text: title,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            maxLines: 5,
                                          ),
                                          Container(height: 3),
                                          TextFont(
                                            text: description!,
                                            fontSize: 14,
                                            maxLines: 5,
                                          ),
                                        ],
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: afterWidget ?? const SizedBox(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsContainerDropdown extends StatefulWidget {
  const SettingsContainerDropdown({
    Key? key,
    required this.title,
    this.description,
    this.icon,
    required this.initial,
    required this.items,
    required this.onChanged,
    this.verticalPadding,
    required this.getLabel,
    this.translate = true,
  }) : super(key: key);

  final String title;
  final String? description;
  final IconData? icon;
  final String initial;
  final List<String> items;
  final Function(String) onChanged;
  final double? verticalPadding;
  final String Function(dynamic) getLabel;
  final bool translate;

  @override
  State<SettingsContainerDropdown> createState() =>
      _SettingsContainerDropdownState();
}

class _SettingsContainerDropdownState extends State<SettingsContainerDropdown> {
  late final GlobalKey<DropdownSelectState>? _dropdownKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SettingsContainer(
      verticalPadding: widget.verticalPadding,
      title: widget.title,
      description: widget.description,
      icon: widget.icon,
      onTap: () {
        _dropdownKey!.currentState!.openDropdown();
      },
      afterWidget: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: DropdownSelect(
          key: _dropdownKey,
          compact: true,
          initial:
              widget.items.contains(widget.initial) == false
                  ? widget.items[0]
                  : widget.initial,
          items: widget.items,
          onChanged: widget.onChanged,
          getLabel: widget.getLabel,
          translate: widget.translate,
        ),
      ),
    );
  }
}
