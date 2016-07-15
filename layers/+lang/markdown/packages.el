;;; packages.el --- Markdown Layer packages File for Spacemacs
;;
;; Copyright (c) 2012-2017 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(setq markdown-packages
  '(
    company
    company-emoji
    emoji-cheat-sheet-plus
    gh-md
    markdown-mode
    markdown-toc
    mmm-mode
    smartparens
    (vmd-mode :toggle (eq 'vmd markdown-live-preview-engine))
    ))

(defun markdown/post-init-company ()
  (spacemacs|add-company-backends :backends company-capf :modes markdown-mode))

(defun markdown/post-init-company-emoji ()
  (spacemacs|add-company-backends
    :backends company-emoji
    :modes markdown-mode))

(defun markdown/post-init-emoji-cheat-sheet-plus ()
  (add-hook 'markdown-mode-hook 'emoji-cheat-sheet-plus-display-mode))

(defun markdown/init-gh-md ()
  (use-package gh-md
    :defer t
    :init
    (spacemacs/set-leader-keys-for-major-mode 'markdown-mode
      "cr"  'gh-md-render-buffer)))

(defun markdown/post-init-smartparens ()
  (add-hook 'markdown-mode-hook 'smartparens-mode))

(defun markdown/mmm-auto-class (lang &optional submode)
  (let ((class (intern (concat "markdown-" lang)))
        (submode (or submode (intern (concat lang "-mode"))))
        (front (concat "^```" lang "[\n\r]+"))
        (back "^```$"))
    (mmm-add-classes (list (list class
                               :submode submode
                               :front front
                               :back back)))
    (mmm-add-mode-ext-class 'markdown-mode nil class)))

(defun markdown/init-markdown-mode ()
  (use-package markdown-mode
    :mode ("\\.m[k]d" . markdown-mode)
    :defer t
    :config
    (progn
      ;; stolen from http://stackoverflow.com/a/26297700
      ;; makes markdown tables saner via orgtbl-mode
      (require 'org-table)
      (defun cleanup-org-tables ()
        (save-excursion
          (goto-char (point-min))
          (while (search-forward "-+-" nil t) (replace-match "-|-"))))
      (add-hook 'markdown-mode-hook 'orgtbl-mode)
      (add-hook 'markdown-mode-hook
                (lambda()
                  (add-hook 'before-save-hook 'cleanup-org-tables  nil 'make-it-local)))
      ;; Insert key for org-mode and markdown a la C-h k
      ;; from SE endless http://emacs.stackexchange.com/questions/2206/i-want-to-have-the-kbd-tags-for-my-blog-written-in-org-mode/2208#2208
      (defun spacemacs/insert-keybinding-markdown (key)
        "Ask for a key then insert its description.
Will work on both org-mode and any mode that accepts plain html."
        (interactive "kType key sequence: ")
        (let* ((tag "~%s~"))
          (if (null (equal key "\r"))
              (insert
               (format tag (help-key-description key nil)))
            (insert (format tag ""))
            (forward-char -6))))

      ;; Declare prefixes and bind keys
      (dolist (prefix '(("mc" . "markdown/command")
                        ("mh" . "markdown/header")
                        ("mi" . "markdown/insert")
                        ("ml" . "markdown/lists")
                        ("mx" . "markdown/text")))
        (spacemacs/declare-prefix-for-mode
         'markdown-mode (car prefix) (cdr prefix)))
      ;; note: `gfm-mode' is part of `markdown-mode.el' so we can define its key
      ;; bindings here
      (dolist (mode '(markdown-mode gfm-mode))
        (spacemacs/set-leader-keys-for-major-mode mode
          ;; Movement
          "{"   'markdown-backward-paragraph
          "}"   'markdown-forward-paragraph
          ;; Completion, and Cycling
          "]"   'markdown-complete
          ;; Indentation
          ">"   'markdown-indent-region
          "<"   'markdown-exdent-region
          ;; Buffer-wide commands
          "c]"  'markdown-complete-buffer
          "cc"  'markdown-check-refs
          "ce"  'markdown-export
          "cm"  'markdown-other-window
          "cn"  'markdown-cleanup-list-numbers
          "co"  'markdown-open
          "cp"  'markdown-preview
          "cv"  'markdown-export-and-preview
          "cw"  'markdown-kill-ring-save
          ;; headings
          "hi"  'markdown-insert-header-dwim
          "hI"  'markdown-insert-header-setext-dwim
          "h1"  'markdown-insert-header-atx-1
          "h2"  'markdown-insert-header-atx-2
          "h3"  'markdown-insert-header-atx-3
          "h4"  'markdown-insert-header-atx-4
          "h5"  'markdown-insert-header-atx-5
          "h6"  'markdown-insert-header-atx-6
          "h!"  'markdown-insert-header-setext-1
          "h@"  'markdown-insert-header-setext-2
          ;; Insertion of common elements
          "-"   'markdown-insert-hr
          "if"  'markdown-insert-footnote
          "ii"  'markdown-insert-image
          "ik"  'spacemacs/insert-keybinding-markdown
          "iI"  'markdown-insert-reference-image
          "il"  'markdown-insert-link
          "iL"  'markdown-insert-reference-link-dwim
          "iw"  'markdown-insert-wiki-link
          "iu"  'markdown-insert-uri
          ;; Element removal
          "k"   'markdown-kill-thing-at-point
          ;; List editing
          "li"  'markdown-insert-list-item
          ;; region manipulation
          "xb"  'markdown-insert-bold
          "xi"  'markdown-insert-italic
          "xc"  'markdown-insert-code
          "xC"  'markdown-insert-gfm-code-block
          "xq"  'markdown-insert-blockquote
          "xQ"  'markdown-blockquote-region
          "xp"  'markdown-insert-pre
          "xP"  'markdown-pre-region
          ;; Following and Jumping
          "N"   'markdown-next-link
          "f"   'markdown-follow-thing-at-point
          "P"   'markdown-previous-link
          "<RET>" 'markdown-jump))
      (when (eq 'eww markdown-live-preview-engine)
        (spacemacs/set-leader-keys-for-major-mode 'markdown-mode
          "cP"  'markdown-live-preview-mode))
      ;; Header navigation in normal state movements
      (evil-define-key 'normal markdown-mode-map
        "gj" 'outline-forward-same-level
        "gk" 'outline-backward-same-level
        "gh" 'outline-up-heading
        ;; next visible heading is not exactly what we want but close enough
        "gl" 'outline-next-visible-heading)
      ;; Promotion, Demotion
      (define-key markdown-mode-map (kbd "M-h") 'markdown-promote)
      (define-key markdown-mode-map (kbd "M-j") 'markdown-move-down)
      (define-key markdown-mode-map (kbd "M-k") 'markdown-move-up)
      (define-key markdown-mode-map (kbd "M-l") 'markdown-demote))))

(defun markdown/init-markdown-toc ()
  (use-package markdown-toc
    :defer t
    :init (spacemacs/set-leader-keys-for-major-mode 'markdown-mode
            "it"  'markdown-toc-generate-toc)))

(defun markdown/init-mmm-mode ()
  (use-package mmm-mode
    :commands mmm-mode
    :init (add-hook 'markdown-mode-hook 'spacemacs/activate-mmm-mode)
    :config
    (progn
      ;; Automatically add mmm class for languages where its name and mode
      ;; name are directly related
      (mapc 'markdown/mmm-auto-class markdown-mmm-auto-modes)

      ;; Otherwise define these manually
      (markdown/mmm-auto-class "html" 'web-mode)
      (markdown/mmm-auto-class "elisp" 'emacs-lisp-mode)
      (markdown/mmm-auto-class "ess" 'R-mode)
      (setq mmm-global-mode t))))

(defun markdown/init-vmd-mode ()
  (use-package vmd-mode
    :defer t
    :init (spacemacs/set-leader-keys-for-major-mode 'markdown-mode
            "cP" 'vmd-mode)))
