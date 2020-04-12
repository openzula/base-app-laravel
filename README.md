# openzula/base-app-laravel
This Docker image is most likely not useful to anybody except for us! It provides a base image to serve our Laravel
applications using PHP-FPM.

## Prerequisites
There are no prerequisites.

## Deployment
This image is intended to be used as a base only and not to be ran directly. Instead you should create and build your
own image using our standard directory structure as follows:

```
./build
-- aws
---- app.dockerfile
./src
-- app
-- bootstrap
-- config
-- ...
```

The `./build/aws/app.dockerfile` should as a minimum contain the following instructions, however it could of course
contain any further instructions that you require:

```dockerfile
FROM openzula/base-app-laravel:latest
```

Then build the image by running the following command in the top most directly of your project:

```shell script
docker build -f build/aws/app.dockerfile -t example/app .
```

## Configuration
There are no environmental variables to configure this image.

## License
This project is licensed under the BSD 3-clause license - see [LICENSE.md](LICENSE.md) file for details.
