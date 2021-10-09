;;; cmd-project.el --- Run commands to manage projects and subprojects -*- lexical-binding: t; -*-

;; Copyright (C) 2021  T. Benjamin

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Quickly run the appropriate commands to configure, compile, install
;; and test your projects whithin emacs. This package relies on the
;; native package 'project.el', and allows to run all the commands
;; from anywhere within a project, using a single directory local
;; variables file at the root of the project (thereafter called
;; 'root directory locals file')y

;; Commands can be specified individually for each project and
;; file type, and can be executed from any path relative to the root
;; of the project. Commands are evaluated before being run, so they can
;; also be written in a generic way. All paths are expected to be
;; relative to the project root.

;; The test command is assumed to be of the form 'cmd files', where files
;; is a path to the tests to run, relatively to the point where the command
;; is being called.

;; Example of a configuration
;; With a project whose root is called 'project' containing four
;; subdirectories 'src', 'doc', 'scripts' and 'tests', the following '.dir-locals.el'
;; file could be placed inside the project:
;; ((nil . ((cmd-project-configure-cmd .
;;				   (let ((prefix (expand-file-name "~/.local")))
;;				     (concat "./configure --prefix=" prefix)))))
;; ("src" . ((nil . ((cmp-project-compile-cmd . "make")
;;		   (cmd-project-test-cmd . "./run_tests.sh")
;;                   (cmd-project-test-cmd-directory . "tests/")
;;                   (cmd-project-test-files-directory . "tests/"))))
;; ("doc" . ((nil . ((cmp-project-compile-cmd . "latexmk -pdf doc.tex")
;;                   (cmp-project-compile-cmd-directory . "doc/"))))))

;; With this example configuration, calling the cmd-project-configure function
;; from anywhere in the project will run "./configure --prefix=$HOME/.local"
;; from the project root, calling the cmd-project-compile function from
;; the 'src' project will run "make" from the project root, and calling the
;; same function from the 'doc' folder will run "latexmk -pdf doc.tex" from
;; that folder. And finally calling the cmd-project-test function from the
;; 'src' folder will prompt for a file or directory from the folder 'tests'
;; and run "./run_tests" from the 'scripts' folder on the prompted files.

;;; Code:

(require 'project)

(defvar cmd-project-configure-cmd "./configure"
  "Configuration command associated to a project or subproject.
Set it in your root directory locals file")
(defvar cmd-project-configure-cmd-directory nil
  "The path from where the configuration command should be run, relatively
to the project root. Set it in your root directory locals file. If not set
the root directory of the project is used.")
(defvar cmd-project-test-cmd "make test"
  "Test command associated to a project or subproject.
  Set it in your root directory locals file")
(defvar cmd-project-test-update-cmd
  "Test update command associated to a project or subproject.
  Set it in your root directory locals file")
(defvar cmd-project-test-cmd-directory nil
  "The path from where the test command should be run, relatively
to the project root. Set it in your root directory locals file. If not set
the root directory of the project is used.")
(defvar cmd-project-test-files-directory nil
  "The path of the test files, relatively to the project root.
Set it in your root directory locals file. If not set
the root directory of the project is used.")
(defvar cmd-project--last-testfiles nil)
(defvar cmd-project-compile-cmd "make"
  "Compilation command associated to a project or subproject.
   Set it in your root directory locals file")
(defvar cmd-project-compile-cmd-directory nil
  "The path from where the compilation command should be run, relatively
to the project root. Set it in your root directory locals file. If not set
the root directory of the project is used.")
(defvar cmd-project-install-cmd "make install"
  "Installation command associated to a project or subproject.
  Set it in your root directory locals file")
(defvar cmd-project-install-cmd-directory nil
  "The path from where the installation command should be run, relatively
to the project root. Set it in your root directory locals file. If not set
the root directory of the project is used.")

(defun cmd-project--navigate (relpath)
  "Navigate to any directory of the project given
a relative path from the project root."
  (concat (project-root (project-current t)) relpath))

(defun cmd-project--select-testfiles ()
  "Select the files to run a test command on"
  (let* (
	 (testdir (concat (project-root (project-current t)) cmd-project-test-files-directory))
	 (testfiles
	  (file-relative-name
	   (read-file-name "Test file:" testdir testdir t)
	   default-directory)))
    (setq cmd-project--last-testfiles
	  (cl-acons (project-current t) testfiles cmd-project--last-testfiles))
    testfiles))

(defun cmd-project-configure ()
  "Run the configuration of the current project or subproject."
  (interactive)
  (let ((default-directory (cmd-project--navigate cmd-project-configure-cmd-directory)))
    (compile (eval cmd-project-configure-cmd))))

(defun cmd-project-test ()
  "Run the testing command of the current project or subproject
   with specified test files."
  (interactive)
  (let* ((default-directory
	   (cmd-project--navigate cmd-project-test-cmd-directory))
	 (testfiles (cmd-project--select-testfiles)))
    (compile (concat (eval cmd-project-test-cmd) " " testfiles))))

(defun cmd-project-quick-retest ()
  "Run the test command of the current project or subproject
   with last testfile."
  (interactive)
  (let ((default-directory
	  (cmd-project--navigate cmd-project-test-cmd-directory))
	(testfiles (alist-get (project-current t) cmd-project--last-testfiles)))
    (compile (concat (eval cmd-project-test-cmd) " " testfiles))))

(defun cmd-project-test-update ()
  "Run the test update command of the current project or subproject
   with specified testfile."
  (interactive)
  (let* ((default-directory
	   (cmd-project--navigate cmd-project-test-cmd-directory))
	 (testfiles (cmd-project--select-testfiles)))
    (compile (concat (eval cmd-project-test-cmd-update) " " testfiles))))

(defun cmd-project-compile ()
  "Run the compilation command of the current project or subproject."
  (interactive)
  (let ((default-directory (cmd-project--navigate cmd-project-compile-cmd-directory)))
    (compile (eval cmd-project-compile-cmd))))

(defun cmd-project-install ()
  "Run the installation command of the current project or subproject."
  (interactive)
  (let ((default-directory (cmd-project--navigate cmd-project-install-cmd-directory)))
    (compile (eval cmd-project-install-cmd))))

(provide 'cmd-project)
