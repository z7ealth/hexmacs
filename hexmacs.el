;;; hexmacs.el --- Auto-run `mix hex.outdated` on mix.exs -*- lexical-binding: t; -*-

;; Author: Your Name
;; Version: 0.1
;; Package-Requires: ((emacs "26.1"))
;; Keywords: elixir, hex, tools
;; URL: https://github.com/yourusername/hexmacs

;;; Commentary:

;; Automatically runs `mix hex.outdated` when a mix.exs file is opened.
;; Displays the results in a read-only buffer.

;;; Code:

(defgroup hexmacs nil
  "Automatically run `mix hex.outdated` when opening `mix.exs`."
  :prefix "hexmacs-"
  :group 'tools)

(defcustom hexmacs-command "mix hex.outdated"
  "Command to run when checking for outdated Hex packages."
  :type 'string
  :group 'hexmacs)

(defun hexmacs--run ()
  "Run `mix hex.outdated` in the project root and display the output."
  (when-let ((project-root (locate-dominating-file default-directory "mix.exs")))
    (let ((buf (get-buffer-create "*mix hex.outdated*")))
      (with-current-buffer buf
        (read-only-mode -1)
        (erase-buffer)
        (let ((default-directory project-root))
          (insert (format "Running in: %s\n\n" default-directory))
          (insert (format "$ %s\n\n" hexmacs-command))
          (call-process-shell-command hexmacs-command nil buf t))
        (read-only-mode 1))
      (display-buffer buf))))

(defun hexmacs--maybe-run ()
  "Run outdated check if current buffer is mix.exs."
  (when (and buffer-file-name
             (string-equal (file-name-nondirectory buffer-file-name) "mix.exs"))
    (hexmacs--run)))

;;;###autoload
(define-minor-mode hexmacs-mode
  "Minor mode to run `mix hex.outdated` when opening mix.exs."
  :lighter " 🔄Hex"
  :global t
  :group 'hexmacs
  (if hexmacs-mode
      (add-hook 'find-file-hook #'hexmacs--maybe-run)
    (remove-hook 'find-file-hook #'hexmacs--maybe-run)))

(provide 'hexmacs)

;;; hexmacs.el ends here
