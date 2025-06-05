library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fila_fifo is
end tb_fila_fifo;

architecture testbench of tb_fila_fifo is
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
    
    -- Sinais de estímulo
    signal clock       : std_logic := '0';
    signal reset       : std_logic := '0';
    signal data_in     : std_logic_vector(7 downto 0) := (others => '0');
    signal enqueue_in  : std_logic := '0';
    signal dequeue_in  : std_logic := '0';
    
    -- Sinais de saída
    signal len_out     : std_logic_vector(3 downto 0);
    signal data_out    : std_logic_vector(7 downto 0);
    
    -- Constante para período do clock (10KHz = 100us)
    constant CLK_PERIOD : time := 100 us;
    
    -- Procedimento para enfileirar um valor
    procedure enqueue(
        value : in integer;
        signal data : out std_logic_vector(7 downto 0);
        signal enq : out std_logic
    ) is
    begin
        data <= std_logic_vector(to_unsigned(value, 8));
        enq <= '1';
        wait for CLK_PERIOD;
        enq <= '0';
        wait for CLK_PERIOD;
    end procedure;
    
    -- Procedimento para desenfileirar
    procedure dequeue(
        signal deq : out std_logic
    ) is
    begin
        deq <= '1';
        wait for CLK_PERIOD;
        deq <= '0';
        wait for CLK_PERIOD;
    end procedure;
begin
    -- Instância da FIFO
    uut: fila_fifo
        port map (
            clock => clock,
            reset => reset,
            data_in => data_in,
            enqueue_in => enqueue_in,
            dequeue_in => dequeue_in,
            len_out => len_out,
            data_out => data_out
        );
    
    -- Geração de clock (10KHz)
    clock_process: process
    begin
        clock <= '0';
        wait for CLK_PERIOD/2;
        clock <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    -- Processo de teste
    stim_process: process
    begin
    
    
        -- Reset inicial
        reset <= '1';
        wait for 200 us;
        reset <= '0';
        wait for CLK_PERIOD;
        
        
        -- Teste 00: Enfileirar 8 valores
        report "Teste 00: Enchendo a fila";
        enqueue(0, data_in, enqueue_in);
        enqueue(1, data_in, enqueue_in);
        enqueue(2, data_in, enqueue_in);
        enqueue(3, data_in, enqueue_in);
        enqueue(4, data_in, enqueue_in);
        enqueue(5, data_in, enqueue_in);
        enqueue(6, data_in, enqueue_in);
        enqueue(7, data_in, enqueue_in);
       
        wait for 500 us;
        
        
        -- Teste 01: Overflow
        report "Teste 01: Transbordar a fila, Encher a fila cheia";
        enqueue(9, data_in, enqueue_in);
       
        wait for 500 us;
        
        
        -- Teste 02: Retirar todos os valores
        report "Teste 02: Esvaziando a fila";
        dequeue(dequeue_in);
        dequeue(dequeue_in);
        dequeue(dequeue_in);
        dequeue(dequeue_in);
        dequeue(dequeue_in);
        dequeue(dequeue_in);
        dequeue(dequeue_in);
        dequeue(dequeue_in);
        
        wait for 500 us;
        
        
        -- Teste 03: Underflow
        report "Teste 03: Esvaziar a fila vazia";
        dequeue(dequeue_in);
        
        wait for 500 us;
        
        -- Teste 04: Operações Simultâneas
        report "Teste 04: Inserção e depois Remoção";
        enqueue(04, data_in, enqueue_in);
        dequeue(dequeue_in);
        
        wait for 500 us;
        
        -- Teste 05: Operações Simultâneas
        report"Teste 05: Remoção e depois Inserção";
        dequeue(dequeue_in);
        enqueue(05, data_in, enqueue_in);
        dequeue(dequeue_in);
        
        wait for 500 us;
        
        -- Teste 06: Operações Simlutâneas
        report"Teste 06: Inserção e Remoção em fila cheia"; 
        enqueue(0, data_in, enqueue_in);
        enqueue(1, data_in, enqueue_in);
        enqueue(2, data_in, enqueue_in);
        enqueue(3, data_in, enqueue_in);
        enqueue(4, data_in, enqueue_in);
        enqueue(5, data_in, enqueue_in);
        enqueue(6, data_in, enqueue_in);
        enqueue(7, data_in, enqueue_in);
        
        wait for 200 us;
        
         data_in <= "10101010"; -- 0xAA
        enqueue_in <= '1';
        dequeue_in <= '1';
        wait for CLK_PERIOD;
        enqueue_in <= '0';
        dequeue_in <= '0';
        wait for CLK_PERIOD;
        
        wait for 500 us;
        
        -- Teste 07: Operações Simultâneas
        report"Teste 07: Inserção e remoção com fila parcialmente preenchida";
        dequeue(dequeue_in);
        dequeue(dequeue_in);
        data_in <= "10111011"; -- 0xBB
        enqueue_in <= '1';
        dequeue_in <= '1';
        wait for CLK_PERIOD;
        enqueue_in <= '0';
        dequeue_in <= '0';
        wait for CLK_PERIOD;
        
        wait for 500 us;
        
        
        --Teste 08: Operações Simultâneas
        report"Teste 08: Inserção e Remoção com fila vazia";
        dequeue(dequeue_in);
        dequeue(dequeue_in);
        dequeue(dequeue_in);
        dequeue(dequeue_in);
        dequeue(dequeue_in);
        dequeue(dequeue_in);
        dequeue(dequeue_in);
        dequeue(dequeue_in);
        
        data_in <= "11001100"; -- 0xCC
        enqueue_in <= '1';
        dequeue_in <= '1';
        wait for CLK_PERIOD;
        enqueue_in <= '0';
        dequeue_in <= '0';
        wait for CLK_PERIOD;
        
        wait for 500 us;
        
        
        
        
        
    
        
        -- Teste 1: Enfileirar 3 valores
        report "Teste 1: Enfileirando 3 valores";
        enqueue(10, data_in, enqueue_in);
        enqueue(20, data_in, enqueue_in);
        enqueue(30, data_in, enqueue_in);
        
        -- Teste 2: Desenfileirar 1 valor
        report "Teste 2: Desenfileirando 1 valor";
        dequeue(dequeue_in);
        assert data_out = "00001010" report "Erro no valor desenfileirado" severity error;
        
        -- Teste 3: Enfileirar até encher a fila
        report "Teste 3: Enchendo a fila";
        for i in 4 to 8 loop
            enqueue(i * 10, data_in, enqueue_in);
        end loop;
        
        -- Teste 4: Tentar enfileirar com fila cheia (deve ser ignorado)
        report "Teste 4: Tentativa de overflow";
        enqueue(90, data_in, enqueue_in);
        
        -- Teste 5: Desenfileirar todos os elementos
        report "Teste 5: Esvaziando a fila";
        for i in 1 to 8 loop
            dequeue(dequeue_in);
            wait for CLK_PERIOD;
        end loop;
        
        -- Teste 6: Tentar desenfileirar com fila vazia (deve ser ignorado)
        report "Teste 6: Tentativa de underflow";
        dequeue(dequeue_in);
        
        -- Teste 7: Operações simultâneas
        report "Teste 7: Enfileirar e desenfileirar simultaneamente";
        data_in <= "10101010";
        enqueue_in <= '1';
        dequeue_in <= '1';
        wait for CLK_PERIOD;
        enqueue_in <= '0';
        dequeue_in <= '0';
        wait for CLK_PERIOD;
        
         -- Reset 
        reset <= '1';
        wait for 200 us;
        reset <= '0';
        wait for CLK_PERIOD;
        
        -- Teste 8: encher a fila
        report "Teste 8: Enchendo a fila";
        
        
        
        
        report "Testes concluídos";
        wait;
    end process;
end testbench;
