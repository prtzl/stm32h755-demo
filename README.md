# STM32H755 dual core CMake configuration

This is a test project for STM32H755 dual core (M7 + M4) MCU. I have the Nucleo-144 development board with STM32H755ZIT6 144pin MCU.  

## What I have learned

This MCU has two independant cores with some internal synchronisation. M7 is responsible for clocks and should start first, but after startup the two cores effectively run independently. That's why each core has its own subfolder with core sources including `main.c`.  
Project generates binaries for both cores. Most libraries are shared in folders `Common` and `Drivers`, core specific ones are found in familiar `Core` folder.  

## Configure CMake

Following lines will only configure CMake for each core separately.

```shell
make cmake_cm4
make cmake_cm7
```

## Build

Following lines will build both project or just one of them.

```shell
make -j<threads>
make cm4 -j<threads>
make cm7 -j<threads>
```

## Flash

*TODO*