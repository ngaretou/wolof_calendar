import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../providers/user_prefs.dart';

class MonthBottomSheet extends StatefulWidget {
  final Size size;
  const MonthBottomSheet({Key? key, required this.size}) : super(key: key);

  @override
  State<MonthBottomSheet> createState() => _MonthBottomSheetState();
}

class _MonthBottomSheetState extends State<MonthBottomSheet> {
  double headerHeight = 140.0;
  double maxHeight = 600.0;
  bool isDragUp = true;
  double bodyHeight = 0.0;

  @override
  Widget build(BuildContext context) {
    UserPrefs userPrefs =
        Provider.of<UserPrefs>(context, listen: true).userPrefs;
    maxHeight = widget.size.height - 250;

    return Positioned(
      bottom: 0.0,
      child: AnimatedContainer(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
          minHeight: headerHeight,
          maxWidth: widget.size.width,
        ),
        curve: Curves.easeOut,
        height: bodyHeight,
        duration: const Duration(milliseconds: 50),
        child: GestureDetector(
          // onVerticalDragUpdate: (DragUpdateDetails data) {
          //   double draggedAmount = widget.size.height - data.globalPosition.dy;
          //   if (isDragUp) {
          //     if (draggedAmount < 100.0) bodyHeight = draggedAmount;
          //     if (draggedAmount > 100.0) bodyHeight = maxHeight;
          //   } else {
          //     /// the _draggedAmount cannot be higher than maxHeight b/c maxHeight is _dragged Amount + header Height
          //     double downDragged = maxHeight - draggedAmount;
          //     if (downDragged < 100.0) bodyHeight = draggedAmount;
          //     if (downDragged > 100.0) bodyHeight = 0.0;
          //   }
          //   setState(() {});
          // },
          onVerticalDragUpdate: (DragUpdateDetails data) {
            double draggedAmount = widget.size.height - data.globalPosition.dy;
            setState(() {
              bodyHeight = draggedAmount;
            });
          },
          onVerticalDragEnd: (DragEndDetails data) {
            if (isDragUp) {
              isDragUp = false;
            } else {
              isDragUp = true;
            }
            setState(() {});
          },
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20.0),
              topLeft: Radius.circular(20.0),
            ),
            child: BackdropFilter(
              filter: userPrefs.glassEffects!
                  ? ImageFilter.blur(sigmaX: 25, sigmaY: 25)
                  : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                decoration: BoxDecoration(
                  color: userPrefs.glassEffects!
                      ? Theme.of(context)
                          .colorScheme
                          .secondaryContainer
                          .withOpacity(.6)
                      : Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20.0),
                    topLeft: Radius.circular(20.0),
                  ),
                  // boxShadow: <BoxShadow>[
                  //   BoxShadow(
                  //       color: Colors.black,
                  //       spreadRadius: 2.0,
                  //       blurRadius: 4.0),
                  // ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      width: widget.size.width,
                      alignment: Alignment.center,
                      // decoration: BoxDecoration(
                      //   color: Theme.of(context).brightness == Brightness.light
                      //       ? Colors.white70
                      //       : Colors.black38,
                      // borderRadius: const BorderRadius.only(
                      //   topRight: Radius.circular(20.0),
                      //   topLeft: Radius.circular(20.0),
                      // ),
                      // boxShadow: <BoxShadow>[
                      //   BoxShadow(
                      //       color: Colors.black,
                      //       spreadRadius: 2.0,
                      //       blurRadius: 4.0),
                      // ],
                      // ),
                      height: headerHeight,
                      child: Column(
                        children: [
                          const Icon(Icons.drag_handle_rounded),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  height: headerHeight - 24,
                                  // width: widget.size.width * .6,
                                  // color: Colors.red,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: headerHeight - 24,
                                  // width: widget.size.width * .4,
                                  // color: Colors.purple,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    const Expanded(
                        child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur scelerisque metus sed ultrices euismod. Maecenas gravida pretium odio. Praesent tempor sem sed consequat congue. Suspendisse fringilla vestibulum risus, sed molestie tortor sollicitudin id. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Curabitur ante orci, tempus vestibulum ullamcorper eget, posuere ac tellus. Nulla facilisi. In vel neque suscipit purus rutrum finibus non non mi. Phasellus venenatis laoreet purus et dictum. Quisque vel quam sed leo feugiat aliquam. In nisi nulla, elementum eget luctus in, iaculis vitae neque. Aenean non ligula leo. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur scelerisque metus sed ultrices euismod. Maecenas gravida pretium odio. Praesent tempor sem sed consequat congue. Suspendisse fringilla vestibulum risus, sed molestie tortor sollicitudin id. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Curabitur ante orci, tempus vestibulum ullamcorper eget, posuere ac tellus. Nulla facilisi. In vel neque suscipit purus rutrum finibus non non mi. Phasellus venenatis laoreet purus et dictum. Quisque vel quam sed leo feugiat aliquam. In nisi nulla, elementum eget luctus in, iaculis vitae neque. Aenean non ligula leo. In luctus metus quis odio semper, ac mollis ipsum iaculis. Praesent vitae leo felis. Donec interdum pulvinar nulla quis finibus. Integer dictum nibh in tellus semper ultrices. Aliquam consectetur augue a leo semper blandit. Nunc venenatis rhoncus faucibus. Etiam id felis felis. Nunc volutpat malesuada dolor a malesuada. Nulla consectetur iaculis erat, eu ultricies arcu porttitor sit amet. Praesent et tincidunt sapien. In purus odio, fringilla ac odio id, maximus maximus sapien. Morbi nec malesuada lectus. Fusce dapibus ut metus id tincidunt. Sed ut posuere purus. Vivamus tristique nec mi vel tincidunt. Nam lobortis mattis lacus, eget ullamcorper sapien bibendum in. Nunc commodo vestibulum convallis. Donec vulputate, nunc in placerat interdum, elit massa hendrerit erat, sit amet vehicula massa est non ligula. Nulla suscipit sed risus a tempor. Vivamus placerat eget lectus vel consectetur. Ut eget nulla et erat mattis consectetur at at quam. Sed molestie luctus augue eu ultrices. In fermentum mauris non dui efficitur, eget sodales dui gravida. Vestibulum ac tellus velit. Donec laoreet ultricies lacus, sed laoreet arcu cursus quis. Etiam condimentum feugiat interdum. Curabitur sit amet dignissim nibh, quis laoreet dui. Duis egestas nec sem non lacinia. Sed pellentesque vestibulum ex vel varius. Maecenas rutrum lobortis turpis eget pulvinar. Aliquam nulla ipsum, tincidunt pulvinar vulputate eget, convallis et sapien. Nunc sit amet fringilla massa, eget elementum purus. Cras nec tortor urna. Integer venenatis, dolor a bibendum consectetur, diam nisl tincidunt sem, sed semper neque metus at massa. Praesent congue est quis imperdiet tempus. Aenean porta a nisl et dapibus. Fusce ut est justo. Vestibulum lorem dui, tristique at magna at, porta semper urna. Pellentesque quis risus nec ligula gravida cursus. Quisque imperdiet sem ac diam faucibus, at lobortis nulla ultricies. Nullam imperdiet, massa et hendrerit interdum, mi est elementum quam, at ornare mi nulla mattis turpis. Vivamus imperdiet elementum tortor a egestas. Etiam in commodo felis, id luctus augue. Morbi aliquam dapibus tellus, at facilisis purus molestie eu. '),
                    )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
