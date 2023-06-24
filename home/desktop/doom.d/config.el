;; Appearance
(setq doom-theme 'catppuccin
      doom-font (font-spec :family "Spleen" :size 16)
      doom-variable-pitch-font (font-spec :family "BlexMono Nerd Font" :size 10.0))

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

(after! apheleia
  (push '(alejandra . ("alejandra" "-")) apheleia-formatters)
  (setf (alist-get 'nix apheleia-mode-alist) 'alejandra))

(setq magit-todos-mode t)

(setq projectile-project-search-path '("~/Projects" "/nixboxes"))
