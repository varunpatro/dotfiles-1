(when (>= emacs-major-version 24)
  (require 'package)
  (add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
  (add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
  (package-initialize))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-and-compile
  (defvar use-package-verbose t) 
  (require 'cl)
  (require 'use-package)
  (require 'bind-key)
  (require 'diminish)
  (setq use-package-always-ensure t))

(use-package validate
  :demand t)

(setq user-full-name "Jethro Kuan"
      user-mail-address "jethrokuan95@gmail.com")

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "chromium")

(add-to-list 'default-frame-alist
             '(font . "Hack-12"))

(tooltip-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)

(setq initial-buffer-choice "~/.org/gtd/next_actions.org")

(defalias 'yes-or-no-p 'y-or-n-p)

(delete-selection-mode +1)

(setq sentence-end-double-space nil)

(setq-default tab-width 2)
(setq-default js-indent-level 2)
(setq-default indent-tabs-mode nil)

(setq-default truncate-lines t)
(defun trunc-lines-hook ()
  (setq truncate-lines nil))

(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

(message "Deleting old backup files...")
(let ((week (* 60 60 24 7))
      (current (float-time (current-time))))
  (dolist (file (directory-files temporary-file-directory t))
    (when (and (backup-file-name-p file)
               (> (- current (float-time (fifth (file-attributes file))))
                  week))
      (message "%s" file)
      (delete-file file))))

(load "~/.emacs.d/secrets.el" t)

(use-package exec-path-from-shell
  :demand t
  :init (exec-path-from-shell-initialize))

(setq-default explicit-shell-file-name "/bin/bash")

(use-package doom-themes
  :init
  (load-theme 'doom-one t)
  :config
  (add-hook 'find-file-hook 'doom-buffer-mode)
  (add-hook 'minibuffer-setup-hook 'doom-brighten-minibuffer)
  (require 'doom-neotree))

(defun open-next-line (arg)
  "Move to the next line and then opens a line.
   See also `newline-and-indent'."
  (interactive "p")
  (end-of-line)
  (open-line arg)
  (next-line 1)
  (when 'newline-and-indent
    (indent-according-to-mode)))

(defun open-previous-line (arg)
  "Open a new line before the current one. 
     See also `newline-and-indent'."
  (interactive "p")
  (beginning-of-line)
  (open-line arg)
  (when 'newline-and-indent
    (indent-according-to-mode)))

(bind-key* "C-o" 'open-next-line)
(bind-key* "M-o" 'open-previous-line)

(defun jethro/nuke-all-buffers ()
  (interactive)
  (mapcar 'kill-buffer (buffer-list))
  (delete-other-windows))

(bind-key* "C-c !" 'jethro/nuke-all-buffers)

(bind-key* "C-x m" 'eshell)

(bind-key* "M-p" 'mark-paragraph)

(bind-key* "<f5>" (lambda ()
                    (interactive)
                    (setq-local compilation-read-command nil)
                    (call-interactively 'compile)))

(use-package hydra)

(use-package flx)

(use-package counsel
  :demand t
  :bind*
  (("C-c C-r" . ivy-resume)
   ("M-a" . counsel-M-x)
   ("C-M-i" . counsel-imenu)
   ("C-x C-f" . counsel-find-file)
   ("C-c d" . counsel-dired-jump)
   ("C-c j" . counsel-git-grep)
   ("C-c k" . counsel-ag)
   ("C-c l" . counsel-locate)
   ("M-y" . counsel-yank-pop))
  :bind (:map help-map
              ("f" . counsel-describe-function)
              ("v" . counsel-describe-variable)
              ("l" . counsel-info-lookup-symbol))
  :config
  (ivy-mode 1)
  (setq counsel-find-file-at-point t)
  (setq ivy-use-virtual-buffers t)
  (setq ivy-display-style 'fancy)
  (setq ivy-initial-inputs-alist nil)
  (define-key ivy-minibuffer-map (kbd "<return>") 'ivy-alt-done))

(use-package swiper
  :bind*
  (("C-s" . swiper)
   ("C-r" . swiper)
   ("C-M-s" . swiper-all))
  :bind
  (:map read-expression-map
        ("C-r" . counsel-expression-history)))

(setq ivy-re-builders-alist
      '((ivy-switch-buffer . ivy--regex-plus)
        (swiper . ivy--regex-plus)
        (t . ivy--regex-fuzzy)))

(define-key ivy-minibuffer-map (kbd "C-:") 'ivy-dired)
(define-key ivy-minibuffer-map (kbd "C-c o") 'ivy-occur)
(define-key read-expression-map (kbd "C-r") 'counsel-expression-history)
(ivy-set-actions
 t
 '(("I" insert "insert")))

(defun ivy-dired ()
  (interactive)
  (if ivy--directory
      (ivy-quit-and-run
       (dired ivy--directory)
       (when (re-search-forward
              (regexp-quote
               (substring ivy--current 0 -1)) nil t)
         (goto-char (match-beginning 0))))
    (user-error
     "Not completing files currently")))

(define-key ivy-minibuffer-map (kbd "C-:") 'ivy-dired)

(use-package crux
  :commands (crux-switch-to-previous-buffer)
  :bind* (("C-c o" . crux-open-with)
          ("C-c n" . crux-cleanup-buffer-or-region)
          ("C-c D" . crux-delete-file-and-buffer)
          ("C-a" . crux-move-beginning-of-line)
          ("M-o" . crux-smart-open-line)
          ("C-c r" . crux-rename-file-and-buffer)
          ("C-c d" . crux-duplicate-current-line-or-region)
          ("C-c M-d" . crux-duplicate-and-comment-current-line-or-region)
          ("s-o" . crux-smart-open-line-above)))

(use-package avy
  :bind* (("C-'" . avy-goto-char)
          ("C-," . avy-goto-char-2))
  :config
  (setq avy-keys '(?h ?t ?n ?s)))

(use-package dumb-jump
  :diminish dumb-jump-mode
  :bind (("C-M-g" . dumb-jump-go)
         ("C-M-p" . dumb-jump-back)
         ("C-M-q" . dumb-jump-quick-look)))

(bind-key* "M-'" 'other-window)

(defun jethro/dired-mode-setup-hook ()
  "hook for dired-mode"
  (dired-hide-details-mode 1))

(add-hook 'dired-mode-hook 'jethro/dired-mode-setup-hook)

(setq dired-listing-switches "-aBhl  --group-directories-first")

(setq dired-recursive-copies (quote always))
(setq dired-recursive-deletes (quote top))

(require 'dired-x)

(save-place-mode 1)

(use-package key-chord
  :config
  (key-chord-mode 1)
  (key-chord-define-global "mw" 'avy-goto-word-1)   
  (key-chord-define-global "jk" 'avy-goto-char)
  (key-chord-define-global "JJ" 'crux-switch-to-previous-buffer)
  (key-chord-define-global "FF" 'counsel-find-file)
  (key-chord-define-global "xx" 'execute-extended-command)
  (key-chord-define-global "yy" 'counsel-yank-pop)
  (key-chord-define-global ",." 'neotree-toggle))

(add-hook 'after-init-hook (lambda () (electric-pair-mode 1)))

(use-package electric-align
  :ensure f
  :load-path "elisp/"
  :diminish electric-align-mode
  :config (add-hook 'prog-mode-hook 'electric-align-mode))

(use-package aggressive-indent
  :diminish aggressive-indent-mode
  :config (add-hook 'prog-mode-hook 'aggressive-indent-mode))

(use-package multiple-cursors
  :bind (("C-M-c" . mc/edit-lines)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)))

(use-package expand-region
  :bind (("C-=" . er/expand-region)))

(use-package smartparens
  :bind (:map smartparens-mode-map
              ("C-M-a" . sp-beginning-of-sexp)
              ("C-M-e" . sp-end-of-sexp)

              ("C-<down>" . sp-down-sexp)
              ("C-<up>"   . sp-up-sexp)
              ("M-<down>" . sp-backward-down-sexp)
              ("M-<up>"   . sp-backward-up-sexp)

              ("C-M-f" . sp-forward-sexp)
              ("C-M-b" . sp-backward-sexp)

              ("C-M-n" . sp-next-sexp)
              ("C-M-p" . sp-previous-sexp)

              ("C-S-f" . sp-forward-symbol)
              ("C-S-b" . sp-backward-symbol)

              ("C-<right>" . sp-forward-slurp-sexp)
              ("M-<right>" . sp-forward-barf-sexp)
              ("C-<left>"  . sp-backward-slurp-sexp)
              ("M-<left>"  . sp-backward-barf-sexp)

              ("C-M-t" . sp-transpose-sexp)
              ("C-M-k" . sp-kill-sexp)
              ("C-k"   . sp-kill-hybrid-sexp)
              ("M-k"   . sp-backward-kill-sexp)
              ("C-M-w" . sp-copy-sexp)

              ("C-M-d" . delete-sexp)

              ("M-<backspace>" . backward-kill-word)
              ("C-<backspace>" . sp-backward-kill-word)
              ([remap sp-backward-kill-word] . backward-kill-word)

              ("M-[" . sp-backward-unwrap-sexp)
              ("M-]" . sp-unwrap-sexp)

              ("C-x C-t" . sp-transpose-hybrid-sexp)

              ("M-c ("  . wrap-with-parens)
              ("M-c ["  . wrap-with-brackets)
              ("M-c {"  . wrap-with-braces)
              ("M-c '"  . wrap-with-single-quotes)
              ("M-c \"" . wrap-with-double-quotes)
              ("M-c _"  . wrap-with-underscores)
              ("M-c `"  . wrap-with-back-quotes)) 
  :init
  (add-hook 'emacs-lisp-mode-hook 'turn-on-smartparens-mode)
  (add-hook 'clojure-mode-hook 'turn-on-smartparens-mode)
  :config
  (require 'smartparens-config)
  (defmacro def-pairs (pairs)
    `(progn
       ,@(loop for (key . val) in pairs
               collect
               `(defun ,(read (concat
                               "wrap-with-"
                               (prin1-to-string key)
                               "s"))
                    (&optional arg)
                  (interactive "p")
                  (sp-wrap-with-pair ,val)))))

  (def-pairs ((paren        . "(")
              (bracket      . "[")
              (brace        . "{")
              (single-quote . "'")
              (double-quote . "\"")
              (back-quote   . "`"))))

(autoload 'zap-up-to-char "misc"
  "Kill up to, but not including ARGth occurrence of CHAR.

  \(fn arg char)"
  'interactive)

(bind-key* "M-z" 'zap-up-to-char)

(use-package move-text
  :bind (("M-<up>" . move-text-up)
         ("M-<down>" . move-text-down)))

(use-package flycheck
  :config
  (global-set-key (kbd "C-c f")
                  (defhydra hydra-flycheck
                    (:pre (progn (setq hydra-lv t) (flycheck-list-errors))
                          :post (progn (setq hydra-lv nil) (quit-windows-on "*Flycheck errors*"))
                          :hint nil)
                    "Errors"
                    ("f"  flycheck-error-list-set-filter                            "Filter")
                    ("n"  flycheck-next-error                                       "Next")
                    ("p"  flycheck-previous-error                                   "Previous")
                    ("<" flycheck-first-error                                      "First")
                    (">"  (progn (goto-char (point-max)) (flycheck-previous-error)) "Last")
                    ("q"  nil)))
  (use-package flycheck-pos-tip
    :config (flycheck-pos-tip-mode))
  (add-hook 'prog-mode-hook 'global-flycheck-mode))

(use-package yasnippet
  :diminish yas-global-mode yas-minor-mode
  :init (add-hook 'after-init-hook 'yas-global-mode)
  :config (setq yas-snippet-dirs '("~/.emacs.d/snippets/")))

(use-package company
  :diminish company-mode
  :init (progn
          (add-hook 'after-init-hook 'global-company-mode)
          (setq company-dabbrev-ignore-case nil
                company-dabbrev-code-ignore-case nil
                company-dabbrev-downcase nil
                company-idle-delay 0
                company-begin-commands '(self-insert-command)
                company-transformers '(company-sort-by-occurrence))
          (use-package company-quickhelp
            :config (company-quickhelp-mode 1))))

(use-package flyspell
  :ensure f
  :diminish flyspell-mode
  :config
  (add-hook 'text-mode-hook 'flyspell-mode)
  (add-hook 'org-mode-hook 'flyspell-mode)
  (add-hook 'markdown-mode-hook 'flyspell-mode))

(bind-key "C-c C-k" 'eval-buffer)

(use-package go-mode
  :mode ("\\.go\\'" . go-mode)
  :config (progn
            (add-hook 'go-mode-hook 'compilation-auto-quit-window)
            (add-hook 'go-mode-hook (lambda ()
                                      (set (make-local-variable 'company-backends) '(company-go))
                                      (company-mode)))
            (add-hook 'go-mode-hook (lambda ()
                                      (add-hook 'before-save-hook 'gofmt-before-save)
                                      (local-set-key (kbd "M-.") 'godef-jump)))
            (add-hook 'go-mode-hook
                      (lambda ()
                        (unless (file-exists-p "Makefile")
                          (set (make-local-variable 'compile-command)
                               (let ((file (file-name-nondirectory buffer-file-name)))
                                 (format "go build %s"
                                         file))))))
            (use-package go-dlv
              :config (require 'go-dlv))
            (use-package golint
              :config
              (add-to-list 'load-path (concat (getenv "GOPATH")  "/src/github.com/golang/lint/misc/emacs"))
              (require 'golint))
            (use-package gorepl-mode
              :config (add-hook 'go-mode-hook #'gorepl-mode))
            (use-package company-go
              :config (add-hook 'go-mode-hook (lambda ()
                                                (set (make-local-variable 'company-backends) '(company-go))
                                                (company-mode))))))

(add-hook 'c++-mode-hook
          (lambda ()
            (unless (file-exists-p "Makefile")
              (set (make-local-variable 'compile-command)
                   (let ((file (file-name-nondirectory buffer-file-name)))
                     (format "g++ -Wall -s -pedantic-errors %s -o %s --std=c++14"
                             file
                             (file-name-sans-extension file)))))))

(use-package fish-mode
  :mode ("\\.fish\\'" . fish-mode))

(use-package rust-mode
  :mode ("\\.rs\\'" . rust-mode))

(use-package elpy
  :mode ("\\.py\\'" . elpy-mode)
  :init
  (add-hook 'python-mode-hook (lambda () (aggressive-indent-mode -1)))
  :config
  (when (require 'flycheck nil t)
    (remove-hook 'elpy-modules 'elpy-module-flymake)
    (remove-hook 'elpy-modules 'elpy-module-yasnippet)
    (remove-hook 'elpy-mode-hook 'elpy-module-highlight-indentation)
    (add-hook 'elpy-mode-hook 'flycheck-mode))
  (elpy-enable)
  (setq elpy-rpc-backend "jedi"))

(use-package web-mode
  :mode (("\\.html\\'" . web-mode)
         ("\\.html\\.erb\\'" . web-mode)
         ("\\.mustache\\'" . web-mode)
         ("\\.jinja\\'" . web-mode)
         ("\\.php\\'" . web-mode))
  :config
  (setq web-mode-enable-css-colorization t)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-markup-indent-offset 2))

(use-package emmet-mode
  :diminish emmet-mode
  :config
  (add-hook 'web-mode-hook 'emmet-mode)
  (add-hook 'vue-mode-hook 'emmet-mode))

(use-package rainbow-mode
  :diminish rainbow-mode
  :config
  (add-hook 'css-mode-hook 'rainbow-mode)
  (add-hook 'scss-mode-hook 'rainbow-mode))

(use-package scss-mode
  :mode "\\.scss\\'" 
  :config (progn
            (setq scss-compile-at-save nil)))

(flycheck-add-mode 'javascript-eslint 'js2-mode)

(use-package js-comint
  :config
  (add-hook 'js2-mode-hook
            (lambda ()
              (local-set-key (kbd "C-x C-e") 'js-send-last-sexp)
              (local-set-key (kbd "C-M-x") 'js-send-last-sexp-and-go)
              (local-set-key (kbd "C-c b") 'js-send-buffer)
              (local-set-key (kbd "C-c C-b") 'js-send-buffer-and-go)
              (local-set-key (kbd "C-c l") 'js-load-file-and-go))))

(use-package js2-mode
  :mode ("\\.js\\'" . js2-mode)
  :config
  (use-package tern
    :diminish tern-mode
    :config    
    (add-hook 'js2-mode-hook 'tern-mode)
    (use-package company-tern
      :config
      (add-to-list 'company-backends 'company-tern))))

(use-package js2-refactor
  :config
  (add-hook 'js2-mode-hook #'js2-refactor-mode)
  (js2r-add-keybindings-with-prefix "C-c C-j"))

(use-package jade)

(use-package vue-mode
  :mode "\\.vue\\'")

(use-package json-mode
  :mode "\\.json\\'"
  :config (add-hook 'json-mode-hook (lambda ()
                                      (make-local-variable 'js-indent-level)
                                      (setq js-indent-level 2))))

(use-package markdown-mode
  :mode ("\\.md\\'" . markdown-mode)
  :config (progn
            (setq markdown-command "multimarkdown")
            (add-hook 'markdown-mode-hook #'trunc-lines-hook)))

(use-package clojure-mode
  :mode (("\\.clj\\'" . clojure-mode)
         ("\\.boot\\'" . clojure-mode)
         ("\\.edn\\'" . clojure-mode)
         ("\\.cljs\\'" . clojurescript-mode)
         ("\\.cljs\\.hl\\'" . clojurescript-mode))
  :init
  (add-hook 'clojure-mode-hook #'eldoc-mode)
  (add-hook 'clojure-mode-hook #'subword-mode)
  (add-hook 'clojure-mode-hook #'cider-mode)
  (add-hook 'clojure-mode-hook #'clj-refactor-mode))

(use-package cider
  :init
  (add-hook 'cider-mode-hook #'clj-refactor-mode)
  (add-hook 'cider-repl-mode-hook #'company-mode)
  (add-hook 'cider-mode-hook #'company-mode)
  :diminish subword-mode
  :config
  (setq nrepl-log-messages t                  
        cider-repl-display-in-current-window t
        cider-repl-use-clojure-font-lock t    
        cider-prompt-save-file-on-load 'always-save
        cider-font-lock-dynamically '(macro core function var)
        nrepl-hide-special-buffers t
        cider-show-error-buffer nil
        cider-overlays-use-font-lock t
        cider-repl-result-prefix ";; => ")
  (setq cider-cljs-lein-repl "(do (use 'figwheel-sidecar.repl-api) (start-figwheel!) (cljs-repl))")
  (cider-repl-toggle-pretty-printing))

(use-package clj-refactor
  :defines cljr-add-keybindings-with-prefix
  :diminish clj-refactor-mode
  :config (cljr-add-keybindings-with-prefix "C-c C-j"))

(use-package flycheck-clojure
  :config
  (flycheck-clojure-setup))

(global-hl-line-mode 1)

(require 'whitespace)
(setq whitespace-line-column 80) ;; limit line length
(setq whitespace-style '(face lines-tail))

(add-hook 'prog-mode-hook 'whitespace-mode)

(use-package page-break-lines)

(use-package smart-mode-line
  :config
  (setq sml/theme 'light)
  (add-hook 'after-init-hook 'sml/setup)
  (setq sml/name-width 30)
  (setq sml/shorten-directory t)
  (setq sml/shorten-modes t)
  (setq sml/mode-width 'full)
  (setq sml/replacer-regexp-list
        '(("^~/.org/" ":O:")
          ("^~/\\.emacs\\.d/" ":ED")))
  (setq rm-blacklist
        (format "^ \\(%s\\)$"
                (mapconcat #'identity
                           '("FlyC.*"
                             "Projectile.*"
                             "GitGutter"
                             "ivy"
                             "company"
                             ""
                             "doom"
                             ","
                             "ElDoc")
                           "\\|"))))

(setq display-time-24hr-format t)
(display-time-mode 1)

(use-package nyan-mode
  :config
  (nyan-mode 1))

(defhydra hydra-zoom (global-map "<f2>")
  "zoom"
  ("i" text-scale-increase "in")
  ("o" text-scale-decrease "out"))

(use-package beacon
  :diminish beacon-mode
  :config
  (beacon-mode 1)
  (setq beacon-push-mark 10))

(show-paren-mode 1)
(setq show-paren-delay 0)

(use-package golden-ratio
  :diminish golden-ratio-mode
  :config (progn
            (add-to-list 'golden-ratio-extra-commands 'ace-window)
            (golden-ratio-mode 1)))

(use-package volatile-highlights
  :diminish volatile-highlights-mode
  :config (volatile-highlights-mode t))

(use-package git-gutter-fringe+
  :config
  (global-git-gutter+-mode)
  (set-face-foreground 'git-gutter+-modified "gold1")
  (set-face-foreground 'git-gutter+-added    "SeaGreen")
  (set-face-foreground 'git-gutter+-deleted  "IndianRed")
  (setq git-gutter-fr+-side 'left-fringe))

(use-package htmlize
  :config
  (require 'htmlize))

(use-package org
  :bind (("C-c c" . org-capture)
         ("C-c a" . org-agenda)
         ("C-c l" . org-store-link))
  :mode ("\\.org\\'" . org-mode)
  :init
  (add-hook 'org-mode-hook #'trunc-lines-hook)
  (setq org-ellipsis "…")
  (setq org-directory "~/.org")
  (setq org-default-notes-directory (concat org-directory "/notes.org"))   
  (setq org-hide-emphasis-markers t)
  (setq org-src-tab-acts-natively t)
  (font-lock-add-keywords 'org-mode
                  '(("^ +\\([-*]\\) "
                     (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•")))))) 
  (setq org-refile-targets
                 '((nil :maxlevel . 3)
                   (org-agenda-files :maxlevel . 3)))
  (setq org-use-fast-todo-selection t)
  (setq org-treat-S-cursor-todo-selection-as-state-change nil)
  (setq org-capture-templates
                 '(("b" "Book" entry (file "~/.org/books.org")
                    "* TO-READ %(org-set-tags)%? %i\n"))))

(defvar jethro/org-agenda-files
  (append
   ;;(file-expand-wildcards "~/.org/*.org")
   (file-expand-wildcards "~/.org/calendars/*.org")
   (file-expand-wildcards "~/.org/gtd/*.org"))
  "Files to include in org-agenda-files")

(setq org-agenda-files jethro/org-agenda-files)

(setq org-agenda-custom-commands 
      '(("w" todo "WAITING" nil) 
        ("n" todo "NEXT" nil)
        ("d" "Agenda + Next Actions" ((agenda) (todo "NEXT"))))
      )

(setq org-agenda-dim-blocked-tasks t)

(setq org-icalendar-combined-agenda-file (concat org-directory "/org.ics"))
(setq org-icalendar-include-todo '(all))
(setq org-icalendar-use-scheduled '(event-if-todo event-if-not-todo))
(setq org-icalendar-use-deadline '(event-if-todo event-if-not-todo))
(setq org-agenda-default-appointment-duration 60)

;; this hook saves an ics file once an org-buffer is saved
(defun jethro/org-ical-export()
  (org-icalendar-combine-agenda-files))

(setq jethro/emacsd-site-dir "~/Documents/Code/emacsd_site/")

(setq org-publish-project-alist
      '(("books"
         ;; Path to your org files.
         :publishing-function org-html-publish-to-html
         :publishing-directory "~/Documents/Code/books/"
         :base-directory "~/.org/"
         :exclude ".*"
         :include ["books.org"]
         :with-emphasize t
         :with-todo-keywords t
         :with-toc nil
         :html-preamble t)
        ("emacs.d"
         :publishing-function org-html-publish-to-html
         :publishing-directory "~/Documents/Code/emacsd_site/"
         :base-directory "~/.emacs.d/"
         :exclude ".*"
         :include ["init.org"]
         :completion-function (lambda () (let ((htmlfile (concat jethro/emacsd-site-dir
                                                                 "init.html")))
                                           (if (file-exists-p htmlfile)
                                               (progn
                                                 (rename-file htmlfile
                                                              (concat jethro/emacsd-site-dir
                                                                      "index.html") t)
                                                 (shell-command (concat "cd " jethro/emacsd-site-dir " && git add -A && git commit -m 'New Changes: $(date)' && git push origin master"))))))
         :with-emphasize t
         :with-title nil
         :with-toc t
         :html-head "<link rel=\"stylesheet\" href=\"/css/emacsd.css\" type=\"text/css\">"
         :html-preamble t)))

(use-package ox-reveal
  :config
  (require 'ox-reveal))

(setq org-latex-pdf-process
      '("xelatex -shell-escape -interaction nonstopmode %f"
        "xelatex -shell-escape -interaction nonstopmode %f"))
(require 'ox-latex)
(setq org-latex-tables-booktabs t)
(setq org-latex-listings 'minted)
(setq org-format-latex-options (plist-put org-format-latex-options :scale 2.0))
(setq org-latex-minted-options
      '(("frame" "lines")
        ("linenos")
        ("numbersep" "5pt")
        ("framesep" "2mm")
        ("fontfamily" "tt")))
(add-to-list 'org-latex-classes
             '("book"
               "\\documentclass[10pt]{memoir}
                      \\usepackage{charter}
                      \\usepackage[T1]{fontenc}
                      \\usepackage{booktabs}
                      \\usepackage{amsmath}
                      \\usepackage{minted}
                      \\usemintedstyle{borland}
                      \\usepackage{color}
                      \\usepackage{epigraph}
                      \\usepackage{enumitem}
                      \\setlist{nosep}
                      \\setlength\\epigraphwidth{13cm}
                      \\setlength\\epigraphrule{0pt}
                      \\usepackage{fontspec}
                      \\usepackage{graphicx}
                      \\usepackage{hyperref}
                      \\hypersetup {colorlinks = true, allcolors = red}
                      \\title{}
                      [NO-DEFAULT-PACKAGES]
                      [NO-PACKAGES]"
               ("\\chapter{%s}" . "\\chapter*{%s}")
               ("\\section{%s}" . "\\section*{%s}")
               ("\\subsection{%s}" . "\\subsection*{%s}")
               ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
               ("\\paragraph{%s}" . "\\paragraph*{%s}")
               ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))
(add-to-list 'org-latex-classes
             '("notes"
               "\\documentclass[10pt,oneside]{amsbook}
                      \\usepackage{charter}                       
                      \\usepackage{booktabs}
                      \\usepackage{amsmath}
                      \\usepackage{minted}
                      \\usemintedstyle{borland}
                      \\usepackage{color}
                      \\usepackage{enumitem}
                      \\setlist{nosep}
                      \\usepackage{graphicx}
                      \\usepackage[a4paper,left=3cm,right=2cm,top=2.5cm,bottom=2.5cm]{geometry}
                      \\usepackage{hyperref}
                      \\hypersetup {colorlinks = true, allcolors = red}
                      \\title{}
                      [NO-DEFAULT-PACKAGES]
                      [NO-PACKAGES]"
               ("\\chapter{%s}" . "\\chapter*{%s}")
               ("\\section{%s}" . "\\section*{%s}")
               ("\\subsection{%s}" . "\\subsection*{%s}")
               ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
               ("\\paragraph{%s}" . "\\paragraph*{%s}")
               ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))

(use-package org-pomodoro
  :bind ("C-c C-x C-i" . org-pomodoro))

(use-package org-download
  :config
  (setq-default org-download-image-dir "./pictures")
  (setq-default org-download-heading-lvl nil)
  (require 'org-download))

(defun jethro/org-sort-books ()
    (interactive)
    (let ((old-point (point)))
      (beginning-of-buffer)
      (org-sort-entries t ?a)
      (beginning-of-buffer)
      (org-sort-entries t ?o)
      (show-all)
      (org-global-cycle)
      (goto-char old-point)))

(defun jethro/org-after-save-books ()
  (org-publish "books"))

(defun jethro/org-after-save-init ()
  (org-babel-tangle))

(use-package gtd-mode
  :bind (("C-c x" . gtd-clear-inbox)
         ("C-c i". gtd-into-inbox))
  :ensure f
  :load-path "elisp/"
  :config
  (gtd-mode 1))

(use-package epresent
  :bind ("<f5>"))

(use-package smerge-mode
  :functions smerge-next smerge-prev smerge-keep-all smerge-keep-mine smerge-keep-other
  :config
  (progn
    (global-set-key (kbd "C-c s")
                    (defhydra hydra-smerge (:body-pre (smerge-mode 1) :color red)
                      "Smerge mode"
                      ("<down>" smerge-next        "Next conflict")
                      ("<up>"   smerge-prev        "Previous conflict")
                      ("M-a"    smerge-keep-all    "Keep all")
                      ("M-m"    smerge-keep-mine   "Keep mine")
                      ("M-o"    smerge-keep-other  "Keep other")))))

(use-package magit  
  :bind (("s-g" . magit-status)
         ("s-G" . magit-blame))
  :init (setq magit-auto-revert-mode nil)
  :config
  ;; (use-package magithub)
  (add-hook 'magit-mode-hook 'hl-line-mode))

(use-package projectile
  :demand t
  :init (projectile-global-mode 1)
  :bind-keymap* ("C-x p" . projectile-command-map)
  :config
  (require 'projectile)
  (use-package counsel-projectile 
    :bind (("s-f" . counsel-projectile-find-file)
           ("s-b" . counsel-projectile-switch-to-buffer)))
  (setq projectile-use-git-grep t)
  (setq projectile-create-missing-test-files t)
  (setq projectile-completion-system 'ivy))

(use-package esup
  :defer t)

(use-package keyfreq
  :config
  (keyfreq-mode 1)
  (keyfreq-autosave-mode 1))

(use-package pivotal-tracker
  :config
  (setq pivotal-api-token jethro/pivotal-api-token))

(use-package which-key
  :diminish which-key-mode
  :config (add-hook 'after-init-hook 'which-key-mode))

(use-package nameless
  :diminish nameless-mode
  :config
  (add-hook 'emacs-lisp-mode-hook 'nameless-mode-from-hook)
  (setq nameless-global-aliases
        '(("fl" . "font-lock")
          ("s" . "seq")
          ("me" . "macroexp")
          ("c" . "cider")
          ("q" . "queue"))))

(use-package firestarter
  :bind ("C-c m s" . firestarter-mode)
  :init (put 'firestarter 'safe-local-variable 'identity))

(use-package paradox
  :commands (paradox-list-packages)
  :config
  (setq paradox-github-token jethro/paradox-user-token))

(use-package focus
  :diminish focus-mode
  :bind ("C-c m f" . focus-mode))

(use-package artbollocks-mode
  :bind (("C-c m a" . artbollocks-mode))
  :config
  (add-hook 'text-mode-hook 'artbollocks-mode))

(use-package darkroom
  :bind (("C-c m d" . darkroom-mode)
         ("C-c m t" . darkroom-tentative-mode)))

(use-package bury-successful-compilation
  :config
  (bury-successful-compilation 1))
