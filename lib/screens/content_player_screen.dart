import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class ContentPlayerScreen extends StatefulWidget {
  final Content content;
  const ContentPlayerScreen({super.key, required this.content});
  @override State<ContentPlayerScreen> createState() => _State();
}

class _State extends State<ContentPlayerScreen> {
  BetterPlayerController? _ctrl;
  bool _playing = false, _controlsVisible = true, _buffering = false;
  Timer? _hideTimer;
  Duration _pos = Duration.zero;
  Duration _dur = const Duration(hours: 2);

  bool get hasStream => widget.content.streamUrl != null && widget.content.streamUrl!.isNotEmpty;

  @override
  void initState() { super.initState(); if (hasStream) _initPlayer(); }

  void _initPlayer() {
    final rawUrl = widget.content.streamUrl!;
    final parts = rawUrl.split('|');
    final url = parts[0].trim();
    final headers = <String, String>{};
    if (parts.length > 1) { for (final kv in parts[1].split('&')) { final i = kv.indexOf('='); if (i > 0) headers[kv.substring(0,i).trim()] = kv.substring(i+1).trim(); } }
    BetterPlayerVideoFormat? fmt;
    if (url.contains('.m3u8')) fmt = BetterPlayerVideoFormat.hls;
    if (url.contains('.mpd'))  fmt = BetterPlayerVideoFormat.dash;
    _ctrl = BetterPlayerController(const BetterPlayerConfiguration(autoPlay: true, fit: BoxFit.contain, controlsConfiguration: BetterPlayerControlsConfiguration(showControls: false), allowedScreenSleep: false));
    _ctrl!.setupDataSource(BetterPlayerDataSource(BetterPlayerDataSourceType.network, url, videoFormat: fmt, headers: headers.isNotEmpty ? headers : null));
    _ctrl!.addEventsListener((e) {
      if (!mounted) return;
      if (e.betterPlayerEventType == BetterPlayerEventType.play) setState(() => _playing = true);
      if (e.betterPlayerEventType == BetterPlayerEventType.pause) setState(() => _playing = false);
      if (e.betterPlayerEventType == BetterPlayerEventType.bufferingStart) setState(() => _buffering = true);
      if (e.betterPlayerEventType == BetterPlayerEventType.bufferingEnd) setState(() => _buffering = false);
      if (e.betterPlayerEventType == BetterPlayerEventType.progress) {
        final vp = _ctrl?.videoPlayerController?.value;
        if (vp != null) setState(() { _pos = vp.position; _dur = vp.duration ?? const Duration(hours: 2); });
      }
    });
    _startHideTimer();
  }

  void _startHideTimer() { _hideTimer?.cancel(); _hideTimer = Timer(const Duration(seconds: 4), () { if (mounted) setState(() => _controlsVisible = false); }); }
  void _skip(int s) { _ctrl?.seekTo(_pos + Duration(seconds: s)); _startHideTimer(); }
  String _fmt(Duration d) => '${d.inMinutes.toString().padLeft(2,'0')}:${d.inSeconds.remainder(60).toString().padLeft(2,'0')}';

  @override
  void dispose() { _hideTimer?.cancel(); _ctrl?.dispose(); SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.black,
    body: hasStream ? _buildPlayer() : _buildDetail());

  Widget _buildPlayer() {
    final prog = _dur.inMilliseconds > 0 ? (_pos.inMilliseconds / _dur.inMilliseconds).clamp(0.0, 1.0) : 0.0;
    return Stack(children: [
      Positioned.fill(child: _ctrl != null ? BetterPlayer(controller: _ctrl!) : const Center(child: CircularProgressIndicator(color: AppTheme.accentCyan))),
      if (_buffering) const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)),
      Positioned.fill(child: GestureDetector(behavior: HitTestBehavior.opaque,
        onTap: () { setState(() => _controlsVisible = !_controlsVisible); if (_controlsVisible) _startHideTimer(); },
        onDoubleTapDown: (d) { final w = MediaQuery.of(context).size.width; _skip(d.localPosition.dx < w/2 ? -10 : 10); },
        child: const ColoredBox(color: Colors.transparent))),
      AnimatedOpacity(duration: const Duration(milliseconds: 300), opacity: _controlsVisible ? 1.0 : 0.0,
        child: IgnorePointer(ignoring: !_controlsVisible, child: Stack(children: [
          Positioned(top:0,left:0,right:0,child:Container(height:80,decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Colors.black.withOpacity(0.85),Colors.transparent])))),
          Positioned(bottom:0,left:0,right:0,child:Container(height:100,decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.bottomCenter,end:Alignment.topCenter,colors:[Colors.black.withOpacity(0.9),Colors.transparent])))),
          Positioned(top:40,left:12,child:GestureDetector(onTap:()=>Navigator.pop(context),child:Container(width:38,height:38,decoration:const BoxDecoration(shape:BoxShape.circle,gradient:LinearGradient(colors:AppTheme.logoGradient)),child:const Icon(Icons.chevron_left,color:Colors.white,size:26)))),
          Center(child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[
            GestureDetector(onTap:()=>_skip(-10),child:const Column(mainAxisSize:MainAxisSize.min,children:[Icon(Icons.replay,color:Colors.white,size:32),Text('10',style:TextStyle(color:Colors.white,fontSize:10))])),
            const SizedBox(width:40),
            GestureDetector(onTap:(){if(_playing)_ctrl?.pause();else _ctrl?.play();_startHideTimer();},child:Container(width:64,height:64,decoration:const BoxDecoration(shape:BoxShape.circle,color:Colors.white),child:Icon(_playing?Icons.pause:Icons.play_arrow,color:Colors.black,size:36))),
            const SizedBox(width:40),
            GestureDetector(onTap:()=>_skip(10),child:const Column(mainAxisSize:MainAxisSize.min,children:[Icon(Icons.forward_10,color:Colors.white,size:32),Text('10',style:TextStyle(color:Colors.white,fontSize:10))])),
          ])),
          Positioned(bottom:16,left:16,right:16,child:Column(mainAxisSize:MainAxisSize.min,children:[
            Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(_fmt(_pos),style:const TextStyle(color:Colors.white,fontSize:12)),Text(_fmt(_dur),style:const TextStyle(color:Colors.white,fontSize:12))]),
            SliderTheme(data:SliderTheme.of(context).copyWith(activeTrackColor:AppTheme.accentCyan,inactiveTrackColor:Colors.white24,thumbColor:Colors.white,thumbShape:const RoundSliderThumbShape(enabledThumbRadius:7),overlayShape:SliderComponentShape.noOverlay,trackHeight:3),
              child:Slider(value:prog,onChanged:(v)=>_ctrl?.seekTo(Duration(milliseconds:(v*_dur.inMilliseconds).toInt())))),
          ])),
        ]))),
    ]);
  }

  Widget _buildDetail() => SafeArea(child:Column(children:[
    Padding(padding:const EdgeInsets.fromLTRB(12,12,12,0),child:Row(children:[
      GestureDetector(onTap:()=>Navigator.pop(context),child:Container(width:38,height:38,decoration:const BoxDecoration(shape:BoxShape.circle,gradient:LinearGradient(colors:AppTheme.logoGradient)),child:const Icon(Icons.chevron_left,color:Colors.white,size:26))),
      const SizedBox(width:12),
      Expanded(child:Text(widget.content.title,style:const TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.bold),maxLines:1,overflow:TextOverflow.ellipsis)),
    ])),
    Expanded(child:Padding(padding:const EdgeInsets.all(24),child:ClipRRect(borderRadius:BorderRadius.circular(20),child:CachedNetworkImage(imageUrl:widget.content.posterUrl,fit:BoxFit.contain,placeholder:(_,__)=>Container(color:AppTheme.surface),errorWidget:(_,__,___)=>Container(color:AppTheme.surface,child:const Icon(Icons.movie,color:AppTheme.textHint,size:80)))))),
    Padding(padding:const EdgeInsets.fromLTRB(24,0,24,32),child:Column(children:[
      if(widget.content.description!=null)...[Text(widget.content.description!,textAlign:TextAlign.center,maxLines:3,overflow:TextOverflow.ellipsis,style:const TextStyle(color:AppTheme.textSecondary,fontSize:14)),const SizedBox(height:16)],
      GradientButton(text:'▶  Reproducir',onPressed:(){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Agrega la URL del stream en el panel admin'),backgroundColor:AppTheme.accentCyan));}),
    ])),
  ]));
}
