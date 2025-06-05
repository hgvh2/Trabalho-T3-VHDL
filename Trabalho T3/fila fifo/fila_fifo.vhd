library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fila_fifo is
    Port (
        -- Entradas
        clock       : in  std_logic;                     -- Clock do sistema (10KHz)
        reset       : in  std_logic;                     -- Reset assíncrono
        data_in     : in  std_logic_vector(7 downto 0);  -- Dado de entrada
        enqueue_in  : in  std_logic;                     -- Sinal para adicionar à fila
        dequeue_in  : in  std_logic;                     -- Sinal para remover da fila
        
        -- Saídas
        len_out     : out std_logic_vector(3 downto 0);  -- Número de elementos na fila (0-8)
        data_out    : out std_logic_vector(7 downto 0)   -- Dado removido
    );
end fila_fifo;

architecture behavioral of fila_fifo is
    -- Definição do tipo para a memória da fila
    type fifo_memory is array (0 to 7) of std_logic_vector(7 downto 0);
    
    -- Sinais internos
    signal mem : fifo_memory := (others => (others => '0'));  -- Memória da fila
    signal head_ptr : integer range 0 to 7 := 0;              -- Ponteiro para o início
    signal tail_ptr : integer range 0 to 7 := 0;              -- Ponteiro para o fim
    signal count : integer range 0 to 8 := 0;                 -- Contador de elementos
    
    -- Registrador para armazenar o dado removido
    signal removed_data : std_logic_vector(7 downto 0) := (others => '0');
begin
    -- Processo principal: operações síncronas
    process(clock, reset)
    begin
        -- Reset assíncrono: limpa toda a fila
        if reset = '1' then
            head_ptr <= 0;
            tail_ptr <= 0;
            count <= 0;
            mem <= (others => (others => '0'));
            removed_data <= (others => '0');
            
        elsif rising_edge(clock) then
        
			-- Operações Simultâneas (deq = 1 and enq = 1)
			
			if dequeue_in = '1' and enqueue_in = '1'then
			
				if head_ptr = tail_ptr and count <= 0 then
					
					removed_data <= data_in;
					
				else 
						-- remove elemento do início
						removed_data <= mem(head_ptr);	-- Armazena dado removido
						-- Atualiza head
						if head_ptr = 7 then 
							head_ptr <= 0;
						else
							head_ptr <= head_ptr + 1;
						end if;
						
						if rising_edge(clock) then -- Após um ciclo enqueue
							--Insere elemento no fim da fila
							mem(tail_ptr) <= data_in; 
							-- Atualiza Tail
							if tail_ptr = 7 then
								tail_ptr <= 0;
							else
								tail_ptr <= tail_ptr + 1;
							end if;
						
						end if;	
				end if;
			-- Se a operação NÃO é Simultânea então: código antigo
			
				
					

			else
					
				-- Operação de remoção (dequeue) tem prioridade sobre inserção
				if dequeue_in = '1' and count > 0 then
					-- 1. REMOVE elemento do início da fila
					removed_data <= mem(head_ptr);  -- Armazena dado removido
                
					-- Atualiza ponteiro de cabeça (com wrap-around)
					if head_ptr = 7 then
						head_ptr <= 0;
					else
						head_ptr <= head_ptr + 1;
					end if;
                
					-- Decrementa contador
					count <= count - 1;
				end if;
            
            
				-- Operação de inserção (enqueue)
				if enqueue_in = '1' and count < 8 then
				
					-- 2. ADICIONA elemento no fim da fila
					mem(tail_ptr) <= data_in;
					
					-- Atualiza ponteiro de cauda (com wrap-around)
					if tail_ptr = 7 then
						tail_ptr <= 0;
					else
						tail_ptr <= tail_ptr + 1;
					end if;
                
					-- Incrementa contador
					count <= count + 1;
				end if;
        
			end if;
        end if;
    end process;
    
    -- Saídas contínuas (não registradas)
    len_out <= std_logic_vector(to_unsigned(count, 4));  -- Converte contador para vetor
    data_out <= removed_data;  -- Saída do último dado removido
end behavioral;
