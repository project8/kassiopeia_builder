# kassiopeia_builder
Light wrapper on Kassiopeia to build as a Project 8 Docker contianer

This repository is intended to build a Docker container with Kassiopeia (the project8/kassiopeia fork) built on top of the luna_base container.

Two versions of the container are built, a production version and a development version. 
* The production version includes a Release build of Kassiopeia, and is built on top of the production version of the luna_base container (luna_base tag = vX.Y.Z).  Tags of the kassiopeia_builder container are in the form vX.Y.Z.
* The development version includes a Develop build of Kassiopeia, and is built on top of the development version of the luna_base container (luna_base tag = vX.Y.Z-dev).  Tags of the kassiopeia_builder container are in the form vX.Y.Z-dev.

In practice the container is built and pushed by GitHub Actions when a new tag is created.  The tag should match the tag for the corresponding version of Kassiopeia.  The workflow needs to be triggered manually until a method for automatic triggering is developed (e.g. to trigger automatically when a Kassiopeia tag is created/pushed).
