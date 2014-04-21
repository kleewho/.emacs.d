;;; init.el --- Lukasz Klich's init file
;;; Commentary:
;;; Code:
;; Disable this fancy graphics shit
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(when (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(setq inhibit-startup-screen t)

(set-default 'tramp-default-proxies-alist (quote ((".*" "\\`root\\'" "/ssh:%h:"))))

;; Set other not related to packages stuff
(load-theme `wombat)
;;(set-face-font 'default "-unknown-Inconsolata-normal-normal-normal-*-13-*-*-*-m-0-iso10646-1")
;;(set-face-font 'default "Ubuntu Mono")
(setq-default indent-tabs-mode nil)
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(mouse-wheel-mode 1)
(setq scroll-step 1)
(setq transient-mark-mode 1)
(fset 'yes-or-no-p 'y-or-n-p)
(global-auto-revert-mode t)
(recentf-mode t)
(savehist-mode t)
(show-paren-mode t)
(visual-line-mode -1)
(winner-mode t)
(global-subword-mode t)
(delete-selection-mode t)
(which-function-mode t)
(server-start)
;; Prevent the cursor from blinking
(blink-cursor-mode 0)
;; Don't use messages that you don't read
(setq initial-scratch-message "")
(setq inhibit-startup-message t)



;;;; package.el
(require 'package)
(setq package-user-dir "~/.emacs.d/elpa")
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
(add-to-list 'package-archives '("marmalade" .
                                 "http://marmalade-repo.org/packages/"))
(package-initialize)


(defun lk-install-rad-packages ()
  "Install only the sweetest of packages."
  (interactive)
  (package-refresh-contents)
  (mapc #'(lambda (package)
            (unless (package-installed-p package)
              (package-install package)))
        '(browse-kill-ring
          ido-ubiquitous
          magit
          smex
          undo-tree
          ace-jump-mode
          ido-ubiquitous
          ido-vertical-mode
          flx-ido
          rainbow-delimiters
          undo-tree
          paredit
          company
          diminish
          paredit
          company
          undo-tree
          smartparens
          js2-mode
          flycheck
          browse-kill-ring
          fill-column-indicator)))

;;;; macros
(defmacro after (mode &rest body)
  "`eval-after-load' MODE evaluate BODY."
  (declare (indent defun))
  `(eval-after-load ',mode
     (progn ,@body)))

(defmacro rename-modeline (package-name mode new-name)
  `(eval-after-load ,package-name

     '(defadvice ,mode (after rename-modeline activate)
        (setq mode-name ,new-name))))

(defmacro when-windows (&rest body)
  `(when (equal system-type 'windows-nt)
     ,@body))

;;;; emacs lisp
(defun imenu-elisp-sections ()
  (setq imenu-prev-index-position-function nil)
  (add-to-list 'imenu-generic-expression '("Sections" "^;;;; \\(.+\\)$" 1) t))

(add-hook 'emacs-lisp-mode-hook 'imenu-elisp-sections)


;;;;
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(when-windows
 (prefer-coding-system 'cp1252-dos))

;;;; global set keys
(global-set-key (kbd "RET") 'newline-and-indent)

;;;; saveplace
(require 'saveplace)
(setq save-place-file "~/.emacs.d/saved-places")
(setq-default save-place t)

;;;; uniquify
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

;;;; ace-jump-mode
(define-key global-map (kbd "C-;") 'ace-jump-mode)

;;;; rainbow-delimiters
(after rainbow-delimiters-autoloads
  (add-hook 'prog-mode-hook 'rainbow-delimiters-mode-enable))

;;;; undo-tree
(after undo-tree-autoloads
  (global-undo-tree-mode t)
  (setq undo-tree-visualizer-relative-timestamps t)
  (setq undo-tree-visualizer-timestamps t))

;;;; paredit
(after paredit-autoloads
  (add-hook 'emacs-lisp-mode-hook 'paredit-mode)
  (add-hook 'clojure-mode-hook 'paredit-mode))

;;;; company-mode
(after company-autoloads
  (add-hook 'init-hook 'global-company-mode))

;; ;;;; diminish - dont show these modes in modeline
;; (after diminish-autoloads
;;   (after paredit (diminish 'paredit-mode))
;;   (after company (diminish 'company-mode))
;;   (after undo-tree (diminish 'undo-tree-mode)))

;;;; smartparens
(after smartparens-autoloads
  (require 'smartparens-config))

;; ;;;; js2-mode
;; (after js2-mode-autoloads
;;   (add-to-list 'auto-mode-alist '("\\.js$" . js2-mode)))

(rename-modeline "js2-mode" js2-mode "JS2")

;;;; flycheck
(after flycheck-autoloads
  (require 'flycheck)
  (add-hook 'after-init-hook #'global-flycheck-mode)
  (when (file-exists-p "~/.emacs.d/packages/jslint-reporter/jslint-reporter.bat")
    (flycheck-define-checker javascript-jslint-reporter
      "A JavaScript syntax and style checker based on JSLint Reporter.
       See URL `https://github.com/FND/jslint-reporter'."
      :command ("~/.emacs.d/packages/jslint-reporter/jslint-reporter.bat" source)
      :error-patterns
      ((error line-start (1+ nonl) ":" line ":" column ":" (message) line-end))
      :modes (js-mode js2-mode js3-mode))
    (add-hook 'js-mode-hook (lambda ()
                              (flycheck-select-checker 'javascript-jslint-reporter)
                              (flycheck-mode))))
  (when (file-exists-p "~/.emacs.d/jshint-reporter.bat")
    (flycheck-define-checker my-jshint
      "A JavaScript syntax and style checker using jshint.

       See URL `http://www.jshint.com'."
      :command ("~/.emacs.d/jshint-reporter.bat" "--checkstyle-reporter"
                (config-file "--config" flycheck-jshintrc)
                source)
      :error-parser flycheck-parse-checkstyle
      :modes (js-mode js2-mode js3-mode))))


;;;; browse-kill-ring
(after browse-kill-ring-autoloads
  (global-set-key (kbd "C-x C-y") 'browse-kill-ring))

;;;; whitespace-mode
(require 'whitespace)
(setq whitespace-style '(face empty tabs trailing tab-mark space-mark))
(global-whitespace-mode t)

;;;; markdown
(after markdown-mode-autoloads
  (autoload 'markdown-mode "markdown-mode"
    "Major mode for editing Markdown files" t)
  (add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode)))


;;;; eclim
(after emacs-eclim-autoloads
  (require 'eclim)
  (global-eclim-mode)
  (require 'eclimd)
  (custom-set-variables
   '(eclim-eclipse-dirs "~/opt/eclipse"))
  (setq help-at-pt-display-when-idle t)
  (setq help-at-pt-timer-delay 0.1)
  (help-at-pt-set-timer)
  (require 'company)
  (require 'company-emacs-eclim)
  (company-emacs-eclim-setup)
  (global-company-mode t)
  (after eclim-mode-major-mode
    (define-key eclim-mode-map (kbd "M-<f7>") 'eclim-java-find-references)))

;;;; auctex
(after auctex-autoloads
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq TeX-PDF-mode t))

;;;; cider
(after cider-autoloads
  (add-hook 'cider-mode-hook 'cider-turn-on-eldoc-mode)
  (setq nrepl-hide-special-buffers t)
  (add-hook 'cider-repl-mode-hook 'paredit-mode)
  (add-hook 'cider-repl-mode-hook 'rainbow-delimiters-mode))

;;;; yasnippets
(after yasnippet-autoloads
  (require 'yasnippet)
  (yas-global-mode 1))

(after projectile-autoloads
  (projectile-global-mode))

(after dash-autoloads
  (dash-enable-font-lock))

(after key-chord-autoloads
  (require 'key-chord)
  (key-chord-define-global "jj" 'ace-jump-word-mode)
  (key-chord-define-global "jl" 'ace-jump-line-mode)
  (key-chord-define-global "jk" 'ace-jump-char-mode)
  (key-chord-define-global "uu" 'undo-tree-visualize)
  (key-chord-define-global "xx" 'execute-extended-command)
  (key-chord-define-global "yy" 'browse-kill-ring)
  (key-chord-mode 1))

(after helm-autoloads
  (helm-mode)
  (global-set-key (kbd "M-x") 'helm-M-x)
  (global-set-key (kbd "C-x C-f") 'helm-find-files)
  (global-set-key (kbd "C-x C-b") 'helm-buffers-list))

;;; init.el ends here
