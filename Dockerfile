# Image
FROM node:6.11.1-alpine

# Environment variables
ENV WKHTMLTOX_VERSION=0.12.4

# Copy patches
RUN mkdir -p /tmp/patches
COPY conf/* /tmp/patches/

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
&& patch -i /tmp/patches/wkhtmltopdf-buildconfig.patch \
&& cd /tmp/wkhtmltopdf/qt \
&& patch -p1 -i /tmp/patches/qt-musl.patch \
&& patch -p1 -i /tmp/patches/qt-musl-iconv-no-bom.patch \
&& patch -p1 -i /tmp/patches/qt-recursive-global-mutex.patch \
&& patch -p1 -i /tmp/patches/qt-font-pixel-size.patch \

# Modify qmake config
&& sed -i "s|-O2|$CXXFLAGS|" mkspecs/common/g++.conf \
&& sed -i "/^QMAKE_RPATH/s| -Wl,-rpath,||g" mkspecs/common/g++.conf \
&& sed -i "/^QMAKE_LFLAGS\s/s|+=|+= $LDFLAGS|g" mkspecs/common/g++.conf \

# Prepare optimal build settings
&& NB_CORES=$(grep -c '^processor' /proc/cpuinfo) \

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
&& make --jobs $(($NB_CORES*2)) --silent \
&& make install \

# Install wkhtmltopdf
&& cd /tmp/wkhtmltopdf \
&& qmake \
&& make --jobs $(($NB_CORES*2)) --silent \
&& make install \
&& make clean \
&& make distclean \

# Uninstall qt
&& cd /tmp/wkhtmltopdf/qt \
&& make uninstall \
&& make clean \
&& make distclean \

# Clean up when done
&& rm -rf /tmp/* \
&& apk del .build-deps
