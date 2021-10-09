# Cmd-project

Quickly run the appropriate commands to configure, compile, install
and test your projects whithin emacs. This package relies on the
native package `project.el`, and allows to run all the commands
from anywhere within a project, using a single directory local
variables file at the root of the project (thereafter called
`root` directory locals file')y

Commands can be specified individually for each project and
file type, and can be executed from any path relative to the root
of the project. Commands are evaluated before being run, so they can
also be written in a generic way. All paths are expected to be
relative to the project root.

The test command is assumed to be of the form 'cmd files', where files
is a path to the tests to run, relatively to the point where the command
is being called.

## Usage
Bind the following functions to your convenience, define the command
they should run, and from where in your root director locals file and execute the
commands easily
- `cmd-project-configure`
- `cmd-project-compile`
- `cmd-project-install`
- `cmd-project-test`
- `cmd-project-test-update`

## Example of a configuration
With a project whose root is called `project` containing four
subdirectories `src`, `doc`, `scripts` and `tests`.
the file `project/.dir-locals.el` could be the following
```
((nil . ((cmd-project-configure-cmd .
	(let ((prefix (expand-file-name "~/.local")))
		(concat "./configure --prefix=" prefix)))))
("src" . ((nil . ((cmp-project-compile-cmd . "make")
	(cmd-project-test-cmd . "./run_tests.sh")
		(cmd-project-test-cmd-directory . "tests/")
		(cmd-project-test-files-directory . "tests/"))))
("doc" . ((nil . ((cmp-project-compile-cmd . "latexmk -pdf doc.tex")
	(cmp-project-compile-cmd-directory . "doc/"))))))
```
With this example configuration:
- Calling the `cmd-project-configure` function
from anywhere in the project will run `./configure --prefix=~/.local`
(expanding correctly the `--prefix` argument to give an absolute path)
from the `project` directory.
- Calling the `cmd-project-compile` function from
the `src` project will run` make` from the `project` directory
- Calling the `cmd-project-compile` the `doc` directory will run `latexmk -pdf doc.tex` from
there.
- Calling the `cmd-project-test` function from the
`src` directory will prompt for a file or directory from the folder `project/tests`
and run `./run_tests` from the `project/scripts` directory on the prompted files.
