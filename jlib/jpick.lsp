;;full path or have it in your PATH
(define p2j "./pickle2json")

;(apply pickle2json "pca-km-clustering-n256-ratio.pkl" "pca-km-clustering-n256-ratio.lsp.json")

(define pickle2json (pickleFile jsonFile)
  (let
      (
       (command (concat p2j " " pickleFile " " jsonFile))
       (result (mkarray java.lang.String (int 2)))
       )
    (let ((p2jProc (invoke (sinvoke "java.lang.Runtime" "getRuntime") "exec" command))
          (retcode (invoke p2jProc "waitFor")))
      (boolean true)
      )
    )
  )
