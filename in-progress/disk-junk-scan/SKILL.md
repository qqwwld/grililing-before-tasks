---
name: disk-junk-scan
description: 扫描诊断 Windows 磁盘缓存/垃圾文件并分级报告（🟢照单可清 / 🟡有代价需判断），审查通过后经用户明确指示"清理"，用内置受控脚本按白名单执行删除并核验。触发词：清理内存、清垃圾文件、清缓存、扫描垃圾、C盘满了、磁盘空间不足、释放空间、电脑卡、磁盘清理、查什么占了空间、执行清理。
---

# Disk Junk Scan — 先审查，后受控清理

两阶段：**扫描审查（默认，只读）→ 仅当用户明确说"清理"且报告已供其审查，才受控执行删除**。

## 硬约束

1. **审查阶段零删除**：扫描、生成报告期间禁止任何删除、移动、重命名、清空回收站、改权限。
2. **无报告不执行**：本对话必须已有扫描报告并交用户审查。用户未看报告就说"清理"→ 先扫描出报告请其审查，本轮不执行。
3. **删除只经 `scripts\clean.ps1`**：清理一律通过"生成 manifest → 该脚本执行"完成；禁止手写删除命令（`Remove-Item`、`Del`、`rd`、`rm`、`cleanmgr`、`Clear-RecycleBin` 等），不生成其他清理脚本。脚本内置路径校验（允许根、个人/系统/虚拟磁盘黑名单、系统目录白名单、保护目录）；被脚本拒绝的项如实告知用户，不绕过、不换手段。
4. PowerShell 调用一律 `-File` 方式；复杂内联逻辑先写临时 `.ps1` 再执行（内联 `-Command` 会被外层 shell 吞掉 `$_` 和引号）。

## 范围规则

- 用户泛指"清理/清一下" → 只清报告中 🟢。
- 用户点名具体项（如"unity缓存"） → 点名项计入范围（可为 🟡）；未点名的 🟡 一律不动。
- 个人文件（Downloads、Documents、桌面、图片、OneDrive、聊天/下载文件）、系统目录（WinSxS、Program Files、Windows 本体）、虚拟磁盘（`*.vhdx`、Docker/WSL）永不进入 manifest——即使被点名也告知不可清、需另行处理。

## 审查阶段（默认触发）

1. 全盘只读扫描：
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File "<skill目录>\scripts\scan.ps1" -OutFile "$env:TEMP\junk-scan.json"
   ```
   全盘约 3–10 分钟；`-KnownOnly` 快速模式；`-Path "<目录>"` 单目录测量。输出 `known[]`（含 `path` 模式与 `running` 进程标记）、`deep[]`、`tree[]`、`rootFiles[]`、`disks[]`、`totals`、`truncated`、`isAdmin`。
2. 对照 `references/known-junk-locations.md` 分级：`known[]` 按 `id` 查表得 🟢/🟡 及清理后果（`running=true` 注明先关闭的进程）；`deep[]`/`tree[]`/`rootFiles[]` 按该文件"路径模式规则"判定；个人文件只进目录级汇总；拿不准的归"需人工判断"。
3. 报告写到**当前工作目录**，文件名 `junk-scan-report-<yyyyMMdd-HHmmss>.md`：
   ```markdown
   # 垃圾文件扫描报告 <时间>
   > 盘符 | 管理员权限 | 耗时 | 完整/截断
   ## 🟢 可直接清理（合计）
   | 大小 | 位置 | 说明 |（running=true 注明先关闭的进程）
   ## 🟡 清理有代价（合计，自行决定）
   | 大小 | 位置 | 代价与注意事项 |
   ## 个人文件目录级汇总
   ## 需人工判断（不建议直接删）
   ## 扫描说明（非管理员低估、截断、跳过项）
   ```
   表格只写路径和大小，不写任何删除命令。
4. 聊天摘要：TOP 占用 → 🟢 合计 → 🟡 合计 → 报告路径。
5. `truncated=true` 说明未扫完可加大 `-MaxSeconds` 重跑（问用户）；`isAdmin=false` 说明部系统目录低估，是否管理员重跑由用户决定。

## 执行阶段（仅在用户明确"清理"后）

1. 按范围规则从本对话的报告/扫描 JSON 生成 manifest：UTF-8 文本 `%TEMP%\junk-clean-manifest.txt`，每行一个目标，`#` 开头为注释。
   - `known` 项：直接照抄 JSON 中该 id 的 `path` 字段（含 `%VAR%` 与通配符，脚本会展开）。
   - `deep`/`tree` 项：抄 JSON 中的具体路径。
   - 执行前逐行对照报告核对范围：只含本次指令覆盖的目标。
2. 执行：
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File "<skill目录>\scripts\clean.ps1" -Manifest "%TEMP%\junk-clean-manifest.txt"
   ```
3. 读 `%TEMP%\junk-clean-result.txt`，汇报：逐项 `freedMB/删除数/失败/跳过/拒绝原因` + TOTAL + 各盘可用空间 before/after。
4. `REFUSED`（路径被安全校验拒绝）如实说明并指明替代途径（如应用内清理）；`failed`（占用/ACL）视为正常跳过，提示可关闭相应应用后重试该单项目；不擅自扩大范围重跑。
5. 把执行结果追加为该报告文件的 `## 执行记录` 一节（逐项结果 + 磁盘前后对比）。

## 成功标准

1. 扫描请求 → 零删除，报告含 🟢/🟡/个人汇总/需人工判断/扫描说明五部分。
2. 无报告时的"清理" → 先扫描并请审查，未执行任何删除。
3. 有报告后"清理" → 仅 manifest 内目标被清；未点名的 🟡、个人文件、系统目录、虚拟磁盘零触碰。
4. 执行后有逐项 freed/失败/拒绝明细与磁盘前后差值；部分占用失败属正常。
5. 全程无散装删除命令；每笔删除都能追溯到 clean.ps1 结果文件。
