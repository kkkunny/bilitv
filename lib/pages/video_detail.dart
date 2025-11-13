import 'package:bilitv/apis/bilibili/media.dart'
    show getVideoInfo, getArchiveRelation, ArchiveRelation;
import 'package:bilitv/apis/bilibili/rcmd.dart' show fetchRelatedVideos;
import 'package:bilitv/apis/bilibili/toview.dart';
import 'package:bilitv/icons/iconfont.dart';
import 'package:bilitv/models/video.dart';
import 'package:bilitv/pages/video_player.dart';
import 'package:bilitv/storages/cookie.dart' show loginInfoNotifier;
import 'package:bilitv/utils/format.dart';
import 'package:bilitv/widgets/bilibili_image.dart';
import 'package:bilitv/widgets/loading.dart';
import 'package:bilitv/widgets/text.dart';
import 'package:bilitv/widgets/tooltip.dart';
import 'package:bilitv/widgets/video_grid_view.dart';
import 'package:flutter/material.dart';

class VideoDetailPageWrap extends StatelessWidget {
  final int? avid;
  final String? bvid;

  const VideoDetailPageWrap({super.key, this.avid, this.bvid});

  @override
  Widget build(BuildContext context) {
    return LoadingPage(
      loader: () async {
        final res = await Future.wait([
          getVideoInfo(avid: avid, bvid: bvid),
          getArchiveRelation(
            avid: avid,
            bvid: bvid,
          ).onError((_, _) => ArchiveRelation()),
          fetchRelatedVideos(avid: avid, bvid: bvid),
        ]);
        return VideoDetailPageInput(
          res[0] as Video,
          res[1] as ArchiveRelation,
          res[2] as List<MediaCardInfo>,
        );
      },
      builder: (context, input) {
        return VideoDetailPage(
          video: input.video,
          relation: input.relation,
          relatedVideos: input.relatedVideos,
        );
      },
    );
  }
}

class VideoDetailPageInput {
  final Video video;
  final ArchiveRelation relation;
  final List<MediaCardInfo> relatedVideos;

  VideoDetailPageInput(this.video, this.relation, this.relatedVideos);
}

class VideoDetailPage extends StatefulWidget {
  final Video video;
  final ArchiveRelation relation;
  final List<MediaCardInfo> relatedVideos;

  const VideoDetailPage({
    super.key,
    required this.video,
    required this.relation,
    this.relatedVideos = const [],
  });

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  late final _currentEpisodeCid = ValueNotifier(widget.video.cid);
  final _relatedVideosProvider = VideoGridViewProvider();

  @override
  void initState() {
    _relatedVideosProvider.addAll(widget.relatedVideos);
    super.initState();
  }

  void _onCoverTapped() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) =>
            VideoPlayerPage(video: widget.video, cid: _currentEpisodeCid.value),
      ),
    );
  }

  void _onVideoTapped(int _, MediaCardInfo video) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => VideoDetailPageWrap(avid: video.avid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = widget.video.episodes.length == 1
        ? [
            Expanded(flex: 3, child: _buildVideoHeader()),
            const Spacer(flex: 1),
            Expanded(flex: 2, child: _buildRelatedVideos()),
          ]
        : [
            Expanded(flex: 3, child: _buildVideoHeader()),
            Expanded(flex: 1, child: _buildEpisodes()),
            Expanded(flex: 2, child: _buildRelatedVideos()),
          ];
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildVideoHeader() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [_buildVideoPlayer(), SizedBox(width: 10), _buildVideoInfo()],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return InkWell(
      autofocus: true,
      onTap: _onCoverTapped,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BilibiliMediaThumbnail(widget.video.cover),
              ),
            ),
            Icon(Icons.play_circle_sharp, size: 150, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoInfo() {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildTitle()),
              Expanded(flex: 1, child: _buildRelations()),
              Expanded(flex: 3, child: _buildDescription()),
              Expanded(flex: 1, child: _buildOtherInfo()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return FixedLineAdaptiveText(
      widget.video.title,
      line: 2,
      style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRelations() {
    return Row(
      children: [
        Expanded(
          child: MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onPressed: () => pushTooltipWarning(context, '暂不支持该功能！'),
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Icon(
                      Icons.thumb_up_rounded,
                      color: widget.relation.like
                          ? Colors.pinkAccent
                          : Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: FixedLineAdaptiveText(
                    amountString(widget.video.stat.likeCount),
                    line: 1,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onPressed: () => pushTooltipWarning(context, '暂不支持该功能！'),
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Transform.scale(
                      scaleX: -1,
                      child: Icon(
                        Icons.thumb_down_rounded,
                        color: widget.relation.dislike
                            ? Colors.pinkAccent
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: FixedLineAdaptiveText(
                    amountString(widget.video.stat.dislikeCount),
                    line: 1,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onPressed: () => pushTooltipWarning(context, '暂不支持该功能！'),
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Icon(
                      IconFont.coin,
                      color: widget.relation.coin > 0
                          ? Colors.pinkAccent
                          : Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: FixedLineAdaptiveText(
                    amountString(widget.video.stat.coinCount),
                    line: 1,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onPressed: () => pushTooltipWarning(context, '暂不支持该功能！'),
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Icon(
                      Icons.favorite_rounded,
                      color: widget.relation.favorite
                          ? Colors.pinkAccent
                          : Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: FixedLineAdaptiveText(
                    amountString(widget.video.stat.favoriteCount),
                    line: 1,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onPressed: () {
              if (!loginInfoNotifier.value.isLogin) return;

              setState(() {
                widget.relation.inPlayList = !widget.relation.inPlayList;
              });
              if (widget.relation.inPlayList) {
                deleteToView(widget.video.avid);
                pushTooltipInfo(context, '已从稍后再看中移除：${widget.video.title}');
              } else {
                addToView(avid: widget.video.avid);
                pushTooltipInfo(context, '已加入稍后再看：${widget.video.title}');
              }
            },
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Icon(
                      Icons.playlist_add_rounded,
                      color: widget.relation.inPlayList
                          ? Colors.pinkAccent
                          : Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: FixedLineAdaptiveText(
                    '稍后再看',
                    line: 1,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onPressed: null,
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Icon(IconFont.share, color: Colors.grey),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: FixedLineAdaptiveText(
                    amountString(widget.video.stat.shareCount),
                    line: 1,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: FixedLineAdaptiveText(
            '视频简介',
            line: 1,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Spacer(flex: 1),
        Expanded(
          flex: 14,
          child: FixedLineAdaptiveText(
            widget.video.desc,
            line: 12,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtherInfo() {
    return Row(
      children: [
        BilibiliAvatar(widget.video.userAvatar),
        const SizedBox(width: 12),
        Column(
          children: [
            Spacer(flex: 1),
            Expanded(
              flex: 3,
              child: FixedLineAdaptiveText(
                widget.video.userName,
                line: 1,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Spacer(flex: 1),
            Expanded(
              flex: 2,
              child: FixedLineAdaptiveText(
                'UP主',
                line: 1,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
            Spacer(flex: 1),
          ],
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Spacer(flex: 3),
              Expanded(
                flex: 1,
                child: FixedLineAdaptiveText(
                  '发布日期: ${datetimeString(widget.video.publishTime)}',
                  line: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onEpisodeTapped(Episode episode) {
    if (episode.cid == _currentEpisodeCid.value) return;
    _currentEpisodeCid.value = episode.cid;
  }

  Widget _buildEpisodes() {
    final children = widget.video.episodes
        .map(
          (episode) => AspectRatio(
            aspectRatio: 1.5,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.pinkAccent.shade100, Colors.blue.shade100],
                ),
              ),
              child: ValueListenableBuilder(
                valueListenable: _currentEpisodeCid,
                builder: (context, cid, child) => MaterialButton(
                  color: episode.cid == cid ? Colors.pinkAccent.shade100 : null,
                  focusColor: episode.cid == cid
                      ? Colors.lightBlueAccent
                      : Colors.blue.shade100,
                  hoverColor: episode.cid == cid
                      ? Colors.lightBlueAccent
                      : Colors.blue.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onPressed: () => _onEpisodeTapped(episode),
                  child: child,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'P${episode.index}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        episode.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        videoDurationString(episode.duration),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        margin: const EdgeInsets.all(16),
        child: ListView(scrollDirection: Axis.horizontal, children: children),
      ),
    );
  }

  Widget _buildRelatedVideos() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: VideoGridView(
        provider: _relatedVideosProvider,
        scrollDirection: Axis.horizontal,
        onItemTap: _onVideoTapped,
        crossAxisCount: 1,
      ),
    );
  }
}
