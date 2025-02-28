(ql:quickload :cl-collider)

(in-package :sc-user)
;; Export the functions so they can be imported into other packages
(export '(start-server test-sound test-sound-fm troubleshoot-audio test-loud-sound))
(named-readtables:in-readtable :sc)

;; please check *sc-synth-program*, *sc-plugin-paths*, *sc-synthdefs-path*
;; if you have different path then set to
;;
;; (setf *sc-synth-program* "/path/to/scsynth")
;; (setf *sc-plugin-paths* (list "/path/to/plugin_path" "/path/to/extension_plugin_path"))
;; (setf *sc-synthdefs-path* "/path/to/synthdefs_path")

;; `*s*` defines the server for the entire session
;; functions may use it internally.

;; Function to safely start the server
(defun start-server ()
  (format t "~%Attempting to start SuperCollider server...~%")
  
  ;; First, try to quit any existing server
  (when (boundp '*s*)
    (when *s*
      (format t "Quitting existing server...~%")
      (ignore-errors (server-quit *s*))
      (sleep 1)))  ;; Give it time to shut down
  
  ;; Now try to boot a new server
  (format t "Booting server...~%")
  (setf *s* (make-external-server "localhost" :port 48800))
  (handler-case
      (progn
        (server-boot *s*)
        (format t "Server booted successfully!~%")
        t)  ;; Return true if successful
    (error (e)
      (format t "Error booting server: ~a~%" e)
      (format t "~%TROUBLESHOOTING:~%")
      (format t "1. There might be another SuperCollider server already running.~%")
      (format t "2. Try killing existing servers with: pkill scsynth (in terminal)~%")
      (format t "3. Or use task manager to kill scsynth processes~%")
      (format t "4. Then try running this script again~%")
      nil)))  ;; Return nil if failed

;; in Linux, maybe you need to call this function
;; Commented out to avoid undefined function error
;; #+linux
;; (jack-connect)

;; Hack music - more noticeable sound with frequency modulation
(format t "Creating synth...~%")
(defvar *synth*)
(setf *synth* (play 
               (let* ((freq (+ 440 (sin-osc.kr 0.5 0 100)))  ;; Modulating frequency
                      (sig (sin-osc.ar [freq (+ freq 2)] 0 0.3)))
                 sig)))
(format t "Synth created successfully!~%")
(format t "You should hear a sine wave with changing pitch.~%")

;; Stop music
;; (free *synth*)

;; Quit SuperCollider server
;; (server-quit *s*)

;; Simple test function that creates a synth
(defun test-sound ()
  (format t "~%Testing sound output...~%")
  
  ;; Make sure we have a running server
  (unless (start-server)
    (format t "Cannot test sound without a running server.~%")
    (return-from test-sound nil))
  
  ;; Create a simple synth
  (format t "Creating synth...~%")
  (let ((test-synth (play (sin-osc.ar 440 0 0.3))))
    (format t "Synth created. You should hear a 440 Hz tone.~%")
    (format t "The synth will continue playing until you evaluate (free ~a)~%" test-synth)
    test-synth))

;; More interesting sound with frequency modulation
(defun test-sound-fm ()
  (format t "~%Testing sound with frequency modulation...~%")
  
  ;; Make sure we have a running server
  (unless (start-server)
    (format t "Cannot test sound without a running server.~%")
    (return-from test-sound-fm nil))
  
  ;; Create a more interesting synth
  (format t "Creating FM synth...~%")
  (let ((synth (play 
                (let* ((freq (+ 440 (sin-osc.kr 0.5 0 100)))  ;; Modulating frequency
                       (sig (sin-osc.ar [freq (+ freq 2)] 0 0.3)))
                  sig))))
    (format t "Synth created. You should hear a sine wave with changing pitch.~%")
    (format t "The synth will continue playing until you evaluate (free ~a)~%" synth)
    synth))

;; Troubleshooting function
(defun troubleshoot-audio ()
  (format t "~%AUDIO TROUBLESHOOTING GUIDE:~%")
  (format t "1. Make sure SuperCollider (scsynth) is installed on your system~%")
  (format t "2. Check if your audio output is muted or volume is too low~%")
  (format t "3. Try different audio output devices if available~%")
  (format t "4. On Linux, you might need to configure JACK audio properly~%")
  (format t "5. Check if the paths to SuperCollider are correct:~%")
  (format t "   Current scsynth path: ~a~%" *sc-synth-program*)
  (format t "   Current plugin paths: ~a~%" *sc-plugin-paths*)
  (format t "   Current synthdefs path: ~a~%" *sc-synthdefs-path*)
  (format t "6. Try running SuperCollider directly to test if audio works there~%"))

;; Print instructions
(format t "~%INSTRUCTIONS:~%")
(format t "1. First, kill any existing SuperCollider servers:~%")
(format t "   - In terminal: pkill scsynth~%")
(format t "   - Or use task manager to kill scsynth processes~%")
(format t "2. Then run one of these functions:~%")
(format t "   - (sc-user:test-sound) - Simple 440 Hz tone~%")
(format t "   - (sc-user:test-sound-fm) - Frequency modulated tone~%")
(format t "3. If you still don't hear anything, run (sc-user:troubleshoot-audio)~%")

(format t "~%IMPORTANT: The functions are defined in the SC-USER package.~%")
(format t "To use them from the REPL, either:~%")
(format t "1. Switch to the SC-USER package:~%")
(format t "   (in-package :sc-user)~%")
(format t "   (test-sound)~%")
(format t "2. Or call them with the package prefix:~%")
(format t "   (sc-user:test-sound)~%")

;; Add this function to your file
(defun connect-jack-ports ()
  (format t "Attempting to connect SuperCollider to JACK system outputs...~%")
  (let ((result (ignore-errors 
                  (uiop:run-program 
                   "jack_connect SuperCollider:out_1 system:playback_1 && jack_connect SuperCollider:out_2 system:playback_2"
                   :output :string))))
    (if result
        (format t "Successfully connected to JACK outputs~%")
        (format t "Failed to connect to JACK outputs. You may need to do this manually with qjackctl~%"))))

;; Call this after booting the server
(connect-jack-ports)

;; Add this before booting the server
(defun use-alsa-audio ()
  (format t "Configuring SuperCollider to use ALSA directly...~%")
  (setf *sc-synth-program* "/usr/bin/scsynth")  ;; Adjust path if needed
  (setf *sc-plugin-paths* (list "/usr/lib/SuperCollider/plugins" 
                               "/usr/share/SuperCollider/Extensions"))  ;; Adjust paths
  (setf *sc-synthdefs-path* "/home/yourusername/.local/share/SuperCollider/synthdefs")  ;; Adjust path
  
  ;; Set ALSA as the audio backend
  (setf *sc-server-options*
        (append *sc-server-options*
                (list "-u" "57110" "-a" "1024" "-D" "0" "-R" "0" "-o" "2" "-i" "2" "-z" "128" "-d" "alsa"))))

;; Add this function to your file
(defun test-loud-sound ()
  (format t "~%Testing with a LOUD, noticeable sound...~%")
  
  ;; Make sure we have a running server
  (unless (start-server)
    (format t "Cannot test sound without a running server.~%")
    (return-from test-loud-sound nil))
  
  ;; Create a very noticeable synth
  (format t "Creating LOUD synth...~%")
  (let ((synth (play 
                (let* ((freq (+ 300 (sin-osc.kr 3 0 200)))  ;; Dramatic frequency sweep
                       (amp (line.kr 0 0.8 5))  ;; Gradually increase volume
                       (sig (* amp (saw.ar [freq (+ freq 2)] 0.3))))  ;; Saw wave is harsher than sine
                  sig))))
    (format t "Synth created. You should hear a LOUD sweeping sound.~%")
    (format t "The synth will continue playing until you evaluate (free ~a)~%" synth)
    synth))