import 'package:flutter/material.dart';

import '../../../../features/shop/screens/widgets/product_details/widgets/product_details/t_brand_title_text_with_verified_icon.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../images/t_rounded_image.dart';
import '../text/product_title_text.dart';

class TCartItem extends StatelessWidget {
  const TCartItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        ///Image
        TRoundedImage(
          imageUrl: TImages.Product1Camera,
          width: 60,
          height: 60,
          padding: const EdgeInsets.all(TSizes.sm),
          backgroundColor: TColors.light,
        ),
        const SizedBox(width: TSizes.spaceBtwItems),

        ///Title, Price, & Size
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TBrandTitleTextWithVerifiedIcon(title: 'Test 1'),
              Flexible(child: const TProductTitleText(title: 'Test 1', maxLines: 1,)),

              ///Atrrtibutes
              Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'Color', style: Theme.of(context).textTheme.bodySmall),
                      TextSpan(text: 'Green', style: Theme.of(context).textTheme.bodyLarge),
                      TextSpan(text: 'Size', style: Theme.of(context).textTheme.bodySmall),
                      TextSpan(text: 'UK 08', style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
