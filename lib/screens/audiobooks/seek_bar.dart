import 'package:flutter/material.dart';

class PositionSeekWidget extends StatefulWidget {
  final Duration currentPosition;
  final Duration duration;
  final Function(Duration) seekTo;

  const PositionSeekWidget({
    Key? key,
    required this.currentPosition,
    required this.duration,
    required this.seekTo,
  }) : super(key: key);

  @override
  PositionSeekWidgetState createState() => PositionSeekWidgetState();
}

class PositionSeekWidgetState extends State<PositionSeekWidget> {
  late Duration _visibleValue;
  bool listenOnlyUserInteraction = false;

  double get percent => widget.duration.inMilliseconds == 0 ? 0 : _visibleValue.inMilliseconds / widget.duration.inMilliseconds;

  @override
  void initState() {
    super.initState();
    _visibleValue = widget.currentPosition;
  }

  @override
  void didUpdateWidget(PositionSeekWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listenOnlyUserInteraction) {
      _visibleValue = widget.currentPosition;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(durationToString(widget.currentPosition)),
            Text(durationToString(widget.duration)),
          ],
        ),
        Slider(
          min: 0,
          max: widget.duration.inMilliseconds.toDouble(),
          value: percent * widget.duration.inMilliseconds.toDouble(),
          onChangeEnd: (newValue) {
            setState(() {
              listenOnlyUserInteraction = false;
              widget.seekTo(_visibleValue);
            });
          },
          onChangeStart: (_) {
            setState(() {
              listenOnlyUserInteraction = true;
            });
          },
          onChanged: (newValue) {
            setState(() {
              final to = Duration(milliseconds: newValue.floor());
              _visibleValue = to;
            });
          },
        ),
      ],
    );
  }
}

String durationToString(Duration duration) {
  String twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(Duration.minutesPerHour));
  final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(Duration.secondsPerMinute));
  return '$twoDigitMinutes:$twoDigitSeconds';
}
