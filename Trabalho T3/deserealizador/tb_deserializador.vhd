library ieee;
use ieee.std_logic_1164.all;

entity tb_deserializador is
end tb_deserializador;

architecture testbench of tb_deserializador is
    component deserializador
        Port (
            data_in     : in  std_logic;
            write_in    : in  std_logic;
            ack_in      : in  std_logic;
            reset       : in  std_logic;
            clock       : in  std_logic;
            data_out    : out std_logic_vector(7 downto 0);
            data_ready  : out std_logic;
            status_out  : out std_logic
        );
    end component;
    
    -- Sinais de estímulo
    signal clock      : std_logic := '0';
    signal reset      : std_logic := '0';
    signal data_in    : std_logic := '0';
    signal write_in   : std_logic := '0';
    signal ack_in     : std_logic := '0';
    
    -- Sinais de saída
    signal data_out   : std_logic_vector(7 downto 0);
    signal data_ready : std_logic;
    signal status_out : std_logic;
    
    -- Constante para período do clock (100KHz = 10us)
    constant CLK_PERIOD : time := 10 us;
begin
    -- Instância do deserializador
    uut: deserializador
        port map (
            data_in     => data_in,
            write_in    => write_in,
            ack_in      => ack_in,
            reset       => reset,
            clock       => clock,
            data_out    => data_out,
            data_ready  => data_ready,
            status_out  => status_out
        );
    
    -- Geração de clock (100KHz)
    clock_process: process
    begin
        clock <= '0';
        wait for CLK_PERIOD/2;
        clock <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    -- Processo de estímulo
    stim_process: process
    begin
        -- Reset inicial
        reset <= '1';
        wait for 20 us;
        reset <= '0';
        wait for CLK_PERIOD;
        
        -- Envio do byte 10101010 (AA hex)
        write_in <= '1';
        data_in <= '1'; wait for CLK_PERIOD;  -- Bit 7 (MSB)
        data_in <= '0'; wait for CLK_PERIOD;
        data_in <= '1'; wait for CLK_PERIOD;
        data_in <= '0'; wait for CLK_PERIOD;
        data_in <= '1'; wait for CLK_PERIOD;
        data_in <= '0'; wait for CLK_PERIOD;
        data_in <= '1'; wait for CLK_PERIOD;
        data_in <= '0'; wait for CLK_PERIOD;  -- Bit 0 (LSB)
        write_in <= '0';
        
        -- Aguarda confirmação
        wait for 50 us;
        ack_in <= '1';
        wait for CLK_PERIOD;
        ack_in <= '0';
        
        -- Envio de segundo byte 11001100 (CC hex)
        wait for 20 us;
        write_in <= '1';
        data_in <= '1'; wait for CLK_PERIOD;  -- Bit 7
        data_in <= '1'; wait for CLK_PERIOD;
        data_in <= '0'; wait for CLK_PERIOD;
        data_in <= '0'; wait for CLK_PERIOD;
        data_in <= '1'; wait for CLK_PERIOD;
        data_in <= '1'; wait for CLK_PERIOD;
        data_in <= '0'; wait for CLK_PERIOD;
        data_in <= '0'; wait for CLK_PERIOD;  -- Bit 0
        write_in <= '0';
        
        -- Simula atraso na confirmação
        wait for 100 us;
        ack_in <= '1';
        wait for CLK_PERIOD;
        ack_in <= '0';
        
        wait;
    end process;
end testbench;
