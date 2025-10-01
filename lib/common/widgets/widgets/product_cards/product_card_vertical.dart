import 'package:finalapp/common/widgets/widgets/images/t_rounded_image.dart';
import 'package:finalapp/common/widgets/widgets/product_cards/rounded_container.dart';
import 'package:finalapp/common/widgets/widgets/product_cards/shadows.dart';
import 'package:finalapp/common/widgets/widgets/text/product_title_text.dart';
import 'package:finalapp/utils/constants/image_strings.dart';
import 'package:finalapp/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../features/shop/screens/widgets/product_details/widgets/product_details/product_detail.dart';
import '../../../../utils/constants/colors.dart';
import '../../icons/t_circular_icon.dart';
import '../../layouts/product_price_text.dart';

class TProductCardVertical extends StatelessWidget {
  const TProductCardVertical({super.key});

  @override
  Widget build(BuildContext context) {


    return GestureDetector(
      onTap: () => Get.to(() => const ProductDetailScreen()),
      child: Container(
        ///Container With side padding, color, edges, radius and shadow
        width: 315,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          boxShadow: [TShadowStyle.verticalProductShadow],
          borderRadius: BorderRadius.circular(TSizes.productImageRadius),
          color: TColors.white,///////////
        ),
        child: Column(
          children: [
            ///Thumbnail, wishlist, discount tag
            TRoundContainer(
            height: 180,
            padding: const EdgeInsets.all(TSizes.sm),
            backgroundColor: TColors.light,
            child: Stack(
              children: [
                ///Thumbnail Image
                TRoundedImage(imageUrl: TImages.Product1Camera, applyImageRadius: true),

                ///Sale Tag
                Positioned(
                  top: 12,
                  child: TRoundContainer(
                    radius: TSizes.sm,
                    backgroundColor: TColors.secondary.withOpacity(0.8),
                    padding: const EdgeInsets.symmetric(horizontal: TSizes.sm, vertical: TSizes.xs),
                    child: Text('25%', style: Theme.of(context).textTheme.labelLarge!.apply(color: TColors.black)),
                  ),
                ),

                ///Favourite Icon Button
                const Positioned(
                    top: 0,
                    right: 0,
                    child: TCircularIcon(icon: Iconsax.heart5, color: Colors.red)),
              ],
            ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 2),

            ///Details
            Padding(
              padding: const EdgeInsets.only(left: TSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TProductTitleText(title: 'Service 1', smallSize: true),
                  SizedBox(height: TSizes.spaceBtwItems / 2),
                  Row(
                    children: [
                      Text('SERVICE', overflow: TextOverflow.ellipsis, maxLines: 1, style: Theme.of(context).textTheme.labelMedium),
                      const SizedBox(width: TSizes.xs),
                      Icon(Iconsax.verify5, color: TColors.primary, size: TSizes.iconXs),
                    ],
                  ),

                  ///const Spacer(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        ///Price
                        Padding(
                          padding: const EdgeInsets.only(left: TSizes.sm),
                          child: const TProductPrice(price: '35.0'),
                        ),

                      ///Add to Cart Button
                      Container(
                        decoration: const BoxDecoration(
                          color: TColors.dark,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(TSizes.cardRadiusMd),
                            bottomRight: Radius.circular(TSizes.productImageRadius),
                          ),
                        ),
                        child: const SizedBox(
                          width: TSizes.iconLg * 1.2,
                          height: TSizes.iconLg * 1.2,
                          child: Center(child: Icon(Iconsax.add, color: TColors.white))),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

