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

👨‍💻 Autor

Jean de Souza
Engenharia Elétrica / Microeletrônica
FPGA | Sistemas Embarcados | Verilog | VESA Timing
