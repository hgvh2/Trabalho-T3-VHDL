--======================================================================
-- Arquivo: deserializador.vhd
-- Autor: Aluno Henzo G. de Vasconcellos
-- E-mail: henzo.gradaschi@edu.pucrs
-- Projeto: Deserializador
-- Data de criação: 28/05/2025
-- Última atualização: 04/06/2025
--=======================================================================
--Bibliotecas Padrão
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity deserializador is
    Port (
        -- Entradas
        data_in     : in  std_logic;      -- Bit serial de entrada
        write_in    : in  std_logic;      -- Sinal para escrever bit (Enable)
        ack_in      : in  std_logic;      -- Confirmação de recebimento
        reset       : in  std_logic;      -- Reset 
        clock       : in  std_logic;      -- Clock do sistema (100KHz)
        
        -- Saídas
        data_out    : out std_logic_vector(7 downto 0); -- Byte completo
        data_ready  : out std_logic;      -- Dado pronto para leitura
        status_out  : out std_logic       -- Status (ocupado, livre)
    );
end deserializador;

architecture behavioral of deserializador is
    -- Máquina de Estados
    type estado_t is (RECEBENDO, DADOS_PRONTOS, LIBERANDO);
    signal estado_atual, proximo_estado : estado_t;
    
    -- Registrador de deslocamento para acumular bits
    signal reg_desloc : std_logic_vector(7 downto 0) := (others => '0');
    
    -- Contador de bits recebidos
    signal contador : integer range 0 to 8 := 0;
begin
    -- Processo síncrono: atualização de registradores
    process(clock, reset)
    begin
        if reset = '1' then
            -- Reset: limpa
            estado_atual <= RECEBENDO;
            reg_desloc <= (others => '0');
            contador <= 0;
        elsif rising_edge(clock) then
            estado_atual <= proximo_estado;
            
            -- Lógica de deslocamento e contagem
            if estado_atual = RECEBENDO and write_in = '1' then
                -- Desloca o registrador e insere novo bit no bit menos significativo
                reg_desloc <= data_in & reg_desloc(7 downto 1);
                contador <= contador + 1;
            end if;
            
            -- Reset do contador quando inicia novo ciclo
            if estado_atual = LIBERANDO then
                contador <= 0;
            end if;
        end if;
    end process;
    
    -- Processo combinacional: lógica de transição de estados
    process(estado_atual, contador, ack_in, write_in)
    begin
        -- Valores padrão 
        proximo_estado <= estado_atual;
        data_ready <= '0';
        status_out <= '0';
        
        case estado_atual is
            when RECEBENDO =>
                -- Verifica se recebeu 8 bits
                if contador = 8 then
                    proximo_estado <= DADOS_PRONTOS;
                end if;
                
            when DADOS_PRONTOS =>
                data_ready <= '1';        -- Sinaliza dado pronto
                status_out <= '1';         -- Sinaliza ocupado
                
                -- Aguarda confirmação do receptor
                if ack_in = '1' then
                    proximo_estado <= LIBERANDO;
                end if;
                
            when LIBERANDO =>
                -- Estado temporário para resetar contador
                proximo_estado <= RECEBENDO;
                
        end case;
    end process;
    
    -- Saída contínua do registrador
    data_out <= reg_desloc;
end behavioral;
