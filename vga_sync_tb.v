/*
    0–639   → VISIBLE
    640–655 → FRONT
    656–751 → SYNC
    752–799 → BACK
    
    ### Testbach Completa:

    - Teste_vesa_clock  [OK]
    - Teste_vesa_Hsynk  [OK]
    - Teste_vesa_Vsynk  [OK]
    - Teste_H_VISIBLE   [OK]
    - Teste_HFRONT      [OK]

    ### Tasks a se fazer:
    - Teste_H_SYNC      [OK]
    - Teste_H_BACK
    - Teste_H_TOTAL
    - Teste_V_VISIBLE
    - Teste_V_FRONT
    - Teste_V_SYNC
    - Teste_V_BACK
    - Teste_V_TOTAL
*/

`timescale 1ps/1ps
`include "vga_sync.v"

module vga_sync_tb();
    
    reg clk = 0;
    reg rst = 1;
    wire hSync, vSync, display;
    wire [9:0] pixel_x;
    wire [9:0] pixel_y;

    localparam clock_esperado = 25.175;
   
    vga_sync uut (
        .clk(clk), .rst(rst),
        .hsync(hSync), .vsync(vSync),
        .display(display), 
        .pixel_x(pixel_x), .pixel_y(pixel_y)
    );

    // 25.175 MHz
    always #19860 clk = ~clk;

    // função que calcula o valor absoluto
    function real abs_real(input real val);
        begin
            abs_real = (val < 0.0) ? -val : val;
        end
    endfunction

    // função que calcula o perido
    function real tempo_esperado;
        input real freq_mhz;
        input integer ciclos;
        real periodo;
    begin
        periodo = 1_000.0 / freq_mhz; // MHz → ns
        tempo_esperado = ciclos * periodo;
    end
    endfunction

    // Inicio da Task check_vesa_clock
    task Teste_vesa_clock;
        real periodo, frequencia, erro;   
        time t1, t2;                                
    begin
        $display("\n==== Teste CLOCK VESA ====");

        @(posedge clk); t1 = $time; // tempo de uma primeira borda de subida do clock
        @(posedge clk); t2 = $time; // tempo da próxima borda de subida do clock
        periodo = t2 - t1;             
        frequencia = 1_000_000.0 / periodo; //caculo da frequencia
        erro = ((frequencia- 25.175) / 25.175) * 100.0; // margem de erro

        $display("Pixel clock: %f MHz | Erro: %0.3f%% | %s", 
            frequencia, abs_real(erro), (abs_real(erro) <= 0.5) ? "[OK]" : "[FORA]");
    end
    endtask

   //teste Hsynk
    task Teste_vesa_Hsynk;
        real erro, hsync;   
        time t1, t2;                                
    begin
        $display("\n==== Tempo Hsynk VESA ====");

        @(negedge hSync); t1 = $time; // tempo decida hsynk
        @(posedge hSync); t2 = $time; // tempo subida hsink
        hsync = t2 - t1;            
        hsync = hsync/1000;
        erro = ((hsync - 3813.12) /  3813.12) * 100.0; // erro

        $display("Tempo Hsynk: %f ns | Erro: %0.3f%% | %s", 
            hsync, abs_real(erro), (abs_real(erro) <= 0.5) ? "[OK]" : "[FORA]");
    end
    endtask
    
    //teste Hsynk
    task Teste_vesa_Vsynk;
        real erro, vsync;   
        time t1, t2;  
    
     begin                             
        $display("\n==== Tempo Vsynk VESA ====");

        @(negedge vSync); t1 = $time; // tempo decida vsynk
        @(posedge vSync); t2 = $time; // tempo subida vsynk
        vsync = t2 - t1;             
        vsync = vsync/1000;
        erro = ((vsync - 63552) /  63552) * 100.0; // margem de erro

        $display("Tempo Vsynk: %f ns | Erro: %0.3f%% | %s", 
            vsync, abs_real(erro), (abs_real(erro) <= 0.5) ? "[OK]" : "[FORA]");
    end
    endtask

    // VCD - Nescessário no IcarusVerilog
    initial begin
        $dumpfile("vga_sync_tb.vcd"); // gera o arquivo VCD para Simulação
        $dumpvars(0, vga_sync_tb);    // Aponta o incio das variáveis
    end

    // Inicialização do Sistema
    task init_system;
    begin
         rst = 1;
         #1000;
         rst = 0;
         repeat(1000) @(posedge clk);
    end
    endtask

    task Teste_H_VISIBLE;
        time t1, t2;
        real tempo, erro;
        real esperado;
    begin
        $display("\n==== Tempo H_VISIBLE VESA ====");
        esperado = tempo_esperado(25.175, uut.H_VISIBLE);

        // Espera início da linha visível
        wait (uut.h_count == 0); 
        @(posedge clk);
        t1 = $time;

        // Espera fim da área visível
        wait (uut.h_count == uut.H_VISIBLE); // H_VISIBLE = 640
        @(posedge clk);
        t2 = $time;

        tempo = (t2 - t1) / 1000.0;
        erro = ((tempo - esperado) / esperado) * 100.0;
        $display("Tempo H_VISIBLE: %f ns | Erro: %0.3f%% | %s",tempo,abs_real(erro),(abs_real(erro) <= 0.5) ? "[OK]" : "[FORA]");
    end
    endtask

    task Teste_HFRONT;
        time t1, t2;
        real tempo, erro;
        real periodo_clock;
        real esperado;
    begin
        $display("\n==== Tempo H_FRONT VESA ====");

        // calculo de tempo peciso
        esperado = tempo_esperado(25.175, uut.H_FRONT);

        // Espera início do H_FRONT
        wait (uut.h_count == uut.H_VISIBLE); // 640
        @(posedge clk);
        t1 = $time;

        // Espera fim do H_FRONT
        wait (uut.h_count == (uut.H_VISIBLE + uut.H_FRONT)); // 640 + 16
        @(posedge clk);
        t2 = $time;

        tempo = (t2 - t1) / 1_000.0; // ps -> ns
        erro = ((tempo - esperado) / esperado) * 100.0;

        $display("Tempo H_FRONT: %f ns | Erro: %0.3f%% | %s",
            tempo, abs_real(erro),
            (abs_real(erro) <= 0.5) ? "[OK]" : "[FORA]");
    end
    endtask

    task Teste_H_SYNC;
        time t1, t2;
        real tempo, erro;
        real periodo_clock;
        real esperado;
    begin
        $display("\n==== Tempo H_SYNC VESA ====");

        // calculo de tempo peciso
        esperado = tempo_esperado(25.175, uut.H_SYNC);

        // Espera início do H_SYNC
        wait (uut.h_count == uut.H_VISIBLE + uut.H_FRONT); // 656
        @(posedge clk);
        t1 = $time;

        // Espera fim do H_SYNC
        wait (uut.h_count == (uut.H_VISIBLE + uut.H_FRONT + uut.H_SYNC)); // 656 + 96
        @(posedge clk);
        t2 = $time;

        tempo = (t2 - t1) / 1_000.0; // ps -> ns
        erro = ((tempo - esperado) / esperado) * 100.0;

        $display("Tempo H_SYNC: %f ns | Erro: %0.3f%% | %s",
            tempo, abs_real(erro),
            (abs_real(erro) <= 0.5) ? "[OK]" : "[FORA]");
    end
    endtask
 
    initial begin
        init_system();
        Teste_vesa_clock();
        Teste_vesa_Hsynk();
        Teste_vesa_Vsynk();
        Teste_HFRONT();
        Teste_H_VISIBLE();
        Teste_H_SYNC();
        #800000;
        $finish;
    end
endmodule