import '../models/work.dart';

/// MVP用の仮作品データ。
/// TODO(future): 公式サイトのRSS/API、ユーザー投稿、管理画面承認に置き換える。
const List<Work> mockWorks = [
  Work(
    id: 'w_kimetsu',
    title: '鬼滅の刃',
    aliases: ['Kimetsu no Yaiba', 'Demon Slayer'],
    genre: 'アニメ / 漫画',
    isFavorite: true,
  ),
  Work(
    id: 'w_jujutsu',
    title: '呪術廻戦',
    aliases: ['Jujutsu Kaisen', 'JJK'],
    genre: 'アニメ / 漫画',
    isFavorite: true,
  ),
  Work(
    id: 'w_bluelock',
    title: 'ブルーロック',
    aliases: ['BLUE LOCK'],
    genre: 'アニメ / 漫画',
  ),
  Work(
    id: 'w_oshinoko',
    title: '推しの子',
    aliases: ['【推しの子】', 'Oshi no Ko'],
    genre: 'アニメ / 漫画',
    isFavorite: true,
  ),
  Work(
    id: 'w_frieren',
    title: '葬送のフリーレン',
    aliases: ['Frieren'],
    genre: 'アニメ / 漫画',
  ),
  Work(
    id: 'w_genshin',
    title: '原神',
    aliases: ['Genshin Impact'],
    genre: 'ゲーム',
  ),
  Work(
    id: 'w_umamusume',
    title: 'ウマ娘 プリティーダービー',
    aliases: ['ウマ娘', 'Uma Musume'],
    genre: 'ゲーム / アニメ',
  ),
  Work(
    id: 'w_fate',
    title: 'Fate シリーズ',
    aliases: ['Fate/Grand Order', 'FGO', 'Fate/stay night'],
    genre: 'ゲーム / アニメ',
  ),
];
