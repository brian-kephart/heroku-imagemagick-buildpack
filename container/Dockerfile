FROM heroku/heroku:22-build

ENV DEBIAN_FRONTEND=noninteractive

ARG COMPILE_VERSION_LIBDE265=1.0.9
ARG COMPILE_VERSION_LIBAOM=3.5.0
ARG COMPILE_VERSION_LIBHEIF=1.17.6
ARG COMPILE_VERSION_LIBWEBP=1.2.4
ARG COMPILE_VERSION_IMAGEMAGICK=7.1.0-53

RUN apt update
# for building aom
RUN apt install ninja-build

# Install the latest libde265 library
RUN curl -sSL --retry 3 https://github.com/strukturag/libde265/releases/download/v$COMPILE_VERSION_LIBDE265/libde265-$COMPILE_VERSION_LIBDE265.tar.gz | tar zx
WORKDIR /libde265-$COMPILE_VERSION_LIBDE265
RUN ./autogen.sh
RUN ./configure
RUN make -j$(nproc)
RUN make install
RUN ldconfig /usr/local/lib
WORKDIR /

# Install the latest libwebp library
RUN curl -sSL --retry 3 http://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-$COMPILE_VERSION_LIBWEBP.tar.gz | tar zx
WORKDIR /libwebp-$COMPILE_VERSION_LIBWEBP
RUN ./autogen.sh
RUN ./configure --enable-shared --enable-libwebpdecoder --enable-libwebpdemux --enable-libwebpmux --enable-static=no
RUN make -j$(nproc)
RUN make install
RUN ldconfig /usr/local/lib
WORKDIR /

# Install the latest libaom library
# RUN git clone -b v${COMPILE_VERSION_LIBAOM} --depth 1 https://aomedia.googlesource.com/aom
# WORKDIR /build_aom
# RUN cmake ../aom/ -DENABLE_TESTS=0 -DBUILD_SHARED_LIBS=1
# RUN make -j$(nproc)
# RUN make install
# RUN ldconfig /usr/local/lib
# WORKDIR /

# Install the latest libheif library
RUN curl -sSL --retry 3 https://github.com/strukturag/libheif/releases/download/v$COMPILE_VERSION_LIBHEIF/libheif-$COMPILE_VERSION_LIBHEIF.tar.gz | tar zx
WORKDIR /libheif-$COMPILE_VERSION_LIBHEIF/third-party
RUN chmod +x aom.cmd
RUN ./aom.cmd
# https://github.com/strukturag/libheif/blob/e8b33b2359d6fa5100e3890af089f954a2cb59ae/third-party/aom.cmd#L24-L25
RUN export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$(pwd)/aom/dist/lib/pkgconfig
WORKDIR /libheif-$COMPILE_VERSION_LIBHEIF/build
RUN cmake --preset=release-noplugins ..
RUN make -j$(nproc)
RUN make install
RUN ldconfig /usr/local/lib
WORKDIR /

# Get, configure and install ImageMagick
RUN curl -sSL --retry 3 https://github.com/ImageMagick/ImageMagick/archive/refs/tags/$COMPILE_VERSION_IMAGEMAGICK.tar.gz | tar zx
WORKDIR ImageMagick-$COMPILE_VERSION_IMAGEMAGICK
RUN ./configure --prefix=/usr/src/imagemagick --disable-docs --with-avif=yes --with-heic=yes --with-webp=yes --with-tiff=yes --with-openexr=no --with-x=no
RUN make -j$(nproc)
RUN make install
RUN ldconfig /usr/local/lib
WORKDIR /

# Copy shared libraries just compiled
RUN cp -a /usr/local/lib/. /usr/src/imagemagick/lib

# Clean up and compress the build
WORKDIR /usr/src/imagemagick
RUN strip lib/*.a lib/lib*.so*
RUN rm -rf build
RUN mkdir build
RUN tar cjf /usr/src/imagemagick/build/imagemagick.tar.bz2 bin include lib etc share
