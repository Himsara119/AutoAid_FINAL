import 'package:finalapp/common/widgets/curved_edges/Rounded_Container.dart';
import 'package:finalapp/common/widgets/widgets/images/t_rounded_image.dart';
import 'package:finalapp/common/widgets/widgets/product_cards/shadows.dart';
import 'package:finalapp/common/widgets/widgets/text/product_title_text.dart';
import 'package:finalapp/features/shop/screens/widgets/product_details/widgets/product_details/product_price_text.dart';
import 'package:finalapp/features/shop/screens/widgets/product_details/widgets/product_details/t_brand_title_text_with_verified_icon.dart';
import 'package:finalapp/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';

class TProductCardHorizontal extends StatelessWidget {
  const TProductCardHorizontal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 310,
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TSizes.productImageRadius),
        color: TColors.lightContainer,
      ),
      child: Row(
        children: [
          ///Thumbnail
          TRoundedContainer(
            height: 120,
            padding: const EdgeInsets.all(TSizes.sm),
            backgroundColor: TColors.light,
            child: const Stack(
              children: [
                /// Thumbnail Image
                SizedBox(
                  height: 120,
                  width: 120,

                  ///Thumbnail Image
                  child: TRoundedImage(
                    imageUrl: TImages.Product1Camera,
                    applyImageRadius: true,
                  ),
                ),
              ],
            ),
          ),

          ///Details
          SizedBox(
            width: 172,
            child: Padding(
              padding: EdgeInsets.only(top: TSizes.sm, left: TSizes.sm),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TProductTitleText(title: 'Green Nike Half Sleeves Shirt'),
                      SizedBox(height: TSizes.spaceBtwItems / 2),
                      TBrandTitleTextWithVerifiedIcon(title: 'Nike'),
                    ],
                  ),

                  const Spacer(),

                  ///Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                     const Flexible(child: TProductPriceText(price: '256.0')),

                      ///Add to Cart Button
                      Container(
                        decoration: const BoxDecoration(
                          color: TColors.dark,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(TSizes.cardRadiusMd),
                            bottomRight: Radius.circular(
                              TSizes.productImageRadius,
                            ),
                          ),
                        ),
                        child: const SizedBox(
                          width: TSizes.iconLg * 1.2,
                          height: TSizes.iconLg * 1.2,
                          child: Center(
                            child: Icon(Iconsax.add, color: TColors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
