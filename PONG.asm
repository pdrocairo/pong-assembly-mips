.data 
   #nomes que serao usados durante o codigo
   .eqv azul 0x539EF0
   .eqv preto 0x00000000
   .eqv branco 0x00FFFFFF 
   .eqv inicio_tela 0x10010000
   .eqv pixels 8192 
   .eqv ultima_linha 0x10017E00


#formula -> Endereco = base + (linha* 128 + coluna) * 4

.text
main:
	li $8, inicio_tela
	li $9, preto
	li $10, 0 #for "(i)"
	li $11, pixels
	
	
for:
	beq $10, $11, dados_horizontal1
	sw $9, 0($8)
	
	addi $8, $8, 4
	addi $10, $10, 1
	
	j for
	
dados_horizontal1:
	li $6, branco
	li $5, 0
	li $15, 108
	li $8, 0x10010028
	addi $8, $8, 4096        
		
for_horizontal1:
	beq $5, $15, dados_horizontal2
	sw $6, 0($8)               
	addi $8, $8, 4            
	addi $5, $5, 1
	
	j for_horizontal1
	
dados_horizontal2:
	li $6, branco
	li $5, 0
	li $15, 108   
	li $8, 0x10016A28   
	
for_horizontal2:
	beq $5, $15, dados_divisao_central
	
	sw $6, 0($8)
	addi $8, $8, 4
	addi $5, $5, 1
	
	j for_horizontal2
# Endereco = base + (linha* 128 + coluna) * 4	
dados_divisao_central:
	li $6, branco
	li $5, 0
	li $15, 22     
	li $8, 0x10010300
	addi $8, $8, 4096

for_centro:
	beq $5, $15, dados_divisao_central2
	sw $6, 0($8)
	
	addi $8, $8, 1024
	addi $5, $5, 1
	j for_centro
	
dados_divisao_central2:
	li $6, branco
	li $5, 0
	li $15, 22     
	li $8, 0x10010304
	addi $8, $8, 4096

for_centro2:
	beq $5, $15, dados_lateral1
	sw $6, 0($8)
	
	addi $8, $8, 1024
	addi $5, $5, 1
	j for_centro2
# Endereco = base + (linha* 128 + coluna) * 4
dados_lateral1:
	li $6, branco
	li $5, 0
	li $15, 44     
	li $8, 0x10011228
for_lateral1:
	beq $5, $15, dados_lateral2
	sw $6, 0($8)
	
	addi $8, $8, 512
	addi $5, $5, 1
	j for_lateral1
# Endereco = base + (linha* 128 + coluna) * 4
dados_lateral2:
	li $6, branco
	li $5, 0
	li $15, 44     
	li $8, 0x100113D4
for_lateral2:
	beq $5, $15, dados_stick
	sw $6, 0($8)
	
	addi $8, $8, 512
	addi $5, $5, 1
	j for_lateral2	

# Endereco = base + (linha* 128 + coluna) * 4
dados_stick:
	li $6, branco
	li $14, 0x10017248
	li $15, 10            
	li $16, 0            

for_sticks:
	beq $16, $15, dados_pes

	li $5, 0             
	move $8, $14        

for_linhas:
	beq $5, 5, proxima_coluna   
	sw $6, 0($8)
	addi $8, $8, 512    
	addi $5, $5, 1
	j for_linhas

proxima_coluna:
	addi $14, $14, 40   
	addi $16, $16, 1
	j for_sticks
	
dados_pes:
	li $14, 0x10017C44 #pe inicial esquerdo
	li $17, 0x10017C4C #pe inicial direito	
	li $6, branco
	li $15, 10            
	li $16, 0

for_pes:
	beq $16, $15, loop_animacao
	sw $6, 0($14)
	sw $6, 0($17)
	
	addi $16, $16, 1
	addi $14, $14, 40
	addi $17, $17, 40
	j for_pes
	
loop_animacao:
	li $6, 0x00FF8DA1
	li $7, preto
	li $15, 10            
	li $16, 0
	li $14, 0x10017844
	li $17, 0x1001764C
	
desenha_braco_esq:
	beq $16, $15, delay1
	sw $6, 0($14)
	sw $6, 0($17)
	addi $16, $16, 1
	addi $14, $14, 40
	addi $17, $17, 40
	j desenha_braco_esq

delay1:
	li $25, 300000
delay1_loop:
	beq $25, $0, apaga_ini1
	addi $25, $25, -1
	j delay1_loop

apaga_ini1:
	li $15, 10            
	li $16, 0
	li $14, 0x10017844
	li $17, 0x1001764C
apaga_braco_esq:
	beq $16, $15, dados_bracos_dir
	sw $7, 0($14)
	sw $7, 0($17)
	addi $16, $16, 1
	addi $14, $14, 40
	addi $17, $17, 40
	j apaga_braco_esq

dados_bracos_dir:
	li $15, 10            
	li $16, 0
	li $14, 0x10017644
	li $17, 0x1001784C
desenha_braco_dir:
	beq $16, $15, delay2
	sw $6, 0($14)
	sw $6, 0($17)
	addi $16, $16, 1
	addi $14, $14, 40
	addi $17, $17, 40
	j desenha_braco_dir

delay2:
	li $25, 300000
delay2_loop:
	beq $25, $0, apaga_ini2
	addi $25, $25, -1
	j delay2_loop

apaga_ini2:
	li $15, 10            
	li $16, 0
	li $14, 0x10017644
	li $17, 0x1001784C
apaga_braco_dir:
	beq $16, $15, loop_animacao
	sw $7, 0($14)
	sw $7, 0($17)
	addi $16, $16, 1
	addi $14, $14, 40
	addi $17, $17, 40
	j apaga_braco_dir

fim:
	j fim
