--==========================================================
-- Arquivo: tb_top_level.vhd
-- Autor: Aluno Henzo G. de Vasconcellos
-- E-mail: henzo.gradaschi@edu.pucrs
-- Projeto: tb top(Testes e Estímulos)
-- Data de criação: 28/05/2025
-- Última atualização: 04/06/2025
--===========================================================
-- Bibliotecas padrão
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_top_level is
end tb_top_level;

architecture behavior of tb_top_level is
    component top_level
        Port (
            clk_1mhz   : in  std_logic;
            reset      : in  std_logic;
            data_in    : in  std_logic;
            write_in   : in  std_logic;
            dequeue_in : in  std_logic;
            status_out : out std_logic;
            len_out    : out std_logic_vector(3 downto 0)
        );
    end component;
    
    -- Sinais de entrada
    signal clk_1mhz   : std_logic := '0';
    signal reset      : std_logic := '0';
    signal data_in    : std_logic := '0';
    signal write_in   : std_logic := '0';
    signal dequeue_in : std_logic := '0';
    
    -- Sinais de saída
    signal status_out : std_logic;
    signal len_out    : std_logic_vector(3 downto 0);
    
    -- Constantes de clock
    constant CLK_1MHZ_PERIOD : time := 1 us;  -- Período de 1 us (1 MHz)
    
    -- Procedimento para enviar um byte (8 bits) para o deserializador
    procedure send_byte(signal data: out std_logic; signal write: out std_logic; byte: in std_logic_vector(7 downto 0)) is
    begin
        -- Envia do bit mais significativo para o menos significativo
        for i in 7 downto 0 loop
            data <= byte(i);
            write <= '1';
            wait for CLK_1MHZ_PERIOD * 10;  -- Espera 10 ciclos de 1MHz (equivalente a 1 ciclo de 100KHz)
            write <= '0';
            wait for CLK_1MHZ_PERIOD * 10;  -- Espera entre bits
        end loop;
    end procedure;

begin
    uut: top_level
        port map (
            clk_1mhz   => clk_1mhz,
            reset      => reset,
            data_in    => data_in,
            write_in   => write_in,
            dequeue_in => dequeue_in,
            status_out => status_out,
            len_out    => len_out
        );
    
    -- Geração do clock de 1MHz
    clk_1mhz_process: process
    begin
        clk_1mhz <= '0';
        wait for CLK_1MHZ_PERIOD/2;
        clk_1mhz <= '1';
        wait for CLK_1MHZ_PERIOD/2;
    end process;
    --=============================================
    -- Processo de estímulo
    --=============================================
    stim_proc: process
    begin
        -- Reset inicial
        reset <= '1';
        wait for 100 us;
        reset <= '0';
        wait for 100 us;
        
        -- =====================================================
        -- CASO RUIM: Travamento quando fila cheia
        -- =====================================================
        report "Caso ruim: Enchendo a fila sem remover";
        
        -- Envia 8 bytes para encher a fila
        for i in 0 to 7 loop
            send_byte(data_in, write_in, std_logic_vector(to_unsigned(i+65, 8)));  -- Envia letras 'A' a 'H'
            wait for 100 us;  -- Espera entre bytes
        end loop;
        
        -- Tenta enviar um 9º byte (deve causar travamento)
        send_byte(data_in, write_in, X"49");  -- 'I'
        
        -- Verifica se o status_out indica ocupado (travado)
        wait for 100 us;
        assert status_out = '1' 
            report "ERRO: Deserializador deveria estar travado" 
            severity error;
        
        -- Reset para próximo teste
        reset <= '1';
        wait for 100 us;
        reset <= '0';
        wait for 100 us;
        
        -- =====================================================
        -- CASO BOM: Operação equilibrada sem travamento
        -- =====================================================
        report "Caso bom: Envio e remoção equilibrados";
        
        -- Envia 4 bytes
        for i in 0 to 3 loop
            send_byte(data_in, write_in, std_logic_vector(to_unsigned(i+65, 8))); -- 'A','B','C','D'
            wait for 100 us;
        end loop;
        
        -- Remove 2 bytes
        dequeue_in <= '1';
        wait for 100 us;  -- 1 ciclo de 10KHz (100us) para remover um
        dequeue_in <= '0';
        wait for 100 us;  -- Espera
        
        dequeue_in <= '1';
        wait for 100 us;
        dequeue_in <= '0';
        wait for 100 us;
        
        -- Envia mais 4 bytes
        for i in 4 to 7 loop
            send_byte(data_in, write_in, std_logic_vector(to_unsigned(i+65, 8))); -- 'E','F','G','H'
            wait for 100 us;
        end loop;
        
        -- Remove os restantes
        for i in 0 to 5 loop  -- 6 itens restantes
            dequeue_in <= '1';
            wait for 100 us;
            dequeue_in <= '0';
            wait for 100 us;
        end loop;
        
        -- Verifica que o sistema não travou
        assert status_out = '0' 
            report "ERRO: Deserializador travado no caso bom" 
            severity error;
        
        report "Testes concluídos com sucesso!";
        wait;
    end process;
end behavior;
