# TASK 4.3
## I2C 

I2C (Inter-Integrated Circuit, eye-squared-C), alternatively known as I2C or IIC, is a synchronous, multi-controller/multi-target (controller/target), packet switched, single-ended, serial communication bus invented in 1982 by Philips Semiconductors. It is widely used for attaching lower-speed peripheral ICs to processors and microcontrollers in short-distance, intra-board communication.
![image](https://user-images.githubusercontent.com/42721310/177541587-a57ff048-6818-409c-9136-b95b960f7587.png)


### STM32 I2C
The I2C (inter-integrated circuit) bus interface handles communications between the
microcontroller and the serial I2C bus. It provides multimaster capability, and controls all I2C
bus-specific sequencing, protocol, arbitration and timing. It supports Standard-mode (Sm),
Fast-mode (Fm) and Fast-mode Plus (Fm+).

It is also SMBus (system management bus) and PMBus (power management bus) compatible.

DMA can be used to reduce CPU overload.

![image](https://user-images.githubusercontent.com/42721310/177541704-76094856-d736-490e-8cb4-461225b053e0.png)

##### Mode selection

The interface can operate in one of the four following modes:
• Slave transmitter
• Slave receiver
• Master transmitter
• Master receiver
By default, it operates in slave mode. The interface automatically switches from slave to
master when it generates a START condition, and from master to slave if an arbitration loss
or a STOP generation occurs, allowing multimaster capability

##### Communication flow

In Master mode, the I2C interface initiates a data transfer and generates the clock signal. A
serial data transfer always begins with a START condition and ends with a STOP condition.
Both START and STOP conditions are generated in master mode by software.
In Slave mode, the interface is capable of recognizing its own addresses (7 or 10-bit), and
the General Call address. The General Call address detection can be enabled or disabled
by software. The reserved SMBus addresses can also be enabled by software.
Data and addresses are transferred as 8-bit bytes, MSB first. The first byte(s) following the
START condition contain the address (one in 7-bit mode, two in 10-bit mode). The address
is always transmitted in Master mode.
A 9th clock pulse follows the 8 clock cycles of a byte transfer, during which the receiver must
send an acknowledge bit to the transmitter. Refer to the following figure.

![image](https://user-images.githubusercontent.com/42721310/177541831-3e17bd14-3421-4a6d-98ee-c1da892e360d.png)

### Activation and Using I2C with extension board

![image](https://user-images.githubusercontent.com/42721310/177542212-9b31b43d-4a36-4df9-9c18-bbbd56894ede.png)

GPIO SETTING AND APH BUS ACTIVATION
![image](https://user-images.githubusercontent.com/42721310/177566840-37b6e3f4-5f80-4d31-9870-4f27e04ce7ec.png)

```
    __HAL_RCC_GPIOB_CLK_ENABLE();
    /**I2C1 GPIO Configuration
    PB7     ------> I2C1_SDA
    PB8     ------> I2C1_SCL
    */
    GPIO_InitStruct.Pin = GPIO_PIN_7|GPIO_PIN_8;
    GPIO_InitStruct.Mode = GPIO_MODE_AF_OD;
    GPIO_InitStruct.Pull = GPIO_NOPULL;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_HIGH;
    GPIO_InitStruct.Alternate = GPIO_AF1_I2C1;
    HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

  
```
I2C SETTING
```
      /*Peripheral clock enable*/
      __HAL_RCC_I2C1_CLK_ENABLE();
  	  
      hi2c1.Instance = I2C1;
  	  hi2c1.Init.Timing = 0x0000020B;
  	  hi2c1.Init.OwnAddress1 = 0;
  	  hi2c1.Init.AddressingMode = I2C_ADDRESSINGMODE_7BIT;
  	  hi2c1.Init.DualAddressMode = I2C_DUALADDRESS_DISABLE;
  	  hi2c1.Init.OwnAddress2 = 0;
  	  hi2c1.Init.OwnAddress2Masks = I2C_OA2_NOMASK;
  	  hi2c1.Init.GeneralCallMode = I2C_GENERALCALL_DISABLE;
  	  hi2c1.Init.NoStretchMode = I2C_NOSTRETCH_DISABLE;
  	  HAL_I2C_Init(&hi2c1);
```
# The Sensor

On the extension board, there is a sensor which called [AltIMU](https://www.pololu.com/product/2469), which can measure barometer, gyroscope, accelerametor and magnometer. 

In this task we will use barometer [LPS331AP](https://www.pololu.com/file/0J622/LPS331AP.pdf) and magnometer and accelerametor [LSM303D](https://www.pololu.com/file/0J703/LSM303D.pdf)

### The Sensor Check

In the sensors, there is a "WHO_AM_I" register, which help to user idetifed sensor. So, we will start to identifty our sensor at first.

```
uint8_t ret,ret1;
int16_t fat = 0;

void read_who_am_i()
{
	HAL_StatusTypeDef status,status1;
	
	status = HAL_I2C_IsDeviceReady(&hi2c1, (LPS331AP_ADDR), 4, 100);
	status1 = HAL_I2C_IsDeviceReady(&hi2c1, (LSM303D_ADDR), 4, 100);

// In the debug mode, users can read the inside of register via ret and ret1
   
   HAL_I2C_Mem_Read(&hi2c1, LPS331AP_ADDR, LPS331AP_WHO_AM_I, 1, &ret, sizeof(fat), HAL_MAX_DELAY);
    HAL_I2C_Mem_Read(&hi2c1, LSM303D_ADDR, LSM303D_WHO_AM_I, 1, &ret1, sizeof(fat), HAL_MAX_DELAY);

// if the user able to reach register in a correct way, then LED will turn on
   
   if(status == HAL_OK){
    	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, GPIO_PIN_SET);
    	if(status1 == HAL_OK)
    	{
    		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_1, GPIO_PIN_SET);
    	}
    }

}

```


### The Sensor Data Fetch

1) We should the select our specified data from sensor in order to obtain accurate data.
2) In the task request to create a class
3) From this class we will fetch the data
```
class write_read_data
{
	public:
		void write_reg(uint8_t reg, uint8_t value)
		{
		HAL_I2C_Mem_Write(&hi2c1, LSM303D_ADDR, reg, 1, &value, sizeof(value), HAL_MAX_DELAY);
		}

	 	 void write_reg2(uint8_t reg, uint8_t value)
		{
			HAL_I2C_Mem_Write(&hi2c1, LPS331AP_ADDR, reg, 1, &value, sizeof(value), HAL_MAX_DELAY);
		}


	   int16_t read_value(uint8_t reg)
		{
			int16_t value = 0;
			uint8_t lo, hi;
			HAL_I2C_Mem_Read(&hi2c1, LSM303D_ADDR, reg, 1, &lo, sizeof(value), HAL_MAX_DELAY);
			HAL_I2C_Mem_Read(&hi2c1, LSM303D_ADDR, reg + 1, 1, &hi, sizeof(value), HAL_MAX_DELAY);
			value = (hi<<8) + lo;
			return value;
		}

		int16_t read_value2(uint8_t reg)
			{
				uint32_t value = 0;
				uint8_t lo, hi, xl;

				HAL_I2C_Mem_Read(&hi2c1, LPS331AP_ADDR, reg, 1, &xl, sizeof(value), HAL_MAX_DELAY);
				HAL_I2C_Mem_Read(&hi2c1, LPS331AP_ADDR, reg + 1, 1, &lo, sizeof(value), HAL_MAX_DELAY);
				HAL_I2C_Mem_Read(&hi2c1, LPS331AP_ADDR, reg + 2, 1, &hi, sizeof(value), HAL_MAX_DELAY);


				value = ((hi<<16) + (lo<<8)  +xl) / 4096;
				return value;
			}
};

```
Under the main function, the setting of sensor should be done
```
   write_read_data w_r;

	 w_r.write_reg(LSM303D_CTRL1, 0x47); // AODR2 (25Hz) | AXEN | AYEN | AZEN
	HAL_Delay(100);
	 w_r.write_reg(LSM303D_CTRL5, 0x90); // TEMP_EN | M_ODR2 (50Hz)
	 HAL_Delay(100);
	 w_r.write_reg(LSM303D_CTRL7, 0x00); // TEMP_EN | M_ODR2 (50Hz)
	 HAL_Delay(100);
	 w_r.write_reg2(LPS331AP_CTRL1 , 0xC0); // Active Mode | M_ODR2 (25Hz)

```
#### Accelerometer and Magnetometer Register Setting  
CTRL1 (20h)

![image](https://user-images.githubusercontent.com/42721310/178079439-ec77ca60-3f28-47fe-996b-08c8d358a4b5.png)

![image](https://user-images.githubusercontent.com/42721310/178079489-2ffde105-9266-4b50-ab9b-de83baa4b0e1.png)

CTRL5(24H)

![image](https://user-images.githubusercontent.com/42721310/178079528-bf09e01a-31a3-4ccb-b254-98fdf7f86ce4.png)

![image](https://user-images.githubusercontent.com/42721310/178079551-fdf791e4-7903-4158-9963-56fa24c50b19.png)

CTRL7(26h)

![image](https://user-images.githubusercontent.com/42721310/178079588-12126997-5286-4aae-8387-a3ef6a420b89.png)

![image](https://user-images.githubusercontent.com/42721310/178079604-f28dd0d4-c06d-47bd-b7be-8e640848c12e.png)

All others settings in the default mode.

#### Barometer Register Setting

![image](https://user-images.githubusercontent.com/42721310/178476115-6cda8ed9-11e5-4cf2-a709-82e7dc89aabf.png)

![image](https://user-images.githubusercontent.com/42721310/178476150-a3265ead-1b8a-41d2-9c7f-07769a53745e.png)


All others settings in the default mode.


##### Read Out The Data and Process It

We should do that inside of the while(1) loop in order to obtain constant data via sensors.

1) Acquiring the raw data

```
                 //Temperature from LSM303D
		 
		 temp = w_r.read_value(LSM303D_TEMP_OUT);
		 
		 //Acceleromter
		 
		 a_xRaw = w_r.read_value(LSM303D_OUT_X_A);
		 a_yRaw = w_r.read_value(LSM303D_OUT_Y_A);
		 a_zRaw = w_r.read_value(LSM303D_OUT_Z_A);
		
		//Magnometer
		 
		 m_Rawx = w_r.read_value(OUT_X_L_M );
		 m_Rawy = w_r.read_value(OUT_Y_L_M );
		 m_Rawz = w_r.read_value(OUT_Z_L_M );
		
		//Barometer
		 
		 p_RawPre = w_r.read_value2(LPS331AP_PRESS_OUT_XL);
		 

```

2) After acquiring the raw data we should proccess because it is not in human readable format

![image](https://user-images.githubusercontent.com/42721310/178494843-583c8993-4cf1-4de7-be90-745a4296f153.png)

convert the RAW values into acceleration in 'mg' we have to multiply according to the Full scale value set in FS_SEL. So I am multiplying by 0.061, this number can be changed according to the requirements of the user via CTRL2 and we are using the default value , and dividing to 1000 to acquire 'g' value.
              
```


		 a_x = (a_xRaw * 0.061f) / 1000;
		 a_y = (a_yRaw * 0.061f) / 1000;
		 a_z = (a_zRaw * 0.061f) / 1000;
```
convert the RAW values into magnometer in 'mgauss' we have to multiply according to the Full scale value set in FS_SEL. So I am multiplying by 0.1601, this number can be changed according to the requirements of the user via CTRL6 and we are using the default value, and dividing to 1000 to acquire 'gauss' value.
```
		 m_x = (a_xRaw * 0.1601f) / 1000;
		 m_y = (a_yRaw * 0.160f) / 1000;
		 m_z = (a_zRaw * 0.160f) / 1000;

```

![image](https://user-images.githubusercontent.com/42721310/178494449-abf289cd-5a3d-49f2-a47a-74eadbdd133b.png)


![image](https://user-images.githubusercontent.com/42721310/178652449-30164b0d-5a1c-4a37-bc5b-68de4c32c8ce.png)

#### Reference

[STM32 Reference Manual](https://www.st.com/resource/en/reference_manual/rm0091-stm32f0x1stm32f0x2stm32f0x8-advanced-armbased-32bit-mcus-stmicroelectronics.pdf)

[Wiki]( https://en.wikipedia.org/wiki/I%C2%B2C#:~:text=I2C%20(Inter%2DIntegrated,in%201982%20by%20Philips%20Semiconductors )
