import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import '../../../../news/models/news_model.dart';

class InfoContainer extends StatefulWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String imageHint;
  final Widget footer;

  const InfoContainer(
      {super.key,
        required this.title,
        required this.description,
        required this.imageUrl,
        required this.imageHint,
        required this.footer,
      });

  @override
  State<InfoContainer> createState() => _InfoContainerState();
}

class _InfoContainerState extends State<InfoContainer> {

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.grey,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.imageHint,
                            style: Theme.of(context).textTheme.titleMedium,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    content: CachedNetworkImage(
                      imageUrl: widget.imageUrl,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  );
                },
              );
            },
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      colorFilter:
                      ColorFilter.mode(Colors.red, BlendMode.dstIn)),
                ),
              ),
              progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(value: downloadProgress.progress),
                ),
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,

            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                //Text(
                HtmlWidget(
                      "<p style='text-align: justify;'>${widget.description}</p>",
                  //style: Theme.of(context).textTheme.bodyMedium,
                  //textAlign: TextAlign.justify,
                ),
                SizedBox(
                  height: 10,
                ),
                widget.footer,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
