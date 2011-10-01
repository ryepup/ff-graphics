;;;; ff-graphics.asd

(asdf:defsystem #:ff-graphics
  :serial t
  :depends-on (#:iterate
               #:alexandria
               #:vecto
               #:lispbuilder-sdl)
  :components ((:file "package")
               (:file "ff-graphics")))

