import '../models/video_model.dart';

class MockData {
  static List<VideoModel> getVideoList() {
    return [
      VideoModel(
        id: '1',
        title: '【2024拜年纪】洛天依原创曲《万家灯火》',
        description: '一首温暖的歌曲，陪伴大家度过美好的春节时光',
        thumbnail:
            'https://static-cse.canva.cn/blob/381231/1600w-YZq7I0hiBT8.jpg',
        duration: '3:45',
        viewCount: '128.5万',
        danmakuCount: '8932',
        userName: '洛天依Official',
        userAvatar:
            'https://th.bing.com/th/id/OSK.27768dbe2ead012b57a8b7c5ca83f4d9?w=102&h=102&c=7&o=6&dpr=1.3&pid=SANGAM',
        publishTime: DateTime.now().subtract(const Duration(days: 1)),
      ),
      VideoModel(
        id: '2',
        title: '【4K60帧】原神4.6版本「两界为火，赤夜将熄」前瞻特别节目',
        description: '原神4.6版本前瞻直播，精彩内容不容错过',
        thumbnail:
            'https://static-cse.canva.cn/blob/381231/1600w-YZq7I0hiBT8.jpg',
        duration: '28:16',
        viewCount: '256.8万',
        danmakuCount: '12543',
        userName: '原神',
        userAvatar:
            'https://th.bing.com/th/id/OSK.27768dbe2ead012b57a8b7c5ca83f4d9?w=102&h=102&c=7&o=6&dpr=1.3&pid=SANGAM',
        publishTime: DateTime.now().subtract(const Duration(days: 2)),
      ),
      VideoModel(
        id: '3',
        title: '【MMD】Racing is everything【L2D/表情/动作表情】',
        description: '精彩的MMD舞蹈视频，高清画质享受视觉盛宴',
        thumbnail:
            'https://static-cse.canva.cn/blob/381231/1600w-YZq7I0hiBT8.jpg',
        duration: '4:12',
        viewCount: '89.3万',
        danmakuCount: '6721',
        userName: 'MMD爱好者',
        userAvatar:
            'https://th.bing.com/th/id/OSK.27768dbe2ead012b57a8b7c5ca83f4d9?w=102&h=102&c=7&o=6&dpr=1.3&pid=SANGAM',
        publishTime: DateTime.now().subtract(const Duration(days: 3)),
      ),
      VideoModel(
        id: '4',
        title: '【AI翻唱】《花海》周杰伦 vs 邓紫棋【AI孙燕姿】',
        description: 'AI技术重现经典歌曲，不一样的视听体验',
        thumbnail:
            'https://static-cse.canva.cn/blob/381231/1600w-YZq7I0hiBT8.jpg',
        duration: '4:38',
        viewCount: '312.6万',
        danmakuCount: '18932',
        userName: 'AI音乐实验室',
        userAvatar:
            'https://th.bing.com/th/id/OSK.27768dbe2ead012b57a8b7c5ca83f4d9?w=102&h=102&c=7&o=6&dpr=1.3&pid=SANGAM',
        publishTime: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      VideoModel(
        id: '5',
        title: '【游戏实况】艾尔登法环DLC黄金树幽影全流程',
        description: '详细攻略解说，助你轻松通关DLC内容',
        thumbnail:
            'https://static-cse.canva.cn/blob/381231/1600w-YZq7I0hiBT8.jpg',
        duration: '45:20',
        viewCount: '67.9万',
        danmakuCount: '5432',
        userName: '游戏达人',
        userAvatar:
            'https://th.bing.com/th/id/OSK.27768dbe2ead012b57a8b7c5ca83f4d9?w=102&h=102&c=7&o=6&dpr=1.3&pid=SANGAM',
        publishTime: DateTime.now().subtract(const Duration(days: 5)),
      ),
      VideoModel(
        id: '6',
        title: '【美食】家常菜谱：红烧肉的完美做法',
        description: '详细步骤教学，让你在家也能做出餐厅级美味',
        thumbnail:
            'https://static-cse.canva.cn/blob/381231/1600w-YZq7I0hiBT8.jpg',
        duration: '12:45',
        viewCount: '45.2万',
        danmakuCount: '3210',
        userName: '美食生活家',
        userAvatar:
            'https://th.bing.com/th/id/OSK.27768dbe2ead012b57a8b7c5ca83f4d9?w=102&h=102&c=7&o=6&dpr=1.3&pid=SANGAM',
        publishTime: DateTime.now().subtract(const Duration(days: 7)),
      ),
      VideoModel(
        id: '7',
        title: '【科技】2024年最值得期待的数码产品盘点',
        description: '最新科技产品评测，数码爱好者必看',
        thumbnail:
            'https://static-cse.canva.cn/blob/381231/1600w-YZq7I0hiBT8.jpg',
        duration: '18:30',
        viewCount: '92.7万',
        danmakuCount: '7891',
        userName: '科技前沿',
        userAvatar:
            'https://th.bing.com/th/id/OSK.27768dbe2ead012b57a8b7c5ca83f4d9?w=102&h=102&c=7&o=6&dpr=1.3&pid=SANGAM',
        publishTime: DateTime.now().subtract(const Duration(days: 4)),
      ),
      VideoModel(
        id: '8',
        title: '【萌宠】猫咪的日常：当猫咪遇到激光笔',
        description: '可爱猫咪的搞笑日常，治愈你的心灵',
        thumbnail:
            'https://static-cse.canva.cn/blob/381231/1600w-YZq7I0hiBT8.jpg',
        duration: '8:15',
        viewCount: '156.4万',
        danmakuCount: '11234',
        userName: '萌宠世界',
        userAvatar:
            'https://th.bing.com/th/id/OSK.27768dbe2ead012b57a8b7c5ca83f4d9?w=102&h=102&c=7&o=6&dpr=1.3&pid=SANGAM',
        publishTime: DateTime.now().subtract(const Duration(days: 6)),
      ),
    ];
  }

  static List<String> getCategories() {
    return [
      '推荐',
      '动画',
      '游戏',
      '知识',
      '影视',
      '生活',
      '鬼畜',
      '音乐',
      '舞蹈',
      '游戏',
      '知识',
      '数码',
      '运动',
      '美食',
      '动物',
      '汽车',
    ];
  }
}
