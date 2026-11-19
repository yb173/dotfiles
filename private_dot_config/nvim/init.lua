-- Neovim の設定。~/.vimrc から使っている設定だけを移した
-- Neovim で最初からそうなっている設定（autoindent・incsearch・hidden・smarttab・laststatus=2 など）は書かない

-- ○ や □ のように幅が決まっていない文字（ambiwidth）は、既定の 1 文字分のまま。
-- Ghostty はこれらを 1 文字分で出す（変える設定もない）ので、2 文字分（double）にするとカーソルや表示がずれる

-- タブの代わりに空白を入れる。幅は 4
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4

-- 行番号を表示する
vim.o.number = true
-- 閉じ括弧を入力したとき、対応する括弧を強調する
vim.o.showmatch = true
-- ヤンクと貼り付けに macOS のクリップボードを使う
vim.o.clipboard = 'unnamed'

local map = vim.keymap.set

-- ; と : を入れ替える
map('n', ';', ':')
map('n', ':', ';')
-- 折り返した行の中を上下に動く（j・k と gj・gk を入れ替える）
map('n', 'j', 'gj')
map('n', 'k', 'gk')
map('n', 'gj', 'j')
map('n', 'gk', 'k')
-- H・L で行の先頭・末尾へ、J・K で次・前の段落へ
map('', 'H', '^')
map('', 'L', '$')
map('', 'J', '}')
map('', 'K', '{')
-- jj・っj（日本語入力のまま）・Ctrl-J で挿入モードを抜ける
map('i', 'jj', '<Esc>')
map('i', 'っj', '<Esc>')
map('i', '<C-j>', '<Esc>')
-- Ctrl-J でコマンドラインも抜ける（打ちかけのコマンドを取り消す）。
-- マッピングから送った <Esc> は、コマンドラインでは取り消さずに実行してしまうので、<C-c> を送る
map('c', '<C-j>', '<C-c>')
-- Esc を 2 回押して、検索の強調を消す
map('n', '<Esc><Esc>', '<Cmd>nohlsearch<CR>')

-- 配色。組み込みのプラグインマネージャー（vim.pack）で入れる
-- 入れた版は nvim-pack-lock.json に書かれる。更新したら chezmoi re-add でリポジトリに戻す
vim.pack.add({ 'https://github.com/cocopon/iceberg.vim' })
vim.cmd.colorscheme('iceberg')
