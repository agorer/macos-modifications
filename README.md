Allows using the MacOS Terminal preference `Use Option as Meta key` without losing the ability too write the symbols associated with option+<number>.

It is possible to launch it at start up using an Automator.app script but some issues have to be taken into account:

- Launching it in the background.
- Redirecting executable output.
- Give accesibility permission to the automator script and the executable.

Right now spanish keyboard keycodes are used. Within the source code there are instructions to add more keycodes.
