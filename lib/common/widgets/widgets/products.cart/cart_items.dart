import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../features/shop/screens/widgets/product_details/widgets/product_details/product_price_text.dart';
import '../../../../features/shop/screens/widgets/product_details/widgets/product_details/t_brand_title_text_with_verified_icon.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../images/t_rounded_image.dart';
import '../text/product_title_text.dart';
import 'add_remove_button.dart';
import 'cart_item.dart';

class TCartItems extends StatelessWidget {
  const TCartItems({super.key, this.showAddRemoveButtons = true});

  final bool showAddRemoveButtons;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: 2,
      separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwSections),
      itemBuilder: (_, index) => Column(
            children: [
              ///Cart Item
              const TCartItem(),
              if (showAddRemoveButtons) const SizedBox(height: TSizes.spaceBtwItems),

              if (showAddRemoveButtons)
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ///Extra Space
                        SizedBox(width: 70),

                        ///Add Remove Buttons
                        TProductQuantityWithAddRemoveButton(),
                      ],
                    ),

                    ///Product Total Price
                    TProductPriceText(price: '256'),
                  ],
                ),
            ],
          ),
    );
  }
}
