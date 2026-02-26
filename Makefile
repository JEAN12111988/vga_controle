# Nome base dos arquivos (sem extensão)

### Regra para funcionar o Makefile ###
# O $dumpfile("mux_2x1_tb.vcd"); tem que ter o mesmo nome do arquivo de testbanch
# Alem do dumpfile, não pode esquecer o $dumpvars(0, mux_2x1_tb)

MODULE := $(basename $(filter-out %_tb.v, $(wildcard *.v)))
TB := $(basename $(filter %_tb.v, $(wildcard *.v)))

# Compilador e visualizador
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Arquivos de entrada e saída
SRC = $(MODULE).v
TB_SRC = $(TB).v
OUT = $(MODULE).vvp
VCD = $(TB).vcd

# compila o módulo
compila_m:
	$(IVERILOG) $(SRC)

# compila a testbanch
compila_tb:
	$(IVERILOG) $(TB_SRC)

# Compila
compila:
	$(IVERILOG) -o $(OUT) $(TB_SRC)

# Executa a simulação (gera .vcd)
vcd:
	$(VVP) $(OUT)

# GTK Wave
wave:
	$(GTKWAVE) $(VCD)

clear:
	rm a.out
	rm $(OUT)
	rm $(VCD)
	clear

clear_win:
	del a.out
	del $(OUT)
	del $(VCD)
	clear

# Alvo padrão: executa tudo
all:
	compila_m
	compila_tb
	compila
	vcd
	wave