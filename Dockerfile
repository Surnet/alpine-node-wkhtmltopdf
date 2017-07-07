# Image
FROM node:6.11.0-alpine

# Environment variables
ENV WKHTMLTOPDF_VERSION=0.12.4

# Copy patches
RUN mkdir -p /tmp/qt-patches
COPY conf/qt-musl.patch /tmp/qt-patches/qt-musl.patch
COPY conf/qt-musl-iconv-no-bom.patch /tmp/qt-patches/qt-musl-iconv-no-bom.patch
COPY conf/qt-recursive-global-mutex.patch /tmp/qt-patches/qt-recursive-global-mutex.patch
COPY conf/qt-font-pixel-size.patch /tmp/qt-patches/qt-font-pixel-size.patch

# Install needed packages
RUN apk add --no-cache \
  glib \
  gtk+ \
  openssl \
&& apk add --no-cache --virtual .build-deps \
  g++ \
  git \
  glib-dev \
  gtk+-dev \
  make \
  mesa-dev \
  openssl-dev \
  patch \

# Download source files
&& git clone --recursive https://github.com/wkhtmltopdf/wkhtmltopdf.git /tmp/wkhtmltopdf \
&& cd /tmp/wkhtmltopdf \
&& git checkout tags/$WKHTMLTOPDF_VERSION \

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
  -fast \
  -release \
  -static \
  -largefile \
  -glib \
  -graphicssystem raster \
  -qt-zlib \
  -qt-libpng \
  -qt-libmng \
  -qt-libtiff \
  -qt-libjpeg \
  -svg \
  -webkit \
  -gtkstyle \
  -xmlpatterns \
  -script \
  -scripttools \
  -openssl-linked \
  -nomake demos \
  -nomake docs \
  -nomake examples \
  -nomake tools \
  -nomake tests \
  -nomake translations \
  -no-qt3support \
  -no-pch \
  -no-icu \
  -no-phonon \
  -no-phonon-backend \
  -no-rpath \
  -no-separate-debug-info \
  -no-dbus \
  -no-opengl \
  -no-openvg \
  -no-accessibility \
  -no-stl \
  -no-opengl \
  -no-declarative \
  -no-sql-ibase \
  -no-sql-mysql \
  -no-sql-odbc \
  -no-sql-psql \
  -no-sql-sqlite \
  -no-sql-sqlite2 \
  -no-mmx \
  -no-3dnow \
  -no-sse \
  -no-sse2 \
  -no-multimedia \
  -no-nis \
  -no-cups \
  -no-nas-sound \
  -no-sm \
  -no-xshape \
  -no-xcursor \
  -no-xfixes \
  -no-xrandr \
  -no-mitshm \
  -no-xinput \
  -no-xkb \
  -no-xsync \
  -no-audio-backend \
  -no-sse3 \
  -no-ssse3 \
  -no-sse4.1 \
  -no-sse4.2 \
  -no-avx \
  -no-neon \
  -exceptions \
  -xrender \
  -iconv \
  -D ENABLE_VIDEO=0 \
&& make --silent \
&& make check \
&& make install \
&& make clean \
&& make distclean \

# Install wkhtmltopdf
&& cd /tmp/wkhtmltopdf \
&& qmake \
&& make --silent \
&& make check \
&& make install \
&& make clean \
&& make distclean \

# Clean up when done
&& rm -rf /tmp/* \
&& apk del .build-deps
