## Developer's instructions

|      Name      |    SID     | Contribution ratio |                      Work                       |
| :------------: | :--------: | :----------------: | :---------------------------------------------: |
| Ruixiang Jiang | $12111611$ |       $33\%$       | ALU, IFetch, CPUTop, Led, Switch, Set, Document |
|  Yujing Zhang  | $12111944$ |       $33\%$       |                                                 |
|   Yilun Qiu    | $12013005$ |       $33\%$       |                                                 |

## Version modification record

-   v$1.0$(05-14): Basic modules completed
-   v$1.1$(05-20): Top module completed

## CPU architecture design specification

-   CPU Features
    -   Instruction set architecture
        Registers: number = $32$, width = $32$
        Exception handling:  
        <img src="/Users/jrx/课程资料/CS202/Computer-Organization-Project-Spring-2023/ISA.png" style="zoom: 50%;" />
    -   Address space design
        - Architecture: Harvard architecture
        - Addressing unit: Byte
        - Instruction space: $0x00000000$ ~ $0xFFFFFFFF$
        - Data space: $0x00000000$ ~ $0xFFFFFC00$
    -   External I/O devices: none
    -   CPI: single cycle CPU
-   CPU interface
    -   Clock: Built-in clock interface of EGO1 development board
    -   Reset: R1 of EGO1 development board