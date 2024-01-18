library audio_recorder_pack;

import 'dart:io';
import 'dart:math';

import 'package:audio_recorder_pack/timer_view_model.dart';
import 'package:audio_recorder_pack/audio_record_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class AudioRecorderWidget extends StatefulWidget {
  final File? audioFile;
  final bool isReported;
  const AudioRecorderWidget(
      {super.key, this.audioFile, required this.isReported});

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  // final recorder = FlutterSoundRecorder();
  // bool isRecordReady = false;
  // final audioPlayer = AudioPlayer();
  // File? audioFile;
  // bool isPlaying = false;
  // Duration fullDuration = const Duration();
  // Duration position = const Duration();

  late AudioRecorderProvider audioRecorderProvider;

  // Future<void> initRecorder() async {
  //   final status = await Permission.microphone.request();

  //   if (status != PermissionStatus.granted) {
  //     throw ("error");
  //   }

  //   await recorder.openRecorder();
  //   isRecordReady = true;

  //   recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  // }

  @override
  void initState() {
    audioRecorderProvider = context.read<AudioRecorderProvider>();
    audioRecorderProvider.initRecorder();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      audioRecorderProvider.initAudio(widget.audioFile);
    });

    // audioPlayer.playingStream.listen((event) {
    //   setState(() {
    //     isPlaying = event;
    //   });
    // });

    super.initState();
  }

  @override
  void dispose() {
    // closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.isReported && widget.audioFile == null
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Theme.of(context).colorScheme.surfaceVariant)),
                  child: PhosphorIcon(
                    PhosphorIconsRegular.speakerSlash,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    size: 36,
                  ),
                )
              : (audioRecorderProvider.audioFile == null)
                  ? Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                side: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceVariant),
                                fixedSize: const Size.fromHeight(45),
                              ),
                              onPressed: () async {
                                var audioFile = await addAoudioFile();

                                if (audioFile != null) {
                                  await audioRecorderProvider
                                      .changeAudioFile(audioFile);
                                }

                                setState(() {});
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  PhosphorIcon(
                                    PhosphorIconsBold.paperclip,
                                    size: 20,
                                  ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Text(
                                    "Pilih Audio",
                                  )
                                ],
                              )),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        IconButton(
                          style: IconButton.styleFrom(
                              fixedSize: const Size(45, 45),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              shape: const CircleBorder()),
                          onPressed: () async {
                            showModalBottomSheet(
                              context: context,
                              isDismissible: false,
                              // enableDrag: false,
                              builder: (context) {
                                return ChangeNotifierProvider(
                                  create: (context) => TimerProvider(),
                                  child: Consumer<TimerProvider>(
                                      builder: (context, timerProvider, _) {
                                    return Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(30),
                                      child: !audioRecorderProvider
                                                  .recorder.isRecording &&
                                              !audioRecorderProvider
                                                  .recorder.isPaused
                                          ? Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "Mulai Rekam",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge,
                                                ),
                                                const SizedBox(
                                                  height: 8,
                                                ),
                                                IconButton(
                                                    style: IconButton.styleFrom(
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primary,
                                                        fixedSize:
                                                            const Size(45, 45),
                                                        shape:
                                                            const CircleBorder()),
                                                    onPressed: () async {
                                                      if (!audioRecorderProvider
                                                          .isRecordReady) {
                                                        return;
                                                      }

                                                      await audioRecorderProvider
                                                          .startRecorder();

                                                      setState(() {});
                                                    },
                                                    icon: Icon(
                                                      Icons.mic,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary,
                                                    ))
                                              ],
                                            )
                                          : Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "Rekaman Baru",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall,
                                                ),
                                                const SizedBox(
                                                  height: 8,
                                                ),
                                                Text(_printDuration(
                                                    timerProvider.elapsedTime)),
                                                const SizedBox(
                                                  height: 8,
                                                ),
                                                Row(
                                                  children: [
                                                    const Expanded(
                                                        child:
                                                            WaveFormsWidget()),
                                                    IconButton(
                                                        style: IconButton.styleFrom(
                                                            backgroundColor:
                                                                Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary,
                                                            fixedSize:
                                                                const Size(
                                                                    32, 32),
                                                            shape:
                                                                const CircleBorder()),
                                                        onPressed: () async {
                                                          if (audioRecorderProvider
                                                              .recorder
                                                              .isPaused) {
                                                            await audioRecorderProvider
                                                                .resumeRecorder();
                                                            timerProvider
                                                                .resumeTimer();
                                                          } else {
                                                            await audioRecorderProvider
                                                                .pauseRecorder();
                                                            timerProvider
                                                                .pauseTimer();
                                                          }

                                                          setState(() {});
                                                        },
                                                        icon: Icon(
                                                          audioRecorderProvider
                                                                  .recorder
                                                                  .isPaused
                                                              ? Icons
                                                                  .play_arrow_rounded
                                                              : Icons.pause,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                        )),
                                                    IconButton(
                                                        style: IconButton.styleFrom(
                                                            backgroundColor:
                                                                Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .error,
                                                            fixedSize:
                                                                const Size(
                                                                    32, 32),
                                                            shape:
                                                                const CircleBorder()),
                                                        onPressed: () async {
                                                          await audioRecorderProvider
                                                              .stopRecorder();

                                                          setState(() {});

                                                          if (context.mounted) {
                                                            Navigator.pop(
                                                                context);
                                                          }
                                                        },
                                                        icon: Icon(
                                                          Icons.stop,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onError,
                                                        ))
                                                  ],
                                                )
                                              ],
                                            ),
                                    );
                                  }),
                                );
                              },
                            );
                          },
                          icon: Icon(
                            Icons.mic,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      ],
                    )
                  : StreamBuilder(
                      stream: audioRecorderProvider.audioPlayer.positionStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final data = snapshot.data!;
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceVariant),
                                borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        path.basename(audioRecorderProvider
                                            .audioFile!.path),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceVariant,
                                          shape: BoxShape.circle),
                                    ),
                                    FutureBuilder<String>(
                                        future: getFileSize(
                                            audioRecorderProvider.audioFile!),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return Text(
                                              snapshot.data.toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            );
                                          } else {
                                            return const SizedBox();
                                          }
                                        }),
                                    const Expanded(child: SizedBox()),
                                    widget.isReported
                                        ? const SizedBox()
                                        : Align(
                                            alignment: Alignment.centerRight,
                                            child: InkWell(
                                                onTap: () async {
                                                  await audioRecorderProvider
                                                      .stopAudio();

                                                  audioRecorderProvider
                                                      .resetAudioFile();

                                                  setState(() {});
                                                },
                                                child: PhosphorIcon(
                                                  PhosphorIconsBold.trash,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .error,
                                                )))
                                  ],
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        if (audioRecorderProvider
                                            .audioPlayer.playing) {
                                          await audioRecorderProvider
                                              .pauseAudio();
                                        } else {
                                          await audioRecorderProvider
                                              .playAudio();
                                        }
                                      },
                                      child: audioRecorderProvider
                                              .audioPlayer.playing
                                          ? Icon(
                                              Icons.pause_circle,
                                              size: 28,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            )
                                          : Icon(
                                              Icons.play_circle_fill_rounded,
                                              size: 28,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                    ),
                                    Expanded(
                                      child: SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          trackHeight: 5,
                                          thumbShape:
                                              SliderComponentShape.noThumb,
                                        ),
                                        child: Slider.adaptive(
                                          value: data.inSeconds.toDouble(),
                                          min: 0,
                                          max: audioRecorderProvider.audioPlayer
                                                  .duration?.inSeconds
                                                  .toDouble() ??
                                              data.inSeconds.toDouble() * 2,
                                          inactiveColor: Theme.of(context)
                                              .colorScheme
                                              .surfaceVariant,
                                          onChanged: (value) async {
                                            final position = Duration(
                                                seconds: value.toInt());

                                            await audioRecorderProvider
                                                .audioPlayer
                                                .seek(position);
                                          },
                                        ),
                                      ),
                                    ),
                                    audioRecorderProvider
                                                .audioPlayer.duration !=
                                            null
                                        ? Text(_printDuration(
                                            audioRecorderProvider
                                                .audioPlayer.duration!))
                                        : const SizedBox()
                                  ],
                                )
                              ],
                            ),
                          );
                        }

                        return const SizedBox();
                      },
                    )
        ],
      ),
    );
  }

  // void showRecordSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     isDismissible: false,
  //     // enableDrag: false,
  //     builder: (context) {
  //       return ChangeNotifierProvider(
  //         create: (context) => TimerProvider(),
  //         child: Consumer<TimerProvider>(builder: (context, timerProvider, _) {
  //           return StatefulBuilder(builder: (context, setState) {
  //             return Container(
  //               width: double.infinity,
  //               padding: const EdgeInsets.all(30),
  //               child: !audioRecorderProvider.recorder.isRecording &&
  //                       !audioRecorderProvider.recorder.isPaused
  //                   ? Column(
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         Text(
  //                           "Mulai Rekam",
  //                           style: Theme.of(context).textTheme.titleLarge,
  //                         ),
  //                         const SizedBox(
  //                           height: 8,
  //                         ),
  //                         IconButton(
  //                             style: IconButton.styleFrom(
  //                                 backgroundColor:
  //                                     Theme.of(context).colorScheme.primary,
  //                                 fixedSize: const Size(45, 45),
  //                                 shape: const CircleBorder()),
  //                             onPressed: () async {
  //                               if (!audioRecorderProvider.isRecordReady) {
  //                                 return;
  //                               }

  //                               await audioRecorderProvider.startRecorder();

  //                               setState(() {});
  //                             },
  //                             icon: Icon(
  //                               Icons.mic,
  //                               color: Theme.of(context).colorScheme.onPrimary,
  //                             ))
  //                       ],
  //                     )
  //                   : Column(
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         Text(
  //                           "Rekaman Baru",
  //                           style: Theme.of(context).textTheme.titleSmall,
  //                         ),
  //                         const SizedBox(
  //                           height: 8,
  //                         ),
  //                         Text(_printDuration(timerProvider.elapsedTime)),
  //                         const SizedBox(
  //                           height: 8,
  //                         ),
  //                         Row(
  //                           children: [
  //                             Expanded(
  //                                 child:
  //                                     SvgPicture.asset('assets/waveforms.svg')),
  //                             IconButton(
  //                                 style: IconButton.styleFrom(
  //                                     backgroundColor:
  //                                         Theme.of(context).colorScheme.primary,
  //                                     fixedSize: const Size(32, 32),
  //                                     shape: const CircleBorder()),
  //                                 onPressed: () async {
  //                                   if (audioRecorderProvider
  //                                       .recorder.isPaused) {
  //                                     await audioRecorderProvider
  //                                         .resumeRecorder();
  //                                     timerProvider.resumeTimer();
  //                                   } else {
  //                                     await audioRecorderProvider
  //                                         .pauseRecorder();
  //                                     timerProvider.pauseTimer();
  //                                   }

  //                                   setState(() {});
  //                                 },
  //                                 icon: Icon(
  //                                   audioRecorderProvider.recorder.isPaused
  //                                       ? Icons.play_arrow_rounded
  //                                       : Icons.pause,
  //                                   color:
  //                                       Theme.of(context).colorScheme.onPrimary,
  //                                 )),
  //                             IconButton(
  //                                 style: IconButton.styleFrom(
  //                                     backgroundColor:
  //                                         Theme.of(context).colorScheme.error,
  //                                     fixedSize: const Size(32, 32),
  //                                     shape: const CircleBorder()),
  //                                 onPressed: () async {
  //                                   await audioRecorderProvider.stopRecorder();

  //                                   setState(() {});

  //                                   if (context.mounted) {
  //                                     Navigator.pop(context);
  //                                   }
  //                                 },
  //                                 icon: Icon(
  //                                   Icons.stop,
  //                                   color:
  //                                       Theme.of(context).colorScheme.onError,
  //                                 ))
  //                           ],
  //                         )
  //                       ],
  //                     ),
  //             );
  //           });
  //         }),
  //       );
  //     },
  //   );
  // }
}

Future<File?> addAoudioFile() async {
  FilePickerResult? result =
      await FilePicker.platform.pickFiles(type: FileType.audio);

  if (result != null) {
    File file = File(result.files.single.path!);

    return file;
  }

  return null;
}

Future<String> getFileSize(File file) async {
  int bytes = await file.length();
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  var i = (log(bytes) / log(1024)).floor();
  return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
}

String _printDuration(Duration duration) {
  String negativeSign = duration.isNegative ? '-' : '';
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
  return "$negativeSign$twoDigitMinutes:$twoDigitSeconds";
}

extension ColorExtension on Color {
  /// Return uppercase RGB hex code string, with # and no alpha value.
  /// This format is often used in APIs and in CSS color values..
  String get hex {
    // ignore: lines_longer_than_80_chars
    return '#${value.toRadixString(16).toUpperCase().padLeft(8, '0').substring(2)}';
  }

  Color get disable => withOpacity(0.38);
}

class WaveFormsWidget extends StatelessWidget {
  const WaveFormsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var primaryColor = Theme.of(context).colorScheme.primary.hex;

    return SvgPicture.string('''
<svg width="258" height="32" viewBox="0 0 258 32" fill="none" xmlns="http://www.w3.org/2000/svg">
<rect y="15" width="2" height="2" rx="1" fill="$primaryColor"/>
<rect x="6" y="12" width="2" height="8" rx="1" fill="$primaryColor"/>
<rect x="12" y="9" width="2" height="14" rx="1" fill="$primaryColor"/>
<rect x="18" y="14" width="2" height="4" rx="1" fill="$primaryColor"/>
<rect x="24" y="8" width="2" height="16" rx="1" fill="$primaryColor"/>
<rect x="30" y="9" width="2" height="14" rx="1" fill="$primaryColor"/>
<rect x="36" y="11" width="2" height="10" rx="1" fill="$primaryColor"/>
<rect x="42" y="11" width="2" height="10" rx="1" fill="$primaryColor"/>
<rect x="48" y="11" width="2" height="10" rx="1" fill="$primaryColor"/>
<rect x="54" y="9" width="2" height="14" rx="1" fill="$primaryColor"/>
<rect x="60" y="11" width="2" height="10" rx="1" fill="$primaryColor"/>
<rect x="66" y="8" width="2" height="16" rx="1" fill="$primaryColor"/>
<rect x="72" y="11" width="2" height="10" rx="1" fill="$primaryColor"/>
<rect x="78" y="14" width="2" height="4" rx="1" fill="$primaryColor"/>
<rect x="84" y="15" width="2" height="2" rx="1" fill="$primaryColor"/>
<rect x="86" y="15" width="2" height="2" rx="1" fill="$primaryColor"/>
<rect x="92" y="12" width="2" height="8" rx="1" fill="$primaryColor"/>
<rect x="98" y="9" width="2" height="14" rx="1" fill="$primaryColor"/>
<rect x="104" y="14" width="2" height="4" rx="1" fill="$primaryColor"/>
<rect x="110" y="8" width="2" height="16" rx="1" fill="$primaryColor"/>
<rect x="116" y="9" width="2" height="14" rx="1" fill="$primaryColor"/>
<rect x="122" y="11" width="2" height="10" rx="1" fill="$primaryColor"/>
<rect x="128" y="11" width="2" height="10" rx="1" fill="$primaryColor"/>
<rect x="134" y="11" width="2" height="10" rx="1" fill="$primaryColor"/>
<rect x="140" y="9" width="2" height="14" rx="1" fill="$primaryColor"/>
<rect x="146" y="11" width="2" height="10" rx="1" fill="$primaryColor"/>
<rect x="152" y="8" width="2" height="16" rx="1" fill="$primaryColor"/>
<rect x="158" y="11" width="2" height="10" rx="1" fill="$primaryColor"/>
<rect x="164" y="14" width="2" height="4" rx="1" fill="$primaryColor"/>
<rect x="170" y="15" width="2" height="2" rx="1" fill="$primaryColor"/>
<rect x="172" y="15" width="2" height="2" rx="1" fill="$primaryColor"/>
<rect x="178" y="12" width="2" height="8" rx="1" fill="$primaryColor"/>
<rect x="184" y="9" width="2" height="14" rx="1" fill="$primaryColor"/>
<rect x="190" y="14" width="2" height="4" rx="1" fill="$primaryColor"/>
<rect x="196" y="8" width="2" height="16" rx="1" fill="$primaryColor"/>
<rect x="202" y="9" width="2" height="14" rx="1" fill="$primaryColor"/>
<rect x="208" y="11" width="2" height="10" rx="1" fill="$primaryColor"/>
<rect x="214" y="11" width="2" height="10" rx="1" fill="$primaryColor"/>
<rect x="220" y="11" width="2" height="10" rx="1" fill="$primaryColor"/>
<rect x="226" y="9" width="2" height="14" rx="1" fill="$primaryColor"/>
<rect x="232" y="11" width="2" height="10" rx="1" fill="$primaryColor"/>
<rect x="238" y="8" width="2" height="16" rx="1" fill="$primaryColor"/>
<rect x="244" y="11" width="2" height="10" rx="1" fill="$primaryColor"/>
<rect x="250" y="14" width="2" height="4" rx="1" fill="$primaryColor"/>
<rect x="256" y="15" width="2" height="2" rx="1" fill="$primaryColor"/>
</svg>

''');
  }
}
