# Script completo de simulação

# Cria e mapeia biblioteca de trabalho
vlib work
vmap work work

# Compila os arquivos VHDL
vcom -2008 fila_fifo.vhd
vcom -2008 tb_fila_fifo.vhd

# Inicia simulação
vsim -voptargs=+acc work.tb_fila_fifo

# Adiciona ondas
add wave -divider "Testbench"
add wave -position insertpoint \
sim:/tb_fila_fifo/clock \
sim:/tb_fila_fifo/reset \
sim:/tb_fila_fifo/data_in \
sim:/tb_fila_fifo/enqueue_in \
sim:/tb_fila_fifo/dequeue_in

add wave -divider "FIFO"
add wave -position insertpoint \
sim:/tb_fila_fifo/uut/head_ptr \
sim:/tb_fila_fifo/uut/tail_ptr \
sim:/tb_fila_fifo/uut/count \
sim:/tb_fila_fifo/uut/mem \
sim:/tb_fila_fifo/len_out \
sim:/tb_fila_fifo/data_out

# Configura formato das ondas
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -timelineunits us
wave zoom full

# Executa simulação
run -all
