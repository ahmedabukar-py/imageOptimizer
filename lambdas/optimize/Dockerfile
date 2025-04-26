FROM public.ecr.aws/lambda/python:3.10

RUN yum install -y \
    libjpeg-devel \
    zlib-devel \
    freetype-devel \
    zip

RUN pip install Pillow -t /opt/python

WORKDIR /opt

RUN zip -r /tmp/pillow-layer.zip python && echo "Layer built successfully!"

