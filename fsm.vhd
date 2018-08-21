library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;


--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;

ENTITY power_controller IS
   PORT (
--Ports of FSM	
			enable_power_gating : IN STD_LOGIC;
         disable_power_gating: IN STD_LOGIC;
			clk: IN STD_LOGIC;
         rst_n: IN STD_LOGIC;
          ---
         clk_out : OUT STD_LOGIC;
         n_isolate: OUT STD_LOGIC;
         save_out: OUT STD_LOGIC;
         n_reset: OUT STD_LOGIC;
         n_pwron: OUT STD_LOGIC;
		 restore_out: OUT STD_LOGIC;

--Ports of save_delay register
			d_save   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			ld_save  : IN STD_LOGIC; -- load/enable.
			clr_save : IN STD_LOGIC; -- async. clear.
			clk_save : IN STD_LOGIC; -- clockUSE
			q_save   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- output

--Ports of load_delay register			 
			d_load   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			ld_load  : IN STD_LOGIC; -- load/enable.
			clr_load : IN STD_LOGIC; -- async. clear.
			clk_load : IN STD_LOGIC; -- clockUSE
			q_load   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- output
			);
						 
END;


ARCHITECTURE behavior OF power_controller IS 
  
  TYPE state_t IS (IDLE, OFF_CLOCK, ISOLATE, SAVE, RESET, POWER_ON, RESTORE);
  SIGNAL current_state: state_t;
  SIGNAL next_state: state_t;
  --
  signal dsave_reg : std_logic_vector(d_save'range);
  TYPE temp_s IS (A, B);
  signal temp_save : temp_s;
  signal dload_reg : std_logic_vector(d_save'range);
  signal temp_load : temp_s;
  
  --signal clk_temp: std_logic:='0';
  --Tin hieu bo dem
  signal save_count : natural range 0 to 31;
  signal load_count : natural range 0 to 31;
BEGIN
     ---
     clk_out <= clk when (current_state = IDLE and disable_power_gating = '1') else '0';
     
     ---
     POWER_OFF: PROCESS(clk, rst_n)
     BEGIN -- PROCESS POWER_ON
     IF rst_n = '0' THEN 
        current_state <= IDLE;
     ELSIF clk'EVENT AND clk = '1' THEN 
        current_state <= next_state;
     END IF;     
     END PROCESS POWER_OFF;

     ---
     NEXTSTATE: PROCESS(enable_power_gating, disable_power_gating, current_state)
     BEGIN -- PROCESS FSM
       
       CASE current_state IS

           WHEN IDLE =>
              IF enable_power_gating = '1' AND disable_power_gating = '0' THEN -- POWER OFF
                 next_state <= OFF_CLOCK;
                 --n_isolate <= '0';
                 --n_reset <= '0';
                 --n_pwron <= '0';
					  --restore_out <= '0';
              ELSIF disable_power_gating = '1' AND enable_power_gating = '0' THEN -- POWER ON
                 next_state <= IDLE;
					  n_isolate <= '1';
                 n_reset <= '1';
                 n_pwron <= '1';
                 save_out <= '0';
                 restore_out <= '0';
              END IF;

           WHEN OFF_CLOCK =>
              IF enable_power_gating = '1' AND disable_power_gating = '0' THEN -- POWER OFF
                next_state <= ISOLATE;
                n_isolate <= '0';
              ELSIF disable_power_gating = '1' AND enable_power_gating = '0' THEN -- POWER ON
                next_state <= IDLE;
                n_isolate <= '1';	
                --clk_temp <= clk;
              END IF;

           WHEN ISOLATE =>
              IF enable_power_gating = '1' AND disable_power_gating = '0' THEN -- POWER OFF
                next_state <= SAVE;
                save_out <= '1';
              ELSIF disable_power_gating = '1' AND enable_power_gating = '0' THEN -- POWER ON
                next_state <= OFF_CLOCK;
                --n_isolate <= '1';
                restore_out <= '0';
              END IF;
				  
			  
           WHEN SAVE =>
			  
				--Load to save_delay register
					q_save <= dsave_reg;
				process(clk_save, clr_save)
					begin
						if clr_save = '1' then
							dsave_reg <= (dsave_reg'range => '0');
						elsif rising_edge(clk_save) then
							if ld_save = '1' then
								dsave_reg <= d_save;
							end if;
						end if;
				end process;
				
				--Start counter
					if save_count = q_save - 1 then
						temp_save <= A;
					else
						save_count <= save_count +1;
					end if;
					
               save_out <= '0';
               IF enable_power_gating = '1' AND disable_power_gating = '0' AND temp_save = A THEN -- POWER OFF
                next_state <= RESET;
                --n_reset <= '0';
                save_out <= '0';
              ELSIF disable_power_gating = '1' AND enable_power_gating = '0' AND temp_save = A THEN -- POWER ON
                next_state <= IDLE;
                save_out <= '0';
              END IF;
 
           WHEN RESET =>
              IF enable_power_gating = '1' AND disable_power_gating = '0' THEN -- POWER OFF
                next_state <= POWER_ON; 
                n_reset <= '0';
                --n_pwron <= '0';
              ELSIF disable_power_gating = '1' AND enable_power_gating = '0' THEN -- POWER ON
                next_state <= RESTORE; 
                n_reset <= '1';	
              END IF;
			  
				  
           WHEN RESTORE =>
			  --Load to restore_delay register
					q_load <= dload_reg;
				process(clk_load, clr_load)
					begin
						if clr_load = '1' then
							dload_reg <= (dload_reg'range => '0');
						elsif rising_edge(clk_load) then
							if ld_load = '1' then
								dload_reg <= d_load;
							end if;
						end if;
				end process;
				
				--Start counter
					if load_count = q_load -1 then
						temp_load <= A;
					else
						load_count <= load_count +1;
					end if;
              IF enable_power_gating = '1' AND disable_power_gating = '0' AND temp_load = A THEN -- POWER OFF
                 next_state <= IDLE;
              ELSIF disable_power_gating = '1' AND enable_power_gating = '0' AND temp_load = A THEN -- POWER ON
                 next_state <= ISOLATE;
                 restore_out <= '1';
              END IF;

           WHEN POWER_ON =>
              IF enable_power_gating = '1' AND disable_power_gating = '0' THEN -- POWER OFF
                n_pwron <= '0';
                next_state <= POWER_ON;
              ELSIF disable_power_gating = '1' AND enable_power_gating = '0' THEN -- POWER ON
                next_state <= RESET;
                n_pwron <= '1'; 
              END IF;
           
           WHEN OTHERS => NULL;

        END CASE;

      END PROCESS;
END ARCHITECTURE;