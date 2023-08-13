;;TODO: use corfu instead of company
;;Cosmetic
(setq doom-font (font-spec :family "Iosevka Nerd Font Mono" :size 14)
      doom-variable-pitch-font (font-spec :family "Iosevka Nerd Font Mono" :size 14)
      doom-unicode-font doom-font
      )
(setq doom-theme 'doom-gruvbox)

;;Evil
(setq evil-snipe-scope 'buffer
      select-enable-clipboard nil)

;;Org
(setq org-directory "~/org"
      org-agenda-files org-directory
      org-agenda-mouse-1-follows-link t
      ;;TODO: decide on speed commands
      org-return-follows-link t
      org-startup-numerated t
      org-yank-adjusted-subtrees t)

;;Completion
(setq orderless-matching-styles '(orderless-literal orderless-prefixes orderless-regexp)
      company-idle-delay 0.1
      ;;Allows using multiple components for selection with orderless.
      ;;Remember that orderless defines & to be a separator by default
      company-require-match nil)

;;General
(setq fill-column 80)
(add-hook 'prog-mode-hook 'display-fill-column-indicator-mode)
(add-hook 'text-mode-hook 'display-fill-column-indicator-mode)

;;Pinentry
(use-package! pinentry
  :init (setq epa-pinentry-mode 'loopback)
        (pinentry-start)
        (setenv "SSH_AUTH_SOCK" (shell-command-to-string "gpgconf --list-dirs agent-ssh-socket")))
