library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all; 

entity traffic_light is

	port (
		pushbutton : in STD_LOGIC; -- pushbutton
		clk : in STD_LOGIC; -- clock
		rst_n : in STD_LOGIC; -- reset active low
		lampu_jalanraya : out STD_LOGIC_VECTOR(2 downto 0); -- output lampu jalan raya (M, K, H)
		lampu_peternakan : out STD_LOGIC_VECTOR(2 downto 0)-- output lampu peternaka (M, K, H)
	);
	
end traffic_light;

architecture traffic_light of traffic_light is

	signal counter_1s : std_logic_vector(27 downto 0) := x"0000000";
	signal delay_count : std_logic_vector(3 downto 0) := x"0";
	signal delay_merah, delay_kuning_peternakan, delay_kuning_jalanraya, merah_nyala, kuning_jr_nyala, kuning_p_nyala : std_logic := '0';
	signal clk_enable : std_logic; -- mengaktifkan clock
	type FSM_States is (jrhijau_pmerah, jrkuning_pmerah, jrmerah_phijau, jrmerah_pkuning);
	-- jrhijau_pmerah : lampu jalan raya hijau dan lampu peternakan merah
	-- jrkuning_pmerah : lampu jalan raya kuning dan lampu peternakan merah
	-- jrmerah_phijau : lampu jalan raya merah dan lampu peternakan hijau
	-- jrmerah_pkuning : Highway red and farm yellow
	signal current_state, next_state : FSM_States;
	
begin
	-- next state
	process (clk, rst_n)
	
	begin
		if (rst_n = '1') then
			current_state <= jrhijau_pmerah;
		elsif (rising_edge(clk)) then
			current_state <= next_state;
		end if;
	end process;
	
	-- combinational logic
	process (current_state, pushbutton, delay_kuning_peternakan, delay_kuning_jalanraya, delay_merah)
		begin
			case current_state is
				when jrhijau_pmerah => -- kondisi lampu hijau pada jalan raya dan lampu merah di peternakan
					merah_nyala <= '0';-- matikan counting delay merah
					kuning_jr_nyala <= '0';-- matikan counting kuning pada lampu jalan raya
					kuning_p_nyala <= '0';-- matikan counting kuning pada lampu peternakan
					lampu_jalanraya <= "001"; -- lampu hijau jalan raya nyala
					lampu_peternakan <= "100"; -- lampu merah peternakan nyala
					if (pushbutton = '1') then -- kondisi pushbuttons
						next_state <= jrkuning_pmerah;
						-- lampu jalan raya jadi kuning
					else
						next_state <= jrhijau_pmerah;
						-- lampu jalan raya hijau dan lampu peternakan merah
					end if;
					
				when jrkuning_pmerah => -- kondisi lampu kuning pada jalan raya dan lampu merah di peternakan
					lampu_jalanraya <= "010";-- lampu kuning jalan raya 
					lampu_peternakan <= "100";-- lampu merah peternakan
					merah_nyala <= '0';-- matikan counting delay merah 
					kuning_jr_nyala <= '1';-- nyalakan counting delay kuning jalan raya
					kuning_p_nyala <= '0';-- matikan counting delay kuning peternakan
					if (delay_kuning_jalanraya = '1') then
						-- kondisi delay kuning
						-- lampu jalan raya menjadi merah
						-- lampu peternakan menjadi hijau
						next_state <= jrmerah_phijau;
					else
						next_state <= jrkuning_pmerah;
						-- lampu jalan raya kuning dan lampu peternakan merah
					end if;
					
				when jrmerah_phijau => 
					lampu_jalanraya <= "100";-- lampu merah jalan raya
					lampu_peternakan <= "001";-- lampu hijau peternakan
					merah_nyala <= '1';-- nyalakan counting delay merah
					kuning_jr_nyala <= '0';-- matikan counting kuning jalan raya
					kuning_p_nyala <= '0';-- matikan counting kuning peternakan
					
					if (delay_merah = '1') then
						-- kondisi delay merah
						-- jalan raya lampu merah 
						-- peternakan lampu kuning
						next_state <= jrmerah_pkuning;
					else
						next_state <= jrmerah_phijau;
						-- lampu jalan raya merah
					end if;
					
				when jrmerah_pkuning => 
					lampu_jalanraya <= "100";-- lampu merah jalan raya
					lampu_peternakan <= "010";-- lampu kuning peternakan
					merah_nyala <= '0'; -- matikan counting delay merah
					kuning_jr_nyala <= '0';-- matikan couting delay kuning jalan raya
					kuning_p_nyala <= '1';-- nyalakan counting delay peternakan
					
					if (delay_kuning_peternakan = '1') then
						-- kondisi delay kuning
						-- jalan raya hijau
						-- peternakan merah
						next_state <= jrhijau_pmerah;
					else
						next_state <= jrmerah_pkuning;
						-- lampu jalan raya merah
					end if;
				when others => next_state <= jrhijau_pmerah; -- jalan raya hijau, peternakan merah
				
			end case;
		end process;

		process (clk)
			begin
				if (rising_edge(clk)) then
					if (clk_enable = '1') then
						if (merah_nyala = '1' or kuning_jr_nyala = '1' or kuning_p_nyala = '1') then
							delay_count <= delay_count + x"1";
							if ((delay_count = x"9") and merah_nyala = '1') then
								delay_merah <= '1';
								delay_kuning_jalanraya <= '0';
								delay_kuning_peternakan <= '0';
								delay_count <= x"0";
							elsif ((delay_count = x"3") and kuning_jr_nyala = '1') then
								delay_merah <= '0';
								delay_kuning_jalanraya <= '1';
								delay_kuning_peternakan <= '0';
								delay_count <= x"0";
							elsif ((delay_count = x"3") and kuning_p_nyala = '1') then
								delay_merah <= '0';
								delay_kuning_jalanraya <= '0';
								delay_kuning_peternakan <= '1';
								delay_count <= x"0";
							else
								delay_merah <= '0';
								delay_kuning_jalanraya <= '0';
								delay_kuning_peternakan <= '0';
							end if;
						end if;
					end if;
				end if;
			end process;
			
			-- delay
			process (clk)
			
				begin
					if (rising_edge(clk)) then
						counter_1s <= counter_1s + x"0000001";
						if (counter_1s >= x"2FAF080") then -- x"--------" clock agar dapat diliat
							-- desimal ke hexadesimal x"2FAF080" -> 50.000.000 hz
							counter_1s <= x"0000000";
						end if;
					end if;
					
				end process;
				
				clk_enable <= '1' when counter_1s = x"2FAF080" else '0'; -- x"--------" clock agar dapat diliat
				-- desimal ke hexadesimal x"2FAF080" -> 50.000.000 hz
end traffic_light;