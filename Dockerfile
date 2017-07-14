# Image
FROM node:6.11.1-alpine

# Environment variables
ENV WKHTMLTOX_VERSION=0.12.4

# Copy patches
RUN mkdir -p /tmp/qt-patches
COPY conf/qt-musl.patch /tmp/qt-patches/qt-musl.patch
COPY conf/qt-musl-iconv-no-bom.patch /tmp/qt-patches/qt-musl-iconv-no-bom.patch
COPY conf/qt-recursive-global-mutex.patch /tmp/qt-patches/qt-recursive-global-mutex.patch
COPY conf/qt-font-pixel-size.patch /tmp/qt-patches/qt-font-pixel-size.patch

# Install needed packages
RUN apk add --no-cache \
  gtk+ \
&& apk add --no-cache --virtual .build-deps \
  g++ \
  git \
  gtk+-dev \
  make \
  mesa-dev \
  patch \

# Download source files
&& git clone --recursive https://github.com/wkhtmltopdf/wkhtmltopdf.git /tmp/wkhtmltopdf \
&& cd /tmp/wkhtmltopdf \
&& git checkout tags/$WKHTMLTOX_VERSION \

# Apply patches
&& cd /tmp/wkhtmltopdf/qt \
&& patch -p1 -i /tmp/qt-patches/qt-musl.patch \
&& patch -p1 -i /tmp/qt-patches/qt-musl-iconv-no-bom.patch \
&& patch -p1 -i /tmp/qt-patches/qt-recursive-global-mutex.patch \
&& patch -p1 -i /tmp/qt-patches/qt-font-pixel-size.patch \

# Modify qmake config
&& sed -i "s|-O2|$CXXFLAGS|" mkspecs/common/g++.conf \
&& sed -i "/^QMAKE_RPATH/s| -Wl,-rpath,||g" mkspecs/common/g++.conf \
&& sed -i "/^QMAKE_LFLAGS\s/s|+=|+= $LDFLAGS|g" mkspecs/common/g++.conf \

# Install qt
&& ./configure -confirm-license -opensource \
  -prefix /usr \
  -datadir /usr/share/qt \
  -sysconfdir /etc \
  -plugindir /usr/lib/qt/plugins \
  -importdir /usr/lib/qt/imports \
  -silent \
  -release \
  -static \
  -fast \
  -webkit \
  -script \
  -svg \
  -exceptions \
  -xmlpatterns \
  -no-largefile \
  -no-accessibility \
  -no-stl \
  -no-sql-ibase \
  -no-sql-mysql \
  -no-sql-odbc \
  -no-sql-psql \
  -no-sql-sqlite \
  -no-sql-sqlite2 \
  -no-qt3support \
  -no-opengl \
  -no-openvg \
  -no-system-proxies \
  -no-multimedia \
  -no-audio-backend \
  -no-phonon \
  -no-phonon-backend \
  -no-javascript-jit \
  -no-scripttools \
  -no-declarative \
  -no-declarative-debug \
  -no-mmx \
  -no-3dnow \
  -no-sse \
  -no-sse2 \
  -no-sse3 \
  -no-ssse3 \
  -no-sse4.1 \
  -no-sse4.2 \
  -no-avx \
  -no-neon \
  -no-openssl \
  -no-rpath \
  -no-nis \
  -no-cups \
  -no-pch \
  -no-dbus \
  -no-separate-debug-info \
  -no-gtkstyle \
  -no-nas-sound \
  -no-opengl \
  -no-openvg \
  -no-sm \
  -no-xshape \
  -no-xvideo \
  -no-xsync \
  -no-xinerama \
  -no-xcursor \
  -no-xfixes \
  -no-xrandr \
  -no-mitshm \
  -no-xinput \
  -no-xkb \
  -no-glib \
  -nomake demos \
  -nomake docs \
  -nomake examples \
  -nomake tools \
  -nomake tests \
  -nomake translations \
  -graphicssystem raster \
  -qt-zlib \
  -qt-libpng \
  -qt-libmng \
  -qt-libtiff \
  -qt-libjpeg \
  -optimized-qmake \
  -iconv \
  -xrender \
  -fontconfig \
  -D ENABLE_VIDEO=0 \
&& make --jobs 20 --silent \
&& make --jobs 20 install \

# Install wkhtmltopdf
&& cd /tmp/wkhtmltopdf \
&& qmake \
&& make --jobs 20 --silent \
&& make --jobs 20 install \
&& make --jobs 20 clean \
&& make --jobs 20 distclean \

# Uninstall qt
&& cd /tmp/wkhtmltopdf/qt \
&& make --jobs 20 uninstall \
&& make --jobs 20 clean \
&& make --jobs 20 distclean \

# Clean up when done
&& rm -rf /tmp/* \
&& apk del .build-deps
