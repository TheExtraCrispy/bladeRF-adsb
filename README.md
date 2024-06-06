# bladeRF VHDL ADS-B decoder core

![bladeRF-adsb](https://raw.githubusercontent.com/Nuand/bladeRF-adsb/master/images/bladerf_adsb.png)
dump1090 visualizing the output of the bladeRF ADS-B VHDL decoder.

This repository contains all of the neccessary files to simulate, and build the ADS-B core. A multipart tutorial series detailing the implementation of the ADS-B core can be found [here](http://nuand.com/adsb).

# Theory of operation

The ADS-B decoder decodes signals directly in the FPGA as opposed to on a CPU. The hardware acceleration gains are used to increase the range of the ADS-B receiver by performing operations that could not run in realtime even on a recent Intel i7. The decoder attempts to detect and resolve many bit errors and correct for packet collisions; features that up until now have only been available in commercial ADS-B decoders.

The ADS-B decoder runs on the FPGA, and sends fully decoded messages whose CRC pass to libbladeRF. The bladeRF-adsb user-mode utility that is found in this repository takes the decoded messages and sends them to a dump1090 server listening on port 30001. dump1090 can then be used to visualize the location of planes (as can be seen in the screenshot above).

The decoder runs on any bladeRF including the [bladeRF x40](https://www.nuand.com/blog/product/bladerf-x40/) and [bladeRF x115](https://www.nuand.com/blog/product/bladerf-x115/). Any low noise amplifier works with the bladeRF, however there is a bladeRF specific LNA available, the [XB-300](https://www.nuand.com/blog/product/amplifier/).


# Installation

## Install libbladeRF and bladeRF-cli.

The bladeRF project repository, [https://github.com/Nuand/bladeRF](bladeRF), contains [installation guides](https://github.com/Nuand/bladeRF/wiki#Getting_Started) for most operating systems.

## Install and run dump1090-fa

Information about dump1090 and it's installation can be found on the [project's Github](https://github.com/flightaware/dump1090.git).

Once dump1090-fa is installed, run it configured to accept raw data packets on port 30001 in net only mode:

````
$ dump1090-fa --net-only --raw --interactive
````

Once dump1090 is running visit the HTTP server setup by dump1090 at [http://localhost:8080](/http://localhost:8080/)

## Fetch latest source and bitstreams, and run bladeRF-adsb

````
$ git clone https://github.com/Nuand/bladeRF-adsb
$ cd bladeRF-adsb/bladeRF_adsb
$ wget http://nuand.com/fpga/adsbx40.rbf
$ wget http://nuand.com/fpga/adsbx115.rbf
$ wget http://nuand.com/fpga/adsbxA4.rbf
$ wget http://nuand.com/fpga/adsbxA5.rbf
$ wget http://nuand.com/fpga/adsbxA9.rbf
$ make
$ ./bladeRF_adsb
````

This will compile and run the user-mode utility that interfaces with the VHDL decoder. The user-mode program loads the prebuilt ADS-B decoder FPGA image. As soon as a message is received from the FPGA it is displayed to the command line and also transmitted to dump1090 for visualization. Once messages get displayed in the command line, they will appear on the local dump1090 HTTP server.

# Building ADS-B image

The ADS-B decoder is a core that substantially modifies the operation of the bladeRF FPGA. The core has its own FPGA revision called "adsb" separate from the normal "hosted" image. To compile the core, fetch a recent snapshot of the existing bladeRF repository. Afterwards, clone this repository in to hdl/fpga/ip/nuand.

````
$ git clone http://github.com/Nuand/bladeRF.git
$ cd bladeRF
$ cd hdl/fpga/ip/nuand
$ git clone http://github.com/Nuand/bladeRF-adsb.git adsb
````

Once the repository is setup, use the standard [FPGA build directions](https://github.com/Nuand/bladeRF/tree/master/hdl) to build the ADS-B decoder image.

````
$ ./build_bladerf.sh -r adsb -b bladeRF -s 40
````

And if building for an x115,

````
$ ./build_bladerf.sh -r adsb -b bladeRF -s 115
````

And for the bladeRF 2.0 micro,
````
$ ./build_bladerf.sh -r adsb -b bladeRF-micro -s A4
$ ./build_bladerf.sh -r adsb -b bladeRF-micro -s A5
$ ./build_bladerf.sh -r adsb -b bladeRF-micro -s A9
````

## Usage

Run the script as
 
```
./bladerf_adsb
```

Arguments can be provided for setting the LNA, vga1, vga2, and unified gain.

The first argument sets the script to use unified gain, or  sets the LNA power. The LNA options are 'min', 'mid' and 'max'


The second argument is an integer that either sets the unified gain level or vga1, depending on the first argument.

The third argument sets vga2, and should not be provided in unified gain mode.

Ex: This starts the script with the default unified gain of 35:

```
./bladerf_adsb unified
```

This specified a unified gain of 60

```
./bladerf_adsb unified 60
```

This sets the LNA to mid, and vga1 and 2 to 35

```
./bladerf_adsb mid 35 35
```

#Note
If you run the install script, the executable should be moved to your PATH, so (i think) you can forgo the './'

# Service

I put a service file in here (that mostly works i think) so the script can be ran on startup.

It also has a config file which is used to provide the parameters to the script when it autoruns.

I tried to make it more portable with a shady script. It creates a config file and moves things around so that they can be accessed with absolute paths

You can run it with
```
sudo ./install.sh a1 a2 a3
```
Where a1-3 are the 3 arguments you can optionally add on startup. 

(The sudo is because the locations are protected) ((Not a virus i promise))

Once the script is finished, you can activate the service with
```
sudo systemctl daemon-reload
sudo systemctl enable bladeRF-adsb.service
```
