FROM debian:10

# Step 1: Install tools for building EPICS Base
RUN apt update
RUN apt install --yes build-essential

# Step 2: Build EPICS Base
ADD epics-base-R3.15.9.tar.gz opt/epics
RUN mv /opt/epics/epics-base-R3.15.9 /opt/epics/base
RUN make -j -C /opt/epics/base

# Step 3: Install tools for building synApps
RUN apt install --yes libusb-dev libusb-1.0-0-dev libxext-dev re2c

# Step 4: Build synApps
ADD synApps_6_0.tar.gz /opt
RUN mv /opt/synApps/support /opt/epics/synApps
RUN sed 's/\/home\/oxygen40\/KLANG\/Documents\/synApps\/support/\/opt\/epics\/synApps/' -i /opt/epics/synApps/configure/RELEASE
RUN sed 's/\/APSshare\/epics\/base-3.15.5/\/opt\/epics\/base/' -i /opt/epics/synApps/configure/RELEASE
RUN make -j -C /opt/epics/synApps release
RUN make -j -C /opt/epics/synApps

# Step 5: Build epics-base.deb package
ADD base-skel /root/epics-base
RUN mv /opt/epics/base /root/epics-base/opt/epics
RUN dpkg-deb --build /root/epics-base

# Step 6: Build epics-synApps.deb package
ADD synApps-skel /root/epics-synApps
RUN mv /opt/epics/synApps /root/epics-synApps/opt/epics
RUN dpkg-deb --build /root/epics-synApps

# Step 7: Copy packages to host system
CMD cp /root/*.deb /mnt/host
