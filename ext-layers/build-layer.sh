#!/bin/bash
export PKG_DIR="python/lib/python3.9/site-packages"
cd ext-layers
rm -rf ${PKG_DIR} && mkdir -p ${PKG_DIR}

docker run --rm -v $(pwd):/foo -w /foo public.ecr.aws/sam/build-python3.9 pip3 install -r "${1}_requirements.txt" -t ${PKG_DIR}

zip -r "${1}_lambda_layer.zip" python

rm -rf python
```