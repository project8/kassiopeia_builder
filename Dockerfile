ARG final_img_repo=ghcr.io/project8/luna_base
ARG final_img_tag=v1.3.1

ARG build_img_repo=ghcr.io/project8/luna_base
ARG build_img_tag=v1.3.1-dev

########################
FROM ${build_img_repo}:${build_img_tag} AS build

ARG build_type=Release
ARG kass_tag=beta
ARG kass_subdir=kassiopeia

ARG nproc=4

# this variable is redefined in the final image
ENV KASS_PREFIX=${P8_ROOT}/${kass_subdir}/${kass_tag}

RUN mkdir -p $KASS_PREFIX &&\
    chmod -R 777 $KASS_PREFIX/.. &&\
    cd $KASS_PREFIX &&\
    echo "source ${COMMON_PREFIX}/setup.sh" > setup.sh &&\
    echo "export KASS_TAG=${kass_tag}" >> setup.sh &&\
    echo "export KASS_PREFIX=${KASS_PREFIX}" >> setup.sh &&\
    echo 'ln -sfT $KASS_PREFIX $KASS_PREFIX/../current' >> setup.sh &&\
    echo 'export PATH=$KASS_PREFIX/bin:$PATH' >> setup.sh &&\
    echo 'export LD_LIBRARY_PATH=$KASS_PREFIX/lib:$LD_LIBRARY_PATH' >> setup.sh &&\
    echo 'export LD_LIBRARY_PATH=$KASS_PREFIX/lib64:$LD_LIBRARY_PATH' >> setup.sh &&\
    /bin/true

COPY kassiopeia /tmp_source/kassiopeia

# repeat the cmake command to get the change of install prefix to set correctly (a package_builder known issue)
RUN source $KASS_PREFIX/setup.sh &&\
    cd /tmp_source/kassiopeia &&\
    mkdir build &&\
    cd build &&\
    cmake -D CMAKE_BUILD_TYPE=$build_type \
          -D CMAKE_INSTALL_PREFIX:STRING=${KASS_PREFIX} \ 
          -D CMAKE_INSTALL_LIBDIR:STRING=lib \
          -D BUILD_KASSIOPEIA:BOOL=TRUE \
          -D BUILD_KEMFIELD:BOOL=TRUE \
          -D BUILD_KGEOBAG:BOOL=TRUE \
          -D BUILD_KOMMON:BOOL=TRUE \
          .. &&\
    make -j$nproc install &&\
    /bin/true

########################
FROM ${final_img_repo}:${final_img_tag}

COPY --from=build $P8_ROOT $P8_ROOT
