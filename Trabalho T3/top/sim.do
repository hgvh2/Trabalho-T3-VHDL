# Script de simulação para ModelSim/QuestaSim

# Configuração inicial
quit -sim
vlib work
vmap work work

# Compilar arquivos
vcom -2008 deserializador.vhd
vcom -2008 fila_fifo.vhd
vcom -2008 top_level.vhd
vcom -2008 tb_top_level.vhd

# Iniciar simulação
vsim -voptargs=+acc work.tb_top_level

# Adicionar ondas
add wave -divider "Entradas Globais"
add wave -position insertpoint \
sim:/tb_top_level/clk_1mhz \
sim:/tb_top_level/reset \
sim:/tb_top_level/data_in \
sim:/tb_top_level/write_in \
sim:/tb_top_level/dequeue_in

add wave -divider "Saídas"
add wave -position insertpoint \
sim:/tb_top_level/status_out \
sim:/tb_top_level/len_out

add wave -divider "Deserializador"
add wave -position insertpoint \
sim:/tb_top_level/uut/deser_data_out \
sim:/tb_top_level/uut/deser_data_ready \
sim:/tb_top_level/uut/deser_status_out

add wave -divider "Fila FIFO"
add wave -position insertpoint \
sim:/tb_top_level/uut/fifo_enqueue \
sim:/tb_top_level/uut/len_out \
sim:/tb_top_level/uut/fifo_data_out

add wave -divider "Clocks Gerados"
add wave -position insertpoint \
sim:/tb_top_level/uut/clk_100khz \
sim:/tb_top_level/uut/clk_10khz

# Configurar formato das ondas
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -timelineunits us
wave zoom full

# Executar simulação completa
run -all
