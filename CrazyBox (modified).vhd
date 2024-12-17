library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CrazyBox is
    Port ( R : out  STD_LOGIC;--vgapp
           G : out  STD_LOGIC;--vga
           B : out  STD_LOGIC;--vga
           Hsync : out  STD_LOGIC;--vga
           Vsync : out  STD_LOGIC;--vga
           PlayerDown : in  STD_LOGIC;--push button bawah
           PlayerUp : in  STD_LOGIC;--push button atas
           Start : in  STD_LOGIC;--switch button
           clk : in  STD_LOGIC);--clock bawaan xilink spartan 3e
end CrazyBox;

architecture Behavioral of CrazyBox is

--clock 1/2
signal halfClock: STD_LOGIC;

--ukuran layar
signal horizontalPosition : integer range 0 to 800 :=0;
signal verticalPosition : integer range 0 to 512 :=0;

--enable
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

--counter gerak kotak
signal kotakMovementClockCounter : integer range 0 to 1000000 :=0;
signal kotakMovementClock : STD_LOGIC :='0';
signal upkotak : integer :=250; --gak dipake dimana2 (?)

--counter gerak penghalang
signal penghalangMovementClockCounter : integer range 0 to 1000000 :=0;
signal penghalangMovementClock : STD_LOGIC :='0';

--endgame
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

--konfigurasi display
signalTiming: process(halfClock)
	begin
		if halfClock'event and halfClock ='1' then
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
	--penghalang 1
		if penghalang1X >=110 and penghalang1X <=170 then
			if kotakY >=penghalang1Y-30 and kotakY<=penghalang1Y +30 then
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
			if kotakY >= penghalang3Y - 25 and kotakY <= penghalang3Y + 25 then
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
		if gameOver = '0' then
		--penghalang1
			if photonX >=penghalang1X -40 and photonX <= penghalang1X + 30 and
			photonY >= penghalang1Y - 20 and photonY <= penghalang1Y +20 then
				color <="001";
		--penghalang2
			elsif photonX >= penghalang2X - 30 and photonX <= penghalang2X + 30 and
			photonY >= penghalang2Y - 20 and photonY <= penghalang2Y + 20 then
				color <="001";
		--penghalang3
			elsif photonX >= penghalang3X - 40 and photonX <= penghalang3X + 40 and
			photonY >= penghalang3Y -25 and photonY <= penghalang3y +25 then
				color <="001";
		--penghalang4
			elsif photonX >=  penghalang4X - 30 and photonX <= penghalang4X + 30 and 
			photonY >= penghalang4Y - 20 and photonY <= penghalang4Y + 20 then
				color <= "001";
		--penghalang5
			elsif photonX >=  penghalang5X - 40 and photonX <= penghalang5X + 40 and 
			photonY >= penghalang5Y - 20 and photonY <= penghalang5Y + 20 then
				color <= "001";
		--batasUp
			elsif photonX >= batasUpX - 320 and photonX <= batasUpX +320 and
			photonY <= batasUpY + 20 and photonY >=batasUpY - 10 then
				if photonX >= batasUpX - 320 and photonX <= batasUpX -240 and
				photonY <= batasUpY + 20 and photonY >=batasUpY - 10 then
					color <= "110";
				elsif photonX >= batasUpX - 160 and photonX <= batasUpX -80 and
				photonY <= batasUpY + 20 and photonY >=batasUpY - 10 then
					color <= "110";
				elsif photonX >= batasUpX + 0 and photonX <= batasUpX +80 and
				photonY <= batasUpY + 20 and photonY >=batasUpY - 10 then
					color <= "110";
				elsif photonX >= batasUpX + 160 and photonX <= batasUpX +240 and
				photonY <= batasUpY + 20 and photonY >=batasUpY - 10 then
					color <= "110";
				elsif photonX >= batasUpX - 240 and photonX <= batasUpX -160 and
				photonY <= batasUpY + 20 and photonY >=batasUpY - 10 then
					color <= "000";
				elsif photonX >= batasUpX - 80 and photonX <= batasUpX -0 and
				photonY <= batasUpY + 20 and photonY >=batasUpY - 10 then
					color <= "000";
				elsif photonX >= batasUpX + 80 and photonX <= batasUpX +160 and
				photonY <= batasUpY + 20 and photonY >=batasUpY - 10 then
					color <= "000";
				elsif photonX >= batasUpX + 240 and photonX <= batasUpX +320 and
				photonY <= batasUpY + 20 and photonY >=batasUpY - 10 then
					color <= "000";
				end if;
		--batasDown
			elsif photonX >= batasDownX - 320 and photonX <= batasDownX +320 and
			photonY >= batasDownY - 20 and photonY <=batasDownY + 10 then
				if photonX >= batasDownX - 320 and photonX <= batasDownX -240 and
				photonY >= batasDownY - 20 and photonY <=batasDownY + 10 then
					color <= "110";
				elsif photonX >= batasDownX - 160 and photonX <= batasDownX -80 and
				photonY >= batasDownY - 20 and photonY <=batasDownY + 10 then
					color <= "110";
				elsif photonX >= batasDownX + 0 and photonX <= batasDownX +80 and
				photonY >= batasDownY - 20 and photonY <=batasDownY + 10 then
					color <= "110";
				elsif photonX >= batasDownX + 160 and photonX <= batasDownX +240 and
				photonY >= batasDownY - 20 and photonY <=batasDownY + 10 then
					color <= "110";
				elsif photonX >= batasDownX - 240 and photonX <= batasDownX -160 and
				photonY >= batasDownY - 20 and photonY <=batasDownY + 10 then
					color <= "000";
				elsif photonX >= batasDownX - 80 and photonX <= batasDownX -0 and
				photonY >= batasDownY - 20 and photonY <=batasDownY + 10 then
					color <= "000";
				elsif photonX >= batasDownX + 80 and photonX <= batasDownX +160 and
				photonY >= batasDownY - 20 and photonY <=batasDownY + 10 then
					color <= "000";
				elsif photonX >= batasDownX + 240 and photonX <= batasDownX +320 and
				photonY >= batasDownY - 20 and photonY <=batasDownY + 10 then
					color <= "000";
				end if;
		--kotak
			elsif photonX >= kotakX - 30 and photonX <= kotakX + 30 and                        
			photonY >= kotakY - 20 and photonY <= kotakY + 20 then
				if photonX >= kotakX - 10 and photonX <= kotakX + 10 and
				photonY >= kotakY - 8 and photonY <= kotakY + 8 then
					color <= "011"; -- Cyan for the windshield
				elsif photonX >= kotakX - 25 and photonX <= kotakX + 25 and
				photonY >= kotakY - 15 and photonY <= kotakY + 15 then
					color <= "100"; -- Red for the car body
				elsif (photonX >= kotakX - 25 and photonX <= kotakX - 15) and
				photonY >= kotakY + 15 and photonY <= kotakY + 20 then
					color <= "000"; -- Black for the back-right wheels
				elsif (photonX >= kotakX - 25 and photonX <= kotakX - 15) and
				photonY >= kotakY - 20 and photonY <= kotakY -15 then
					color <= "000"; -- Black for the back-left wheels
				elsif (photonX >= kotakX + 15 and photonX <= kotakX + 25) and
				photonY >= kotakY + 15 and photonY <= kotakY + 20 then
					color <= "000"; -- Black for the front-right wheels
				elsif (photonX >= kotakX + 15 and photonX <= kotakX + 25) and
				photonY >= kotakY - 20 and photonY <= kotakY -15 then
					color <= "000"; -- Black for the front-left wheels
			--background kotak
				else 
					color <= "111";
				end if;
		--background
			else 
				color <= "111";
			end if;
			
			--game over
			else
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

				--background game over	
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
			penghalang1X <=penghalang1X -2;
			penghalang2X <=penghalang2X -3;
			penghalang3X <=penghalang3X -2;
			penghalang4X <=penghalang4X -1;
			penghalang5X <=penghalang5X -1;
		end if;
	end process penghalangMovement;

-- draw/display/main
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