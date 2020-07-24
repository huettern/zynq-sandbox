# MYiR Tech Z-turn board 

Mfc. part number: MYS-7Z010-C-S

## Clocks

| Name       | Generator       | Connection  | Pkg | Description |
|:-----------|:----------------|:------------|:----|:------------|
| `hdmi_clk` | 12M Clock X2    | IO_B34_LP11 | U14 |             |
| `ps_clk`   | 33.33M Clock X1 | PS_CLK_500  | E7  |             |

## Components

| Component                 | Part                 | Connection                                     |
|:--------------------------|:---------------------|:-----------------------------------------------|
| DDR                       | 2x MT41K256M16TW-107 | DDR                                            |
| QSPI                      | W25Q128BVFIG         | QSP0I                                          |
| Ethernet                  | AR8035               | RGMII0                                         |
| USB                       | USB3320C             | USB0                                           |
| HDMI                      | SIL9022A + TPD12S016 | PL                                             |
| Temperature Sensor        | STLM75               | I2C1, `MEMS_INTn` = IO_L23P_T3_34, N17           |
| MEMS 3 Axis Accelerometer | ADXL345              | I2C1, `MEMS_INTn`                              |
| CAN                       | TJA1050              | CAN0                                           |
| Beeper                    |                      | `BP`, IO_L23N_T3_34, P18                       |
| SDCARD                    | TXS02612RTWR         | SDIO0                                          |
| UART                      | CP2103               | UART1                                          |
| PS LEDs                   |                      | `PS_USER_LED1` MIO0, `PS_USER_LED2` MIO9       |
| PL LEDs                   | RGB                  | IO_B34_LN6 (R), IO_B34_LP7 (G), IO_B34_LN7 (B) |
| PL DIP Switch             | DIP Switch           | IO_B34_0, IO_B34_25, IO_B35_0, IO_B35_25       |
| PS Button                 | Button               | PS_MIO50_501 B13                               |

## DDR
Part: 2x MT41K256M16TW-107
Target timing:  tRCD-tRP-CL

> **TABLE DEPERCATED**

| Vivado Propoerty         | Datasheet Symbol | Value     |
|:-------------------------|:-----------------|:----------|
| Memory Type              |                  | DDR3      |
| Memory Part              |                  | Custom    |
| Effective DRAM Bus Width |                  | 32 Bit    |
| Burst Length             |                  | 8 ?       |
| DDR                      |                  | 533.333 ? |
| IC Bus Width             |                  | 16        |
| Device Capacity          |                  | 256Meg    |
| Speed Bin                | Speed Grade      | 1600K     |
| Bank Address Count       |                  | 3         |
| Row Address Count        |                  | 15        |
| Col Address Count        |                  | 10        |
| CAS Laatency             | CL               | 11        |
| CAS Write Latency        | CWL              | 8         |
| RAS to CAS Delay         | tRCD             | 11        |
| Precharge Time           | tRP              | 11        |
| tRC                      | tRC              | >48.75ns  |
| tRASmin                  | tRAS             | >35ns     |
| tFAW                     | tFAW             | 32        |


