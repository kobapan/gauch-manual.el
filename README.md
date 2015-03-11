you can refer to gauche online manual (<a href="http://practical-scheme.net/gauche/man/" target="_blank">http://practical-scheme.net/gauche/man/</a>) with emacs

This is additional function for scheme-mode of Gauche

As Gauche , see bellow ..

<a href="http://practical-scheme.net/gauche/" target="_blank">http://practical-scheme.net/gauche/</a>


## Installation:

### Basic installation

Add gauche-manual.el to your load path and add
```cl
(autoload 'gauche-manual "gauche-manual" "jump to gauche online manual." t)
(add-hook 'scheme-mode-hook
   (lambda ()
     (define-key scheme-mode-map "\C-c\C-f" 'gauche-manual)))
```
to .emacs

### w3m option
As a default gauche-manual use OS default browser. If you use w3m , add
```cl
(custom-set-variables
    '(gauche-manual-use-w3m t))
```
to .emacs

### manual language option
default manual language is japanese. If you use english manual , add
```cl
(custom-set-variables
     '(gauche-manual-lang "en"))
```
to .emacs


## Usage:


Pointing or selecting a word you search, type C-c C-f

Prompted in minibuffer, edit searching word or just type ENTER if you don't need to edit.

Browser will start if not started , and go to searching function's section in <a href="http://practical-scheme.net/gauche/" target="_blank">http://practical-scheme.net/gauche/</a>

