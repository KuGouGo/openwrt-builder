# OpenClaw systemd 常驻模板

这份文档用于在 VPS 上把 OpenClaw 配成 systemd 服务，实现开机自启和后台常驻。

## 一、前提

假设：

- 用户名：`user`
- OpenClaw 已安装
- workspace 位于：`/home/user/.openclaw/workspace`
- OpenClaw 可执行命令已在 PATH 中

如果 `openclaw` 不在 PATH，请先用下面命令确认：

```bash
which openclaw
```

例如返回：

```bash
/usr/bin/openclaw
```

---

## 二、创建 systemd 服务文件

创建：

```bash
sudo nano /etc/systemd/system/openclaw.service
```

写入以下内容：

```ini
[Unit]
Description=OpenClaw Agent Service
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=user
WorkingDirectory=/home/user/.openclaw/workspace
ExecStart=/usr/bin/openclaw
Restart=always
RestartSec=5
Environment=HOME=/home/user
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
```

> 注意把 `User=`、`WorkingDirectory=`、`ExecStart=` 改成你 VPS 上的真实路径。

---

## 三、启用服务

```bash
sudo systemctl daemon-reload
sudo systemctl enable openclaw
sudo systemctl start openclaw
```

查看状态：

```bash
systemctl status openclaw
```

---

## 四、常用命令

### 启动

```bash
sudo systemctl start openclaw
```

### 停止

```bash
sudo systemctl stop openclaw
```

### 重启

```bash
sudo systemctl restart openclaw
```

### 查看状态

```bash
systemctl status openclaw
```

### 查看日志

```bash
journalctl -u openclaw -f
```

---

## 五、如果 openclaw 需要完整命令

如果你的启动方式不是单纯 `openclaw`，而是类似：

```bash
openclaw gateway start
```

那就把 `ExecStart=` 改成真实命令，例如：

```ini
ExecStart=/usr/bin/openclaw gateway start
```

如果不确定可执行方式，先在 VPS 上手动跑通，再写入 systemd。

---

## 六、排错建议

### 1. 服务起不来

先看：

```bash
systemctl status openclaw
journalctl -u openclaw -n 100 --no-pager
```

### 2. 命令找不到

检查：

```bash
which openclaw
```

把真实路径写到 `ExecStart=`。

### 3. 工作目录不对

确认：

```bash
ls /home/user/.openclaw/workspace
```

### 4. 权限问题

确认服务使用的用户和文件归属一致：

```bash
ls -ld /home/user/.openclaw
ls -ld /home/user/.openclaw/workspace
```

---

## 七、建议

第一次迁移到 VPS 时：

- 先用 `tmux` 跑通
- 再改成 `systemd`

因为这样更容易排错。
