;; pl-util.lsp

(import 'sys')
(define print2err (str)
  (apply sys.stderr.write str)
  (apply sys.stderr.write '\n')
  (apply sys.stderr.flush)
  )



(import 'os')
(define interpretTilde (str)
  (invoke str 'replace' '~' (apply os.path.expanduser '~'))
  )

(define canonical_path (str)
  (let ((str0 (apply interpretTilde str))
	(str1 (apply os.path.realpath str0)))
    str1
    )
  )
