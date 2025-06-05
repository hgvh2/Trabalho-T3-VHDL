# Cria e mapeia biblioteca de trabalho
vlib work
vmap work work

# Compila os arquivos VHDL
vcom -2008 deserializador.vhd
vcom -2008 tb_deserializador.vhd

# Inicia simulação
vsim -voptargs=+acc work.tb_deserializador

# Adiciona ondas
add wave -divider "Testbench"
add wave -position insertpoint \
sim:/tb_deserializador/clock \
sim:/tb_deserializador/reset \
sim:/tb_deserializador/data_in \
sim:/tb_deserializador/write_in \
sim:/tb_deserializador/ack_in

add wave -divider "Deserializador"
add wave -position insertpoint \
sim:/tb_deserializador/uut/estado_atual \
sim:/tb_deserializador/uut/reg_desloc \
sim:/tb_deserializador/uut/contador \
sim:/tb_deserializador/data_out \
sim:/tb_deserializador/data_ready \
sim:/tb_deserializador/status_out

# Configura formato das ondas
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -timelineunits us
wave zoom full

# Executa simulação
run 300 us
