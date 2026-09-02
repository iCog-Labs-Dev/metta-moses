;; ============================================================================
;; External Domain Loader
;; ============================================================================
;;
;; Loads a user-provided .metta domain file into the current MeTTa environment.
;;
;; The path is supplied through:
;;
;;   --domainFile=<path>
;;
;; The external file is expected to define/configure everything required by
;; the generic MOSES action-domain execution path.
;;

(= (load-domain-file)
   (let $file (param domainFile)
      (if (== $file "")
          ()
          (import! &self $file))))
