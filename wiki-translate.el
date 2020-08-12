;; wt-translate


(defcustom wt-prefix "wt-"
  "Prefix to use before the automatically generated functions of the type `fr-en`. Can be an empty string."
  :type 'string)

(defcustom wt-input-idle-delay 0.6
  "`helm-input-idle-delay' used for wiki-translate."
  :type 'float)

;; The custom variable above was introduced because helm auto-complete generated the following errors on MS Windows (which appeared in the minibuffer during completion):
;; error in process filter: url-http-generic-filter: Transfer interrupted!
;; error in process filter: Transfer interrupted!

;; Simplest case (until now) to reproduce the problem, with function below:

;; (defun test()
;;   (interactive)
;;   (completing-read "Type a word."
;; 		   (completion-table-dynamic #'(lambda (x) (wt-basic-search x "fr")))
;; 		   nil t))


;; When not encapsulated in a function, the completing-read outputs only in the Messages buffer, with the following: "code enters debugger"...

;; Two solutions:
;; 1 - set helm-input-idle-delay to 0.4 (original value is 0.1) - works only 70% of the time
;; 2 - or set debug-on-error to t.



;; CUSTOMIZE THIS VARIABLE ACCORDING TO YOUR NEEDS, AND THEN RELOAD THIS FILE (M-x load-file <RET><RET>)
;; Use the Wikipedia code (generally defined by ISO 639-1, but there are some exceptions, see https://en.wikipedia.org/wiki/List_of_Wikipedias) 
(defcustom wt-languages '("en" "fr" "pt" "eo" "ja" "zh" "de")
  "Languages for which a translation function will be created with format style: fr-en"
  )
;; END OF CUSTOMIZATION

;; (defun make-api-request (ws-url)
;;   (with-temp-buffer
;;     (url-insert-file-contents ws-url)
;;     (buffer-string)))

(defun wt-get-ws-json (ws-url)
  "Calls the JSON WS <ws-url>.
Returns asynchronously the JSON as a hash-table."
  (require 'json)
  (let* ((json-object-type 'hash-table)
	 (json-array-type 'list)
	 (json-key-type 'string))
    (with-temp-buffer
      (url-insert-file-contents ws-url)
      (let ((json-false :false))
	    (json-read)))))

;; (pp (wt-get-ws-json "https://www.mediawiki.org/w/api.php?action=query&list=allpages&apfrom=B&format=json"))



(defun wt-translate (word lang-from lang-to)
  "Translates word from lang-from to lang-to using Wikipedia APIs.
Example usage: (wt-translate \"Banana\" \"en\" \"ja\")."
  ;; url API usage: https://fr.wikipedia.org/w/api.php?action=query&prop=langlinks&titles=V%C3%A9rone&lllang=en&formatversion=2&redirects&format=json
  (let* (
	 (url (concat "https://"
		      lang-from
		      ".wikipedia.org/w/api.php?action=query&prop=langlinks&titles="
		      word
		      "&lllang="
		      lang-to
		      "&formatversion=2&redirects&format=json"))
	 (wikipedia-JSON (wt-get-ws-json url))
	 ;; query.pages[0].langlinks, if it exists, contains the translation: query.pages[0].langlinks[0].title
	 (query (gethash "query" wikipedia-JSON))
	 (pages (gethash "pages" query))
	 (langlinks (gethash "langlinks" (car pages))))

    (if (not langlinks) ;; page does not exist
	nil
      ;; else
      (let* ((langlinks (gethash "langlinks" (car pages)))
	     (translation (gethash "title" (car langlinks))))
	translation))))

;; (browse-url (concat "https://eo.wikipedia.org/wiki/" (url-hexify-string "Unuiĝintaj Nacioj")))


(defun wt-generic-interactive-translate (lang-from lang-to)
  "Model of the functions fr-eo and so on"
  (let* ((debug-on-error t)
	 (helm-input-idle-delay wt-input-idle-delay)
	 (completion-ignore-case t)
	 (word 
	  (completing-read (format "Type a word in %s: " lang-from)
			   (completion-table-dynamic #'(lambda (x) (wt-advanced-search x lang-from)))
			   nil t))
	 (translation (wt-translate word lang-from lang-to)))
    (if (not translation)
	(message (concat word "'s translation could not be found."))
      (progn
	(if current-prefix-arg
	    (browse-url (concat "https://" lang-to ".wikipedia.org/wiki/" (url-hexify-string translation))))
	(message translation)))))


;; Defining the functions <wt-prefix>en-fr, <wt-prefix>en-pt, eo-fr, etc.
(dolist (lang-from wt-languages)
  (dolist (lang-to wt-languages)
    (if (not (string= lang-from lang-to))
	(defalias (intern (concat wt-prefix lang-from "-" lang-to))
	  `(lambda(), (format "Translate from %s to %s using Wikipedia APIs." lang-from lang-to)
	     (interactive)
	       (wt-generic-interactive-translate ,lang-from ,lang-to))))))



(defun wt-basic-search (prefix lang)
  ;; Uses Wikipedia "query" API:
  ;; Example url: https://en.wikipedia.org/w/api.php?action=query&list=allpages&apprefix=donald tr&formatversion=2&aplimit=15&format=json
  (let* ((url (concat "https://" lang ".wikipedia.org/w/api.php?"
		      "action=query"
		      "&list=allpages"
		      "&apprefix=" prefix
		      "&formatversion=2"
		      "&aplimit=15"
		      "&format=json"))
	 (json (wt-get-ws-json url))
	 (query (gethash "query" json))
	 (all-categories (gethash "allpages" query))
	 )
    (let ((result (car all-categories)))
      (mapcar
       (lambda (x) (gethash "title" x))
       all-categories))))



(defun wt-advanced-search (query lang)
  ;; uses Wikipedia "opensearch" API. (&format=json is useful when query is empty)
  ;; https://fr.wikipedia.org/w/api.php?action=opensearch&search=Ivan%C2%A0Ill&format=json
  ;; Result: a list L containing in L[1] all possible names.
  (let* ((query (if (or (not query) (string= query ""))
		    " "
		  query))
	 (url (concat "https://" lang ".wikipedia.org/w/api.php?"
		      "action=opensearch"
		      "&search="
		      query
		      "&format=json"))
	 (json (wt-get-ws-json url)))
	 (nth 1 json)))



