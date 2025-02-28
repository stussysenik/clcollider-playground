# SuperCollider with Common Lisp (cl-collider)

This project demonstrates using SuperCollider for sound synthesis from Common Lisp using the cl-collider library.

## What is SuperCollider?

SuperCollider is a platform for audio synthesis and algorithmic composition. It consists of two main components:

1. **scsynth** - The synthesis server that actually produces sound
2. **sclang** - The language client that sends commands to the server

These components communicate via Open Sound Control (OSC) messages.

## What is cl-collider?

cl-collider is a Common Lisp client for SuperCollider. It replaces sclang with Common Lisp, allowing you to:

- Control SuperCollider's synthesis engine from Common Lisp
- Define synthesizers and patterns in Lisp syntax
- Integrate sound synthesis with other Lisp applications

In essence, cl-collider lets you use Common Lisp instead of sclang while still using SuperCollider's powerful audio engine.

## Architecture Comparison

Traditional SuperCollider:

# Command to run:

SCSYNTH commands:
1. `scsynth -u 57110`

SBCL commands
1. `XDG_DATA_DIRS="/usr/local/share/:/usr/share/" sbcl`
2. load the file
(sc-user:test-loud-sound)# clcollider-playground
