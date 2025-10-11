# UChicago CS Development Containers

This repository contains a [Development Container](https://containers.dev/) ("dev container") template for UChicago CS courses. It is designed to provide a consistent development environment for students and instructors.

The template is published on the GitHub Container Registry, and can be used with Visual Studio Code or any other tool that supports dev containers. The template URL is the following:

```
ghcr.io/uchicago-cs/devcontainers/cmsc
```

## Dev Container Basics

Dev Containers provide a simple mechanism for you to run a Linux environment on your personal computer, regardless of whether you are running Windows, macOS, or another Linux distrubution. 

If you are familiar with using the CS Linux Servers, you can think of a dev container as having your own personal Linux server running on your computer, but with a few key differences:

- You do not need to connect to the dev container via SSH. Instead, a Linux terminal will be available directly in your code editor (e.g., Visual Studio Code) or via the command line. This also means that you do not need to be connected to the internet to use the dev container (and don't have to deal with connection issues, etc.)
- The dev container will automatically synchronize files between your computer and the dev container, so you can edit files on your computer and run them in the dev container without needing to manually copy files back and forth.
- You have full control over the dev container, including the ability to install additional software, change configuration settings, etc.

Typically, you will launch a dev container from a specific project directory on your computer, effectively allowing to run a Linux terminal in that directory. That container will be specific to that project, and will have access to the files in that directory.  You can create multiple dev containers for different projects, each with its own configuration.

Dev containers are supported by a variety of code editors, which allow you to easily open a terminal in the dev container, edit files, and run commands. There are also command line tools that allow you to manage dev containers without using a specific code editor. We describe both options below.

## Installing and Using the Dev Container

Please see the [User Documentation](docs/user/README.md) for instructions on how to install prerequisite software and use the dev container with Visual Studio Code or from the command line.

