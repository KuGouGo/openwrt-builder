# Mac → VPS 迁移清单

这份文档用于把当前 OpenClaw 环境从 Mac 迁移到 VPS。

## 迁移目标

保留以下内容：

- OpenClaw workspace
- 当前规则仓库与脚本
- 记忆文件与身份文件
- 后续在 VPS 上继续运行 OpenClaw

---

## 一、建议迁移策略

推荐采用：

1. 在 VPS 上重新安装运行环境
2. 从 Mac 迁移 `~/.openclaw/workspace`
3. 在 VPS 上重新配置 Git / SSH / 机器人相关凭据
4. 用 `tmux` 或 `systemd` 保持常驻

这样比直接整目录硬搬更干净，也更适合长期维护。

---

## 二、Mac 端导出

### 1. 只导出 workspace（推荐）

```bash
tar czf openclaw-workspace.tar.gz -C ~/.openclaw workspace
```

导出后会得到：

- `openclaw-workspace.tar.gz`

### 2. 如果需要整目录备份（可选）

```bash
tar czf openclaw-full-backup.tar.gz ~/.openclaw
```

> 不推荐直接整目录原样恢复到 VPS，除非你明确知道里面的状态文件也需要保留。

---

## 三、传输到 VPS

假设你的 VPS 用户名是 `user`，IP 是 `1.2.3.4`：

```bash
scp openclaw-workspace.tar.gz user@1.2.3.4:/home/user/
```

如果是整目录备份：

```bash
scp openclaw-full-backup.tar.gz user@1.2.3.4:/home/user/
```

---

## 四、VPS 上准备环境

以 Ubuntu / Debian 为例：

```bash
sudo apt update
sudo apt install -y git curl zsh tar gzip python3
```

安装 Node.js（按你习惯的方法即可，例如 nvm 或官方源）。

确认基础命令可用：

```bash
node -v
npm -v
git --version
python3 --version
```

---

## 五、VPS 上恢复 workspace

### 1. 创建目录

```bash
mkdir -p ~/.openclaw
```

### 2. 解压 workspace

```bash
tar xzf openclaw-workspace.tar.gz -C ~/.openclaw
```

恢复后应看到：

- `~/.openclaw/workspace`

### 3. 检查关键文件

```bash
ls ~/.openclaw/workspace
```

重点确认这些还在：

- `AGENTS.md`
- `SOUL.md`
- `USER.md`
- `IDENTITY.md`
- `MEMORY.md`
- `memory/`

---

## 六、Git / GitHub 推送能力

如果你希望 VPS 上也能推 GitHub，推荐单独配置一把 SSH key。

### 1. 生成 SSH key

```bash
ssh-keygen -t ed25519 -C "openclaw-vps"
```

### 2. 查看公钥

```bash
cat ~/.ssh/id_ed25519.pub
```

把输出内容添加到 GitHub：

- 账号 SSH Keys
或
- 仓库 Deploy Key

### 3. 测试连接

```bash
ssh -T git@github.com
```

### 4. 检查仓库 remote

```bash
git -C ~/.openclaw/workspace/Rules remote -v
```

如果你想用 SSH 推送，建议 remote 改成：

```bash
git -C ~/.openclaw/workspace/Rules remote set-url origin git@github.com:KuGouGo/Rules.git
```

---

## 七、OpenClaw 运行建议

### 方案 A：先用 tmux（推荐试运行）

安装：

```bash
sudo apt install -y tmux
```

启动：

```bash
tmux new -s openclaw
```

在 tmux 里运行 OpenClaw。

分离会话：

- `Ctrl+b` 然后按 `d`

恢复会话：

```bash
tmux attach -t openclaw
```

### 方案 B：后续再做 systemd

适合你确定 VPS 上要长期常驻后再配。

---

## 八、迁移后建议检查

### 1. 工作区是否完整

```bash
ls ~/.openclaw/workspace
```

### 2. 仓库是否正常

```bash
git -C ~/.openclaw/workspace/Rules status
```

### 3. 能否拉取 / 推送

```bash
git -C ~/.openclaw/workspace/Rules fetch origin
```

### 4. 关键脚本能否执行

```bash
cd ~/.openclaw/workspace/Rules
chmod +x scripts/*.sh
./scripts/lint-custom-rules.sh
```

---

## 九、建议不要直接生搬的内容

以下内容建议在 VPS 上重新配置，而不是直接照搬：

- GitHub 登录态
- SSH 私钥（如非必要）
- 本机 App 缓存
- Mac 专属路径相关配置
- 依赖 GUI 的本地工具

---

## 十、推荐迁移顺序

1. VPS 安装基础环境
2. 迁移 `workspace`
3. 配置 Git / SSH
4. 跑通仓库脚本
5. 启动 OpenClaw
6. 再决定是否做 systemd 常驻

---

## 十一、最小命令清单

### Mac

```bash
tar czf openclaw-workspace.tar.gz -C ~/.openclaw workspace
scp openclaw-workspace.tar.gz user@1.2.3.4:/home/user/
```

### VPS

```bash
sudo apt update
sudo apt install -y git curl zsh tar gzip python3 tmux
mkdir -p ~/.openclaw
tar xzf openclaw-workspace.tar.gz -C ~/.openclaw
ssh-keygen -t ed25519 -C "openclaw-vps"
tmux new -s openclaw
```

---

如果后面需要，可以再单独补：

- `systemd` 常驻模板
- GitHub CLI 配置
- OpenClaw 在 VPS 上的长期运行方案
