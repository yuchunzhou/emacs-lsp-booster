;;; emacs-lsp-booster.el --- emacs-lsp-booster package -*- lexical-binding: t; -*-

;; Copyright (C) 2025 Chunzhou Yu
;;
;; Author: Chunzhou Yu <enjoylife.czzz@gmail.com>
;; Version: 0.1
;; Package-Requires: ((emacs "30.1"))
;;
;;; Commentary:
;;
;; A simple emacs-lsp-booster wrapper.
;;
;;; Code:

(defgroup emacs-lsp-booster nil
  "A simple emacs-lsp-booster wrapper"
  :group 'emacs-lsp-booster
  :link '(url-link "https://github.com/yuchunzhou/emacs-lsp-booster"))

(defcustom emacs-lsp-booster-command "emacs-lsp-booster"
  "The binary (or full path to binary)"
  :type 'string
  :group 'emacs-lsp-booster
  :package-version '(emacs-lsp-booster . "0.1"))


(require 'json)

(advice-add (if (fboundp 'json-parse-buffer) 'json-parse-buffer 'json-read)
	    :around #'(lambda
			(orig-func &rest args)
			(or
			 (when (equal (following-char) ?#)
			   (let ((bytecode (read (current-buffer))))
			     (when (byte-code-function-p bytecode) (funcall bytecode))))
			 (apply orig-func args))))

(advice-add 'lsp-resolve-final-command :around
            #'(lambda (orig-func cmd &optional test?)
                (let ((orig-result (funcall orig-func cmd test?)))
                  (if (and
		       (not test?)
                       (not (file-remote-p default-directory))
                       lsp-use-plists
                       (not (functionp 'json-rpc-connection))
                       (executable-find emacs-lsp-booster-command))
                      (progn
                        (when-let ((command-from-exec-path
				    (executable-find (car orig-result))))
                          (setcar orig-result command-from-exec-path))
                        (message "Using emacs-lsp-booster for %s!" orig-result)
                        (cons
			 (file-name-nondirectory emacs-lsp-booster-command)
			 orig-result))
                    orig-result))))

(provide 'emacs-lsp-booster)
;;; emacs-lsp-booster.el ends here
