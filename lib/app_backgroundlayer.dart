import 'package:cached_network_image/cached_network_image.dart';
import "package:flutter/material.dart";
const double _kFlexibleSpaceMaxHeight = 356.0;

class _BackgroundLayer {
  _BackgroundLayer({int level, double parallax})
      : parallaxTween = new Tween<double>(begin: 0.0, end: parallax);
  final Tween<double> parallaxTween;
}

final List<_BackgroundLayer> _kBackgroundLayers = <_BackgroundLayer>[
  new _BackgroundLayer(level: 0, parallax: _kFlexibleSpaceMaxHeight),
  new _BackgroundLayer(level: 1, parallax: _kFlexibleSpaceMaxHeight),
  new _BackgroundLayer(level: 2, parallax: _kFlexibleSpaceMaxHeight / 2.0),
  new _BackgroundLayer(level: 3, parallax: _kFlexibleSpaceMaxHeight / 4.0),
  new _BackgroundLayer(level: 4, parallax: _kFlexibleSpaceMaxHeight / 2.0),
  new _BackgroundLayer(level: 5, parallax: _kFlexibleSpaceMaxHeight)
];

class _AppBarBackground extends StatelessWidget {
  const _AppBarBackground({Key key, this.animation, this.imageUrl, this.text})
      : super(key: key);

  final Animation<double> animation;
  final String imageUrl;
  final String text;

  @override
  Widget build(BuildContext context) {
    return new AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget child) {
          return new Stack(
              children: _kBackgroundLayers.map((_BackgroundLayer layer) {
                return new Positioned(
                  top: -layer.parallaxTween.evaluate(animation),
                  left: 0.0,
                  right: 0.0,
                  bottom: 0.0,
                  child: new CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: _kFlexibleSpaceMaxHeight,
                    fit: BoxFit.cover,
                  ),
                );
              }).toList());
        });
  }
}
