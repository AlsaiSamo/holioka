;;TODO: use corfu instead of company
;;Cosmetic
(setq doom-font (font-spec :family "Sarasa Mono J" :size 14 :weight 'regular)
      doom-variable-pitch-font (font-spec :family "Sarasa Mono J" :weight 'normal)
      doom-unicode-font (font-spec :family "Sarasa Mono J" :weight 'normal)
      )
(setq doom-theme 'doom-gruvbox
      fancy-splash-image "~/org/mhk.png")

;;Evil
(setq evil-snipe-scope 'whole-visible
      select-enable-clipboard nil)

;;Org
(setq org-directory "~/org"
      org-agenda-files (cons "~/org/routine.org" (cons "~/org/notes.org" (directory-files-recursively "~/org/" "tasks.org")))
      org-agenda-file-regexp "tasks.org"
      org-agenda-mouse-1-follows-link t
      org-return-follows-link t
      ;org-startup-numerated t
      org-yank-adjusted-subtrees t)

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
(set-face-attribute 'org-level-1 nil :height 1.5 :family "Sarasa Mono J")
(set-face-attribute 'org-level-2 nil :height 1.4)
(set-face-attribute 'org-level-3 nil :height 1.2)
(set-face-attribute 'org-level-4 nil :height 1.1)
;(set-face-attribute 'org-document-title nil :inherit 'org-level-1)
(set-face-attribute 'org-default nil :family "Sarasa Mono J")
(setq org-bullets-bullet-list '("§" "✿" "⬙" "⦿"))
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
(add-hook 'org-todo-repeat-hook #'org-reset-checkbox-state-subtree)
(doom/reload-font)
)

(use-package! alert
  :init (setq alert-default-style 'libnotify
              alert-fade-time 120
              alert-persist-idle-time 6)
)

; I currently use org-alert for hourly reminders for the day/week
(use-package! org-alert
  :init (setq
         org-alert-interval 3600
         org-alert-notify-cutoff 10
         org-alert-notify-after-event-cutoff 10
         org-alert-notification-title "Org daily/weekly")
)

(after! org-alert
  (org-alert-enable)
  )

;;TODO: package of version 0.1, while I want 1.0
;;This package suits me better than alert because it does exactly what I want,
;;that is - notifying me always, including when I am idle.
;;
;;TODO: I could later build upon it to make task rotation (record time I was working
;;on some task and forcing me to switch. Would need to also ask me to start/stop timer tho)
(use-package! org-clock-reminder
  :init (setq
         org-clock-reminder-interval 900
         org-clock-reminder-notification-title "Org activity"
         org-clock-reminder-format-string "Time: %s on task %s"
         org-clock-reminder-empty-text "No task clocked"
         org-clock-reminder-remind-inactivity 't
         ;; org-clock-reminder-inactive-notifications-p 't
         ))
(after! org-clock-reminder
  (org-clock-reminder-activate))

;; (after! org-clock-reminder
;;   (org-clock-reminder-mode))

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

;TODO: formatter is not applied on save?
(set-formatter! 'alejandra "alejandra -q - " :modes '(nix-mode))
;; (setq-hook! 'nix-mode-hook +format-with 'alejandra)
; Requires format without +onsave (replaces it)
(add-hook 'nix-mode-hook #'format-all-mode)
(add-hook 'rustic-mode-hook #'format-all-mode)

;;SSH, GPG
;;TODO: look into load-env-vars package and something that would create a file with vars
(use-package! pinentry
  :init (setq epa-pinentry-mode 'loopback)
        (pinentry-start)
        (setenv "SSH_AUTH_SOCK" (string-clean-whitespace (shell-command-to-string "gpgconf --list-dirs agent-ssh-socket")))
        )
