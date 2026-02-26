# 🎯 VGA Sync Controller – 640x480 @ 60Hz (VESA)

Implementação em **Verilog** de um controlador de sincronismo VGA seguindo o padrão **VESA 640x480 @ 60 Hz**.

O projeto gera:

- ✅ HSYNC (ativo em nível baixo)
- ✅ VSYNC (ativo em nível baixo)
- ✅ Sinal de habilitação de vídeo (`display`)
- ✅ Coordenadas do pixel atual (`pixel_x`, `pixel_y`)
- ✅ Testbench com verificação automática de temporização

---

# 📐 Especificações VESA – 640x480 @ 60Hz

| Parâmetro      | Horizontal | Vertical |
|---------------|------------|------------|
| Área visível  | 640 px     | 480 linhas |
| Front Porch   | 16 px      | 10 linhas |
| Sync Pulse    | 96 px      | 2 linhas |
| Back Porch    | 48 px      | 33 linhas |
| Total         | 800 px     | 525 linhas |
| Pixel Clock   | **25.175 MHz** | — |

---

# 🧠 Arquitetura

O módulo `vga_sync` utiliza dois contadores principais:

- `h_count` → conta pixels (0–799)
- `v_count` → conta linhas (0–524)

## Área Visível
assign display = (h_count < H_VISIBLE) &&
                 (v_count < V_VISIBLE);

🔹 Coordenadas do Pixel
assign pixel_x = h_count;
assign pixel_y = v_count;

🔹 Sincronismo Ativo em Nível Baixo
hsync <= 0; // durante H_SYNC
vsync <= 0; // durante V_SYNC

📊 Temporização Horizontal
|<-------- 640 -------->|<-16->|<----96---->|<-48->|
|       VISIBLE         |FRONT |    SYNC    | BACK |
0–639   → VISIBLE
640–655 → FRONT
656–751 → SYNC
752–799 → BACK

📊 Temporização Vertical
|<-------- 480 -------->|<-10->|<-2->|<-33->|
|       VISIBLE         |FRONT |SYNC |BACK  |

🔬 Testbench Automatizado

O testbench realiza verificação automática de:

✔ Pixel Clock
Frequência esperada: 25.175 MHz
Tolerância: ±0.5%

✔ Temporização Horizontal

H_VISIBLE
H_FRONT
H_SYNC
(H_BACK e H_TOTAL podem ser adicionados)

✔ Temporização Vertical
V_SYNC
(V_VISIBLE, V_FRONT, V_BACK e V_TOTAL podem ser adicionados)

Cálculo do erro percentual:
erro = ((medido - esperado) / esperado) * 100.0;

Exemplo de saída:
Tempo H_SYNC: 3813.120 ns | Erro: 0.002% | [OK]

├── vga_sync.v
├── vga_sync_tb.v
├── vga_sync_tb.vcd   (gerado na simulação)
└── README.md

👨‍💻 Autor

Jean de Souza
Engenharia Elétrica / Microeletrônica
FPGA | Sistemas Embarcados | Verilog | VESA Timing
