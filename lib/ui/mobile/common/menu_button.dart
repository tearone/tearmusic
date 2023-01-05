import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({Key? key, this.child, this.onPressed, this.icon}) : super(key: key);

  final Widget? child;
  final Widget? icon;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.0),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
        child: Row(
          children: [
            if (icon != null)
              IconTheme(
                data: IconThemeData(
                  color: Theme.of(context).colorScheme.secondary,
                  size: 24.0,
                ),
                child: icon!,
              ),
            if (child != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: DefaultTextStyle(
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 16.0,
                        ),
                    child: child!,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
