;;TODO: review new features
;;TODO: look into default keybinds
;;TODO: rebind keys
;;Cosmetic
(setq doom-font (font-spec :family "Iosevka Nerd Font Mono" :size 14 :weight 'regular)
      doom-variable-pitch-font (font-spec :family "Iosevka Nerd Font" :weight 'normal)
      doom-symbol-font (font-spec :family "Iosevka Nerd Font" :weight 'normal))

(setq doom-theme 'doom-gruvbox
      fancy-splash-image (concat doom-user-dir "mhk.png"))

;;Evil
(setq evil-snipe-scope 'whole-visible
      select-enable-clipboard nil)

;; TODO: research dirvish
(after! dirvish
  (setq dirvish-reuse-session t))

;; TODO: redo my org setup
;;Org
(setq org-directory "~/org"
      org-agenda-files (cons "~/org/routine.org" (cons "~/org/notes.org" (directory-files-recursively "~/org/" "tasks.org")))
      org-agenda-file-regexp "tasks.org"
      org-agenda-mouse-1-follows-link t
      org-return-follows-link t
      ;; org-startup-numerated t
      org-yank-adjusted-subtrees t)

;; TODO: redo my org setup
(after! org
  (setq org-todo-keywords
        ;;Work
        '((sequence "TODO(t)" "ACTIVE(a)" "WAITING(w)" "DELEGATED(s)" "|" "DONE(d)" "CANCEL(c)")
          ;;Project
          (sequence "CURRENT" "NEXT" "|" "DONE"))
        org-todo-keyword-faces
        ;; TODO: keep those that I actually use
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

  ;;Looks
  (set-face-attribute 'org-level-1 nil :height 1.5 :family "Iosevka Nerd Font")
  (set-face-attribute 'org-level-2 nil :height 1.4)
  (set-face-attribute 'org-level-3 nil :height 1.2)
  (set-face-attribute 'org-level-4 nil :height 1.1)
  ;;(set-face-attribute 'org-document-title nil :inherit 'org-level-1)
  (set-face-attribute 'org-default nil :family "Iosevka Nerd Font")
  (setq org-bullets-bullet-list '("§" "✿" "⬙" "⦿"))
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
  (add-hook 'org-todo-repeat-hook #'org-reset-checkbox-state-subtree)
  (doom/reload-font))

;;Completion
(setq orderless-matching-styles '(orderless-literal orderless-prefixes orderless-regexp)
      ;; TODO: "Corfu is only enabled if the minibuffer sets the variable
      ;; completion-at-point-functions locally."
      ;; find more about this, I want to not set the +corfu-want-minibuffer-completion as nil
      +corfu-want-minibuffer-completion nil
      corfu-auto-delay 0.12)

;;General
(setq fill-column 80)
(add-hook 'prog-mode-hook 'display-fill-column-indicator-mode)
;;(add-hook 'text-mode-hook 'display-fill-column-indicator-mode)

(use-package! exec-path-from-shell
  :config (dolist (var '("SSH_AUTH_SOCK" "SSH_AGENT_PID"))
            (add-to-list 'exec-path-from-shell-variables var))
  (exec-path-from-shell-initialize))
;;SSH, GPG
(use-package! pinentry
  :init (setq
         epg-gpg-home-directory "/state/secrets/.gnupg")
  (setenv "GNUPGHOME" "/state/secrets/.gnupg")
  :config (pinentry-start))
