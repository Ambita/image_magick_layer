
# ImageMagick layer builder for AWS lambda

## Introduction
Run _build_zip.sh_ to build the Docker image and copy a zip file with the layer out of the image.

## Usage

Move the image_magick_layer.zip into a directory for your layer in the SAM source tree.
Add a LayerVersion to the Resources section of your SAM template.yaml:
```
Resources:
  ImageMagickLayer:
    Type: AWS::Serverless::LayerVersion
    Properties:
      ContentUri: image_magick_layer/image_magick_layer.zip
      CompatibleRuntimes:
        - python3.7
```

Add the layer to lambdas that need it in template.yaml:
```
  ExtractPageImages:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: extract_images_from_pdf/
      Handler: extract_images_from_pdf.lambda_handler
      Policies:
        - AWSLambdaExecute
        - Version: "2012-10-17"
          Statement:
            - Effect: Allow
              Action:
                - "s3:GetObject"
              Resource: "arn:aws:s3:::*"
      Runtime: python3.8
      Layers:
        - !Ref ImageMagickLayer
      Environment:
        Variables:
          LD_LIBRARY_PATH: "$LAMBDA_TASK_ROOT/lib:$LAMBDA_TASK_ROOT/lib64:$LAMBDA_RUNTIME_DIR:$LAMBDA_RUNTIME_DIR/lib:$LAMBDA_TASK_ROOT:/opt/lib64:/opt/lib:/usr/lib64:/usr/lib:/lib64:/lib"
```
You need to add /opt/lib64 to LD_LIBRARY_PATH for libraries to be found.

## Verification

### One stop script
Run the script *test.sh* and it will use the docker image to convert test/test.pdf to image-0.png and image-1.png.

*Example output*
```
> ./test.sh
docker cp test/test.pdf 27d5e0bd67f93a957ea6c311660d4f04d7f3b4b8dc2b3ef884145e1eca5d9b99:/tmp/.
docker cp test/convert.sh 27d5e0bd67f93a957ea6c311660d4f04d7f3b4b8dc2b3ef884145e1eca5d9b99:/tmp/.
docker start 27d5e0bd67f93a957ea6c311660d4f04d7f3b4b8dc2b3ef884145e1eca5d9b99
27d5e0bd67f93a957ea6c311660d4f04d7f3b4b8dc2b3ef884145e1eca5d9b99
docker exec 27d5e0bd67f93a957ea6c311660d4f04d7f3b4b8dc2b3ef884145e1eca5d9b99 sh /tmp/convert.sh
docker cp 27d5e0bd67f93a957ea6c311660d4f04d7f3b4b8dc2b3ef884145e1eca5d9b99:/tmp/image-0.png .
docker cp 27d5e0bd67f93a957ea6c311660d4f04d7f3b4b8dc2b3ef884145e1eca5d9b99:/tmp/image-1.png .
docker stop 27d5e0bd67f93a957ea6c311660d4f04d7f3b4b8dc2b3ef884145e1eca5d9b99
27d5e0bd67f93a957ea6c311660d4f04d7f3b4b8dc2b3ef884145e1eca5d9b99
docker rm 27d5e0bd67f93a957ea6c311660d4f04d7f3b4b8dc2b3ef884145e1eca5d9b99
27d5e0bd67f93a957ea6c311660d4f04d7f3b4b8dc2b3ef884145e1eca5d9b99
```
### Manual verification

If you want to manually test the image , run
```
docker run -it image_magick
```
This will open up a bash shell in the image.

Run *docker ps* in a different shell and note the **container id**.

Copy a pdf file into it like this:
```
docker cp  <pdf filename> <container id>:/tmp/test.pdf
```
Replace *<pdf filename>* and *<container_id>* with the actual name of the test file and the **container id** you found with *docker ps*.

Run the following inside the docker image:
```
export GS_LIB=/opt/share/ghostscript/9.06/Resource/Init
export MAGICK_HOME=/opt
export MAGICK_CONFIGURE_PATH=/opt/etc/ImageMagick
export MAGICK_CODER_MODULE_PATH=/opt/lib64/ImageMagick-6.7.8/modules-Q16/coders
export LD_LIBRARY_PATH=/opt/lib64:/opt/lib:/lib64:/usr/lib64:/usr/lib
/opt/bin/convert -density 300 -background white -alpha remove /tmp/test.pdf -quality 100 /tmp/image.png
```

Copy the resulting image out of the container to view it:
```
docker cp  <container id>:/tmp/image.png .
open /tmp/image.png
```
Replace open with your application of choice if either your OS doesn't supporting open or you want to open the image in another application.

### Test Lambda application

First build the new layer with build_zip.sh.
Go to the example directory (cd example).
Build and deploy the application:
```
sam build
sam package --output-template-file package.yaml --s3-bucket <deployment bucket name>
sam deploy --template-file package.yaml --region eu-central-1 --capabilities CAPABILITY_IAM --stack-name image-magick-example
```
Test the application on an image.
```
aws s3 cp ../test/test.pdf s3://imagemagick-test-bucket/pdf/test.pdf
```
After a few seconds, images of the pages will appear in the S3 bucket:
```
aws s3 ls s3://imagemagick-test-bucket/images/
```


## Python3.8
Seems like necessary libraries are not avilable in python3.8 lambda environments so this will only work for 3.7.