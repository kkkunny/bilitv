import 'package:bilitv/apis/bilibili/media.dart'
    show getVideoInfo, getArchiveRelation, ArchiveRelation;
import 'package:bilitv/apis/bilibili/rcmd.dart' show fetchRelatedVideos;
import 'package:bilitv/consts/bilibili.dart';
import 'package:bilitv/icons/iconfont.dart';
import 'package:bilitv/models/video.dart';
import 'package:bilitv/pages/video_player.dart';
import 'package:bilitv/utils/format.dart';
import 'package:bilitv/widgets/bilibili_image.dart';
import 'package:bilitv/widgets/loading.dart';
import 'package:bilitv/widgets/video_card.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
          getArchiveRelation(avid: avid, bvid: bvid),
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

  void _onCoverTapped() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) =>
            VideoPlayerPage(video: widget.video, cid: _currentEpisodeCid.value),
      ),
    );
  }

  void _onVideoTapped(MediaCardInfo video) {
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
            _buildVideoHeader(),
            const SizedBox(height: 24),
            _buildRelatedVideos(),
          ]
        : [
            _buildVideoHeader(),
            const SizedBox(height: 24),
            _buildEpisodes(),
            const SizedBox(height: 24),
            _buildRelatedVideos(),
          ];
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildVideoHeader() {
    return Row(children: [_buildVideoPlayer(), _buildVideoInfo()]);
  }

  Widget _buildVideoPlayer() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: InkWell(
          onTap: _onCoverTapped,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: coverSizeRatio,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BilibiliNetworkImage(widget.video.cover),
                    ),
                  ),
                ),
                Icon(Icons.play_circle_sharp, size: 150, color: Colors.black54),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoInfo() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: AspectRatio(
            aspectRatio: coverSizeRatio,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 110,
                    child: Text(
                      widget.video.title,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onPressed: () {},
                          child: Column(
                            children: [
                              Icon(
                                Icons.thumb_up_rounded,
                                size: 40,
                                color: widget.relation.like
                                    ? Colors.pinkAccent
                                    : Colors.grey,
                              ),
                              Text(
                                amountString(widget.video.stat.likeCount),
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey.shade600,
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
                          onPressed: () {},
                          child: Column(
                            children: [
                              Transform.scale(
                                scaleX: -1,
                                child: Icon(
                                  Icons.thumb_down_rounded,
                                  size: 40,
                                  color: widget.relation.dislike
                                      ? Colors.pinkAccent
                                      : Colors.grey,
                                ),
                              ),
                              Text(
                                amountString(widget.video.stat.dislikeCount),
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey.shade600,
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
                          onPressed: () {},
                          child: Column(
                            children: [
                              Icon(
                                IconFont.coin,
                                size: 40,
                                color: widget.relation.coin > 0
                                    ? Colors.pinkAccent
                                    : Colors.grey,
                              ),
                              Text(
                                amountString(widget.video.stat.coinCount),
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey.shade600,
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
                          onPressed: () {},
                          child: Column(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 46,
                                color: widget.relation.favorite
                                    ? Colors.pinkAccent
                                    : Colors.grey,
                              ),
                              Text(
                                amountString(widget.video.stat.favoriteCount),
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey.shade600,
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
                          onPressed: () {},
                          child: Column(
                            children: [
                              Icon(
                                Icons.playlist_add_rounded,
                                size: 50,
                                color: widget.relation.inPlayList
                                    ? Colors.pinkAccent
                                    : Colors.grey,
                              ),
                              Text(
                                '',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey.shade600,
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
                              Icon(
                                IconFont.share,
                                size: 40,
                                color: Colors.grey,
                              ),
                              Text(
                                amountString(widget.video.stat.shareCount),
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '视频简介',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Text(
                      widget.video.desc,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: BilibiliAvatar(widget.video.userAvatar),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.video.userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'UP主',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '发布日期: ${datetimeString(widget.video.publishTime)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onEpisodeTapped(Episode episode) {
    if (episode.cid == _currentEpisodeCid.value) return;
    _currentEpisodeCid.value = episode.cid;
  }

  Widget _buildEpisodes() {
    final children = widget.video.episodes
        .map(
          (episode) => Container(
            width: 200,
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
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '视频分P',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            margin: const EdgeInsets.all(16),
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedVideos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '相关视频',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: videoCardWidth,
            childAspectRatio: 1.1,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: widget.relatedVideos.length,
          itemBuilder: (context, index) {
            return VideoCard(
              video: widget.relatedVideos[index],
              onTap: () => _onVideoTapped(widget.relatedVideos[index]),
            );
          },
        ),
      ],
    );
  }
}
