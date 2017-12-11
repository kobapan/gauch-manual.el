;; gauche-manual.el

;;; License
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 2
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

;; Commentary:
;; 
;; gauche-manual.el
;;   jump to gauche online manual.
;; 
;; This is additional function for scheme-mode of Gauche 
;;
;; As Gauche , see bellow ..
;; http://practical-scheme.net/gauche/
;; 

;; Installation:
;;
;; Add gauche-manual.el to your load path and add
;; (autoload 'gauche-manual "gauche-manual" "jump to gauche online manual." t)
;; (add-hook 'scheme-mode-hook
;;    (lambda ()
;;      (define-key scheme-mode-map "\C-c\C-f" 'gauche-manual)))
;; to .emacs
;;
;; ; w3m
;; As a default gauche-manual use OS default browser. If you use w3m , add
;; (custom-set-variables
;;     '(gauche-manual-use-w3m t))
;; to .emacs
;;
;; ; manual language
;; default manual language is japanese. If you use english manual , add
;; (custom-set-variables
;;     '(gauche-manual-lang "en"))
;; to .emacs
;; 

;; Usage:
;;
;; type C-c C-f pointing a word you search OR selecting a word you search
;; 

;; Developer:
;;
;; kobapan
;; kobapan <at> gmail <dot> com
;;

;; $Id$


(defcustom gauche-manual-lang "jp"
  "jp or en"
  :type 'string
  :group 'gauche-manual)

(defcustom gauche-manual-use-w3m nil
  "nil: default browser | t: w3m"
  :type 'boolean
  :group 'gauche-manual)

(defconst gauche-manual-search-engine
  (concat "http://practical-scheme.net/gauche/man/?l=" gauche-manual-lang "&p=%s"))

(defconst gauche-manual-server "practical-scheme.net")

(defvar gauche-manual-location nil
"system use . don't use this value")


(defun gauche-manual-url-encode (str &optional coding)
  (apply (function concat)
         (mapcar
          (lambda (ch) (cond
                        ((eq ch ?\n)               ; newline
                         "%0D%0A")
                        ((string-match "[a-zA-Z0-9\_\:\/\-]" (char-to-string ch)) ; xxx?
                         (char-to-string ch))      ; printable
                        ((char-equal ch ?\x20)     ; space
                         "+")
                        (t
                         (format "%%%02X" ch))))   ; escape
          ;; Coerce a string to a list of chars.
          (append (encode-coding-string (or str "") (or coding 'iso-2022-jp))
                  nil))))


(defun gauche-manual-location-is (process header)
  "get Location: url from html header"
  (let ((startp nil)
        (endp nil))
    (setq startp (string-match "Location:" header))
    (setq endp (string-match "\n" header startp))
    (setq gauche-manual-location
          (cadr (split-string (substring header startp endp) " ")))))
 
(defun gauche-manual-redirection (request)
  "get url for redirection
open tcp connection to gauch-manual-server and receive manual location"
  (let ((tcp-connection (open-network-stream "GET manual-url"
                                             nil
                                             gauche-manual-server
                                             80)))
    (set-process-filter tcp-connection 'gauche-manual-location-is)
    (process-send-string tcp-connection
                         (concat "GET " request " HTTP/1.0\n\n"))
    ;; sleep max 50 times
    (unless (gauche-manual-sleep-for-proccess 50)
      ;; default url
      (setq gauche-manual-location
            (substring gauche-manual-search-engine 0 (string-match "/[^/]*$" gauche-manual-search-engine))))
    (delete-process tcp-connection)
    gauche-manual-location))

(defun gauche-manual-clean ()
  (setq gauche-manual-location nil))

(defun gauche-manual-sleep-for-proccess (max-count)
  "loop if gauche-manual-location is nil."
  (cond 
   ((<= max-count 0)
    (progn (message (concat "retried " max-count " times. Showing Index page..."))
           nil))
   ((null gauche-manual-location)
    (progn (sleep-for 0.1)
           (gauche-manual-sleep-for-proccess (- max-count 1))))
   (t
    t)))


(defun gauche-manual-browse (request)
  "select browser"
  ;;(let ((url (gauche-manual-redirection request)) ;; エラー吐くので使わない
  (let ((url request)
        (b (get-buffer "*w3m*")))
    (if (and gauche-manual-use-w3m (featurep 'w3m-load))
        (and (if b
                 (pop-to-buffer b)
                 (and (split-window) (select-window (next-window))))
             (w3m-browse-url url))
      (browse-url url))))


(defun gauche-manual (str &optional flag)
  "gauche-manual で検索。引数無しだと mini-buffer で編集できる。"
  (interactive
   (list (cond ((or
                 ;; mouse drag の後で呼び出された場合
                 (eq last-command 'mouse-drag-region) ; for emacs
                 (and (eq last-command 'mouse-track) ; for xemacs
                      (boundp 'primary-selection-extent)
                      primary-selection-extent)
                 ;; region が活性
                 (and (boundp 'transient-mark-mode) transient-mark-mode
                      (boundp 'mark-active) mark-active) ; for emacs
                 (and (fboundp 'region-active-p)
                      (region-active-p)) ; for xemacs
                 ;; point と mark を入れ替えた後
                 (eq last-command 'exchange-point-and-mark))
                (buffer-substring-no-properties
                 (region-beginning) (region-end)))
               (t (thing-at-point 'symbol)))
         current-prefix-arg))
  (setq str (read-from-minibuffer "Search Gauche Manual: " str))
  (gauche-manual-browse
   (format gauche-manual-search-engine (gauche-manual-url-encode str)))
  (gauche-manual-clean))



(provide 'gauche-manual)
;; gauche-manual.el
