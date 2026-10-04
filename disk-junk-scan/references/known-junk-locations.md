# 已知缓存/垃圾位置知识库

`scan.ps1` 的 `known[]` 输出按 `id` 查本表得到风险级别与清理后果。
`deep[]`/`tree[]` 的条目没有 id，按文末"路径模式规则"判定。

## 风险级别

- **🟢 可直接清理**：删除后功能完整，顶多重新下载/自动重建，无需判断。
- **🟡 有代价，需用户决定**：有实质代价（重新登录、大体积重新下载、不可逆、混合数据）。

`running=true`（扫描时相关进程在运行）的条目，无论级别，都追加"先关闭 X，否则被占用文件删不掉"。

## 系统位置

| id | 级别 | 清了会怎样 |
|---|---|---|
| sys-temp-user | 🟢 | 用户临时文件；被占用的会删不掉，跳过即可 |
| sys-temp-windows | 🟢 | 系统临时文件；需管理员，同上 |
| sys-update-download | 🟢 | 已下载的 Windows Update 安装包；需要时会重新下载 |
| sys-windows-logs | 🟢 | 系统日志；旧日志可删，当前日志被占用删不掉 |
| sys-minidump / sys-memory-dump | 🟢 | 蓝屏/崩溃转储；不做内部分析即可删 |
| sys-wer-user / sys-wer-shared / sys-crash-dumps | 🟢 | 应用崩溃报告；删了只是失去历史诊断信息 |
| sys-inet-cache | 🟢 | 系统 Web 缓存；自动重建 |
| sys-thumb-cache | 🟢 | 缩略图缓存；重建期间文件夹预览稍慢 |
| sys-delivery-optimization | 🟢 | 更新 P2P 分发缓存；不影响已安装更新 |
| sys-d3d-shader-cache / sys-nvidia-*-cache / sys-amd-*-cache | 🟢 | 显卡着色器缓存；游戏/应用首次启动会重新编译，稍卡 |
| sys-prefetch | 🟢 | 启动预读数据；自动重建，短期开机略慢 |
| sys-live-kernel-reports | 🟢 | 内核诊断转储；可删 |
| sys-store-app-temps / sys-store-ac-temp / sys-store-ac-inetcache | 🟢 | 商店应用临时文件；自动重建 |
| sys-patch-cache | 🟡 | Windows Installer 补丁缓存；删后部分"修复/修改安装"需重新下载，可能失败 |
| sys-package-cache | 🟡 | VS 等安装器的本地安装源；卸载/修改组件时可能找不到源 |
| sys-recycle-bin-C / sys-recycle-bin-D | 🟡 | 回收站；清空不可逆，确认没有要恢复的文件 |

## 浏览器（全部 🟢）

| id | 说明 |
|---|---|
| chrome-cache / chrome-code-cache | 网页缓存；删除后网站首次加载变慢，不丢登录态（Cookies 不在此处） |
| edge-cache / edge-code-cache | 同上 |
| firefox-cache2 | 同上 |
| opera-cache / opera-code-cache | 同上 |

## 开发工具缓存

| id | 级别 | 清了会怎样 |
|---|---|---|
| npm-cache / yarn-cache / pnpm-store / pnpm-cache-dir / pip-cache / uv-cache / poetry-cache | 🟢 | 包管理器缓存；下次安装重新下载 |
| cargo-registry-cache | 🟢 | crate 下载缓存；重新下载 |
| go-build-cache | 🟢 | 编译缓存；下次编译变慢，结果不受影响 |
| electron-cache / electron-builder-cache | 🟢 | 框架二进制缓存；重新下载 |
| puppeteer-cache / playwright-cache | 🟢 | 浏览器二进制缓存；`playwright install` 可重建 |
| user-dot-cache | 🟢 | 通用 `~/.cache`（含 puppeteer 等）；重建 |
| go-pkg-mod | 🟡 | Go 模块本地副本；删后构建需联网重新下载，离线环境会失败 |
| gradle-caches / maven-repository | 🟡 | 依赖与构件库；删后重新下载量大，离线构建失败 |
| nuget-packages | 🟡 | NuGet 全局包目录；`dotnet restore` 可重建，但量大 |
| conda-pkgs | 🟡 | conda 包缓存；已有环境不受影响，新建环境需重新下载 |

## 应用数据（全部 🟡 —— 缓存与数据混合，优先建议在应用内清理）

| id | 说明 |
|---|---|
| app-wechat-local / app-weixin-local | 微信/Weixin 数据与缓存混合；直接删可能触发重新登录、丢本地聊天文件索引。建议在微信"设置 → 存储空间"内清理 |
| app-qq-local | 同类；建议 QQ 内置清理 |
| app-wemeet | 腾讯会议缓存；建议应用内清理 |
| app-wps-kingsoft | WPS 数据/缓存混合；可能含云文档本地缓存，建议 WPS 内清理 |
| app-dingtalk | 钉钉数据/缓存混合；建议应用内清理 |
| app-feishu | 飞书数据/缓存混合；建议应用内清理 |
| steam-htmlcache | Steam 网页缓存；重建 |
| epic-webcache | Epic 启动器网页缓存；重建 |
| docker-wsl-disk | Docker 的 WSL 虚拟磁盘；**绝不直接删文件，也不提供回收命令**，只能提示用户在 Docker Desktop 内使用其内置的镜像/容器清理功能 |

## 路径模式规则（用于 deep[] / tree[] / rootFiles[]）

| 路径匹配 | 处理 |
|---|---|
| `\User Data\` 内的 Cache / Code Cache / GPUCache / ShaderCache / CacheStorage | 🟢 浏览器缓存 |
| `AppData` 下名称含 Cache/Temp/Logs/Crashpad 等（deep[] 已按此收集） | 🟡 应用缓存，建议关闭应用后清理或在应用内清理 |
| `Packages\` 下的 Temp/Cache | 🟢 商店应用缓存 |
| `Downloads`、`Documents`、`Desktop`、`Pictures`、`Videos`、`Music`、`OneDrive`、用户配置文件根目录 | **个人文件**：只进目录级汇总，不列单文件明细 |
| `node_modules`、`.git`、构建产物目录 | **项目文件**：不列为清理项，归入"需人工判断"汇总 |
| `pagefile.sys`、`hiberfil.sys`、`swapfile.sys` | 系统文件：只在汇总中提一句，不可删 |
| `\Windows.old$` | 🟡 升级残留，需用户确认无回滚需求（建议走系统"磁盘清理"） |
| `ext4.vhdx`、`DockerDesktopWSL`、`Hyper-V`、`Virtual Machines` | 虚拟磁盘：**永不建议直接删除**，只统计大小 |
| `C:\Windows`、`Program Files`、`WinSxS`、`System Volume Information` | 系统目录：不列为清理项（扫描脚本已跳过） |
| 其他未命中的大目录（tree[] 大部分） | 归"需人工判断"汇总：只报路径+大小，不建议直接删 |

## 判定兜底

- 拿不准 → 不列明细，放入"需人工判断"汇总。
- 报告中每个 🟡 必须写明代价；每个 🟢 running=true 必须写明先关哪个进程。
