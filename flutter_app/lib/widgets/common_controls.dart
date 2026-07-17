import 'package:flutter/material.dart';
import 'package:flutter_app/theme/app_theme.dart';

class BadgeBubble extends StatelessWidget {
  final String text;
  const BadgeBubble(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: SportZoneTheme.electricLime,
        shape: BoxShape.circle,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: SportZoneTheme.primary,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _AccordionItemState extends State<AccordionItem> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => expanded = !expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                Icon(expanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              widget.content,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: SportZoneTheme.secondary),
            ),
          ),
          crossFadeState: expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        const Divider(color: SportZoneTheme.borderSubtle),
      ],
    );
  }
}

class AccordionItem extends StatefulWidget {
  final String title;
  final String content;
  const AccordionItem({required this.title, required this.content, super.key});

  @override
  State<AccordionItem> createState() => _AccordionItemState();
}

class BadgeTag extends StatelessWidget {
  final String text;
  final bool isAccent;
  const BadgeTag({required this.text, required this.isAccent, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAccent ? SportZoneTheme.electricLime : SportZoneTheme.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isAccent ? SportZoneTheme.primary : SportZoneTheme.onPrimary,
          fontWeight: FontWeight.w900,
          fontSize: 10,
        ),
      ),
    );
  }
}

class PaymentOption {
  final String code;
  final String label;
  final IconData icon;
  const PaymentOption({
    required this.code,
    required this.label,
    required this.icon,
  });
}

class TopActionButton extends StatelessWidget {
  final IconData icon;
  final String? badgeText;
  final VoidCallback onTap;

  const TopActionButton({
    required this.icon,
    required this.onTap,
    this.badgeText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, color: SportZoneTheme.primary),
          if (badgeText != null)
            Positioned(right: -7, top: -7, child: BadgeBubble(badgeText!)),
        ],
      ),
    );
  }
}
