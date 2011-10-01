;;;; ff-graphics.lisp

(in-package #:ff-graphics)

;;; "ff-graphics" goes here. Hacks and glory await!

(defun %call-with-png-stream-bytes (fn)
  (with-open-stream (s (flex:make-in-memory-output-stream :element-type '(unsigned-byte 8)))
    (funcall fn s)
    (flex:get-output-stream-sequence s)))

(defmacro with-png-stream-bytes ((stream-var) &body body)
  `(%call-with-png-stream-bytes #'(lambda (,stream-var) ,@body)))

(defun frame (w h)
  (with-png-stream-bytes (s)
    (vecto:with-canvas (:width w :height h)
      (vecto:rounded-rectangle 0 0 w h 20 20)
      (vecto:set-gradient-fill 0 0 .8 .8 .8 1 0 h 0 0 0 1 :domain-function 'vecto:bilinear-domain)
      (vecto:fill-path)
      (vecto:save-png-stream s))))

(defun frame-border (w h)
  (with-png-stream-bytes (s)
    (vecto:with-canvas (:width w :height h)
      (vecto:set-line-cap :round)
      (vecto:set-line-join :round)
      (vecto:set-rgb-stroke 1 0 0)
      (vecto:move-to 0 0)
      (vecto:line-to 0 h)
      (vecto:line-to w h)
      (vecto:line-to w 0)
      (vecto:close-subpath)
      (vecto:stroke)
      (vecto:save-png-stream s)
      )
    )
  )

(defun draw-test-window (h w fps step)
  (declare (ignorable h w fps step))
  (sdl:clear-display sdl:*black*)

  
  (sdl:draw-surface-at-* (sdl:load-image (frame (- w 20) 100))
			 10 10)
  (sdl:draw-surface-at-* (sdl:load-image (frame-border (- w 20) 100))
			 10 120)
  
  
  (flet ((pct (val percent) (truncate (* val percent))))
    (sdl:draw-box-* 0 (pct h .85)  w h :color sdl:*blue* )
    (let*	
	((frame (mod step fps)) ;;number from 0->fps, sawtooth wave
	 (frame-pct (/ frame fps)) ;; 0.0->1.0
	 (framex (abs (* 2 (- frame (/ fps 2))))) ;;fps->0->fps
	 (border (truncate (alexandria:lerp (/ framex fps)
					     (pct w .01) (pct w .03)))))
      (sdl:draw-box-* (pct w .01) (+ (pct w .01) (pct h .85))
		      (- w (pct w .01) border) (- (pct h .15) (pct w .02))
		      :color (sdl:color :r 128 :g 128 :b 255) )
      
      
      
      ))
  
  )


(defvar *test-window-thread* nil)
(defun test-window (&key (h 480) (w 640) (fps 30))
  (sdl:with-init ()
    (sdl:window w h)
    (setf (sdl:frame-rate) fps)
    (let ((step 0))
    (sdl:with-events ()
      (:quit-event () t)
      (:video-expose-event () (sdl:update-display))
      (:idle ()
	     (handler-case (progn			     
			     (draw-test-window h w fps step)
			     (incf step)
			     (sdl:update-display))
	       (error (c) (break "error: ~a " c))

	       ))))))
(defun launch-test-window ()
  (setf *test-window-thread*
	(sb-thread:make-thread #'test-window :name "test window")))