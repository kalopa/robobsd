#!/bin/sh
#
#
# Do the setup for building a RoboBSD Vagrant box
boxdir=/tmp/box.$$
mkdir -p $boxdir

#
# Create the VMDK file from the NanoBSD image
vagrant scp :/usr/obj/nanobsd.robobsd/_.disk.full $boxdir/raw.img
qemu-img convert -O vmdk $boxdir/raw.img $boxdir/box-disk1.vmdk

#
# Build the box.ovf file
cat > $boxdir/box.ovf << 'EOF'
<?xml version="1.0"?>
<Envelope ovf:version="1.0" xml:lang="en-US" xmlns="http://schemas.dmtf.org/ovf/envelope/1" xmlns:ovf="http://schemas.dmtf.org/ovf/envelope/1" xmlns:rasd="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData" xmlns:vssd="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_VirtualSystemSettingData" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:vbox="http://www.virtualbox.org/ovf/machine">
  <References>
    <File ovf:href="box-disk1.vmdk" ovf:id="file1"/>
  </References>
  <DiskSection>
    <Info>List of the virtual disks used in the package</Info>
    <Disk ovf:capacity="42949672960" ovf:diskId="vmdisk1" ovf:fileRef="file1" ovf:format="http://www.vmware.com/interfaces/specifications/vmdk.html#streamOptimized" vbox:uuid="0dcae266-d30e-4b47-859d-c9ee307a69f0"/>
  </DiskSection>
  <NetworkSection>
    <Info>Logical networks used in the package</Info>
    <Network ovf:name="NAT">
      <Description>Logical network used by this appliance.</Description>
    </Network>
  </NetworkSection>
  <VirtualSystem ovf:id="vagrant-freebsd">
    <Info>A virtual machine</Info>
    <OperatingSystemSection ovf:id="78">
      <Info>The kind of installed guest operating system</Info>
      <Description>FreeBSD_64</Description>
      <vbox:OSType ovf:required="false">FreeBSD_64</vbox:OSType>
    </OperatingSystemSection>
    <VirtualHardwareSection>
      <Info>Virtual hardware requirements for a virtual machine</Info>
      <System>
        <vssd:ElementName>Virtual Hardware Family</vssd:ElementName>
        <vssd:InstanceID>0</vssd:InstanceID>
        <vssd:VirtualSystemIdentifier>vagrant-freebsd</vssd:VirtualSystemIdentifier>
        <vssd:VirtualSystemType>virtualbox-2.2</vssd:VirtualSystemType>
      </System>
      <Item>
        <rasd:Caption>1 virtual CPU</rasd:Caption>
        <rasd:Description>Number of virtual CPUs</rasd:Description>
        <rasd:ElementName>1 virtual CPU</rasd:ElementName>
        <rasd:InstanceID>1</rasd:InstanceID>
        <rasd:ResourceType>3</rasd:ResourceType>
        <rasd:VirtualQuantity>1</rasd:VirtualQuantity>
      </Item>
      <Item>
        <rasd:AllocationUnits>MegaBytes</rasd:AllocationUnits>
        <rasd:Caption>512 MB of memory</rasd:Caption>
        <rasd:Description>Memory Size</rasd:Description>
        <rasd:ElementName>512 MB of memory</rasd:ElementName>
        <rasd:InstanceID>2</rasd:InstanceID>
        <rasd:ResourceType>4</rasd:ResourceType>
        <rasd:VirtualQuantity>512</rasd:VirtualQuantity>
      </Item>
      <Item>
        <rasd:Address>0</rasd:Address>
        <rasd:Caption>ideController0</rasd:Caption>
        <rasd:Description>IDE Controller</rasd:Description>
        <rasd:ElementName>ideController0</rasd:ElementName>
        <rasd:InstanceID>3</rasd:InstanceID>
        <rasd:ResourceSubType>PIIX4</rasd:ResourceSubType>
        <rasd:ResourceType>5</rasd:ResourceType>
      </Item>
      <Item>
        <rasd:Address>1</rasd:Address>
        <rasd:Caption>ideController1</rasd:Caption>
        <rasd:Description>IDE Controller</rasd:Description>
        <rasd:ElementName>ideController1</rasd:ElementName>
        <rasd:InstanceID>4</rasd:InstanceID>
        <rasd:ResourceSubType>PIIX4</rasd:ResourceSubType>
        <rasd:ResourceType>5</rasd:ResourceType>
      </Item>
      <Item>
        <rasd:AddressOnParent>0</rasd:AddressOnParent>
        <rasd:Caption>disk1</rasd:Caption>
        <rasd:Description>Disk Image</rasd:Description>
        <rasd:ElementName>disk1</rasd:ElementName>
        <rasd:HostResource>/disk/vmdisk1</rasd:HostResource>
        <rasd:InstanceID>5</rasd:InstanceID>
        <rasd:Parent>3</rasd:Parent>
        <rasd:ResourceType>17</rasd:ResourceType>
      </Item>
      <Item>
        <rasd:AddressOnParent>0</rasd:AddressOnParent>
        <rasd:AutomaticAllocation>true</rasd:AutomaticAllocation>
        <rasd:Caption>cdrom1</rasd:Caption>
        <rasd:Description>CD-ROM Drive</rasd:Description>
        <rasd:ElementName>cdrom1</rasd:ElementName>
        <rasd:InstanceID>6</rasd:InstanceID>
        <rasd:Parent>4</rasd:Parent>
        <rasd:ResourceType>15</rasd:ResourceType>
      </Item>
      <Item>
        <rasd:AutomaticAllocation>true</rasd:AutomaticAllocation>
        <rasd:Caption>Ethernet adapter on 'NAT'</rasd:Caption>
        <rasd:Connection>NAT</rasd:Connection>
        <rasd:ElementName>Ethernet adapter on 'NAT'</rasd:ElementName>
        <rasd:InstanceID>7</rasd:InstanceID>
        <rasd:ResourceSubType>E1000</rasd:ResourceSubType>
        <rasd:ResourceType>10</rasd:ResourceType>
      </Item>
    </VirtualHardwareSection>
    <vbox:Machine ovf:required="false" version="1.12-linux" uuid="{73ddb494-e4f8-499a-bd14-43afc51caae4}" name="vagrant-freebsd" OSType="FreeBSD_64" snapshotFolder="Snapshots" lastStateChange="2015-07-15T16:47:25Z">
      <ovf:Info>Complete VirtualBox machine configuration in VirtualBox format</ovf:Info>
      <ExtraData>
        <ExtraDataItem name="GUI/LastCloseAction" value="PowerOff"/>
        <ExtraDataItem name="GUI/LastGuestSizeHint" value="720,400"/>
        <ExtraDataItem name="GUI/LastNormalWindowPosition" value="1218,217,720,449"/>
      </ExtraData>
      <Hardware version="2">
        <CPU count="1" hotplug="false">
          <HardwareVirtEx enabled="true"/>
          <HardwareVirtExNestedPaging enabled="true"/>
          <HardwareVirtExVPID enabled="true"/>
          <HardwareVirtExUX enabled="true"/>
          <PAE enabled="false"/>
          <HardwareVirtExLargePages enabled="false"/>
          <HardwareVirtForce enabled="false"/>
        </CPU>
        <Memory RAMSize="512" PageFusion="false"/>
        <HID Pointing="PS2Mouse" Keyboard="PS2Keyboard"/>
        <HPET enabled="false"/>
        <Chipset type="PIIX3"/>
        <Boot>
          <Order position="1" device="DVD"/>
          <Order position="2" device="HardDisk"/>
          <Order position="3" device="None"/>
          <Order position="4" device="None"/>
        </Boot>
        <Display VRAMSize="17" monitorCount="1" accelerate3D="false" accelerate2DVideo="false"/>
        <VideoCapture/>
        <RemoteDisplay enabled="false" authType="Null"/>
        <BIOS>
          <ACPI enabled="true"/>
          <IOAPIC enabled="true"/>
          <Logo fadeIn="true" fadeOut="true" displayTime="0"/>
          <BootMenu mode="MessageAndMenu"/>
          <TimeOffset value="0"/>
          <PXEDebug enabled="false"/>
        </BIOS>
        <USBController enabled="false" enabledEhci="true"/>
        <Network>
          <Adapter slot="0" enabled="true" MACAddress="080027FAE441" cable="true" speed="0" type="82540EM">
            <DisabledModes/>
            <NAT>
              <DNS pass-domain="true" use-proxy="false" use-host-resolver="false"/>
              <Alias logging="false" proxy-only="false" use-same-ports="false"/>
            </NAT>
          </Adapter>
          <Adapter slot="1" enabled="false" MACAddress="0800279C6CA8" cable="true" speed="0" type="82540EM">
            <DisabledModes>
              <NAT>
                <DNS pass-domain="true" use-proxy="false" use-host-resolver="false"/>
                <Alias logging="false" proxy-only="false" use-same-ports="false"/>
              </NAT>
            </DisabledModes>
          </Adapter>
          <Adapter slot="2" enabled="false" MACAddress="0800274C63F9" cable="true" speed="0" type="82540EM">
            <DisabledModes>
              <NAT>
                <DNS pass-domain="true" use-proxy="false" use-host-resolver="false"/>
                <Alias logging="false" proxy-only="false" use-same-ports="false"/>
              </NAT>
            </DisabledModes>
          </Adapter>
          <Adapter slot="3" enabled="false" MACAddress="080027A80B3C" cable="true" speed="0" type="82540EM">
            <DisabledModes>
              <NAT>
                <DNS pass-domain="true" use-proxy="false" use-host-resolver="false"/>
                <Alias logging="false" proxy-only="false" use-same-ports="false"/>
              </NAT>
            </DisabledModes>
          </Adapter>
          <Adapter slot="4" enabled="false" MACAddress="0800271EBC9E" cable="true" speed="0" type="82540EM">
            <DisabledModes>
              <NAT>
                <DNS pass-domain="true" use-proxy="false" use-host-resolver="false"/>
                <Alias logging="false" proxy-only="false" use-same-ports="false"/>
              </NAT>
            </DisabledModes>
          </Adapter>
          <Adapter slot="5" enabled="false" MACAddress="08002704BAFA" cable="true" speed="0" type="82540EM">
            <DisabledModes>
              <NAT>
                <DNS pass-domain="true" use-proxy="false" use-host-resolver="false"/>
                <Alias logging="false" proxy-only="false" use-same-ports="false"/>
              </NAT>
            </DisabledModes>
          </Adapter>
          <Adapter slot="6" enabled="false" MACAddress="080027F8D00A" cable="true" speed="0" type="82540EM">
            <DisabledModes>
              <NAT>
                <DNS pass-domain="true" use-proxy="false" use-host-resolver="false"/>
                <Alias logging="false" proxy-only="false" use-same-ports="false"/>
              </NAT>
            </DisabledModes>
          </Adapter>
          <Adapter slot="7" enabled="false" MACAddress="080027B96595" cable="true" speed="0" type="82540EM">
            <DisabledModes>
              <NAT>
                <DNS pass-domain="true" use-proxy="false" use-host-resolver="false"/>
                <Alias logging="false" proxy-only="false" use-same-ports="false"/>
              </NAT>
            </DisabledModes>
          </Adapter>
        </Network>
        <UART>
          <Port slot="0" enabled="false" IOBase="0x3f8" IRQ="4" hostMode="Disconnected"/>
          <Port slot="1" enabled="false" IOBase="0x2f8" IRQ="3" hostMode="Disconnected"/>
        </UART>
        <LPT>
          <Port slot="0" enabled="false" IOBase="0x378" IRQ="7"/>
          <Port slot="1" enabled="false" IOBase="0x378" IRQ="7"/>
        </LPT>
        <AudioAdapter controller="AC97" driver="Pulse" enabled="false"/>
        <RTC localOrUTC="local"/>
        <SharedFolders/>
        <Clipboard mode="Disabled"/>
        <DragAndDrop mode="Disabled"/>
        <IO>
          <IoCache enabled="true" size="5"/>
          <BandwidthGroups/>
        </IO>
        <HostPci>
          <Devices/>
        </HostPci>
        <EmulatedUSB>
          <CardReader enabled="false"/>
        </EmulatedUSB>
        <Guest memoryBalloonSize="0"/>
        <GuestProperties>
          <GuestProperty name="/VirtualBox/HostInfo/GUI/LanguageID" value="en_US" timestamp="1436978552901969000" flags=""/>
        </GuestProperties>
      </Hardware>
      <StorageControllers>
        <StorageController name="IDE" type="PIIX4" PortCount="2" useHostIOCache="true" Bootable="true">
          <AttachedDevice type="HardDisk" port="0" device="0">
            <Image uuid="{0dcae266-d30e-4b47-859d-c9ee307a69f0}"/>
          </AttachedDevice>
          <AttachedDevice passthrough="false" type="DVD" port="1" device="0"/>
        </StorageController>
      </StorageControllers>
    </vbox:Machine>
  </VirtualSystem>
</Envelope>
EOF

#
# Now build the Vagrantfile
cat > $boxdir/Vagrantfile << 'EOF'
Vagrant::Config.run do |config|
  # This Vagrantfile is auto-generated by `vagrant package` to contain
  # the MAC address of the box. Custom configuration should be placed in
  # the actual `Vagrantfile` in this box.
  config.vm.base_mac = "080027FAE441"
end

# Load include vagrant file if it exists after the auto-generated
# so it can override any of the settings
include_vagrantfile = File.expand_path("../include/_Vagrantfile", __FILE__)
load include_vagrantfile if File.exist?(include_vagrantfile)
EOF

#
# Finally, tar the bits together to make the Vagrant box
(cd $boxdir && tar cvzf $HOME/robobsd.box box.ovf Vagrantfile box-disk1.vmdk)
rm -rf $boxdir
exit 0
