----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    06:57:24 11/19/2022 
-- Design Name: 
-- Module Name:    CrazyBox - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CrazyBox is
    Port ( R : out  STD_LOGIC;--vgapp
           G : out  STD_LOGIC;--vga
           B : out  STD_LOGIC;--vga
           Hsync : out  STD_LOGIC;--vga
           Vsync : out  STD_LOGIC;--vga
           PlayerDown : in  STD_LOGIC;--push button bawah
           PlayerUp : in  STD_LOGIC;--push button atas
           Start : in  STD_LOGIC;--switch button
			  Hard : in STD_LOGIC;--switch button
           clk : in  STD_LOGIC;--clock bawaan xilink spartan 3e
			  rst: in STD_LOGIC);--button kiri
end CrazyBox;

architecture Behavioral of CrazyBox is

signal halfClock: STD_LOGIC;
signal horizontalPosition : integer range 0 to 800 :=0;
signal verticalPosition : integer range 0 to 512 :=0;
signal hsyncEnable :STD_LOGIC;
signal vsyncEnable :STD_LOGIC;

--warna

signal color: STD_LOGIC_VECTOR (2 downto 0) :="000";
signal photonX : integer range 0 to 640 :=0;
signal photonY : integer range 0 to 480 :=0;

--kotak
constant kotakX : integer :=100;
signal kotakY : integer range 0 to 480 :=400;

--batasup
constant batasUpX : integer :=320;
constant batasUpY : integer :=10;

--batasdown

constant batasDownX : integer :=320;
constant batasDownY : integer :=470;

--penghalang1

constant penghalang1Y : integer :=300;
signal penghalang1X : integer range 0 to 640 :=340;

--penghalang2

constant penghalang2Y : integer :=200;
signal penghalang2X : integer range 0 to 640 :=493;

--penghalang3


constant penghalang3Y : integer :=400;
signal penghalang3X : integer range 0 to 640 :=632;

--penghalang4

constant penghalang4Y : integer :=250;
signal penghalang4X : integer range 0 to 640 :=640;

--penghalang5

constant penghalang5Y : integer :=120;
signal penghalang5X : integer range 0 to 640 :=510;

--penghalang6
constant penghalang6Y : integer := 55;
signal penghalang6X : integer range 0 to 640 := 550;

--counter gerak lurus
signal kotakMovementClockCounter : integer range 0 to 1000000 :=0;
signal kotakMovementClock : STD_LOGIC :='0';
SIGNAL upkotak : INTEGER :=250;
--counter gerak penghalang
signal penghalangMovementClockCounter : integer range 0 to 1000000 :=0;
signal penghalangMovementClock : STD_LOGIC :='0';
signal gameOver : STD_LOGIC :='0';
signal stoppenghalang : STD_LOGIC :='0';

begin

--half the clock

	clockScaler : process(clk)
	begin
		if clk'event and clk='1' then
			halfClock<=not halfClock;
		end if;
	end process clockScaler;
--mengatur kecepatan penghalang
	penghalangMovementClockScaler : process(clk)
	begin
		if clk'event and clk='1' then
			penghalangMovementClockCounter <= penghalangMovementClockCounter+4;
			if (penghalangMovementClockCounter =500000) then 
				penghalangMovementClock <=not penghalangMovementClock;
				penghalangMovementClockCounter <=0;
			end if;
		end if;
	end process penghalangMovementClockScaler;
--mengatur kecepatan kotak
kotakMovementClockScaler : process(clk)
	begin 
	if clk'event and clk ='1' then
		kotakMovementClockCounter <=kotakMovementClockCounter +2;
		if(kotakMovementClockCounter = 100000) then
			kotakMovementClock <= not kotakMovementClock;
			kotakMovementClockCounter<=0;
		end if;
	end if;
end process kotakMovementClockScaler;

signalTiming: process(halfClock)
	begin
		if halfClock'event and halfClock ='1' then
		if rst = '0' then
			if horizontalPosition =800 then
				horizontalPosition <=0;
				verticalPosition <= verticalPosition+1;
				if verticalPosition =512 then
					verticalPosition <=0;
				else
					verticalPosition <= verticalPosition+1;
				end if;
			else
				horizontalPosition <= horizontalPosition+1;
			end if;
		elsif rst = '1' then
			verticalPosition <=0;
			horizontalPosition <=0;
		end if;
		end if;
	end process signalTiming;
vgaSync : process(halfClock,horizontalPosition,verticalPosition)
	begin
		if halfClock'event and halfClock ='1' then
			if horizontalPosition >0 and horizontalPosition<97 then
				hsyncEnable <='0';
			else
				hsyncEnable <='1';
			end if;
			
			if verticalPosition >0 and verticalPosition <3 then
				vsyncEnable <='0';
			else
				vsyncEnable <='1';
			end if;
		end if;
	end process vgaSync;
		
coordinates : process(horizontalPosition,verticalPosition)
	begin
		photonX<= horizontalPosition -144;
		photonY<= verticalPosition -31;
	end process coordinates;
-- akhir dari game
finishGame : process(kotakY, penghalang1X,penghalang2X,penghalang3X)
	begin
	--restart
		if rst = '1' then
			gameOver<='0';
			stoppenghalang <= '0';
		end if;
	--penghalang 1
		if penghalang1X >=110 and penghalang1X <=170 then
			if kotakY >=penghalang1Y-15 and kotakY<=penghalang1Y +15 then
				gameOver <='1';
				stoppenghalang <='1';
			end if;
			
	--penghalang 2
		elsif penghalang2X >= 110 and penghalang2X<=160 then
			if kotakY >=penghalang2Y - 15 and kotakY <= penghalang2Y + 15 then
				gameOver<='1';
				stoppenghalang <='1';
			end if;
	
	--penghalang 3
	
		elsif penghalang3X>=110 and penghalang3X <=170 then
			if kotakY >= penghalang3Y - 15 and kotakY <= penghalang3Y + 15 then
				gameOver <= '1';
				stoppenghalang <= '1';
			end if;
			
	--penghalang 4
		elsif penghalang4X >=110 and penghalang4X <= 160 then
			if kotakY >= penghalang4Y -15 and kotakY <= penghalang4Y  + 15 then
				gameOver <= '1';
				stoppenghalang <= '1';
			end if;
	
	--penghalang 5
		elsif penghalang5X >=110 and penghalang5X <=160 then
			if kotakY >= penghalang5Y - 15 and kotakY <= penghalang5Y + 15 then
				gameOver <= '1';
				stoppenghalang <= '1';
			end if;
			
	--penghalang 6
		elsif penghalang6X >= 110 and penghalang6X <= 160 then
			if kotakY >= penghalang6Y - 15 and kotakY <= penghalang6Y + 15 then
				gameOver <= '1';
				stoppenghalang <= '1';
			end if;
			
	--batasUP
		elsif kotakY <= batasUpY + 20 and kotakY >= batasUpY - 10 then
			gameOver <='1';
			stoppenghalang <='1';
	
	--batas bawah
		elsif kotakY >= batasDownY - 20 and kotakY <= batasDownY + 10 then
			gameOver <='1';
			stoppenghalang <='1';
		
	end if;
end process finishGame;

--pembentukan tampilan
colorSetter : process (photonX,photonY,halfClock,penghalang1X,penghalang2x,penghalang3X,kotakY)
	begin
		if gameOver = '0' and Hard ='0' then
			--difficult
			--if Hard = '0' then
				--easy
				--E
				if photonX >=30 and photonX<=35 and
				photonY >=40 and photonY <=80 then
						color <= "000";
				elsif photonX >=30 and photonX<=65 and
				photonY >=40 and photonY <=45 then
					color <= "000";
				elsif photonX >=30 and photonX<=65 and
				photonY >=57 and photonY <=62 then
					color <= "000";
				elsif photonX >=30 and photonX<=65 and
				photonY >=75 and photonY <=80 then
					color <= "000";
				--A
				elsif photonX >=75 and photonX<=80 and
				photonY >=40 and photonY <=80 then
						color <= "000";
				elsif photonX >=80 and photonX<=120 and
				photonY >=40 and photonY <=45 then
					color <= "000";
				elsif photonX >=80 and photonX<=120 and
				photonY >=57 and photonY <=62 then
					color <= "000";
				elsif photonX >=120 and photonX<=125 and
				photonY >=40 and photonY <=80 then
					color <= "000";
				--S
				elsif photonX >=135 and photonX<=175 and
				photonY >=40 and photonY <=45 then
						color <= "000";
				elsif photonX >=135 and photonX<=140 and
				photonY >=40 and photonY <=62 then
					color <= "000";
				elsif photonX >=135 and photonX<=175 and
				photonY >=57 and photonY <=62 then
					color <= "000";
				elsif photonX >=170 and photonX<=175 and
				photonY >=62 and photonY <=80 then
					color <= "000";
				elsif photonX >=135 and photonX<=175 and
				photonY >=75 and photonY <=80 then
					color <= "000";
				--Y
				elsif photonX >=185 and photonX<=190 and
				photonY >=40 and photonY <=60 then
						color <= "000";
				elsif photonX >=185 and photonX<=205 and
				photonY >=55 and photonY <=60 then
					color <= "000";
				elsif photonX >=205 and photonX<=225 and
				photonY >=55 and photonY <=60 then
					color <= "000";
				elsif photonX >=220 and photonX<=225 and
				photonY >=40 and photonY <=60 then
					color <= "000";
				elsif photonX >=202 and photonX<=207 and
				photonY >=60 and photonY <=80 then
					color <= "000";
	
		--penghalang1
			elsif photonX >=penghalang1X -40 and photonX <= penghalang1X + 30 and
			photonY >= penghalang1Y - 20 and photonY <= penghalang1Y +20 then
				color <="000";
		--penghalang2
			elsif photonX >= penghalang2X - 30 and photonX <= penghalang2X + 30 and
			photonY >= penghalang2Y - 20 and photonY <= penghalang2Y + 20 then
				color <="000";
		--penghalang3
			elsif photonX >= penghalang3X - 40 and photonX <= penghalang3X + 40 and
			photonY >= penghalang3Y -25 and photonY <= penghalang3y +25 then
				color <="000";
		--penghalang4
			elsif photonX >=  penghalang4X - 30 and photonX <= penghalang4X + 30 and 
			photonY >= penghalang4Y - 20 and photonY <= penghalang4Y + 20 then
				color <= "000";
		--penghalang5
			elsif photonX >=  penghalang5X - 40 and photonX <= penghalang5X + 40 and 
			photonY >= penghalang5Y - 20 and photonY <= penghalang5Y + 20 then
				color <= "000";
		--penghalang6
			elsif photonX >=  penghalang6X - 40 and photonX <= penghalang6X + 40 and 
			photonY >= penghalang6Y - 20 and photonY <= penghalang6Y + 20 then
				color <= "000";
		--batasup
			elsif photonX >= batasUpX -320 and photonX <= batasUpX +320 and
			photonY <= batasUpY + 20 and photonY >=batasUpY -10 then 
				color <= "011";
		--batasDown
			elsif photonX >= batasDownX - 320 and photonX <= batasDownX +320 and
			photonY >= batasDownY - 20 and photonY <=batasDownY + 10 then 
				color <= "011";
		--kotak
			elsif photonX >=kotakX -30 and photonX <= kotakX + 30 and
			photonY >= kotakY -20 and photonY <= kotakY + 20 then
				color <="100";
		--backgroud
			else 
				color <= "111";
			end if;
			
		elsif gameOver = '0' and Hard ='1' then
			if photonX >=30 and photonX<=35 and
				photonY >=40 and photonY <=80 then
						color <= "000";
				elsif photonX >=30 and photonX<=75 and
				photonY >=57 and photonY <=62 then
					color <= "000";
				elsif photonX >=70 and photonX<=75 and
				photonY >=40 and photonY <=80 then
					color <= "000";
				--A
				elsif photonX >=85 and photonX<=90 and
				photonY >=40 and photonY <=80 then
						color <= "000";
				elsif photonX >=90 and photonX<=130 and
				photonY >=40 and photonY <=45 then
					color <= "000";
				elsif photonX >=90 and photonX<=130 and
				photonY >=57 and photonY <=62 then
					color <= "000";
				elsif photonX >=130 and photonX<=135 and
				photonY >=40 and photonY <=80 then
					color <= "000";
				--R
				elsif photonX >=145 and photonX<=150 and
				photonY >=40 and photonY <=80 then
						color <= "000";
				elsif photonX >=150 and photonX<=190 and
				photonY >=40 and photonY <=45 then
					color <= "000";
				elsif photonX >=150 and photonX<=190 and
				photonY >=57 and photonY <=62 then
					color <= "000";
				elsif photonX >=185 and photonX<=190 and
				photonY >=40 and photonY <=62 then
					color <= "000";
				elsif photonX >=175 and photonX<=180 and
				photonY >=60 and photonY <=80 then
					color <= "000";
				--D
				elsif photonX >=200 and photonX<=205 and
				photonY >=60 and photonY <=80 then
						color <= "000";
				elsif photonX >=200 and photonX<=240 and
				photonY >=57 and photonY <=62 then
					color <= "000";
				elsif photonX >=200 and photonX<=240 and
				photonY >=75 and photonY <=80 then
					color <= "000";
				elsif photonX >=235 and photonX<=240 and
				photonY >=40 and photonY <=80 then
					color <= "000";	

		--penghalang1
			elsif photonX >=penghalang1X -40 and photonX <= penghalang1X + 30 and
			photonY >= penghalang1Y - 20 and photonY <= penghalang1Y +20 then
				color <="000";
		--penghalang2
			elsif photonX >= penghalang2X - 30 and photonX <= penghalang2X + 30 and
			photonY >= penghalang2Y - 20 and photonY <= penghalang2Y + 20 then
				color <="000";
		--penghalang3
			elsif photonX >= penghalang3X - 40 and photonX <= penghalang3X + 40 and
			photonY >= penghalang3Y -25 and photonY <= penghalang3y +25 then
				color <="000";
		--penghalang4
			elsif photonX >=  penghalang4X - 30 and photonX <= penghalang4X + 30 and 
			photonY >= penghalang4Y - 20 and photonY <= penghalang4Y + 20 then
				color <= "000";
		--penghalang5
			elsif photonX >=  penghalang5X - 40 and photonX <= penghalang5X + 40 and 
			photonY >= penghalang5Y - 20 and photonY <= penghalang5Y + 20 then
				color <= "000";
		--penghalang5
			elsif photonX >=  penghalang6X - 40 and photonX <= penghalang6X + 40 and 
			photonY >= penghalang6Y - 20 and photonY <= penghalang6Y + 20 then
				color <= "000";
		--batasup
			elsif photonX >= batasUpX -320 and photonX <= batasUpX +320 and
			photonY <= batasUpY + 20 and photonY >=batasUpY -10 then 
				color <= "011";
		--batasDown
			elsif photonX >= batasDownX - 320 and photonX <= batasDownX +320 and
			photonY >= batasDownY - 20 and photonY <=batasDownY + 10 then 
				color <= "011";
		--kotak
			elsif photonX >=kotakX -30 and photonX <= kotakX + 30 and
			photonY >= kotakY -20 and photonY <= kotakY + 20 then
				color <="100";
		--backgroud
			else 
				color <= "111";
			end if;
			
			else
			--game over
			--G
				if photonX >=220 and photonX<=230 and
				photonY >=115 and photonY <=180 then
					color <= "111";
				elsif photonX >=225 and photonX<=255 and
				photonY >=110 and photonY <=120 then
					color <= "111";
				elsif photonX >=250 and photonX<=260 and
				photonY >=115 and photonY <=125 then
					color <= "111";
				elsif photonX >=225 and photonX<=255 and
				photonY >=175 and photonY <=185 then
					color <= "111";
				elsif photonX >=250 and photonX<=260 and
				photonY >=145 and photonY <=180 then
					color <= "111";
				elsif photonX >=235 and photonX<=260 and
				photonY >=145 and photonY <=155 then
					color <= "111";
				--A
				elsif photonX >=270 and photonX<=280 and
				photonY >=115 and photonY <=185 then
					color <= "111";
				elsif photonX >=275 and photonX<=305 and
				photonY >=110 and photonY <=120 then
					color <= "111";
				elsif photonX >=270 and photonX<=305 and
				photonY >=140 and photonY <=150 then
					color <= "111";
				elsif photonX >=300 and photonX<=310 and
				photonY >=115 and photonY <=185 then
					color <= "111";
				--M
				elsif photonX >=320 and photonX<=330 and
				photonY >=115 and photonY <=185 then
					color <= "111";
				elsif photonX >=340 and photonX<=350 and
				photonY >=115 and photonY <=185 then
					color <= "111";
				elsif photonX >=360 and photonX<=370 and
				photonY >=115 and photonY <=185 then
					color <= "111";
				elsif photonX >=325 and photonX<=365 and
				photonY >=110 and photonY <=120 then
					color <= "111";
				--E
				elsif photonX >=380 and photonX<=390 and
				photonY >=110 and photonY <=185 then
					color <= "111";
				elsif photonX >=380 and photonX<=410 and
				photonY >=110 and photonY <=125 then
					color <= "111";
				elsif photonX >=380 and photonX<=410 and
				photonY >=143 and photonY <=153 then
					color <= "111";
				elsif photonX >=380 and photonX<=410 and
				photonY >=170 and photonY <=185 then
					color <= "111";	
				--O
				elsif photonX >=210 and photonX<=250 and
				photonY >=235 and photonY <=245 then
					color <= "111";
				elsif photonX >=210 and photonX<=250 and
				photonY >=285 and photonY <=295 then
					color <= "111";
				elsif photonX >=205 and photonX<=215 and
				photonY >=240 and photonY <=290 then
					color <= "111";
				elsif photonX >=245 and photonX<=255 and
				photonY >=240 and photonY <=290 then
					color <= "111";
				--V
				elsif photonX >=270 and photonX<=280 and
				photonY >=235 and photonY <=275 then
					color <= "111";
				elsif photonX >=310 and photonX<=320 and
				photonY >=235 and photonY <=275 then
					color <= "111";
				elsif photonX >=275 and photonX<=285 and
				photonY >=270 and photonY <=280 then
					color <= "111";
				elsif photonX >=305 and photonX<=315 and
				photonY >=270 and photonY <=280 then
					color <= "111";	
				elsif photonX >=280 and photonX<=290 and
				photonY >=275 and photonY <=285 then
					color <= "111";
				elsif photonX >=300 and photonX<=310 and
				photonY >=275 and photonY <=285 then
					color <= "111";
				elsif photonX >=300 and photonX<=310 and
				photonY >=275 and photonY <=285 then
					color <= "111";
				elsif photonX >=285 and photonX<=305 and
				photonY >=280 and photonY <=295 then
					color <= "111";
				--E
				elsif photonX >=335 and photonX<=345 and
				photonY >=235 and photonY <=295 then
					color <= "111";
				elsif photonX >=335 and photonX<=365 and
				photonY >=235 and photonY <=250 then
					color <= "111";
				elsif photonX >=335 and photonX<=365 and
				photonY >=260 and photonY <=270 then
					color <= "111";
				elsif photonX >=345 and photonX<=365 and
				photonY >=280 and photonY <=295 then
					color <= "111";	
				--R
				elsif photonX >=380 and photonX<=390 and
				photonY >=235 and photonY <=295 then
					color <= "111";
				elsif photonX >=380 and photonX<=415 and
				photonY >=235 and photonY <=245 then
					color <= "111";
				elsif photonX >=380 and photonX<=415 and
				photonY >=260 and photonY <=275 then
					color <= "111";
				elsif photonX >=410 and photonX<=420 and
				photonY >=240 and photonY <=265 then
					color <= "111";	
				elsif photonX >=410 and photonX<=420 and
				photonY >=270 and photonY <=295 then
					color <= "111";	
				else
				color <="000";
			end if;
		end if;
	end process colorSetter;
		
--gerak kotak
kotakMovement : process(kotakMovementClock,gameOver)
	begin
	if gameOver ='0' then
		if kotakMovementClock'event and kotakMovementClock ='1' and Start='1' then
			if PlayerDown ='1' then
				kotakY <= kotakY-1;
			elsif PlayerUp ='1' then
				kotakY <= kotakY+1;
			else
				kotakY <=kotakY+0;
			end if;
		end if;
	end if;
end process kotakMovement;
-- gerak penghalang
penghalangMovement : process(penghalangMovementClock,stoppenghalang)
	begin 
		if penghalangMovementClock'event and penghalangMovementClock = '1' and stoppenghalang ='0' and Start ='1' then
			if (hard = '0') then
			penghalang1X <=penghalang1X -3;
			penghalang2X <=penghalang2X -3;
			penghalang3X <=penghalang3X -4;
			penghalang4X <=penghalang4X -2;
			penghalang5X <=penghalang5X -1;
			penghalang6X <=penghalang6X -2;
			elsif (hard ='1') then
			penghalang1X <=penghalang1X -5;
			penghalang2X <=penghalang2X -5;
			penghalang3X <=penghalang3X -6;
			penghalang4X <=penghalang4X -3;
			penghalang5X <=penghalang5X -2;
			penghalang6X <=penghalang6X -4;
			end if;
		elsif penghalangMovementClock'event and penghalangMovementClock='1' and stoppenghalang ='0' and Start ='0' then
			penghalang1X <=penghalang1X;
			penghalang2X <=penghalang2X;
			penghalang3X <=penghalang3X;
			penghalang4X <=penghalang4X;
			penghalang5X <=penghalang5X;
			penghalang6X <=penghalang6X;
		end if;
	end process penghalangMovement;
draw : process(photonX,photonY,halfClock)
	begin
		if halfClock'event and halfClock='1' then
			Hsync <=hsyncEnable;
			Vsync <= vsyncEnable;
			
			if (photonX <640 and photonY<480) then
				R <=color(2);
				G <=color(1);
				B <=color(0);
			else
				R <= '0';
				G <= '0';
				B <= '0';
			end if;
		end if;
	end process draw;
	

			

end Behavioral;

