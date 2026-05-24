;; TODO: remove eww
;;TODO: review new features
;;TODO: look into default keybinds
;;TODO: rebind keys:
;; 1. M-q for paragraph readjusting in org
;; 2. Unbind brackets in insert mode (they are bound to lispy-backward and lispy-forward)

;;; General theming
(setq
 ;; Fonts
 doom-font (font-spec :family "Iosevka Nerd Font Mono" :size 14 :weight 'regular)
 ;; TODO: symbols broke again, use a different font?
 doom-symbol-font (font-spec :family "Iosevka Nerd Font Mono" :weight 'normal)
 ;; Custom build of Iosevka, rounder
 doom-variable-pitch-font (font-spec :family "Aporetic Sans" :size 14)

 ;; Theme
 doom-theme 'doom-gruvbox
 ;; Startup screen
 fancy-splash-image (concat doom-user-dir "mhk.png"))


;;; Functional

;;Evil
(setq evil-snipe-scope 'whole-visible
      select-enable-clipboard nil)

;; TODO: research dirvish
(after! dirvish
  (setq dirvish-reuse-session t))

;;Completion
(setq orderless-matching-styles '(orderless-literal orderless-prefixes orderless-regexp)
      ;; TODO: "Corfu is only enabled if the minibuffer sets the variable
      ;; completion-at-point-functions locally."
      ;; find more about this, I want to not set the +corfu-want-minibuffer-completion as nil
      +corfu-want-minibuffer-completion nil
      corfu-auto-delay 0.12)

;; General
(setq fill-column 80)
(add-hook 'prog-mode-hook 'display-fill-column-indicator-mode)

;; SSH, GPG
(use-package! exec-path-from-shell
  :config (dolist (var '("SSH_AUTH_SOCK" "SSH_AGENT_PID"))
            (add-to-list 'exec-path-from-shell-variables var))
  (exec-path-from-shell-initialize))
(use-package! pinentry
  :init (setq
         epg-gpg-home-directory "/state/secrets/.gnupg")
  (setenv "GNUPGHOME" "/state/secrets/.gnupg")
  :config (pinentry-start))


;;; Org
;; TODO: check out packages on melpa
;; TODO: habit tracking
;; TODO: agenda and reminders
;; TODO: capturing information, structuring and browsing information
;; TODO: exporting as a blog (html or something like ox-hugo)
;; TODO: exporting as markdown
;; TODO: try this out
;; https://github.com/yibie/grid-table
;; TODO: can potentially use these org module toggles: hugo, pandoc, roam, present
;; 
(after! org
  ;;; Faces
  ;; TODO: the number line, where it switches from 9 to 10, pushes the variable-pitch text to the right by one space.
  (custom-set-faces!
    '(org-hide :foreground "#282828" :inherit fixed-pitch)
    '(org-table :foreground "#8ec07c" :inherit fixed-pitch)
    '(org-default :inherit variable-pitch)
    '(org-verbatim :foreground "#fabd2f" :inherit fixed-pitch)
    '(org-code :foreground "#fe8019" :inherit fixed-pitch)
    '(org-document-title :foreground "#fbf1c7" :weight bold :height 2.0)
    '(org-document-info :foreground "#d5c4a1" :weight bold)
    '(org-indent :inherit org-hide)
    '(org-document-info-keyword :inherit shadow)
    '(org-tag :inherit shadow)
    '(org-special-keyword :inherit fixed-pitch)
    '(org-meta-line :inherit shadow)
    '(org-checkbox :foreground "#8ec07c" :inherit variable-pitch)
    '(org-drawer :inherit shadow)
    '(org-block :inherit fixed-pitch :background "#1c2021" :extend t)
    '(org-block-begin-line :inherit org-block :foreground "#665c54" :background "#1d2021" :extend t)
    '(org-block-end-line :inherit org-block-begin-line)
    '(org-quote :inherit org-block :background "#1c2021" :slant italic)
    '(org-footnote :foreground "#8ec07c" :background "#32302f" :overline nil)
    '(org-level-1 :foreground "#83a598" :weight bold :height 2.0 :overline nil :extend t)
    '(org-level-2 :foreground "#8ec07c" :weight bold :height 1.8 :overline nil :extend t)
    '(org-level-3 :foreground "#b8bb26" :weight bold :height 1.6 :overline nil :extend t)
    '(org-level-4 :foreground "#fabd2f" :weight bold :height 1.4 :overline nil :extend t)
    '(org-level-5 :foreground "#fe8019" :weight bold :height 1.3 :overline nil :extend t)
    '(org-level-6 :foreground "#fb4934" :weight bold :height 1.2 :overline nil :extend t)
    '(org-level-7 :foreground "#d3869b" :weight bold :height 1.1 :overline nil :extend t)
    '(org-headline-done :foreground "#928374" :inherit variable-pitch :overline nil :extend t)
    '(org-link :foreground "#b8bb26" :slant oblique :overline nil)
    '(org-ellipsis :foreground "#7c6f64" :inherit shadow :weight bold :extend t)
    '(org-modern-label :height 1.0 :weight regular :underline nil :box(:line-width (-1 . -2) :color "#282828" :style nil)))


  ;;; Symbols
  (defun my/prettify-symbols-setup ()
    ;; Blocks
    (push '("#+BEGIN_SRC" . "≪") prettify-symbols-alist)
    (push '("#+END_SRC" . "≫") prettify-symbols-alist)
    (push '("#+begin_src" . "≪") prettify-symbols-alist)
    (push '("#+end_src" . "≫") prettify-symbols-alist)
    ;; TODO: ensure this works
    (push '("#+RESULTS:" . "≡") prettify-symbols-alist)

    (push '("#+BEGIN_QUOTE" . ?❝) prettify-symbols-alist)
    (push '("#+END_QUOTE" . ?❞) prettify-symbols-alist)
    (push '("#+begin_quote" . ?❝) prettify-symbols-alist)
    (push '("#+end_quote" . ?❞) prettify-symbols-alist)

    (prettify-symbols-mode))

  (add-hook! 'org-mode-hook 'variable-pitch-mode #'my/prettify-symbols-setup)

  (setq org-ellipsis " […]"
        org-n-level-faces 8
        org-hide-emphasis-markers 1
        org-modern-star 'replace
        org-modern-table-vertical 2
        org-modern-list '((43 . "◦") (45 . "•"))
        org-modern-checkbox '((88 . "") (45 . "󱅶") (32 . ""))
        ;; TODO: make this work, then remove prettify-symbols-setup
        ;; org-modern-block-name '(
        ;;                         ("quote" ("❝" . "❞"))
        ;;                         ("QUOTE" ("❝" . "❞"))
        ;;                         ("src" ("≪" . "≫"))
        ;;                         ("SRC" ("≪" . "≫"))
        ;;                         )
        )

;;; Functional
  
  (setq
   ;; TODO: redo this when working on agenda, notes, etc.
   org-directory "~/org"
   org-archive-location "~/org/archive/%s_archive::"
   org-agenda-files (cons "~/org/routine.org" (cons "~/org/notes.org" (directory-files-recursively "~/org/" "tasks.org")))
   org-agenda-file-regexp "tasks.org"
   org-agenda-mouse-1-follows-link t
   org-return-follows-link t
   org-yank-adjusted-subtrees t
   )

  (setq org-todo-keywords
        '((sequence "TODO(t)" "WAITING(w)" "ACTIVE(a)" "|" "DONE(d)" "CANCEL(x)"))
        org-todo-keyword-faces
        '(("TODO" . +org-todo-project)
          ("WAITING" . +org-todo-onhold)
          ("ACTIVE" . +org-todo-active)
          ("CANCEL" . +org-todo-cancel)
          ("DONE" . org-done)))

  ;; TODO: rethink when working on capturing
  (setq org-capture-templates
        '(
          ("n" "Note" item (id "21c649d6-624d-44fb-99fe-77d5ae36415c"))
          ("t" "TODO" entry (id "21c649d6-624d-44fb-99fe-77d5ae36415c") "* TODO %?")
          ("c" "Clipboard" item (id "21c649d6-624d-44fb-99fe-77d5ae36415c") "- %x"))
        org-reverse-note-order t)
  (setq org-agenda-dim-blocked-tasks t)

  (add-hook 'org-todo-repeat-hook #'org-reset-checkbox-state-subtree)

  )
