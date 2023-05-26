import 'package:flutter/material.dart';

class ArtistHeaderButton extends StatelessWidget {
  const ArtistHeaderButton({Key? key, this.icon, this.onPressed, required this.child}) : super(key: key);

  final Function()? onPressed;
  final Widget? icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12.0),
      child: Material(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconTheme(
                    data: IconThemeData(
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 20.0,
                    ),
                    child: icon!,
                  ),
                ),
              DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
