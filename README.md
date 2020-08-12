# Wiki-Translate: a Translation Dictionary in Emacs, using Wikipedia

Do you ever look for the translation of a word by looking it up on Wikipedia, then clicking on "Languages" and hovering on the language you're interested in to see the translation?

![Screenshot](img/demo1.png)

This snippet of code automates it for you, inside Emacs.

It creates a user-defined set of functions like `en-fr`, which translates from English to French, or `de-pt`, which translates from German to Portuguese.

By default, a prefix is put before these functions, to comply with [Emacs Lisp Coding Conventions](https://www.gnu.org/software/emacs/manual/html_node/elisp/Coding-Conventions.html#Coding-Conventions), so they are accessible through `wt-en-de`, `wt-en-ru` and so on: but I recommend setting this prefix (`wt-prefix`) to nil if you can, for a more direct access.

Calling the functions with C-u opens the Wikipedia page of the translation.

Autocompletion is available (I recommand helm).


## Example usage

- How do you say *rabbit* in French ? `M-x` `en-fr` `rabbit` gives you the answer. (`wt-en-fr` if you did not set `wt-prefix` to nil).
- `M-x` `en-eo` `Russia` looks for the translation of *Russia* in Esperanto and displays the result (*Rusio*) in the minibuffer.
- `C-u` `M-x` `pt-ja` `Coimbra` looks for the japanese translation of the portuguese name *Coimbra*, displays it in the minibuffer, and opens the [japanese page](https://ja.wikipedia.org/wiki/%E3%82%B3%E3%82%A4%E3%83%B3%E3%83%96%E3%83%A9) dedicated to it.

## Customization

Reload wiki-translate.el (or Emacs) for modifications to take effect.

I suggest setting `wt-prefix` to nil, to be able to access the functions directly through their two-letter codes (`es-en`), without having to type in the prefix (`wt-es-en`).

Default languages are English (en), Esperanto (eo), French (fr), German (de), Japanese (ja), Mandarin Chinese (zh), Portuguese (pt).  
You can add or remove any language you want through the variable `wt-languages`. It uses the [ISO 639-1 code](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) of the languages (generally two letters : `en` for english, `pt` for portuguese, etc.), provided that the Wikipedia in this language exists and is known under this name (which is generally the case, but have a check at the [List Of Wikipedias](https://en.wikipedia.org/wiki/List_of_Wikipedias)) if in doubt).  

For each language pair, the code automatically creates a function to translate from and to this language. For instance, if you specify English (en), German (de) and Russian (ru), it creates the functions `en-de`, `en-ru`, `de-en`,`de-ru`, `ru-en`, and `ru-de`. 



## How does it work?

Wiki-translate is written entirely in Elisp, and uses the following Wikipedia APIs:

- Word selection and auto-completion in the input language: listing API.  
Example: Complete the word "Foundatio" in english:  
https://en.wikipedia.org/w/api.php?action=query&list=allpages&apprefix=Foundatio&formatversion=2&aplimit=15&format=json

- Translation: query API on the input language Wikipedia.  
Example: Translate the french town "Vérone" in english:  
https://fr.wikipedia.org/w/api.php?action=query&prop=langlinks&titles=Vérone&lllang=en&formatversion=2&redirects&format=json


## Possible improvements?

- Find a way to unset `debug-on-error` inside `generic-interactive-wiki-translate` (see code)
- Evaluate if https://en.wikipedia.org/w/api.php?action=opensearch&search=Ivan%C2%A0Ill isn't a better API for the input language. That's the one used by helm-wikipedia.
- Should we offer to open the Wikipedia page in the browser *after* the translation?
- Code cleaning: should-we split get-ws-json in the same way it was done on [this](https://github.com/AccelerationNet/cl-mediawiki/blob/master/src/main.lisp) project?
- Should we rename all functions with a customizable string prefix, by default *wiki-translate*?




