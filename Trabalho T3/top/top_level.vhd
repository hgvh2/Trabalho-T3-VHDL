--===================================================================
-- Arquivo: top_level.vhd
-- Autor: Aluno Henzo G. de Vasconcellos
-- E-mail: henzo.gradaschi@edu.pucrs
-- Projeto: top (Junção de deserializador e fila)
-- Data de criação: 28/05/2025
-- Última atualização: 04/06/2025
--===================================================================
--Bibliotecas Padrão
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
    Port (
        -- Entradas globais
        clk_1mhz   : in  std_logic;   -- Clock principal de 1 MHz
        reset      : in  std_logic;
        -- Entradas do deserializador
        data_in    : in  std_logic;   -- Bit em série
        write_in   : in  std_logic;   -- Sinal para escrever bit
        -- Entradas da fila (controle)
        dequeue_in : in  std_logic;   -- Sinal para remover da fila
        -- Saídas de status
        status_out : out std_logic;   -- Status do deserializador (ocupado)
        len_out    : out std_logic_vector(3 downto 0) -- Tamanho da fila
    );
end top_level;

architecture structural of top_level is
    -- Componente deserializador
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
    
    -- Componente fila_fifo
    component fila_fifo
        Port (
            clock       : in  std_logic;
            reset       : in  std_logic;
            data_in     : in  std_logic_vector(7 downto 0);
            enqueue_in  : in  std_logic;
            dequeue_in  : in  std_logic;
            len_out     : out std_logic_vector(3 downto 0);
            data_out    : out std_logic_vector(7 downto 0)
        );
    end component;
    
    -- Sinais de clock gerados
    signal clk_100khz : std_logic := '0';
    signal clk_10khz  : std_logic := '0';
    
    -- Contadores para divisão de clock
    signal count_100k : integer range 0 to 4 := 0;   		-- 1MHz/10 = 100kHz (divisão por 10) Gera 5  ciclos + lento
    signal count_10k  : integer range 0 to 49 := 0;  		-- 1MHz/100 = 10kHz (divisão por 100) Gera 50 ciclos + rápido
    
    -- Sinais de conexão entre módulos
    signal deser_data_out  : std_logic_vector(7 downto 0);	-- Deserealizador
    signal deser_data_ready: std_logic;						-- Deserealizador
    signal deser_status_out: std_logic;						-- Deserealizador
    
    signal fifo_enqueue    : std_logic := '0';				-- Fila
    signal fifo_data_out   : std_logic_vector(7 downto 0);	-- Fila
    signal ack_signal      : std_logic := '0';				-- Deserealizador
    
    -- Registro para sincronização
    signal data_ready_sync : std_logic := '0';
    
begin
    -- =====================================================
    -- GERADOR DE CLOCKS
    -- =====================================================
    
    -- Divisor de clock para 100KHz (1MHz/10 = 100KHz)
    process(clk_1mhz, reset)
    begin
		-- Reset Padrão
        if reset = '1' then
            count_100k <= 0;
            clk_100khz <= '0';
        elsif rising_edge(clk_1mhz) then
            if count_100k = 4 then  -- 5 estados (0-4) 
                count_100k <= 0;
                clk_100khz <= not clk_100khz;
            else
                count_100k <= count_100k + 1;
            end if;
        end if;
    end process;
    
    -- Divisor de clock para 10KHz (1MHz/100 = 10KHz)
    process(clk_1mhz, reset)
    begin
        if reset = '1' then
            count_10k <= 0;
            clk_10khz <= '0';
        elsif rising_edge(clk_1mhz) then
            if count_10k = 49 then  -- 50 estados (0-49) 
                count_10k <= 0;
                clk_10khz <= not clk_10khz;
            else
                count_10k <= count_10k + 1;
            end if;
        end if;
    end process;
    
    -- =====================================================
    -- INSTANCIAÇÃO DOS MÓDULOS
    -- =====================================================
    
    -- Deserializador (opera a 100KHz)
    deser: deserializador
        port map (
            data_in     => data_in,
            write_in    => write_in,
            ack_in      => ack_signal,
            reset       => reset,
            clock       => clk_100khz,
            data_out    => deser_data_out,
            data_ready  => deser_data_ready,
            status_out  => deser_status_out
        );
    
    -- Fila FIFO (opera a 10KHz)
    fifo: fila_fifo
        port map (
            clock       => clk_10khz,
            reset       => reset,
            data_in     => deser_data_out,
            enqueue_in  => fifo_enqueue,
            dequeue_in  => dequeue_in,
            len_out     => len_out,
            data_out    => fifo_data_out
        );
    
    -- =====================================================
    -- LÓGICA DE CONTROLE
    -- =====================================================
    
    -- Processo para sincronizar o sinal data_ready de 10KHz
    process(clk_10khz, reset)
    begin
        if reset = '1' then
            data_ready_sync <= '0';
        elsif rising_edge(clk_10khz) then
            data_ready_sync <= deser_data_ready;
        end if;
    end process;
    
    -- Lógica para enfileirar quando um byte está pronto
    -- e gerar ack para o deserializador
    process(clk_10khz, reset)
    begin
        if reset = '1' then
            fifo_enqueue <= '0';
            ack_signal <= '0';
        elsif rising_edge(clk_10khz) then
            -- Reset dos sinais de controle
            fifo_enqueue <= '0';
            ack_signal <= '0';
            
            -- Se um novo byte está pronto e o deserializador não está ocupado
            if data_ready_sync = '1' and deser_status_out = '0' then
                fifo_enqueue	<= '1';   -- Enfileira o byte
                ack_signal		<= '1';     -- Envia acknowledge
            end if;
        end if;
    end process;
    
    -- Saída de status (ocupado quando fila cheia ou deserializador travado)
    status_out <= deser_status_out;

end structural;
