FROM ubuntu:focal

RUN apt-get update && \
    apt-get install -yq tzdata && \
    ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# Install base packages
RUN apt-get update && \
        apt-get install -y apt-utils ssh git wget build-essential zlib1g-dev \
        ca-certificates apt-transport-https gnupg software-properties-common \
        python3-pip unzip

# Install CMake
RUN wget -O - "https://apt.kitware.com/keys/kitware-archive-latest.asc" 2>/dev/null | apt-key add - && \
        apt-add-repository "deb https://apt.kitware.com/ubuntu/ bionic main" && \
        apt-get update && \
        apt-get install -y cmake


# Install MSP430-GCC and support files
ENV MSP430_GCC_VERSION 9.3.1.11
ENV MSP430_GCC_SUPPORT_VERSION 1.212
RUN mkdir -p /opt/ti
RUN wget "http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSPGCC/latest/export/msp430-gcc-${MSP430_GCC_VERSION}_linux64.tar.bz2" && \
        wget "http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSPGCC/9_3_1_2/export/msp430-gcc-support-files-${MSP430_GCC_SUPPORT_VERSION}.zip" && \
        tar xf msp430-gcc-${MSP430_GCC_VERSION}_linux64.tar.bz2 && \
        unzip msp430-gcc-support-files-${MSP430_GCC_SUPPORT_VERSION}.zip && \
        mv msp430-gcc-${MSP430_GCC_VERSION}_linux64 /opt/ti/msp430-gcc && \
        mkdir -p /opt/ti/msp430-gcc/include && \
        mv msp430-gcc-support-files/include/* /opt/ti/msp430-gcc/include/ && \
        rm msp430-gcc-${MSP430_GCC_VERSION}_linux64.tar.bz2 && \
        rm msp430-gcc-support-files-${MSP430_GCC_SUPPORT_VERSION}.zip && \
        rm -rf msp430-gcc-support-files
ENV PATH /opt/ti/msp430-gcc/bin:$PATH
ENV MSP430_TOOLCHAIN_PATH /opt/ti/msp430-gcc

# Install packages for UniFlash
RUN apt-get update && \
        apt-get install -y libusb-0.1-4 libgconf-2-4 gdb

# Install UniFlash
ENV UNIFLASH_VERSION=7.0.0.3615
RUN wget "http://software-dl.ti.com/ccs/esd/uniflash/uniflash_sl.${UNIFLASH_VERSION}.run" && \
        chmod +x uniflash_sl.${UNIFLASH_VERSION}.run && \
        ./uniflash_sl.${UNIFLASH_VERSION}.run --unattendedmodeui none --mode unattended --prefix /opt/ti/uniflash && \
        rm uniflash_sl.${UNIFLASH_VERSION}.run && \
        cd /opt/ti/uniflash/TICloudAgentHostApp/install_scripts && \
        mkdir -p /etc/udev/rules.d && \
        cp 70-mm-no-ti-emulators.rules /etc/udev/rules.d/72-mm-no-ti-emulators.rules && \
        cp 71-ti-permissions.rules /etc/udev/rules.d/73-ti-permissions.rules && \
        ln -sf /lib/x86_64-linux-gnu/libudev.so.1 /lib/x86_64-linux-gnu/libudev.so.0

# Install Doxygen
RUN apt-get install -y doxygen

# Install Sphinx and related modules
RUN pip3 install sphinx breathe sphinx-rtd-theme
