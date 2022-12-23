ARG final_img_repo=ghcr.io/project8/luna_base
ARG final_img_tag=v1.3.0

ARG img_repo=ghcr.io/project8/luna_base
ARG img_tag=v1.3.0-dev

########################
FROM ${final_img_repo}:${final_img_tag} AS final_base

########################
FROM ${img_repo}:${img_tag} AS base

ARG build_type=Release
ENV KASS_BUILD_TYPE=$build_type

ARG kass_tag=beta
ENV KASS_TAG=${kass_tag}
ENV KASS_BUILD_PREFIX=/usr/local/p8/kassiopeia/${KASS_TAG}

ARG CC_VAL=gcc
ENV CC=${CC_VAL}
ARG CXX_VAL=g++
ENV CXX=${CXX_VAL}

SHELL ["/bin/bash", "-c"]

RUN mkdir -p $KASS_BUILD_PREFIX &&\
    chmod -R 777 $KASS_BUILD_PREFIX/.. &&\
    cd $KASS_BUILD_PREFIX &&\
    echo "source ${COMMON_BUILD_PREFIX}/setup.sh" > setup.sh &&\
    echo "export KASS_TAG=${KASS_TAG}" >> setup.sh &&\
    echo "export KASS_BUILD_PREFIX=${KASS_BUILD_PREFIX}" >> setup.sh &&\
    echo 'ln -sfT $KASS_BUILD_PREFIX $KASS_BUILD_PREFIX/../current' >> setup.sh &&\
    echo 'export PATH=$KASS_BUILD_PREFIX/bin:$PATH' >> setup.sh &&\
    echo 'export LD_LIBRARY_PATH=$KASS_BUILD_PREFIX/lib:$LD_LIBRARY_PATH' >> setup.sh &&\
    echo 'export LD_LIBRARY_PATH=$KASS_BUILD_PREFIX/lib64:$LD_LIBRARY_PATH' >> setup.sh &&\
    /bin/true

########################
FROM base AS build

ARG nproc=4

COPY kassiopeia /tmp_source/kassiopeia

# repeat the cmake command to get the change of install prefix to set correctly (a package_builder known issue)
RUN source $COMMON_BUILD_PREFIX/setup.sh &&\
    cd /tmp_source/kassiopeia &&\
    mkdir build &&\
    cd build &&\
    cmake -D CMAKE_BUILD_TYPE=$KASS_BUILD_TYPE \
          -D CMAKE_INSTALL_PREFIX:STRING=${KASS_BUILD_PREFIX} \ 
          -D CMAKE_INSTALL_LIBDIR:STRING=lib \
          -D BUILD_KASSIOPEIA:BOOL=TRUE \
          -D BUILD_KEMFIELD:BOOL=TRUE \
          -D BUILD_KGEOBAG:BOOL=TRUE \
          -D BUILD_KOMMON:BOOL=TRUE \
          .. &&\
    make -j$nproc install &&\
    /bin/true

########################
FROM final_base

COPY --from=build $KASS_BUILD_PREFIX $KASS_BUILD_PREFIX
