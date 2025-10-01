import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../utils/constants/colors.dart';

class TUserProfile extends StatelessWidget {
  const TUserProfile({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Text('HandyMan', style: Theme.of(context).textTheme.headlineLarge!.apply(color: TColors.black)),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Text('Handy@gmail.com', style: Theme.of(context).textTheme.titleMedium!.apply(color: TColors.black)),
      ),
      trailing: IconButton(onPressed: onPressed, icon: const Icon(Iconsax.edit, color: TColors.black,)),
    );
  }
}
