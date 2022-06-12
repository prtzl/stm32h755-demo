# STM32H755 dual core CMake configuration

This is a test project for STM32H755 dual core (M7 + M4) MCU. I have the Nucleo-144 development board with STM32H755ZIT6 144pin MCU.  

## What I have learned

This MCU has two independant cores with some internal synchronisation. M7 is responsible for clocks and should start first, but after startup the two cores effectively run independently. That's why each core has its own subfolder with core sources including `main.c`.  
Project generates binaries for both cores. Most libraries are shared in folders `Common` and `Drivers`, core specific ones are found in familiar `Core` folder.  

## Build

Following lines will (re)build both projects.

```shell
make -j<threads>
```

You can also just configure CMake:

``shell
make cmake
```

## Flash

Observing reference manual [`RM0399`](https://www.st.com/resource/en/reference_manual/rm0399-stm32h745755-and-stm32h747757-advanced-armbased-32bit-mcus-stmicroelectronics.pdf) on page **144**; default boot configuration when booting from flash memory (BOOT = 0) is:
 * CM7 boots from memory location `0x08000000` or the first Flash memory bank. Size is 1MB.  
   This is also the usual flash address on other single core STM32s.
 * CM4 boots from memory location `0x08100000` or the second Flash memory bank. Size is 1MB.

We can just flash each core separately with a flashing utility. Using cross platform [stlink](https://github.com/stlink-org/stlink) utility is very simple. I would also include `--reset` only on CM7 when flashing both. That way, CM4 waits for CM7 to be flashed and reset.  

```shell
st-flash write CM4/build/project-cm4.bin 0x08100000
st-flash --reset write CM7/build/project-cm7.bin 0x08000000
```

Or just run make command to flash both at once. It will also check build status.

```shell
make flash
```

### Regarding flash order and booting

Dual core MCUs have some internal synchronisation when booting. This is because, among other things, CM7 is one responsible to handle clock domain configuration. That's why CM4 core has a piece of code at the beginning that disables the core until CM7 has booted and allowed CM4 to continue booting as well. This section looks like this:

```c
HAL_HSEM_ActivateNotification(__HAL_HSEM_SEMID_TO_MASK(HSEM_ID_0));
HAL_PWREx_ClearPendingEvent();
HAL_PWREx_EnterSTOPMode(PWR_MAINREGULATOR_ON, PWR_STOPENTRY_WFE, PWR_D2_DOMAIN);
__HAL_HSEM_CLEAR_FLAG(__HAL_HSEM_SEMID_TO_MASK(HSEM_ID_0));
```

After this section, CM4 `HAL_Init()` and peripheral init functions are placed.  

CM7 has the following section after `HAL_Init()` and `SystemClock_Config()`:

```c
timeout = 0xFFFF;
while((__HAL_RCC_GET_FLAG(RCC_FLAG_D2CKRDY) == RESET) && (timeout-- > 0));
if ( timeout < 0 )
{
  Error_Handler();
}
```

After this section, core peripherals are initialized.  

If you don't have the cores in sync, both will be stuck in endless loop. To avoid that, flash first CM4 and then CM7 with reset as described above.  

**NOTE:** Currently I am having the following error when flashing the CM4:

```shell
ERROR common.c: Verification of flash failed at offset: 0
```

Flashing CM7 is fine.
