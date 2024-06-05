;; Appearance
(setq doom-theme 'catppuccin
      ;; font size in point(pt)
      doom-font (font-spec :family "Spleen" :size 12)
      doom-variable-pitch-font (font-spec :family "Poppins" :size 8))

(load-theme 'catppuccin t t)
(setq catppuccin-flavor 'mocha)
(catppuccin-reload)

(setq fancy-splash-image "~/.doom.d/splash.png")

;; Indent line
(setq highlight-indent-guides-method 'bitmap
      highlight-indent-guides-bitmap-function 'highlight-indent-guides--bitmap-line)
(setq display-line-numbers-type 'relative)

(setq centaur-tabs-style "slant")
(after! centaur-tabs
  (setq centaur-tabs-set-bar 'right))

(use-package! beacon)
(after! beacon (beacon-mode 1))

(use-package treemacs-projectile
  :after (treemacs projectile))
(after! (treemacs projectile)
  (treemacs-project-follow-mode 1))

(use-package volatile-highlights
  :diminish
  :hook
  (after-init . volatile-highlights-mode)
  :custom-face
  (vhl/default-face ((nil (:foreground "#FF3333" :background "#FFCDCD")))))

(use-package! company
  :config
  (setq company-idle-delay 0
        company-minimum-prefix-length 2
        company-selection-wrap-around t))

(custom-set-faces
 '(treemacs-nerd-icons-file-face ((t (:foreground "#b4befe"))))
 '(treemacs-nerd-icons-root-face      ((t (:foreground "#b4befe")))))

(set-formatter! 'alejandra '("alejandra" "--quiet") :modes '(nix-mode))
(setq-hook! 'nix-mode-hook +format-with-lsp nil)

(setq projectile-project-search-path '("~/Projects" "/nixboxes"))

;; replace ; and : to make colon commands easier, I only use magit anyways
(map! :n ";" 'evil-ex)
(map! :n ":" 'evil-repeat-find-char)
