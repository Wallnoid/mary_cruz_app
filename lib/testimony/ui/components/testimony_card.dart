import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mary_cruz_app/core/models/testimony_model.dart';
import 'package:mary_cruz_app/core/utils/screen_utils.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class TestimonyCard extends StatefulWidget {
  final TestimonyModel testimony;

  const TestimonyCard({super.key, required this.testimony});

  @override
  State<TestimonyCard> createState() => _TestimonyCardState();
}

class _TestimonyCardState extends State<TestimonyCard> {
  TestimonyModel get testimony => widget.testimony;

  late YoutubePlayerController controller;
  late bool isMuted;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Cambia el color aquí
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    isMuted = false;

    controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(testimony.urlVideo)!,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: isMuted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(10),
      //   border: Border.all(
      //     color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
      //     width: 1,
      //   ),
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: double.infinity,
              height: getContainerWidth(context) * 0.6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.black,
              ),
              child: YoutubePlayer(
                controller: controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Theme.of(context).colorScheme.primary,
                bottomActions: [
                  const CurrentPosition(),
                  const ProgressBar(isExpanded: true),
                  const RemainingDuration(),
                  isMuted
                      ? IconButton(
                          icon: const Icon(Icons.volume_off),
                          color: Colors.white,
                          onPressed: () {
                            controller.unMute();

                            setState(() {
                              isMuted = false;
                            });
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.volume_up),
                          color: Colors.white,
                          onPressed: () {
                            controller.mute();

                            setState(() {
                              isMuted = true;
                            });
                          },
                        ),
                ],
                controlsTimeOut: const Duration(seconds: 3),
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              testimony.name,
              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Text(
              testimony.description ?? '',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
