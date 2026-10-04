# Sources & quality patterns

Two uses: (1) candidate sources to bet on when general search misses — Chinese-language, niche/indie, "a directory of X", downloads with unknown host sites; (2) quality-pattern samples for the quality gate. Do not come here for common verticals (GitHub, arXiv, Stack Overflow, official docs) — use those directly.

## Reject patterns (黑名单是模式样本，不是穷举 — 同类特征即拒绝)

| Pattern | Examples | Why |
|---|---|---|
| 捆绑下载站 | 当当软件园、华军、天空、多特、pc6、当下软件园 | "高速下载"是假链，真下载器捆绑全家桶；软件一律先找官方站 / GitHub Releases |
| 文档收费墙农场 | docin、doc88、原创力、道客巴巴 | 用户上传+付费墙，来源不可溯，质量不可控 |
| 下载付费墙社区 | CSDN 下载频道 | 用户上传资源换积分，错误版本/缺文件常见；CSDN 博客文章仅低参考 |
| 营销号/SEO 农场 | 百家号、洗稿站、AI 批量生成站 | 无作者、拼凑、标题党；只当线索，不当来源 |
| 假入口站 | 满屏广告的"绿色软件/破解"站、仿官网站 | 域名与官方近似、按钮全是广告位 |

## Chinese aggregators / nav stations (中文聚合与导航)

| Site | URL | Use for |
|---|---|---|
| AIHOT | https://aihot.virxact.com/ | AI 行业多源时间线 + 编辑批注，找 AI 资讯/动态 |
| TopHub 今日热榜 | https://tophub.today/ | 50+ 平台热榜聚合，找"某平台今天在热什么" |
| 一点导航 | https://oneclicknav.cn/ | 资源/工具分类导航，覆盖面广 |
| Buzzing | https://buzzing.cc/ | HN / Twitter 讨论聚合（中英） |
| Zeli | https://zeli.app/ | HN 每日中文摘要 |
| 鳗鱼ACG | https://manyacg.com/ | 二次元综合导航，资讯/站点/美图分区，Bangumi、Pixiv 等入口卡片 |
| 米给二次元导航 | https://acg.migei.com/ | 大而全的二次元网址大全，按导航/视频/游戏/工具分栏 |

## Feed & news aggregation (RSS与新闻聚合)

| Site | URL | Use for |
|---|---|---|
| Ground News | https://ground.news/ | 同一新闻的多源对比，标注左右翼来源占比与 Blindspot |

## Small / independent search engines (小众搜索引擎)

| Engine | URL | Use for |
|---|---|---|
| Marginalia | https://search.marginalia.nu/ | 小众、非商业、个人网站——大引擎搜不到的东西 |
| Wiby | https://wiby.me/ | 独立小站、冷门内容 |
| Mojeek | https://mojeek.com/ | 独立索引，SEO 噪音低 |
| SearchPedia | https://techbloat.com/searchpedia | 250+ 搜索引擎分类目录——要找"某领域的垂直搜索引擎"时查它(有人机验证) |

## Images (图片)

| Source | URL | Use for |
|---|---|---|
| Yandex Images | https://images.yandex.com/ | 以图搜图、角色/动漫图识别，常强于 Google |
| SauceNAO | https://saucenao.com/ | 动漫/插画反查原始出处与画师 |
| Zerochan | https://zerochan.net/ | 动漫角色壁纸垂直站；原图是详情页 `a[href*=".full."]`（`s3.zerochan.net/...` 缩略图是陷阱） |
| Wallhaven | https://wallhaven.cc/ | 高清壁纸；原图直链可推导：`https://w.wallhaven.cc/full/{id前2位}/wallhaven-{id}.jpg`，详情页 `<title>` 内嵌 `WxH` 可页面内 fetch 预筛 |
| gsbooru | https://gsbooru.org/ | booru 镜像，免登录直出 `/files/images/...` 原图（danbooru 原图要登录） |
| pixiv | https://www.pixiv.net/ | 二次元图片、漫画、小说站点 |

## Fonts (字体)

| Site | URL | Use for |
|---|---|---|
| 100font | https://100font.com/ | 免费商用中文字体合集，附授权说明 |
| 猫啃网 | https://maoken.com/ | 免费商用中英文字体，免登录下载，附预览 |
| 自由字体 | https://ziyouziti.com/ | 免费商用字体聚合，中英日韩 |
| 字体天下 | https://fonts.net.cn/ | 中英文字体全，免费/付费分区明确 |
| FontSpace | https://fontspace.com/ | 海量英文免费字体，逐个标注 license |
| 1001 Fonts | https://1001fonts.com/ | 英文免费字体，免登录下载 |
| 求字体 | https://qiuziti.com/ | 识图找字：由截图/照片反查字体名 |

## Design assets (设计素材)

| Site | URL | Use for |
|---|---|---|
| Storyset | https://storyset.com/ | 免费可商用插画，在线改色，SVG/PNG |
| unDraw | https://undraw.co/ | 开源扁平插画，一键换主色 |
| Flaticon | https://flaticon.com/ | 60万+ 图标，PNG/SVG/EPS/PSD |
| 包图网 | https://ibaotu.com/ | 中文综合素材（图片/视频/AE模板），每日免费1次 |
| 站长素材 | https://sc.chinaz.com/ | 老牌中文素材站，PPT/图片/音效免费下 |
| The Noun Project | https://thenounproject.com/ | 极简图标库，按图形找 icon |

## Video & audio assets (音视频素材)

| Site | URL | Use for |
|---|---|---|
| Mixkit | https://mixkit.co/ | 免费视频+BGM+音效，免登录，可商用免署名 |
| Pexels Videos | https://pexels.com/videos | 免费视频/图片，免登录下载 |
| Coverr | https://coverr.co/ | 免费背景视频 |
| PikWizard | https://pikwizard.com/ | 免费视频素材，免登录下载 |
| Freesound | https://freesound.org/ | CC 授权音效库，量最大 |
| ZapSplat | https://zapsplat.com/ | 6.5万+ 免费音效，26 个类目 |
| Musopen | https://musopen.org/ | 古典音乐/乐器录音，免版税 |
| Free Music Archive | https://freemusicarchive.org/ | CC 授权全曲音乐，按许可筛选可用范围 |
| Jamendo | https://jamendo.com/ | 免版税全曲音乐，视频 BGM 主力来源 |

## E-books (电子书)

| Site | URL | Use for |
|---|---|---|
| 鸠摩搜书 | https://jiumodiary.com/ | 中文电子书跨站搜索，按格式分类聚合下载 |
| Project Gutenberg | https://gutenberg.org/ | 公版书鼻祖，免注册，EPUB/Kindle/txt |
| Open Library | https://openlibrary.org/ | 每书一页的开放目录，可借可下 |
| 书格 | https://shuge.org/ | 中文古籍高清 PDF，免费 |
| ManyBooks | https://manybooks.net/ | 免费英文电子书，分类细 |
| LibriVox | https://librivox.org/ | 公版书有声读物，志愿者朗读 |
| Internet Archive | https://archive.org/ | 数千万图书/音视频/软件归档，公版直接下，馆藏书可在线借 |
| Standard Ebooks | https://standardebooks.org/ | 公版书精排版重制，免费电子书里排版最好 |
| 番茄小说 | https://fanqienovel.com/ | 免费网文全本在线读，广告支持，量大 |
| Z-Library | https://z-lib.cx/ | 免费好用、资源全面的电子书下载站；域名换得勤（z-lib.org 证书失效，现行主域 z-lib.cx，另有 https://zh.z-library.sk/ 等镜像） |
| Anna's Archive | https://annas-archive.pk/ | 超大规模电子书/论文/漫画聚合搜索（LibGen+Sci-Hub+Z-Lib 三库合一）；主域常换，.org 已被停，现行镜像 .pk/.gl/.gd |

## Anime & ACG (动漫与ACG)

| Site | URL | Use for |
|---|---|---|
| Bangumi 番组计划 | https://bgm.tv/ | 中文 ACG 资料库与追番记录，动画/书籍/音乐/游戏全收录 |
| MyAnimeList | https://myanimelist.net/ | 英文番剧数据库+季节榜+评分，追番清单事实标准之一 |
| AniList | https://anilist.co/ | 英文番剧数据库，界面现代，趋势/本季人气/Top 100 榜 |
| 萌娘百科 | https://zh.moegirl.org.cn/ | 中文 ACG 百科词条，设定考据/梗源/新番专题 |
| 蜜柑计划 Mikan | https://mikanani.me/ | 番剧资源聚合，按周更新表分栏，自带字幕组发布 |
| Nyaa | https://nyaa.si/ | 最大动漫 BT 种子站，分类含字幕组/生肉/轻小说，日文名检索 |
| awesome-anime-sources | https://github.com/anshumanv/awesome-anime-sources | 动漫/漫画/轻小说资源与数据库的分类清单，找垂直站先翻它 |

## Galgame / Visual Novels (Galgame与视觉小说)

| Site | URL | Use for |
|---|---|---|
| VNDB | https://vndb.org/ | 全球视觉小说数据库（6.6万+条目），标签/评分/翻译状态/职员检索 |
| CnGal 资料站 | https://www.cngal.org/ | 中文 Galgame 资料库，国产作品词条/角色/制作人员最全 |
| 月幕Galgame | https://www.ymgal.games/ | 中文 Galgame 综合平台，游戏精选/专栏/带评分的安利廊 |
| Galgame Wiki | https://www.galgamewiki.com/ | 中文 Galgame 百科（742+词条），按会社整理作品档案（旧域 galgame.it 会跳转） |

## Manga (漫画)

| Site | URL | Use for |
|---|---|---|
| MangaDex | https://mangadex.org/ | 多语种漫画聚合阅读，条目+章节更新流，社区翻译组织全 |

## Software discovery (软件发现与替代)

| Site | URL | Use for |
|---|---|---|
| AlternativeTo | https://alternativeto.net/ | 输入软件名→社区投票的替代品，按免费/开源/平台筛 |
| OpenSource Builders | https://opensource.builders/ | 知名商业产品的开源实现索引 |
| 异次元软件世界 | https://iplaysoft.com/ | 中文老牌软件站，免费/良心软件口碑筛选 |
| 少数派 | https://sspai.com/ | 效率工具评测与年度榜单，中文社区口碑 |

## AI tools (AI 工具)

| Site | URL | Use for |
|---|---|---|
| AI工具集 | https://ai-bot.cn/ | 中文 AI 工具导航，分类+官网直达 |
| AIGC导航 | https://aigc.cn/ | 老牌中文 AI 导航，标注可直连入口 |
| Toolify | https://toolify.ai/ | 全球 AI 工具榜，按流量/类别排 |
| 优设AI导航 | https://hao.uisdc.com/ | 设计师向 AI 工具精选 |

## Games & 3D (游戏与3D素材)

| Site | URL | Use for |
|---|---|---|
| itch.io game-assets | https://itch.io/game-assets | 独立游戏资产，免费比重大，像素/体素风多 |
| OpenGameArt | https://opengameart.org/ | CC/公有领域游戏美术与音乐 |
| Kenney | https://kenney.nl/asset | 公有领域 2D/3D 游戏资产包，整包下 |
| Poly Haven | https://polyhaven.com/ | CC0 PBR 贴图/HDRI/模型 |
| Fab | https://fab.com/ | Epic 旗下综合资产平台，每月免费送 |
| MakerWorld | https://makerworld.com/ | 3D 打印模型社区（拓竹），免登录下载 |
| Printables | https://printables.com/ | Prusa 的 3D 打印模型库 |
| Thingiverse | https://thingiverse.com/ | 老牌 3D 打印模型站，200万+ STL |

## Film & TV (影视)

| Site | URL | Use for |
|---|---|---|
| JustWatch | https://justwatch.com/ | 查某片在哪些正版平台可看（按地区） |
| TMDB | https://themoviedb.org/ | 影视数据库，海报/元数据/字幕站的数据源 |

## Finding resource sites (先找资源站)

Generic search for a download target mostly returns SEO junk; the reliable path is finding the site first, then the resource inside it. Place these bets in the same parallel batch as ordinary queries — drill into them only when ordinary candidates fail verification.

- 社区反查（人分享链接的地方，等于别人先筛过一轮）：`X 在哪下载`、`X 资源站推荐`、`哪里有 X` 加社区限定 — `site:zhihu.com`、`site:tieba.baidu.com`、`site:bilibili.com`、`site:reddit.com`、`site:v2ex.com`；垂直论坛用 `X 论坛` / `X forum` 先搜出来。
- 站生站：拿到任一靠谱站后，看友链/"相关推荐"，或 `site:同类域名 关键词` 裂变出同类候选站。
- 站的通过标准：页面上可见地承载"这一类"资源（分类页、列表页或站内搜索有结果）即可；具体资源留给站内搜那一步。

## Entry patterns (入口模式)

- 站内限定：`site:domain 关键词`
- 图片：`关键词 filetype:jpg` 或引擎的图片标签页；要原图就一路开到图片 URL 本身
- 找资源目录/聚合站：`XX资源聚合`、`XX 导航`、`awesome XX`、`XX directory`
- 中文目标用中文关键词搜一遍，英文目标用英文关键词搜一遍，各跑一次
- 反爬/验证码换入口：同一目标换上面的小众引擎或导航站，而不是死磕
