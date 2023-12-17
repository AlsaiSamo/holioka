;;TODO: use corfu instead of company
;;Cosmetic
(setq doom-font (font-spec :family "Iosevka Nerd Font Mono" :size 14)
      doom-variable-pitch-font (font-spec :family "Iosevka Nerd Font Mono" :size 14)
      doom-unicode-font doom-font
      )
(setq doom-theme 'doom-gruvbox
      fancy-splash-image "~/org/mhk.png")

;;Evil
(setq evil-snipe-scope 'whole-visible
      select-enable-clipboard nil)

;;Org
(setq org-directory "~/org"
      org-agenda-files (cons "~/org/notes.org" (directory-files-recursively "~/org/" "tasks.org"))
      org-agenda-file-regexp "tasks.org"
      org-agenda-mouse-1-follows-link t
      org-return-follows-link t
      ;org-startup-numerated t
      org-yank-adjusted-subtrees t)

(setq alert-default-style 'libnotify
      org-alert-interval 300
      org-alert-notify-cutoff 10
      org-alert-notify-after-event-cutoff 10)

(after! org

(setq org-todo-keywords
      ;Work
      '((sequence "TODO(t)" "ACTIVE(a)" "WAITING(w)" "DELEGATED(s)" "|" "DONE(d)" "CANCEL(c)")
        ;Project
        (sequence "CURRENT" "NEXT" "|" "DONE"))
      org-todo-keyword-faces
      '(("TODO" . +org-todo-project)
        ("ACTIVE" . +org-todo-active)
        ("WAITING" . +org-todo-onhold)
        ("DELEGATED" . +org-todo-onhold)
        ("CANCEL" . +org-todo-cancel)
        ("NEXT" . +org-todo-onhold)))

(setq org-archive-location "~/org/archive/%s_archive::")
(setq org-capture-templates
      '(
        ("n" "Note" item (id "21c649d6-624d-44fb-99fe-77d5ae36415c"))
        ("t" "TODO" entry (id "21c649d6-624d-44fb-99fe-77d5ae36415c") "* TODO %?")
        ("c" "Clipboard" item (id "21c649d6-624d-44fb-99fe-77d5ae36415c") "- %x"))
      org-reverse-note-order t)
(setq org-agenda-dim-blocked-tasks 'invisible)
;Looks
(set-face-attribute 'org-level-1 nil :height 1.5)
(set-face-attribute 'org-level-2 nil :height 1.4)
(set-face-attribute 'org-level-3 nil :height 1.2)
(set-face-attribute 'org-level-4 nil :height 1.1)
;(set-face-attribute 'org-document-title nil :inherit 'org-level-1)
(setq org-bullets-bullet-list '("§" "✿" "⬙" "⦿"))
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
)

;;Completion
(setq orderless-matching-styles '(orderless-literal orderless-prefixes orderless-regexp)
      company-idle-delay 0.05
      ;;Allows using multiple components for selection with orderless.
      ;;Remember that orderless defines & to be a separator by default
      company-require-match nil)

;;General
(setq fill-column 80)
(add-hook 'prog-mode-hook 'display-fill-column-indicator-mode)
;(add-hook 'text-mode-hook 'display-fill-column-indicator-mode)

;;SSH, GPG
;;TODO: look into load-env-vars package and something that would create a file with vars
(use-package! pinentry
  :init (setq epa-pinentry-mode 'loopback)
        (pinentry-start)
        (setenv "SSH_AUTH_SOCK" (string-clean-whitespace (shell-command-to-string "gpgconf --list-dirs agent-ssh-socket")))
        )
