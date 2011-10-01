;;;; ff-graphics.asd

(asdf:defsystem #:ff-graphics
  :serial t
  :depends-on (#:iterate
               #:alexandria
               #:vecto
	       #:flexi-streams
               #:lispbuilder-sdl)
  :components ((:file "package")
               (:file "ff-graphics")))

