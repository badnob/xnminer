# How to get started

**XenBlocks Miner by Tony.x1** — Windows GPU miner for [XenBlocks](https://xenblocks.io).

---

## What you need

1. **Windows** PC  
2. **Python 3.10+** from [python.org](https://www.python.org/downloads/)  
   - Tick **“Add Python to PATH”** during install  
3. **NVIDIA GPU + drivers** from [NVIDIA](https://www.nvidia.com/Download/index.aspx)  
   - Game Ready or Studio is fine  
   - This miner does **not** ship NVIDIA drivers  
4. An **EVM wallet** address (`0x` + 40 hex characters) for rewards  

No NVIDIA GPU? You can mine on **CPU** (much slower) — set `backend = cpu` in `miner.ini` after the first run.

---

## Setup (once)

1. Download or clone this repo.  
2. Double-click **`Start-Miner.bat`**.

That’s it. The launcher will:

- create `miner.ini` if needed  
- install Python packages from `requirements.txt`  
- ask for your **EVM wallet** once, then save it  
- create a **unique miner name** (e.g. `xnminer-a1b2c3d4`) so Woodyminer / XenBlockScan stats do not clash with other users  

You do **not** need to edit config files to start mining. Optional: set your own name later in `miner.ini` (`worker` / `woodyminer_custom_name`).

---

## Run

Double-click:

```text
Start-Miner.bat
```

- First run → enter wallet → mining starts  
- Live dashboard in the console  
- **Ctrl+C** stops mining and flushes any queued blocks  

---

## Check it’s working

| Check | Where |
|--------|--------|
| Hashrate | Dashboard speed / H/s |
| Accepts | Accepted / local accepts |
| Network | Dashboard network status |
| Logs | `data\session.log` |
| Away from PC | [woodyminer.com](https://woodyminer.com) (enabled by default) |

---

## Common issues

| Problem | Fix |
|---------|-----|
| “Python not found” | Reinstall Python with **Add to PATH**, then reopen the window |
| CUDA / DLL errors | Install latest NVIDIA driver; restart PC |
| No GPU | After first run, set `backend = cpu` in `miner.ini` |
| Another miner running | Close the other window, or delete `data\miner.lock` if stale |
| Wrong wallet | Edit `miner.ini` → `[account] address = 0x...` |

---

## Safety

- VRAM limits scale with **your** GPU size (desktop headroom kept free).  
- Temp guard cools the card if it runs hot.  
- Run **only one** copy of this miner per machine.

---

## More detail

See **`README.md`** for features, advanced config, and project layout.

Happy mining.
