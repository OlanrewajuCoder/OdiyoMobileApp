import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:odiyo/widgets/loading.dart';

class CachedImage extends StatelessWidget {
  final double? height;
  final String? url;
  final bool? roundedCorners;
  final bool? circular;
  final File? imageFile;
  final BoxFit boxFit;

  const CachedImage({Key? key, this.height, this.url, this.roundedCorners, this.circular, this.imageFile, this.boxFit = BoxFit.cover}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(circular ?? false
          ? 100
          : roundedCorners ?? true
              ? 10
              : 0),
      child: imageFile != null
          ? Image.file(
              imageFile!,
              fit: boxFit,
              height: height,
              width: height,
            )
          : CachedNetworkImage(
              imageUrl: url ?? '',
              fit: BoxFit.cover,
              height: height,
              width: height,
              placeholder: (context, url) => showImage(url),
              errorWidget: (context, url, error) => errorImage(url),
            ),
    );
  }

  showImage(String url) {
    return const LoadingData();
  }

  errorImage(String url) {
    if (url == 'profile') {
      return Image.asset('assets/images/profile.png', height: height, fit: BoxFit.cover);
    } else {
      return Image.network(url);
    }
  }
}
