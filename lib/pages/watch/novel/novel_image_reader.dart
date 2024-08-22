import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

final imageRegex = RegExp(r"(?<=<!--image-->)(\S*?)(?=<!--image-->)");

class NovelImageReader {
  static final TransformationController _transformationController = TransformationController();
  static Offset _doubleTapPostion = Offset.zero;

  static Widget buildImageWidgets(String content) {
    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: 0.5,
      maxScale: 5.0,
      child: GestureDetector(
        onDoubleTap: _handleDoubleTap,
        onDoubleTapDown: (details) => _doubleTapPostion = details.localPosition,
        child: buildImageList(content),
      ) 
        
    );
  }

  static void _handleDoubleTap() {
    if(_transformationController.value.isIdentity()) {
      _transformationController.value = Matrix4.identity()
        ..translate(-_doubleTapPostion.dx, -_doubleTapPostion.dy)
        ..scale(2.0);
    } else {
      _transformationController.value = Matrix4.identity();
    }
  }

  static Widget buildImageList(String content) {
    return Column(
      children: imageRegex.allMatches(content).map((matchContent) {
        final imageURL = matchContent[0]!;
        final imageName = imageURL.substring(imageURL.lastIndexOf("/") + 1);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildImageStack(imageName, imageURL),
          ),
        );
      }).toList(),
    );
  }

  static Widget _buildImageStack(String imageName, String imageURL) {
    return Stack(
      children: [
        Hero(
          tag: "illust_$imageName", 
          child: _buildCachedImage(imageURL),
        ),
      ],
    );
  }

  static Widget _buildCachedImage(String imageURL) {
    return CachedNetworkImage(
      imageUrl: imageURL,
      fit: BoxFit.contain,
    );
  }
}