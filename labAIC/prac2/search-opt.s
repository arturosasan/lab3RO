        .data
a:      .dword  9,8,0,1,0,5,3,1,2,0
tam:    .dword 10         # Vector size
cont:   .dword 0          # Nr of elements == 0

        .text
start:  addi t0,gp,a      # Pointer
        ld t1,tam(gp)     # Vector size
        add t2,zero,zero  # Counter of zeros
 
loop:   
        ld t3, 0(t0)
        bnez t3,suma
        addi t2, t2, 1
suma:
        addi t1,t1,-1
        addi t0,t0,8
        bnez t1, loop
        sd t2, cont(gp)
        ori x17,x0,10     # Exit system call
        ecall
